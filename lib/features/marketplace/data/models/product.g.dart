// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Product _$ProductFromJson(Map<String, dynamic> json) => _Product(
  id: json['id'] as String,
  farmerId: json['farmerId'] as String,
  name: json['name'] as String,
  category: $enumDecode(_$ProductCategoryEnumMap, json['category']),
  description: json['description'] as String,
  pricePerUnit: (json['pricePerUnit'] as num).toDouble(),
  availableQuantity: (json['availableQuantity'] as num).toDouble(),
  unit: json['unit'] as String,
  imageUrls:
      (json['imageUrls'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  qualityGrade:
      $enumDecodeNullable(_$QualityGradeEnumMap, json['qualityGrade']) ??
      QualityGrade.a,
  status:
      $enumDecodeNullable(_$ProductStatusEnumMap, json['status']) ??
      ProductStatus.available,
  farmer: FarmerSummary.fromJson(json['farmer'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ProductToJson(_Product instance) => <String, dynamic>{
  'id': instance.id,
  'farmerId': instance.farmerId,
  'name': instance.name,
  'category': _$ProductCategoryEnumMap[instance.category]!,
  'description': instance.description,
  'pricePerUnit': instance.pricePerUnit,
  'availableQuantity': instance.availableQuantity,
  'unit': instance.unit,
  'imageUrls': instance.imageUrls,
  'qualityGrade': _$QualityGradeEnumMap[instance.qualityGrade]!,
  'status': _$ProductStatusEnumMap[instance.status]!,
  'farmer': instance.farmer,
};

const _$ProductCategoryEnumMap = {
  ProductCategory.vegetables: 'vegetables',
  ProductCategory.fruits: 'fruits',
  ProductCategory.grains: 'grains',
  ProductCategory.dairy: 'dairy',
};

const _$QualityGradeEnumMap = {
  QualityGrade.aPlus: 'aPlus',
  QualityGrade.a: 'a',
  QualityGrade.b: 'b',
  QualityGrade.c: 'c',
};

const _$ProductStatusEnumMap = {
  ProductStatus.available: 'available',
  ProductStatus.outOfStock: 'outOfStock',
  ProductStatus.comingSoon: 'comingSoon',
};
