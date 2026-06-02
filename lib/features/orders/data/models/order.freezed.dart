// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'order.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$OrderAddress {

 String get street; String get city; String get province; String? get zip;
/// Create a copy of OrderAddress
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OrderAddressCopyWith<OrderAddress> get copyWith => _$OrderAddressCopyWithImpl<OrderAddress>(this as OrderAddress, _$identity);

  /// Serializes this OrderAddress to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OrderAddress&&(identical(other.street, street) || other.street == street)&&(identical(other.city, city) || other.city == city)&&(identical(other.province, province) || other.province == province)&&(identical(other.zip, zip) || other.zip == zip));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,street,city,province,zip);

@override
String toString() {
  return 'OrderAddress(street: $street, city: $city, province: $province, zip: $zip)';
}


}

/// @nodoc
abstract mixin class $OrderAddressCopyWith<$Res>  {
  factory $OrderAddressCopyWith(OrderAddress value, $Res Function(OrderAddress) _then) = _$OrderAddressCopyWithImpl;
@useResult
$Res call({
 String street, String city, String province, String? zip
});




}
/// @nodoc
class _$OrderAddressCopyWithImpl<$Res>
    implements $OrderAddressCopyWith<$Res> {
  _$OrderAddressCopyWithImpl(this._self, this._then);

  final OrderAddress _self;
  final $Res Function(OrderAddress) _then;

/// Create a copy of OrderAddress
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? street = null,Object? city = null,Object? province = null,Object? zip = freezed,}) {
  return _then(_self.copyWith(
street: null == street ? _self.street : street // ignore: cast_nullable_to_non_nullable
as String,city: null == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String,province: null == province ? _self.province : province // ignore: cast_nullable_to_non_nullable
as String,zip: freezed == zip ? _self.zip : zip // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [OrderAddress].
extension OrderAddressPatterns on OrderAddress {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OrderAddress value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OrderAddress() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OrderAddress value)  $default,){
final _that = this;
switch (_that) {
case _OrderAddress():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OrderAddress value)?  $default,){
final _that = this;
switch (_that) {
case _OrderAddress() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String street,  String city,  String province,  String? zip)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OrderAddress() when $default != null:
return $default(_that.street,_that.city,_that.province,_that.zip);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String street,  String city,  String province,  String? zip)  $default,) {final _that = this;
switch (_that) {
case _OrderAddress():
return $default(_that.street,_that.city,_that.province,_that.zip);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String street,  String city,  String province,  String? zip)?  $default,) {final _that = this;
switch (_that) {
case _OrderAddress() when $default != null:
return $default(_that.street,_that.city,_that.province,_that.zip);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OrderAddress implements OrderAddress {
  const _OrderAddress({required this.street, required this.city, required this.province, this.zip});
  factory _OrderAddress.fromJson(Map<String, dynamic> json) => _$OrderAddressFromJson(json);

@override final  String street;
@override final  String city;
@override final  String province;
@override final  String? zip;

/// Create a copy of OrderAddress
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OrderAddressCopyWith<_OrderAddress> get copyWith => __$OrderAddressCopyWithImpl<_OrderAddress>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OrderAddressToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OrderAddress&&(identical(other.street, street) || other.street == street)&&(identical(other.city, city) || other.city == city)&&(identical(other.province, province) || other.province == province)&&(identical(other.zip, zip) || other.zip == zip));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,street,city,province,zip);

@override
String toString() {
  return 'OrderAddress(street: $street, city: $city, province: $province, zip: $zip)';
}


}

/// @nodoc
abstract mixin class _$OrderAddressCopyWith<$Res> implements $OrderAddressCopyWith<$Res> {
  factory _$OrderAddressCopyWith(_OrderAddress value, $Res Function(_OrderAddress) _then) = __$OrderAddressCopyWithImpl;
@override @useResult
$Res call({
 String street, String city, String province, String? zip
});




}
/// @nodoc
class __$OrderAddressCopyWithImpl<$Res>
    implements _$OrderAddressCopyWith<$Res> {
  __$OrderAddressCopyWithImpl(this._self, this._then);

  final _OrderAddress _self;
  final $Res Function(_OrderAddress) _then;

/// Create a copy of OrderAddress
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? street = null,Object? city = null,Object? province = null,Object? zip = freezed,}) {
  return _then(_OrderAddress(
street: null == street ? _self.street : street // ignore: cast_nullable_to_non_nullable
as String,city: null == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String,province: null == province ? _self.province : province // ignore: cast_nullable_to_non_nullable
as String,zip: freezed == zip ? _self.zip : zip // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$OrderItem {

 String get productId; String get farmerId; String get productName; double get quantity; String get unit; double get unitPrice; double get subtotal;
/// Create a copy of OrderItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OrderItemCopyWith<OrderItem> get copyWith => _$OrderItemCopyWithImpl<OrderItem>(this as OrderItem, _$identity);

  /// Serializes this OrderItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OrderItem&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.farmerId, farmerId) || other.farmerId == farmerId)&&(identical(other.productName, productName) || other.productName == productName)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.unit, unit) || other.unit == unit)&&(identical(other.unitPrice, unitPrice) || other.unitPrice == unitPrice)&&(identical(other.subtotal, subtotal) || other.subtotal == subtotal));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,productId,farmerId,productName,quantity,unit,unitPrice,subtotal);

@override
String toString() {
  return 'OrderItem(productId: $productId, farmerId: $farmerId, productName: $productName, quantity: $quantity, unit: $unit, unitPrice: $unitPrice, subtotal: $subtotal)';
}


}

/// @nodoc
abstract mixin class $OrderItemCopyWith<$Res>  {
  factory $OrderItemCopyWith(OrderItem value, $Res Function(OrderItem) _then) = _$OrderItemCopyWithImpl;
@useResult
$Res call({
 String productId, String farmerId, String productName, double quantity, String unit, double unitPrice, double subtotal
});




}
/// @nodoc
class _$OrderItemCopyWithImpl<$Res>
    implements $OrderItemCopyWith<$Res> {
  _$OrderItemCopyWithImpl(this._self, this._then);

  final OrderItem _self;
  final $Res Function(OrderItem) _then;

/// Create a copy of OrderItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? productId = null,Object? farmerId = null,Object? productName = null,Object? quantity = null,Object? unit = null,Object? unitPrice = null,Object? subtotal = null,}) {
  return _then(_self.copyWith(
productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as String,farmerId: null == farmerId ? _self.farmerId : farmerId // ignore: cast_nullable_to_non_nullable
as String,productName: null == productName ? _self.productName : productName // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as double,unit: null == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String,unitPrice: null == unitPrice ? _self.unitPrice : unitPrice // ignore: cast_nullable_to_non_nullable
as double,subtotal: null == subtotal ? _self.subtotal : subtotal // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [OrderItem].
extension OrderItemPatterns on OrderItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OrderItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OrderItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OrderItem value)  $default,){
final _that = this;
switch (_that) {
case _OrderItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OrderItem value)?  $default,){
final _that = this;
switch (_that) {
case _OrderItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String productId,  String farmerId,  String productName,  double quantity,  String unit,  double unitPrice,  double subtotal)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OrderItem() when $default != null:
return $default(_that.productId,_that.farmerId,_that.productName,_that.quantity,_that.unit,_that.unitPrice,_that.subtotal);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String productId,  String farmerId,  String productName,  double quantity,  String unit,  double unitPrice,  double subtotal)  $default,) {final _that = this;
switch (_that) {
case _OrderItem():
return $default(_that.productId,_that.farmerId,_that.productName,_that.quantity,_that.unit,_that.unitPrice,_that.subtotal);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String productId,  String farmerId,  String productName,  double quantity,  String unit,  double unitPrice,  double subtotal)?  $default,) {final _that = this;
switch (_that) {
case _OrderItem() when $default != null:
return $default(_that.productId,_that.farmerId,_that.productName,_that.quantity,_that.unit,_that.unitPrice,_that.subtotal);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OrderItem implements OrderItem {
  const _OrderItem({required this.productId, required this.farmerId, required this.productName, required this.quantity, required this.unit, required this.unitPrice, required this.subtotal});
  factory _OrderItem.fromJson(Map<String, dynamic> json) => _$OrderItemFromJson(json);

@override final  String productId;
@override final  String farmerId;
@override final  String productName;
@override final  double quantity;
@override final  String unit;
@override final  double unitPrice;
@override final  double subtotal;

/// Create a copy of OrderItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OrderItemCopyWith<_OrderItem> get copyWith => __$OrderItemCopyWithImpl<_OrderItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OrderItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OrderItem&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.farmerId, farmerId) || other.farmerId == farmerId)&&(identical(other.productName, productName) || other.productName == productName)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.unit, unit) || other.unit == unit)&&(identical(other.unitPrice, unitPrice) || other.unitPrice == unitPrice)&&(identical(other.subtotal, subtotal) || other.subtotal == subtotal));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,productId,farmerId,productName,quantity,unit,unitPrice,subtotal);

@override
String toString() {
  return 'OrderItem(productId: $productId, farmerId: $farmerId, productName: $productName, quantity: $quantity, unit: $unit, unitPrice: $unitPrice, subtotal: $subtotal)';
}


}

/// @nodoc
abstract mixin class _$OrderItemCopyWith<$Res> implements $OrderItemCopyWith<$Res> {
  factory _$OrderItemCopyWith(_OrderItem value, $Res Function(_OrderItem) _then) = __$OrderItemCopyWithImpl;
@override @useResult
$Res call({
 String productId, String farmerId, String productName, double quantity, String unit, double unitPrice, double subtotal
});




}
/// @nodoc
class __$OrderItemCopyWithImpl<$Res>
    implements _$OrderItemCopyWith<$Res> {
  __$OrderItemCopyWithImpl(this._self, this._then);

  final _OrderItem _self;
  final $Res Function(_OrderItem) _then;

/// Create a copy of OrderItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? productId = null,Object? farmerId = null,Object? productName = null,Object? quantity = null,Object? unit = null,Object? unitPrice = null,Object? subtotal = null,}) {
  return _then(_OrderItem(
productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as String,farmerId: null == farmerId ? _self.farmerId : farmerId // ignore: cast_nullable_to_non_nullable
as String,productName: null == productName ? _self.productName : productName // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as double,unit: null == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String,unitPrice: null == unitPrice ? _self.unitPrice : unitPrice // ignore: cast_nullable_to_non_nullable
as double,subtotal: null == subtotal ? _self.subtotal : subtotal // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}


/// @nodoc
mixin _$Order {

@JsonKey(name: '_id') String get id; String get buyerId; String get farmerId; List<OrderItem> get items; double get totalAmount; double get platformFeePercent; double get platformFeeAmount; double get grandTotal; OrderAddress get shippingAddress; OrderStatus get status; String? get paymentId; String? get shipmentId; DateTime get createdAt; DateTime get updatedAt;
/// Create a copy of Order
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OrderCopyWith<Order> get copyWith => _$OrderCopyWithImpl<Order>(this as Order, _$identity);

  /// Serializes this Order to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Order&&(identical(other.id, id) || other.id == id)&&(identical(other.buyerId, buyerId) || other.buyerId == buyerId)&&(identical(other.farmerId, farmerId) || other.farmerId == farmerId)&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.totalAmount, totalAmount) || other.totalAmount == totalAmount)&&(identical(other.platformFeePercent, platformFeePercent) || other.platformFeePercent == platformFeePercent)&&(identical(other.platformFeeAmount, platformFeeAmount) || other.platformFeeAmount == platformFeeAmount)&&(identical(other.grandTotal, grandTotal) || other.grandTotal == grandTotal)&&(identical(other.shippingAddress, shippingAddress) || other.shippingAddress == shippingAddress)&&(identical(other.status, status) || other.status == status)&&(identical(other.paymentId, paymentId) || other.paymentId == paymentId)&&(identical(other.shipmentId, shipmentId) || other.shipmentId == shipmentId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,buyerId,farmerId,const DeepCollectionEquality().hash(items),totalAmount,platformFeePercent,platformFeeAmount,grandTotal,shippingAddress,status,paymentId,shipmentId,createdAt,updatedAt);

@override
String toString() {
  return 'Order(id: $id, buyerId: $buyerId, farmerId: $farmerId, items: $items, totalAmount: $totalAmount, platformFeePercent: $platformFeePercent, platformFeeAmount: $platformFeeAmount, grandTotal: $grandTotal, shippingAddress: $shippingAddress, status: $status, paymentId: $paymentId, shipmentId: $shipmentId, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $OrderCopyWith<$Res>  {
  factory $OrderCopyWith(Order value, $Res Function(Order) _then) = _$OrderCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: '_id') String id, String buyerId, String farmerId, List<OrderItem> items, double totalAmount, double platformFeePercent, double platformFeeAmount, double grandTotal, OrderAddress shippingAddress, OrderStatus status, String? paymentId, String? shipmentId, DateTime createdAt, DateTime updatedAt
});


$OrderAddressCopyWith<$Res> get shippingAddress;

}
/// @nodoc
class _$OrderCopyWithImpl<$Res>
    implements $OrderCopyWith<$Res> {
  _$OrderCopyWithImpl(this._self, this._then);

  final Order _self;
  final $Res Function(Order) _then;

/// Create a copy of Order
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? buyerId = null,Object? farmerId = null,Object? items = null,Object? totalAmount = null,Object? platformFeePercent = null,Object? platformFeeAmount = null,Object? grandTotal = null,Object? shippingAddress = null,Object? status = null,Object? paymentId = freezed,Object? shipmentId = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,buyerId: null == buyerId ? _self.buyerId : buyerId // ignore: cast_nullable_to_non_nullable
as String,farmerId: null == farmerId ? _self.farmerId : farmerId // ignore: cast_nullable_to_non_nullable
as String,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<OrderItem>,totalAmount: null == totalAmount ? _self.totalAmount : totalAmount // ignore: cast_nullable_to_non_nullable
as double,platformFeePercent: null == platformFeePercent ? _self.platformFeePercent : platformFeePercent // ignore: cast_nullable_to_non_nullable
as double,platformFeeAmount: null == platformFeeAmount ? _self.platformFeeAmount : platformFeeAmount // ignore: cast_nullable_to_non_nullable
as double,grandTotal: null == grandTotal ? _self.grandTotal : grandTotal // ignore: cast_nullable_to_non_nullable
as double,shippingAddress: null == shippingAddress ? _self.shippingAddress : shippingAddress // ignore: cast_nullable_to_non_nullable
as OrderAddress,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as OrderStatus,paymentId: freezed == paymentId ? _self.paymentId : paymentId // ignore: cast_nullable_to_non_nullable
as String?,shipmentId: freezed == shipmentId ? _self.shipmentId : shipmentId // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}
/// Create a copy of Order
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OrderAddressCopyWith<$Res> get shippingAddress {
  
  return $OrderAddressCopyWith<$Res>(_self.shippingAddress, (value) {
    return _then(_self.copyWith(shippingAddress: value));
  });
}
}


/// Adds pattern-matching-related methods to [Order].
extension OrderPatterns on Order {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Order value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Order() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Order value)  $default,){
final _that = this;
switch (_that) {
case _Order():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Order value)?  $default,){
final _that = this;
switch (_that) {
case _Order() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: '_id')  String id,  String buyerId,  String farmerId,  List<OrderItem> items,  double totalAmount,  double platformFeePercent,  double platformFeeAmount,  double grandTotal,  OrderAddress shippingAddress,  OrderStatus status,  String? paymentId,  String? shipmentId,  DateTime createdAt,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Order() when $default != null:
return $default(_that.id,_that.buyerId,_that.farmerId,_that.items,_that.totalAmount,_that.platformFeePercent,_that.platformFeeAmount,_that.grandTotal,_that.shippingAddress,_that.status,_that.paymentId,_that.shipmentId,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: '_id')  String id,  String buyerId,  String farmerId,  List<OrderItem> items,  double totalAmount,  double platformFeePercent,  double platformFeeAmount,  double grandTotal,  OrderAddress shippingAddress,  OrderStatus status,  String? paymentId,  String? shipmentId,  DateTime createdAt,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _Order():
return $default(_that.id,_that.buyerId,_that.farmerId,_that.items,_that.totalAmount,_that.platformFeePercent,_that.platformFeeAmount,_that.grandTotal,_that.shippingAddress,_that.status,_that.paymentId,_that.shipmentId,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: '_id')  String id,  String buyerId,  String farmerId,  List<OrderItem> items,  double totalAmount,  double platformFeePercent,  double platformFeeAmount,  double grandTotal,  OrderAddress shippingAddress,  OrderStatus status,  String? paymentId,  String? shipmentId,  DateTime createdAt,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _Order() when $default != null:
return $default(_that.id,_that.buyerId,_that.farmerId,_that.items,_that.totalAmount,_that.platformFeePercent,_that.platformFeeAmount,_that.grandTotal,_that.shippingAddress,_that.status,_that.paymentId,_that.shipmentId,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Order implements Order {
  const _Order({@JsonKey(name: '_id') required this.id, required this.buyerId, required this.farmerId, required final  List<OrderItem> items, required this.totalAmount, required this.platformFeePercent, required this.platformFeeAmount, required this.grandTotal, required this.shippingAddress, required this.status, this.paymentId, this.shipmentId, required this.createdAt, required this.updatedAt}): _items = items;
  factory _Order.fromJson(Map<String, dynamic> json) => _$OrderFromJson(json);

@override@JsonKey(name: '_id') final  String id;
@override final  String buyerId;
@override final  String farmerId;
 final  List<OrderItem> _items;
@override List<OrderItem> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override final  double totalAmount;
@override final  double platformFeePercent;
@override final  double platformFeeAmount;
@override final  double grandTotal;
@override final  OrderAddress shippingAddress;
@override final  OrderStatus status;
@override final  String? paymentId;
@override final  String? shipmentId;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;

/// Create a copy of Order
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OrderCopyWith<_Order> get copyWith => __$OrderCopyWithImpl<_Order>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OrderToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Order&&(identical(other.id, id) || other.id == id)&&(identical(other.buyerId, buyerId) || other.buyerId == buyerId)&&(identical(other.farmerId, farmerId) || other.farmerId == farmerId)&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.totalAmount, totalAmount) || other.totalAmount == totalAmount)&&(identical(other.platformFeePercent, platformFeePercent) || other.platformFeePercent == platformFeePercent)&&(identical(other.platformFeeAmount, platformFeeAmount) || other.platformFeeAmount == platformFeeAmount)&&(identical(other.grandTotal, grandTotal) || other.grandTotal == grandTotal)&&(identical(other.shippingAddress, shippingAddress) || other.shippingAddress == shippingAddress)&&(identical(other.status, status) || other.status == status)&&(identical(other.paymentId, paymentId) || other.paymentId == paymentId)&&(identical(other.shipmentId, shipmentId) || other.shipmentId == shipmentId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,buyerId,farmerId,const DeepCollectionEquality().hash(_items),totalAmount,platformFeePercent,platformFeeAmount,grandTotal,shippingAddress,status,paymentId,shipmentId,createdAt,updatedAt);

@override
String toString() {
  return 'Order(id: $id, buyerId: $buyerId, farmerId: $farmerId, items: $items, totalAmount: $totalAmount, platformFeePercent: $platformFeePercent, platformFeeAmount: $platformFeeAmount, grandTotal: $grandTotal, shippingAddress: $shippingAddress, status: $status, paymentId: $paymentId, shipmentId: $shipmentId, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$OrderCopyWith<$Res> implements $OrderCopyWith<$Res> {
  factory _$OrderCopyWith(_Order value, $Res Function(_Order) _then) = __$OrderCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: '_id') String id, String buyerId, String farmerId, List<OrderItem> items, double totalAmount, double platformFeePercent, double platformFeeAmount, double grandTotal, OrderAddress shippingAddress, OrderStatus status, String? paymentId, String? shipmentId, DateTime createdAt, DateTime updatedAt
});


@override $OrderAddressCopyWith<$Res> get shippingAddress;

}
/// @nodoc
class __$OrderCopyWithImpl<$Res>
    implements _$OrderCopyWith<$Res> {
  __$OrderCopyWithImpl(this._self, this._then);

  final _Order _self;
  final $Res Function(_Order) _then;

/// Create a copy of Order
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? buyerId = null,Object? farmerId = null,Object? items = null,Object? totalAmount = null,Object? platformFeePercent = null,Object? platformFeeAmount = null,Object? grandTotal = null,Object? shippingAddress = null,Object? status = null,Object? paymentId = freezed,Object? shipmentId = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_Order(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,buyerId: null == buyerId ? _self.buyerId : buyerId // ignore: cast_nullable_to_non_nullable
as String,farmerId: null == farmerId ? _self.farmerId : farmerId // ignore: cast_nullable_to_non_nullable
as String,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<OrderItem>,totalAmount: null == totalAmount ? _self.totalAmount : totalAmount // ignore: cast_nullable_to_non_nullable
as double,platformFeePercent: null == platformFeePercent ? _self.platformFeePercent : platformFeePercent // ignore: cast_nullable_to_non_nullable
as double,platformFeeAmount: null == platformFeeAmount ? _self.platformFeeAmount : platformFeeAmount // ignore: cast_nullable_to_non_nullable
as double,grandTotal: null == grandTotal ? _self.grandTotal : grandTotal // ignore: cast_nullable_to_non_nullable
as double,shippingAddress: null == shippingAddress ? _self.shippingAddress : shippingAddress // ignore: cast_nullable_to_non_nullable
as OrderAddress,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as OrderStatus,paymentId: freezed == paymentId ? _self.paymentId : paymentId // ignore: cast_nullable_to_non_nullable
as String?,shipmentId: freezed == shipmentId ? _self.shipmentId : shipmentId // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

/// Create a copy of Order
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OrderAddressCopyWith<$Res> get shippingAddress {
  
  return $OrderAddressCopyWith<$Res>(_self.shippingAddress, (value) {
    return _then(_self.copyWith(shippingAddress: value));
  });
}
}

// dart format on
