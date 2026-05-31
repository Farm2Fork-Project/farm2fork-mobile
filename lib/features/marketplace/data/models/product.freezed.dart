// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'product.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Product {

@JsonKey(name: '_id') String get id; String get farmerId; String get name; ProductCategory get category; String get description;/// Price in PKR per unit.
 double get price; double get quantity;/// Unit enum matching the backend schema.
 ProductUnit get unit; List<String> get images; QualityGrade get qualityGrade; String? get qrCode; String? get initialBlockchainRecordId; ProductStatus get status;/// Embedded farmer info — avoids a second network call in list views.
 FarmerSummary get farmer;
/// Create a copy of Product
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProductCopyWith<Product> get copyWith => _$ProductCopyWithImpl<Product>(this as Product, _$identity);

  /// Serializes this Product to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Product&&(identical(other.id, id) || other.id == id)&&(identical(other.farmerId, farmerId) || other.farmerId == farmerId)&&(identical(other.name, name) || other.name == name)&&(identical(other.category, category) || other.category == category)&&(identical(other.description, description) || other.description == description)&&(identical(other.price, price) || other.price == price)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.unit, unit) || other.unit == unit)&&const DeepCollectionEquality().equals(other.images, images)&&(identical(other.qualityGrade, qualityGrade) || other.qualityGrade == qualityGrade)&&(identical(other.qrCode, qrCode) || other.qrCode == qrCode)&&(identical(other.initialBlockchainRecordId, initialBlockchainRecordId) || other.initialBlockchainRecordId == initialBlockchainRecordId)&&(identical(other.status, status) || other.status == status)&&(identical(other.farmer, farmer) || other.farmer == farmer));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,farmerId,name,category,description,price,quantity,unit,const DeepCollectionEquality().hash(images),qualityGrade,qrCode,initialBlockchainRecordId,status,farmer);

@override
String toString() {
  return 'Product(id: $id, farmerId: $farmerId, name: $name, category: $category, description: $description, price: $price, quantity: $quantity, unit: $unit, images: $images, qualityGrade: $qualityGrade, qrCode: $qrCode, initialBlockchainRecordId: $initialBlockchainRecordId, status: $status, farmer: $farmer)';
}


}

/// @nodoc
abstract mixin class $ProductCopyWith<$Res>  {
  factory $ProductCopyWith(Product value, $Res Function(Product) _then) = _$ProductCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: '_id') String id, String farmerId, String name, ProductCategory category, String description, double price, double quantity, ProductUnit unit, List<String> images, QualityGrade qualityGrade, String? qrCode, String? initialBlockchainRecordId, ProductStatus status, FarmerSummary farmer
});


$FarmerSummaryCopyWith<$Res> get farmer;

}
/// @nodoc
class _$ProductCopyWithImpl<$Res>
    implements $ProductCopyWith<$Res> {
  _$ProductCopyWithImpl(this._self, this._then);

  final Product _self;
  final $Res Function(Product) _then;

/// Create a copy of Product
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? farmerId = null,Object? name = null,Object? category = null,Object? description = null,Object? price = null,Object? quantity = null,Object? unit = null,Object? images = null,Object? qualityGrade = null,Object? qrCode = freezed,Object? initialBlockchainRecordId = freezed,Object? status = null,Object? farmer = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,farmerId: null == farmerId ? _self.farmerId : farmerId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as ProductCategory,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as double,unit: null == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as ProductUnit,images: null == images ? _self.images : images // ignore: cast_nullable_to_non_nullable
as List<String>,qualityGrade: null == qualityGrade ? _self.qualityGrade : qualityGrade // ignore: cast_nullable_to_non_nullable
as QualityGrade,qrCode: freezed == qrCode ? _self.qrCode : qrCode // ignore: cast_nullable_to_non_nullable
as String?,initialBlockchainRecordId: freezed == initialBlockchainRecordId ? _self.initialBlockchainRecordId : initialBlockchainRecordId // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ProductStatus,farmer: null == farmer ? _self.farmer : farmer // ignore: cast_nullable_to_non_nullable
as FarmerSummary,
  ));
}
/// Create a copy of Product
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FarmerSummaryCopyWith<$Res> get farmer {
  
  return $FarmerSummaryCopyWith<$Res>(_self.farmer, (value) {
    return _then(_self.copyWith(farmer: value));
  });
}
}


