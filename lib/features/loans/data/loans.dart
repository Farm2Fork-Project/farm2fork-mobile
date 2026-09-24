import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:farm2fork_mobile/core/config/app_config.dart';
import 'package:farm2fork_mobile/core/error/api_exception.dart';
import 'package:farm2fork_mobile/core/network/media_url.dart';
import 'package:farm2fork_mobile/core/network/network_providers.dart';
import 'package:farm2fork_mobile/core/network/upload_file.dart';

enum LoanStatus {
  pending('pending'),
  underReview('under_review'),
  approved('approved'),
  rejected('rejected'),
  repaid('repaid');

  const LoanStatus(this.wire);
  final String wire;

  static LoanStatus fromWire(String? value) => values.firstWhere(
    (s) => s.wire == value,
    orElse: () => LoanStatus.pending,
  );
}

class Instalment {
  const Instalment({
    required this.index,
    required this.dueDate,
    required this.amount,
    required this.isPaid,
    this.paidAt,
  });

  final int index;
  final DateTime dueDate;
  final double amount;
  final bool isPaid;
  final DateTime? paidAt;
}

/// Farm summary shown to financial partners.
class LoanApplicant {
  const LoanApplicant({
    required this.farmName,
    required this.cropTypes,
    required this.deliveredOrders,
    required this.deliveredRevenue,
    this.city,
    this.province,
    this.landSizeAcres,
  });

  final String farmName;
  final String? city;
  final String? province;
  final double? landSizeAcres;
  final List<String> cropTypes;
  final int deliveredOrders;
  final double deliveredRevenue;
}

class LoanApplication {
  const LoanApplication({
    required this.id,
    required this.amount,
    required this.purpose,
    required this.durationMonths,
    required this.status,
    required this.documentCount,
    required this.schedule,
    required this.createdAt,
    this.reviewNote,
    this.applicant,
    this.documentUrls = const [],
  });

  final String id;
  final double amount;
  final String purpose;
  final int durationMonths;
  final LoanStatus status;
  final String? reviewNote;
  final int documentCount;
  final List<Instalment> schedule;
  final DateTime createdAt;
  final LoanApplicant? applicant;

  /// Short-lived links (single-application read only). Never stored.
  final List<String> documentUrls;

  bool get isOpen =>
      status == LoanStatus.pending ||
      status == LoanStatus.underReview ||
      status == LoanStatus.approved;

  double get repaidAmount =>
      schedule.where((i) => i.isPaid).fold(0, (sum, i) => sum + i.amount);

  static LoanApplication fromJson(Map<String, dynamic> json) {
    DateTime date(Object? v) => DateTime.tryParse('$v') ?? DateTime.now();
    double number(Object? v) => (v as num?)?.toDouble() ?? 0;
    final applicant = json['applicant'];
    return LoanApplication(
      id: json['id'] as String,
      amount: number(json['amount']),
      purpose: (json['purpose'] as String?) ?? '',
      durationMonths: (json['durationMonths'] as num?)?.toInt() ?? 0,
      status: LoanStatus.fromWire(json['status'] as String?),
      reviewNote: json['reviewNote'] as String?,
      documentCount: (json['documentCount'] as num?)?.toInt() ?? 0,
      createdAt: date(json['createdAt']),
      schedule: [
        for (final i in (json['repaymentSchedule'] as List?) ?? const [])
          if (i is Map)
            Instalment(
              index: (i['index'] as num).toInt(),
              dueDate: date(i['dueDate']),
              amount: number(i['amount']),
              isPaid: i['isPaid'] == true,
              paidAt: i['paidAt'] == null ? null : date(i['paidAt']),
            ),
      ],
      applicant: applicant is Map
          ? LoanApplicant(
              farmName: (applicant['farmName'] as String?) ?? '',
              city: applicant['city'] as String?,
              province: applicant['province'] as String?,
              landSizeAcres: (applicant['landSizeAcres'] as num?)?.toDouble(),
              cropTypes: [
                for (final c in (applicant['cropTypes'] as List?) ?? const [])
                  if (c is String) c,
              ],
              deliveredOrders:
                  (applicant['deliveredOrders'] as num?)?.toInt() ?? 0,
              deliveredRevenue: number(applicant['deliveredRevenue']),
            )
          : null,
      documentUrls: [
        for (final d in (json['documents'] as List?) ?? const [])
          if (d is Map && d['url'] is String)
            resolveMediaUrl(d['url'] as String),
      ],
    );
  }
}

