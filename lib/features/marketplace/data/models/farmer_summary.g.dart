// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'farmer_summary.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_FarmerSummary _$FarmerSummaryFromJson(Map<String, dynamic> json) =>
    _FarmerSummary(
      id: json['id'] as String,
      name: json['name'] as String,
      farmName: json['farmName'] as String,
      farmLocationAddress: json['farmLocationAddress'] as String,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      totalSales: (json['totalSales'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$FarmerSummaryToJson(_FarmerSummary instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'farmName': instance.farmName,
      'farmLocationAddress': instance.farmLocationAddress,
      'rating': instance.rating,
      'totalSales': instance.totalSales,
    };
