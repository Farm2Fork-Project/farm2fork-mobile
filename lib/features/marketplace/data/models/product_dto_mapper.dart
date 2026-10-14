import '../mappers/product_dto_mapper.dart' as shared;
import 'product.dart';

/// Compatibility adapter for existing contract harnesses.
class ProductDtoMapper {
  const ProductDtoMapper();
  Product fromDto(Map<String, dynamic> dto) =>
      shared.ProductDtoMapper.fromDto(dto);
}
