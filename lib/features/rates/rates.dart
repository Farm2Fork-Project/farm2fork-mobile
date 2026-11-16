import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:farm2fork_mobile/core/config/app_config.dart';
import 'package:farm2fork_mobile/core/localization/l10n_extension.dart';
import 'package:farm2fork_mobile/core/network/network_providers.dart';
import 'package:farm2fork_mobile/core/theme/app_colors.dart';
import 'package:farm2fork_mobile/core/theme/app_sizes.dart';
import 'package:farm2fork_mobile/core/theme/app_typography.dart';
import 'package:farm2fork_mobile/core/utils/number_formatters.dart';
import 'package:farm2fork_mobile/core/widgets/app_card.dart';
import 'package:farm2fork_mobile/core/widgets/app_state_placeholder.dart';

class RateEntry {
  const RateEntry({
    required this.commodity,
    required this.unit,
    required this.minPrice,
    required this.maxPrice,
    this.fairPrice,
  });

  final String commodity;
  final String unit;
  final double minPrice;
  final double maxPrice;
  final double? fairPrice;
}

/// One official rate list: a market's prices on one trading day.
class RateList {
  const RateList({
    required this.market,
    required this.tradingDate,
    required this.source,
    required this.entries,
  });

  final String market;
  final DateTime tradingDate;
  final String source;
  final List<RateEntry> entries;

  static RateList fromJson(Map<String, dynamic> json) => RateList(
    market: (json['market'] as String?) ?? '',
    tradingDate:
        DateTime.tryParse(json['tradingDate'] as String? ?? '') ??
        DateTime.now(),
    source: (json['source'] as String?) ?? '',
    entries: [
      for (final row in (json['entries'] as List?) ?? const [])
        if (row is Map && row['commodity'] is String)
          RateEntry(
            commodity: row['commodity'] as String,
            unit: (row['unit'] as String?) ?? '',
            minPrice: (row['minPrice'] as num?)?.toDouble() ?? 0,
            maxPrice: (row['maxPrice'] as num?)?.toDouble() ?? 0,
            fairPrice: (row['fairPrice'] as num?)?.toDouble(),
          ),
    ],
  );
}

abstract class RatesRepository {
  /// Newest published list, or null when the team has not published one.
  Future<RateList?> latest();
}

class ApiRatesRepository implements RatesRepository {
  ApiRatesRepository(this._dio);

  final Dio _dio;

  @override
  Future<RateList?> latest() async {
    final data = (await _dio.get<dynamic>('/rates/latest')).data;
    return data is Map
        ? RateList.fromJson(Map<String, dynamic>.from(data))
        : null;
  }
}

class MockRatesRepository implements RatesRepository {
  @override
  Future<RateList?> latest() async => RateList(
    market: 'Lahore',
    tradingDate: DateTime.now().subtract(const Duration(days: 1)),
    source: 'Market Committee Lahore',
    entries: const [
      RateEntry(
        commodity: 'Wheat',
        unit: '100kg',
        minPrice: 9800,
        maxPrice: 10400,
        fairPrice: 10100,
      ),
      RateEntry(
        commodity: 'Rice Basmati',
        unit: '100kg',
        minPrice: 21000,
        maxPrice: 26500,
        fairPrice: 24000,
      ),
      RateEntry(
        commodity: 'Potato',
        unit: '100kg',
        minPrice: 4500,
        maxPrice: 6200,
      ),
      RateEntry(
        commodity: 'Mango (Chaunsa)',
        unit: '100kg',
        minPrice: 14000,
        maxPrice: 22000,
        fairPrice: 18000,
      ),
    ],
  );
}

final ratesRepositoryProvider = Provider<RatesRepository>((ref) {
  if (AppConfig.useMocks) return MockRatesRepository();
  return ApiRatesRepository(ref.watch(dioProvider));
});

final latestRatesProvider = FutureProvider.autoDispose<RateList?>(
  (ref) => ref.watch(ratesRepositoryProvider).latest(),
);

/// The latest official mandi rate list, searchable by commodity.
class MandiRatesScreen extends ConsumerStatefulWidget {
  const MandiRatesScreen({super.key});

  static const route = '/rates';

  @override
  ConsumerState<MandiRatesScreen> createState() => _MandiRatesScreenState();
}

class _MandiRatesScreenState extends ConsumerState<MandiRatesScreen> {
  String _words = '';

  String _unit(BuildContext context, String unit) {
    final l10n = context.l10n;
    return switch (unit) {
      'kg' => l10n.unitKg,
      'ton' => l10n.unitTon,
      'dozen' => l10n.unitDozen,
      'piece' => l10n.unitPiece,
      'litre' => l10n.unitLitre,
      '40kg' => l10n.unit40Kg,
      '100kg' => l10n.unit100Kg,
      _ => unit,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context);
    final rates = ref.watch(latestRatesProvider);
    String money(double value) =>
        l10n.currencyAmount(formatCurrencyAmount(value, locale));
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(title: Text(l10n.mandiRates, style: AppTextStyles.h3)),
      body: RefreshIndicator(
        color: AppColors.primaryGreen,
        onRefresh: () => ref.refresh(latestRatesProvider.future),
        child: rates.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primaryGreen),
          ),
          error: (_, _) =>
              AppErrorState(onRetry: () => ref.invalidate(latestRatesProvider)),
          data: (list) {
            if (list == null || list.entries.isEmpty) {
              return ListView(
                children: [
                  const SizedBox(height: 96),
                  AppEmptyState(
                    message: l10n.mandiRatesEmpty,
                    icon: Icons.receipt_long_rounded,
                  ),
                ],
              );
            }
            final words = _words.trim().toLowerCase();
            final entries = list.entries
                .where((e) => e.commodity.toLowerCase().contains(words))
                .toList();
            return ListView(
              padding: const EdgeInsets.all(AppSpacing.pagePadding),
              children: [
                Text(list.market, style: AppTextStyles.h2),
                const SizedBox(height: 2),
                Text(
                  l10n.mandiRatesObserved(
                    formatShortDate(list.tradingDate, locale),
                    list.source,
                  ),
                  style: AppTextStyles.small.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  l10n.mandiRatesNote,
                  style: AppTextStyles.small.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                TextField(
                  onChanged: (value) => setState(() => _words = value),
                  decoration: InputDecoration(
                    hintText: l10n.mandiRatesSearch,
                    isDense: true,
                    filled: true,
                    fillColor: AppColors.white,
                    prefixIcon: const Icon(Icons.search_rounded, size: 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                if (entries.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.xxl),
                    child: Text(
                      l10n.mandiRatesNoMatch,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                for (final entry in entries)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Expanded(
                                child: Text(
                                  entry.commodity,
                                  style: AppTextStyles.body.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Text(
                                l10n.mandiRatePer(_unit(context, entry.unit)),
                                style: AppTextStyles.small.copyWith(
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Wrap(
                            spacing: AppSpacing.md,
                            runSpacing: 2,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(
                                '${money(entry.minPrice)} – ${money(entry.maxPrice)}',
                                style: AppTextStyles.body.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primaryGreenDark,
                                ),
                              ),
                              if (entry.fairPrice != null)
                                Text(
                                  l10n.mandiRateFair(money(entry.fairPrice!)),
                                  style: AppTextStyles.small.copyWith(
                                    color: AppColors.textMuted,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
