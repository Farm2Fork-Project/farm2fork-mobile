// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'farmer_summary.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$FarmerSummary {

 String get id; String get name; String get farmName; String get farmLocationAddress; double get rating; int get totalSales;
/// Create a copy of FarmerSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FarmerSummaryCopyWith<FarmerSummary> get copyWith => _$FarmerSummaryCopyWithImpl<FarmerSummary>(this as FarmerSummary, _$identity);

  /// Serializes this FarmerSummary to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FarmerSummary&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.farmName, farmName) || other.farmName == farmName)&&(identical(other.farmLocationAddress, farmLocationAddress) || other.farmLocationAddress == farmLocationAddress)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.totalSales, totalSales) || other.totalSales == totalSales));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,farmName,farmLocationAddress,rating,totalSales);

@override
String toString() {
  return 'FarmerSummary(id: $id, name: $name, farmName: $farmName, farmLocationAddress: $farmLocationAddress, rating: $rating, totalSales: $totalSales)';
}


}

/// @nodoc
abstract mixin class $FarmerSummaryCopyWith<$Res>  {
  factory $FarmerSummaryCopyWith(FarmerSummary value, $Res Function(FarmerSummary) _then) = _$FarmerSummaryCopyWithImpl;
@useResult
$Res call({
 String id, String name, String farmName, String farmLocationAddress, double rating, int totalSales
});




}
/// @nodoc
class _$FarmerSummaryCopyWithImpl<$Res>
    implements $FarmerSummaryCopyWith<$Res> {
  _$FarmerSummaryCopyWithImpl(this._self, this._then);

  final FarmerSummary _self;
  final $Res Function(FarmerSummary) _then;

/// Create a copy of FarmerSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? farmName = null,Object? farmLocationAddress = null,Object? rating = null,Object? totalSales = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,farmName: null == farmName ? _self.farmName : farmName // ignore: cast_nullable_to_non_nullable
as String,farmLocationAddress: null == farmLocationAddress ? _self.farmLocationAddress : farmLocationAddress // ignore: cast_nullable_to_non_nullable
as String,rating: null == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as double,totalSales: null == totalSales ? _self.totalSales : totalSales // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [FarmerSummary].
extension FarmerSummaryPatterns on FarmerSummary {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FarmerSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FarmerSummary() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FarmerSummary value)  $default,){
final _that = this;
switch (_that) {
case _FarmerSummary():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FarmerSummary value)?  $default,){
final _that = this;
switch (_that) {
case _FarmerSummary() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String farmName,  String farmLocationAddress,  double rating,  int totalSales)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FarmerSummary() when $default != null:
return $default(_that.id,_that.name,_that.farmName,_that.farmLocationAddress,_that.rating,_that.totalSales);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String farmName,  String farmLocationAddress,  double rating,  int totalSales)  $default,) {final _that = this;
switch (_that) {
case _FarmerSummary():
return $default(_that.id,_that.name,_that.farmName,_that.farmLocationAddress,_that.rating,_that.totalSales);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String farmName,  String farmLocationAddress,  double rating,  int totalSales)?  $default,) {final _that = this;
switch (_that) {
case _FarmerSummary() when $default != null:
return $default(_that.id,_that.name,_that.farmName,_that.farmLocationAddress,_that.rating,_that.totalSales);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FarmerSummary implements FarmerSummary {
  const _FarmerSummary({required this.id, required this.name, required this.farmName, required this.farmLocationAddress, this.rating = 0.0, this.totalSales = 0});
  factory _FarmerSummary.fromJson(Map<String, dynamic> json) => _$FarmerSummaryFromJson(json);

@override final  String id;
@override final  String name;
@override final  String farmName;
@override final  String farmLocationAddress;
@override@JsonKey() final  double rating;
@override@JsonKey() final  int totalSales;

/// Create a copy of FarmerSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FarmerSummaryCopyWith<_FarmerSummary> get copyWith => __$FarmerSummaryCopyWithImpl<_FarmerSummary>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FarmerSummaryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FarmerSummary&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.farmName, farmName) || other.farmName == farmName)&&(identical(other.farmLocationAddress, farmLocationAddress) || other.farmLocationAddress == farmLocationAddress)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.totalSales, totalSales) || other.totalSales == totalSales));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,farmName,farmLocationAddress,rating,totalSales);

@override
String toString() {
  return 'FarmerSummary(id: $id, name: $name, farmName: $farmName, farmLocationAddress: $farmLocationAddress, rating: $rating, totalSales: $totalSales)';
}


}

/// @nodoc
abstract mixin class _$FarmerSummaryCopyWith<$Res> implements $FarmerSummaryCopyWith<$Res> {
  factory _$FarmerSummaryCopyWith(_FarmerSummary value, $Res Function(_FarmerSummary) _then) = __$FarmerSummaryCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String farmName, String farmLocationAddress, double rating, int totalSales
});




}
/// @nodoc
class __$FarmerSummaryCopyWithImpl<$Res>
    implements _$FarmerSummaryCopyWith<$Res> {
  __$FarmerSummaryCopyWithImpl(this._self, this._then);

  final _FarmerSummary _self;
  final $Res Function(_FarmerSummary) _then;

/// Create a copy of FarmerSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? farmName = null,Object? farmLocationAddress = null,Object? rating = null,Object? totalSales = null,}) {
  return _then(_FarmerSummary(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,farmName: null == farmName ? _self.farmName : farmName // ignore: cast_nullable_to_non_nullable
as String,farmLocationAddress: null == farmLocationAddress ? _self.farmLocationAddress : farmLocationAddress // ignore: cast_nullable_to_non_nullable
as String,rating: null == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as double,totalSales: null == totalSales ? _self.totalSales : totalSales // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
