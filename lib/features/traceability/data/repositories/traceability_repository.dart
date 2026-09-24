import 'package:farm2fork_mobile/features/traceability/data/models/product_trace.dart';

abstract class TraceabilityRepository {
  /// The product's public journey, or null when no such product exists.
  Future<ProductTrace?> fetchProductTrace(String productId);
}
