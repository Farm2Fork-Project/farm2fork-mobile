// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Product _$ProductFromJson(Map<String, dynamic> json) => _Product(
  id: json['_id'] as String,
  farmerId: json['farmerId'] as String,
  name: json['name'] as String,
  category: $enumDecode(_$ProductCategoryEnumMap, json['category']),
  description: json['description'] as String,
  price: (json['price'] as num).toDouble(),
  quantity: (json['quantity'] as num).toDouble(),
  unit: $enumDecode(_$ProductUnitEnumMap, json['unit']),
  images:
      (json['images'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  qualityGrade:
      $enumDecodeNullable(_$QualityGradeEnumMap, json['qualityGrade']) ??
      QualityGrade.a,
  qrCode: json['qrCode'] as String?,
  initialBlockchainRecordId: json['initialBlockchainRecordId'] as String?,
  status:
      $enumDecodeNullable(_$ProductStatusEnumMap, json['status']) ??
      ProductStatus.active,
  farmer: FarmerSummary.fromJson(json['farmer'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ProductToJson(_Product instance) => <String, dynamic>{
  '_id': instance.id,
  'farmerId': instance.farmerId,
  'name': instance.name,
  'category': _$ProductCategoryEnumMap[instance.category]!,
  'description': instance.description,
  'price': instance.price,
  'quantity': instance.quantity,
  'unit': _$ProductUnitEnumMap[instance.unit]!,
  'images': instance.images,
  'qualityGrade': _$QualityGradeEnumMap[instance.qualityGrade]!,
  'qrCode': instance.qrCode,
  'initialBlockchainRecordId': instance.initialBlockchainRecordId,
  'status': _$ProductStatusEnumMap[instance.status]!,
  'farmer': instance.farmer,
};

const _$ProductCategoryEnumMap = {
  ProductCategory.vegetables: 'vegetables',
  ProductCategory.fruits: 'fruits',
  ProductCategory.grains: 'grains',
  ProductCategory.dairy: 'dairy',
};

const _$ProductUnitEnumMap = {
  ProductUnit.kg: 'kg',
  ProductUnit.ton: 'ton',
  ProductUnit.dozen: 'dozen',
  ProductUnit.piece: 'piece',
  ProductUnit.litre: 'litre',
};

const _$QualityGradeEnumMap = {
  QualityGrade.a: 'A',
  QualityGrade.b: 'B',
  QualityGrade.c: 'C',
};

const _$ProductStatusEnumMap = {
  ProductStatus.active: 'active',
  ProductStatus.inactive: 'inactive',
  ProductStatus.soldOut: 'sold_out',
};
