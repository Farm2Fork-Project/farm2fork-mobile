import 'package:farm2fork_mobile/features/marketplace/data/mappers/product_dto_mapper.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> _dto({Object? farmer, String? ledger}) => {
  'id': '6a2fe77bb77795516febc287',
  'farmerId': '6a2fe77bb77795516febc111',
  'name': 'Chaunsa Mangoes',
  'category': 'fruits',
  'price': 320,
  'quantity': 400,
  'unit': 'kg',
  'images': <String>[],
  'qualityGrade': 'A',
  'status': 'active',
  'farmer': farmer,
  'originLedgerStatus': ledger,
};

void main() {
  test('maps the embedded public farm identity and ledger state', () {
    final product = ProductDtoMapper.fromDto(
      _dto(
        farmer: {
          'farmName': 'Green Valley Farm',
          'city': 'Multan',
          'province': 'Punjab',
        },
        ledger: 'confirmed',
      ),
    );

    expect(product.farmer.farmName, 'Green Valley Farm');
    expect(product.farmer.farmLocationAddress, 'Multan, Punjab');
    // No personal name, rating or sales are invented.
    expect(product.farmer.name, isEmpty);
    expect(product.farmer.rating, 0);
    expect(product.farmer.totalSales, 0);
    expect(product.originLedgerStatus, 'confirmed');
  });

  test('keeps an absent farm identity empty', () {
    final product = ProductDtoMapper.fromDto(_dto());
    expect(product.farmer.farmName, isEmpty);
    expect(product.farmer.farmLocationAddress, isEmpty);
    expect(product.originLedgerStatus, isNull);
  });
}
