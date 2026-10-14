import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:farm2fork_mobile/core/error/api_exception.dart';
import 'package:farm2fork_mobile/features/listings/data/services/listings_api_service.dart';

void main() {
  test('all listing endpoints unwrap the normalized ownership error', () async {
    final dio = Dio()
      ..interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            handler.reject(
              DioException(
                requestOptions: options,
                error: const ApiException(
                  ApiErrorKind.forbidden,
                  statusCode: 403,
                ),
              ),
            );
          },
        ),
      );
    final service = ListingsApiService(dio);
    final forbidden = throwsA(
      isA<ApiException>().having(
        (error) => error.kind,
        'kind',
        ApiErrorKind.forbidden,
      ),
    );
    await expectLater(service.fetchMine(), forbidden);
    await expectLater(service.create({'name': 'Harvest'}), forbidden);
    await expectLater(
      service.update('product', {'status': 'inactive'}),
      forbidden,
    );
    await expectLater(service.delete('product'), forbidden);
  });
}