class LoanLimits {
  const LoanLimits({
    required this.minAmount,
    required this.maxAmount,
    required this.maxDurationMonths,
    required this.maxDocuments,
  });

  final double minAmount;
  final double maxAmount;
  final int maxDurationMonths;
  final int maxDocuments;
}

abstract class LoansRepository {
  Future<LoanLimits> limits();
  Future<List<LoanApplication>> mine();
  Future<LoanApplication> apply({
    required double amount,
    required String purpose,
    required int durationMonths,
    required List<XFile> documents,
  });

  // Financial partner.
  Future<List<LoanApplication>> queue({LoanStatus? status});
  Future<LoanApplication> byId(String id);
  Future<LoanApplication> startReview(String id);
  Future<LoanApplication> decide(
    String id, {
    required bool approve,
    String? note,
  });
  Future<LoanApplication> markInstalmentPaid(String id, int index);
}

class ApiLoansRepository implements LoansRepository {
  ApiLoansRepository(this._dio);

  final Dio _dio;

  @override
  Future<LoanLimits> limits() async {
    final d = await _map(() => _dio.get('/loans/limits'));
    return LoanLimits(
      minAmount: (d['minAmount'] as num).toDouble(),
      maxAmount: (d['maxAmount'] as num).toDouble(),
      maxDurationMonths: (d['maxDurationMonths'] as num).toInt(),
      maxDocuments: (d['maxDocuments'] as num).toInt(),
    );
  }

  @override
  Future<List<LoanApplication>> mine() async =>
      _list((await _dio.get<List<dynamic>>('/loans/mine')).data);

  @override
  Future<LoanApplication> apply({
    required double amount,
    required String purpose,
    required int durationMonths,
    required List<XFile> documents,
  }) async {
    final form = FormData.fromMap({
      'amount': amount.round().toString(),
      'purpose': purpose,
      'durationMonths': '$durationMonths',
    });
    for (final doc in documents) {
      form.files.add(MapEntry('documents', await multipartFromXFile(doc)));
    }
    return LoanApplication.fromJson(
      await _map(() => _dio.post('/loans', data: form)),
    );
  }

  @override
  Future<List<LoanApplication>> queue({LoanStatus? status}) async {
    final d = await _map(
      () => _dio.get(
        '/loans',
        queryParameters: {'status': ?status?.wire, 'limit': 50},
      ),
    );
    return _list(d['data'] as List?);
  }

  @override
  Future<LoanApplication> byId(String id) async =>
      LoanApplication.fromJson(await _map(() => _dio.get('/loans/$id')));

  @override
  Future<LoanApplication> startReview(String id) async =>
      LoanApplication.fromJson(
        await _map(() => _dio.post('/loans/$id/review')),
      );

  @override
  Future<LoanApplication> decide(
    String id, {
    required bool approve,
    String? note,
  }) async => LoanApplication.fromJson(
    await _map(
      () => _dio.post(
        '/loans/$id/decision',
        data: {
          'decision': approve ? 'approved' : 'rejected',
          if (note != null && note.trim().isNotEmpty) 'note': note.trim(),
        },
      ),
    ),
  );

  @override
  Future<LoanApplication> markInstalmentPaid(String id, int index) async =>
      LoanApplication.fromJson(
        await _map(() => _dio.post('/loans/$id/instalments/$index/paid')),
      );

  List<LoanApplication> _list(List<dynamic>? data) {
    if (data == null) throw const ApiException(ApiErrorKind.unknown);
    return data
        .whereType<Map>()
        .map((m) => LoanApplication.fromJson(Map<String, dynamic>.from(m)))
        .toList(growable: false);
  }

  Future<Map<String, dynamic>> _map(
    Future<Response<dynamic>> Function() request,
  ) async {
    final data = (await request()).data;
    if (data is! Map) throw const ApiException(ApiErrorKind.unknown);
    return Map<String, dynamic>.from(data);
  }
}

class MockLoansRepository implements LoansRepository {
  final List<LoanApplication> _loans = [];