/// Adds pattern-matching-related methods to [Product].
extension ProductPatterns on Product {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Product value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Product() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Product value)  $default,){
final _that = this;
switch (_that) {
case _Product():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Product value)?  $default,){
final _that = this;
switch (_that) {
case _Product() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: '_id')  String id,  String farmerId,  String name,  ProductCategory category,  String description,  double price,  double quantity,  ProductUnit unit,  List<String> images,  QualityGrade qualityGrade,  String? qrCode,  String? initialBlockchainRecordId,  ProductStatus status,  FarmerSummary farmer)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Product() when $default != null:
return $default(_that.id,_that.farmerId,_that.name,_that.category,_that.description,_that.price,_that.quantity,_that.unit,_that.images,_that.qualityGrade,_that.qrCode,_that.initialBlockchainRecordId,_that.status,_that.farmer);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: '_id')  String id,  String farmerId,  String name,  ProductCategory category,  String description,  double price,  double quantity,  ProductUnit unit,  List<String> images,  QualityGrade qualityGrade,  String? qrCode,  String? initialBlockchainRecordId,  ProductStatus status,  FarmerSummary farmer)  $default,) {final _that = this;
switch (_that) {
case _Product():
return $default(_that.id,_that.farmerId,_that.name,_that.category,_that.description,_that.price,_that.quantity,_that.unit,_that.images,_that.qualityGrade,_that.qrCode,_that.initialBlockchainRecordId,_that.status,_that.farmer);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: '_id')  String id,  String farmerId,  String name,  ProductCategory category,  String description,  double price,  double quantity,  ProductUnit unit,  List<String> images,  QualityGrade qualityGrade,  String? qrCode,  String? initialBlockchainRecordId,  ProductStatus status,  FarmerSummary farmer)?  $default,) {final _that = this;
switch (_that) {
case _Product() when $default != null:
return $default(_that.id,_that.farmerId,_that.name,_that.category,_that.description,_that.price,_that.quantity,_that.unit,_that.images,_that.qualityGrade,_that.qrCode,_that.initialBlockchainRecordId,_that.status,_that.farmer);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Product implements Product {
  const _Product({@JsonKey(name: '_id') required this.id, required this.farmerId, required this.name, required this.category, required this.description, required this.price, required this.quantity, required this.unit, final  List<String> images = const [], this.qualityGrade = QualityGrade.a, this.qrCode, this.initialBlockchainRecordId, this.status = ProductStatus.active, required this.farmer}): _images = images;
  factory _Product.fromJson(Map<String, dynamic> json) => _$ProductFromJson(json);

@override@JsonKey(name: '_id') final  String id;
@override final  String farmerId;
@override final  String name;
@override final  ProductCategory category;
@override final  String description;
/// Price in PKR per unit.
@override final  double price;
@override final  double quantity;
/// Unit enum matching the backend schema.
@override final  ProductUnit unit;
 final  List<String> _images;
@override@JsonKey() List<String> get images {
  if (_images is EqualUnmodifiableListView) return _images;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_images);
}

@override@JsonKey() final  QualityGrade qualityGrade;
@override final  String? qrCode;
@override final  String? initialBlockchainRecordId;
@override@JsonKey() final  ProductStatus status;
/// Embedded farmer info — avoids a second network call in list views.
@override final  FarmerSummary farmer;

/// Create a copy of Product
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProductCopyWith<_Product> get copyWith => __$ProductCopyWithImpl<_Product>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProductToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Product&&(identical(other.id, id) || other.id == id)&&(identical(other.farmerId, farmerId) || other.farmerId == farmerId)&&(identical(other.name, name) || other.name == name)&&(identical(other.category, category) || other.category == category)&&(identical(other.description, description) || other.description == description)&&(identical(other.price, price) || other.price == price)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.unit, unit) || other.unit == unit)&&const DeepCollectionEquality().equals(other._images, _images)&&(identical(other.qualityGrade, qualityGrade) || other.qualityGrade == qualityGrade)&&(identical(other.qrCode, qrCode) || other.qrCode == qrCode)&&(identical(other.initialBlockchainRecordId, initialBlockchainRecordId) || other.initialBlockchainRecordId == initialBlockchainRecordId)&&(identical(other.status, status) || other.status == status)&&(identical(other.farmer, farmer) || other.farmer == farmer));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,farmerId,name,category,description,price,quantity,unit,const DeepCollectionEquality().hash(_images),qualityGrade,qrCode,initialBlockchainRecordId,status,farmer);

@override
String toString() {
  return 'Product(id: $id, farmerId: $farmerId, name: $name, category: $category, description: $description, price: $price, quantity: $quantity, unit: $unit, images: $images, qualityGrade: $qualityGrade, qrCode: $qrCode, initialBlockchainRecordId: $initialBlockchainRecordId, status: $status, farmer: $farmer)';
}


}

/// @nodoc
abstract mixin class _$ProductCopyWith<$Res> implements $ProductCopyWith<$Res> {
  factory _$ProductCopyWith(_Product value, $Res Function(_Product) _then) = __$ProductCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: '_id') String id, String farmerId, String name, ProductCategory category, String description, double price, double quantity, ProductUnit unit, List<String> images, QualityGrade qualityGrade, String? qrCode, String? initialBlockchainRecordId, ProductStatus status, FarmerSummary farmer
});


@override $FarmerSummaryCopyWith<$Res> get farmer;

}
/// @nodoc
class __$ProductCopyWithImpl<$Res>
    implements _$ProductCopyWith<$Res> {
  __$ProductCopyWithImpl(this._self, this._then);

  final _Product _self;
  final $Res Function(_Product) _then;

/// Create a copy of Product
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? farmerId = null,Object? name = null,Object? category = null,Object? description = null,Object? price = null,Object? quantity = null,Object? unit = null,Object? images = null,Object? qualityGrade = null,Object? qrCode = freezed,Object? initialBlockchainRecordId = freezed,Object? status = null,Object? farmer = null,}) {
  return _then(_Product(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,farmerId: null == farmerId ? _self.farmerId : farmerId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as ProductCategory,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as double,unit: null == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as ProductUnit,images: null == images ? _self._images : images // ignore: cast_nullable_to_non_nullable
as List<String>,qualityGrade: null == qualityGrade ? _self.qualityGrade : qualityGrade // ignore: cast_nullable_to_non_nullable
as QualityGrade,qrCode: freezed == qrCode ? _self.qrCode : qrCode // ignore: cast_nullable_to_non_nullable
as String?,initialBlockchainRecordId: freezed == initialBlockchainRecordId ? _self.initialBlockchainRecordId : initialBlockchainRecordId // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ProductStatus,farmer: null == farmer ? _self.farmer : farmer // ignore: cast_nullable_to_non_nullable
as FarmerSummary,
  ));
}

/// Create a copy of Product
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FarmerSummaryCopyWith<$Res> get farmer {
  
  return $FarmerSummaryCopyWith<$Res>(_self.farmer, (value) {
    return _then(_self.copyWith(farmer: value));
  });
}
}

// dart format on
