import 'package:freezed_annotation/freezed_annotation.dart';

part 'farmer_summary.freezed.dart';
part 'farmer_summary.g.dart';

@freezed
abstract class FarmerSummary with _$FarmerSummary {
  const factory FarmerSummary({
    required String id,
    required String name,
    required String farmName,
    required String farmLocationAddress,
    @Default(0.0) double rating,
    @Default(0) int totalSales,
  }) = _FarmerSummary;

  factory FarmerSummary.fromJson(Map<String, dynamic> json) => _$FarmerSummaryFromJson(json);
}