  @override
  Future<LoanLimits> limits() async => const LoanLimits(
    minAmount: 10000,
    maxAmount: 1000000,
    maxDurationMonths: 36,
    maxDocuments: 4,
  );

  @override
  Future<List<LoanApplication>> mine() async => List.unmodifiable(_loans);

  @override
  Future<LoanApplication> apply({
    required double amount,
    required String purpose,
    required int durationMonths,
    required List<XFile> documents,
  }) async {
    final loan = LoanApplication(
      id: 'loan_${DateTime.now().microsecondsSinceEpoch}',
      amount: amount,
      purpose: purpose,
      durationMonths: durationMonths,
      status: LoanStatus.pending,
      documentCount: documents.length,
      schedule: const [],
      createdAt: DateTime.now(),
    );
    _loans.insert(0, loan);
    return loan;
  }

  @override
  Future<List<LoanApplication>> queue({LoanStatus? status}) async =>
      _loans.where((l) => status == null || l.status == status).toList();

  @override
  Future<LoanApplication> byId(String id) async =>
      _loans.firstWhere((l) => l.id == id);

  LoanApplication _replace(
    String id,
    LoanStatus status, {
    String? note,
    List<Instalment>? schedule,
  }) {
    final i = _loans.indexWhere((l) => l.id == id);
    final old = _loans[i];
    return _loans[i] = LoanApplication(
      id: old.id,
      amount: old.amount,
      purpose: old.purpose,
      durationMonths: old.durationMonths,
      status: status,
      reviewNote: note ?? old.reviewNote,
      documentCount: old.documentCount,
      schedule: schedule ?? old.schedule,
      createdAt: old.createdAt,
    );
  }

  @override
  Future<LoanApplication> startReview(String id) async =>
      _replace(id, LoanStatus.underReview);

  @override
  Future<LoanApplication> decide(
    String id, {
    required bool approve,
    String? note,
  }) async {
    final loan = await byId(id);
    final monthly = (loan.amount / loan.durationMonths).floorToDouble();
    return _replace(
      id,
      approve ? LoanStatus.approved : LoanStatus.rejected,
      note: note,
      schedule: approve
          ? [
              for (var i = 0; i < loan.durationMonths; i++)
                Instalment(
                  index: i,
                  dueDate: DateTime.now().add(Duration(days: 30 * (i + 1))),
                  amount: i == loan.durationMonths - 1
                      ? loan.amount - monthly * (loan.durationMonths - 1)
                      : monthly,
                  isPaid: false,
                ),
            ]
          : const [],
    );
  }

  @override
  Future<LoanApplication> markInstalmentPaid(String id, int index) async {
    final loan = await byId(id);
    final schedule = [
      for (final i in loan.schedule)
        i.index == index
            ? Instalment(
                index: i.index,
                dueDate: i.dueDate,
                amount: i.amount,
                isPaid: true,
                paidAt: DateTime.now(),
              )
            : i,
    ];
    return _replace(
      id,
      schedule.every((i) => i.isPaid) ? LoanStatus.repaid : loan.status,
      schedule: schedule,
    );
  }
}

final loansRepositoryProvider = Provider<LoansRepository>((ref) {
  if (AppConfig.useMocks) return MockLoansRepository();
  return ApiLoansRepository(ref.watch(dioProvider));
});

final loanLimitsProvider = FutureProvider.autoDispose<LoanLimits>(
  (ref) => ref.watch(loansRepositoryProvider).limits(),
);

final myLoansProvider = FutureProvider.autoDispose<List<LoanApplication>>(
  (ref) => ref.watch(loansRepositoryProvider).mine(),
);

class LoanQueueFilter extends Notifier<LoanStatus?> {
  @override
  LoanStatus? build() => LoanStatus.pending;

  void select(LoanStatus? status) => state = status;
}

final loanQueueFilterProvider = NotifierProvider<LoanQueueFilter, LoanStatus?>(
  LoanQueueFilter.new,
);

final loanQueueProvider = FutureProvider.autoDispose<List<LoanApplication>>(
  (ref) => ref
      .watch(loansRepositoryProvider)
      .queue(status: ref.watch(loanQueueFilterProvider)),
);

final loanDetailProvider = FutureProvider.autoDispose
    .family<LoanApplication, String>(
      (ref, id) => ref.watch(loansRepositoryProvider).byId(id),
    );
