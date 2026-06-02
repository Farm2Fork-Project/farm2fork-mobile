// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'shipment.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ShipmentAddress {

 String get street; String get city; String get province; String? get zip;
/// Create a copy of ShipmentAddress
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ShipmentAddressCopyWith<ShipmentAddress> get copyWith => _$ShipmentAddressCopyWithImpl<ShipmentAddress>(this as ShipmentAddress, _$identity);

  /// Serializes this ShipmentAddress to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ShipmentAddress&&(identical(other.street, street) || other.street == street)&&(identical(other.city, city) || other.city == city)&&(identical(other.province, province) || other.province == province)&&(identical(other.zip, zip) || other.zip == zip));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,street,city,province,zip);

@override
String toString() {
  return 'ShipmentAddress(street: $street, city: $city, province: $province, zip: $zip)';
}


}

/// @nodoc
abstract mixin class $ShipmentAddressCopyWith<$Res>  {
  factory $ShipmentAddressCopyWith(ShipmentAddress value, $Res Function(ShipmentAddress) _then) = _$ShipmentAddressCopyWithImpl;
@useResult
$Res call({
 String street, String city, String province, String? zip
});




}
/// @nodoc
class _$ShipmentAddressCopyWithImpl<$Res>
    implements $ShipmentAddressCopyWith<$Res> {
  _$ShipmentAddressCopyWithImpl(this._self, this._then);

  final ShipmentAddress _self;
  final $Res Function(ShipmentAddress) _then;

/// Create a copy of ShipmentAddress
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


/// Adds pattern-matching-related methods to [ShipmentAddress].
extension ShipmentAddressPatterns on ShipmentAddress {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ShipmentAddress value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ShipmentAddress() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ShipmentAddress value)  $default,){
final _that = this;
switch (_that) {
case _ShipmentAddress():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ShipmentAddress value)?  $default,){
final _that = this;
switch (_that) {
case _ShipmentAddress() when $default != null:
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
case _ShipmentAddress() when $default != null:
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
case _ShipmentAddress():
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
case _ShipmentAddress() when $default != null:
return $default(_that.street,_that.city,_that.province,_that.zip);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ShipmentAddress implements ShipmentAddress {
  const _ShipmentAddress({required this.street, required this.city, required this.province, this.zip});
  factory _ShipmentAddress.fromJson(Map<String, dynamic> json) => _$ShipmentAddressFromJson(json);

@override final  String street;
@override final  String city;
@override final  String province;
@override final  String? zip;

/// Create a copy of ShipmentAddress
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ShipmentAddressCopyWith<_ShipmentAddress> get copyWith => __$ShipmentAddressCopyWithImpl<_ShipmentAddress>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ShipmentAddressToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ShipmentAddress&&(identical(other.street, street) || other.street == street)&&(identical(other.city, city) || other.city == city)&&(identical(other.province, province) || other.province == province)&&(identical(other.zip, zip) || other.zip == zip));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,street,city,province,zip);

@override
String toString() {
  return 'ShipmentAddress(street: $street, city: $city, province: $province, zip: $zip)';
}


}

/// @nodoc
abstract mixin class _$ShipmentAddressCopyWith<$Res> implements $ShipmentAddressCopyWith<$Res> {
  factory _$ShipmentAddressCopyWith(_ShipmentAddress value, $Res Function(_ShipmentAddress) _then) = __$ShipmentAddressCopyWithImpl;
@override @useResult
$Res call({
 String street, String city, String province, String? zip
});




}
/// @nodoc
class __$ShipmentAddressCopyWithImpl<$Res>
    implements _$ShipmentAddressCopyWith<$Res> {
  __$ShipmentAddressCopyWithImpl(this._self, this._then);

  final _ShipmentAddress _self;
  final $Res Function(_ShipmentAddress) _then;

/// Create a copy of ShipmentAddress
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? street = null,Object? city = null,Object? province = null,Object? zip = freezed,}) {
  return _then(_ShipmentAddress(
street: null == street ? _self.street : street // ignore: cast_nullable_to_non_nullable
as String,city: null == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String,province: null == province ? _self.province : province // ignore: cast_nullable_to_non_nullable
as String,zip: freezed == zip ? _self.zip : zip // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$ShipmentStatusUpdate {

 ShipmentStatus get status; DateTime get timestamp; String get note; String get updatedBy;
/// Create a copy of ShipmentStatusUpdate
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ShipmentStatusUpdateCopyWith<ShipmentStatusUpdate> get copyWith => _$ShipmentStatusUpdateCopyWithImpl<ShipmentStatusUpdate>(this as ShipmentStatusUpdate, _$identity);

  /// Serializes this ShipmentStatusUpdate to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ShipmentStatusUpdate&&(identical(other.status, status) || other.status == status)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&(identical(other.note, note) || other.note == note)&&(identical(other.updatedBy, updatedBy) || other.updatedBy == updatedBy));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,status,timestamp,note,updatedBy);

@override
String toString() {
  return 'ShipmentStatusUpdate(status: $status, timestamp: $timestamp, note: $note, updatedBy: $updatedBy)';
}


}

/// @nodoc
abstract mixin class $ShipmentStatusUpdateCopyWith<$Res>  {
  factory $ShipmentStatusUpdateCopyWith(ShipmentStatusUpdate value, $Res Function(ShipmentStatusUpdate) _then) = _$ShipmentStatusUpdateCopyWithImpl;
@useResult
$Res call({
 ShipmentStatus status, DateTime timestamp, String note, String updatedBy
});




}
/// @nodoc
class _$ShipmentStatusUpdateCopyWithImpl<$Res>
    implements $ShipmentStatusUpdateCopyWith<$Res> {
  _$ShipmentStatusUpdateCopyWithImpl(this._self, this._then);

  final ShipmentStatusUpdate _self;
  final $Res Function(ShipmentStatusUpdate) _then;

/// Create a copy of ShipmentStatusUpdate
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? timestamp = null,Object? note = null,Object? updatedBy = null,}) {
  return _then(_self.copyWith(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ShipmentStatus,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,note: null == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String,updatedBy: null == updatedBy ? _self.updatedBy : updatedBy // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ShipmentStatusUpdate].
extension ShipmentStatusUpdatePatterns on ShipmentStatusUpdate {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ShipmentStatusUpdate value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ShipmentStatusUpdate() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ShipmentStatusUpdate value)  $default,){
final _that = this;
switch (_that) {
case _ShipmentStatusUpdate():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ShipmentStatusUpdate value)?  $default,){
final _that = this;
switch (_that) {
case _ShipmentStatusUpdate() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ShipmentStatus status,  DateTime timestamp,  String note,  String updatedBy)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ShipmentStatusUpdate() when $default != null:
return $default(_that.status,_that.timestamp,_that.note,_that.updatedBy);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ShipmentStatus status,  DateTime timestamp,  String note,  String updatedBy)  $default,) {final _that = this;
switch (_that) {
case _ShipmentStatusUpdate():
return $default(_that.status,_that.timestamp,_that.note,_that.updatedBy);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ShipmentStatus status,  DateTime timestamp,  String note,  String updatedBy)?  $default,) {final _that = this;
switch (_that) {
case _ShipmentStatusUpdate() when $default != null:
return $default(_that.status,_that.timestamp,_that.note,_that.updatedBy);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ShipmentStatusUpdate implements ShipmentStatusUpdate {
  const _ShipmentStatusUpdate({required this.status, required this.timestamp, required this.note, required this.updatedBy});
  factory _ShipmentStatusUpdate.fromJson(Map<String, dynamic> json) => _$ShipmentStatusUpdateFromJson(json);

@override final  ShipmentStatus status;
@override final  DateTime timestamp;
@override final  String note;
@override final  String updatedBy;

/// Create a copy of ShipmentStatusUpdate
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ShipmentStatusUpdateCopyWith<_ShipmentStatusUpdate> get copyWith => __$ShipmentStatusUpdateCopyWithImpl<_ShipmentStatusUpdate>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ShipmentStatusUpdateToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ShipmentStatusUpdate&&(identical(other.status, status) || other.status == status)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&(identical(other.note, note) || other.note == note)&&(identical(other.updatedBy, updatedBy) || other.updatedBy == updatedBy));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,status,timestamp,note,updatedBy);

@override
String toString() {
  return 'ShipmentStatusUpdate(status: $status, timestamp: $timestamp, note: $note, updatedBy: $updatedBy)';
}


}

/// @nodoc
abstract mixin class _$ShipmentStatusUpdateCopyWith<$Res> implements $ShipmentStatusUpdateCopyWith<$Res> {
  factory _$ShipmentStatusUpdateCopyWith(_ShipmentStatusUpdate value, $Res Function(_ShipmentStatusUpdate) _then) = __$ShipmentStatusUpdateCopyWithImpl;
@override @useResult
$Res call({
 ShipmentStatus status, DateTime timestamp, String note, String updatedBy
});




}
/// @nodoc
class __$ShipmentStatusUpdateCopyWithImpl<$Res>
    implements _$ShipmentStatusUpdateCopyWith<$Res> {
  __$ShipmentStatusUpdateCopyWithImpl(this._self, this._then);

  final _ShipmentStatusUpdate _self;
  final $Res Function(_ShipmentStatusUpdate) _then;

/// Create a copy of ShipmentStatusUpdate
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? timestamp = null,Object? note = null,Object? updatedBy = null,}) {
  return _then(_ShipmentStatusUpdate(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ShipmentStatus,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,note: null == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String,updatedBy: null == updatedBy ? _self.updatedBy : updatedBy // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$Shipment {

@JsonKey(name: '_id') String get id; String get orderId; String get transporterId; ShipmentStatus get status; ShipmentAddress get pickupAddress; ShipmentAddress get deliveryAddress; List<ShipmentStatusUpdate> get statusHistory; DateTime get estimatedDelivery; DateTime? get actualDelivery; DateTime get createdAt; DateTime get updatedAt;
/// Create a copy of Shipment
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ShipmentCopyWith<Shipment> get copyWith => _$ShipmentCopyWithImpl<Shipment>(this as Shipment, _$identity);

  /// Serializes this Shipment to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Shipment&&(identical(other.id, id) || other.id == id)&&(identical(other.orderId, orderId) || other.orderId == orderId)&&(identical(other.transporterId, transporterId) || other.transporterId == transporterId)&&(identical(other.status, status) || other.status == status)&&(identical(other.pickupAddress, pickupAddress) || other.pickupAddress == pickupAddress)&&(identical(other.deliveryAddress, deliveryAddress) || other.deliveryAddress == deliveryAddress)&&const DeepCollectionEquality().equals(other.statusHistory, statusHistory)&&(identical(other.estimatedDelivery, estimatedDelivery) || other.estimatedDelivery == estimatedDelivery)&&(identical(other.actualDelivery, actualDelivery) || other.actualDelivery == actualDelivery)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,orderId,transporterId,status,pickupAddress,deliveryAddress,const DeepCollectionEquality().hash(statusHistory),estimatedDelivery,actualDelivery,createdAt,updatedAt);

@override
String toString() {
  return 'Shipment(id: $id, orderId: $orderId, transporterId: $transporterId, status: $status, pickupAddress: $pickupAddress, deliveryAddress: $deliveryAddress, statusHistory: $statusHistory, estimatedDelivery: $estimatedDelivery, actualDelivery: $actualDelivery, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $ShipmentCopyWith<$Res>  {
  factory $ShipmentCopyWith(Shipment value, $Res Function(Shipment) _then) = _$ShipmentCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: '_id') String id, String orderId, String transporterId, ShipmentStatus status, ShipmentAddress pickupAddress, ShipmentAddress deliveryAddress, List<ShipmentStatusUpdate> statusHistory, DateTime estimatedDelivery, DateTime? actualDelivery, DateTime createdAt, DateTime updatedAt
});


$ShipmentAddressCopyWith<$Res> get pickupAddress;$ShipmentAddressCopyWith<$Res> get deliveryAddress;

}
/// @nodoc
class _$ShipmentCopyWithImpl<$Res>
    implements $ShipmentCopyWith<$Res> {
  _$ShipmentCopyWithImpl(this._self, this._then);

  final Shipment _self;
  final $Res Function(Shipment) _then;

/// Create a copy of Shipment
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? orderId = null,Object? transporterId = null,Object? status = null,Object? pickupAddress = null,Object? deliveryAddress = null,Object? statusHistory = null,Object? estimatedDelivery = null,Object? actualDelivery = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,orderId: null == orderId ? _self.orderId : orderId // ignore: cast_nullable_to_non_nullable
as String,transporterId: null == transporterId ? _self.transporterId : transporterId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ShipmentStatus,pickupAddress: null == pickupAddress ? _self.pickupAddress : pickupAddress // ignore: cast_nullable_to_non_nullable
as ShipmentAddress,deliveryAddress: null == deliveryAddress ? _self.deliveryAddress : deliveryAddress // ignore: cast_nullable_to_non_nullable
as ShipmentAddress,statusHistory: null == statusHistory ? _self.statusHistory : statusHistory // ignore: cast_nullable_to_non_nullable
as List<ShipmentStatusUpdate>,estimatedDelivery: null == estimatedDelivery ? _self.estimatedDelivery : estimatedDelivery // ignore: cast_nullable_to_non_nullable
as DateTime,actualDelivery: freezed == actualDelivery ? _self.actualDelivery : actualDelivery // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}
/// Create a copy of Shipment
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ShipmentAddressCopyWith<$Res> get pickupAddress {
  
  return $ShipmentAddressCopyWith<$Res>(_self.pickupAddress, (value) {
    return _then(_self.copyWith(pickupAddress: value));
  });
}/// Create a copy of Shipment
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ShipmentAddressCopyWith<$Res> get deliveryAddress {
  
  return $ShipmentAddressCopyWith<$Res>(_self.deliveryAddress, (value) {
    return _then(_self.copyWith(deliveryAddress: value));
  });
}
}


/// Adds pattern-matching-related methods to [Shipment].
extension ShipmentPatterns on Shipment {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Shipment value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Shipment() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Shipment value)  $default,){
final _that = this;
switch (_that) {
case _Shipment():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Shipment value)?  $default,){
final _that = this;
switch (_that) {
case _Shipment() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: '_id')  String id,  String orderId,  String transporterId,  ShipmentStatus status,  ShipmentAddress pickupAddress,  ShipmentAddress deliveryAddress,  List<ShipmentStatusUpdate> statusHistory,  DateTime estimatedDelivery,  DateTime? actualDelivery,  DateTime createdAt,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Shipment() when $default != null:
return $default(_that.id,_that.orderId,_that.transporterId,_that.status,_that.pickupAddress,_that.deliveryAddress,_that.statusHistory,_that.estimatedDelivery,_that.actualDelivery,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: '_id')  String id,  String orderId,  String transporterId,  ShipmentStatus status,  ShipmentAddress pickupAddress,  ShipmentAddress deliveryAddress,  List<ShipmentStatusUpdate> statusHistory,  DateTime estimatedDelivery,  DateTime? actualDelivery,  DateTime createdAt,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _Shipment():
return $default(_that.id,_that.orderId,_that.transporterId,_that.status,_that.pickupAddress,_that.deliveryAddress,_that.statusHistory,_that.estimatedDelivery,_that.actualDelivery,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: '_id')  String id,  String orderId,  String transporterId,  ShipmentStatus status,  ShipmentAddress pickupAddress,  ShipmentAddress deliveryAddress,  List<ShipmentStatusUpdate> statusHistory,  DateTime estimatedDelivery,  DateTime? actualDelivery,  DateTime createdAt,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _Shipment() when $default != null:
return $default(_that.id,_that.orderId,_that.transporterId,_that.status,_that.pickupAddress,_that.deliveryAddress,_that.statusHistory,_that.estimatedDelivery,_that.actualDelivery,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Shipment implements Shipment {
  const _Shipment({@JsonKey(name: '_id') required this.id, required this.orderId, required this.transporterId, required this.status, required this.pickupAddress, required this.deliveryAddress, required final  List<ShipmentStatusUpdate> statusHistory, required this.estimatedDelivery, this.actualDelivery, required this.createdAt, required this.updatedAt}): _statusHistory = statusHistory;
  factory _Shipment.fromJson(Map<String, dynamic> json) => _$ShipmentFromJson(json);

@override@JsonKey(name: '_id') final  String id;
@override final  String orderId;
@override final  String transporterId;
@override final  ShipmentStatus status;
@override final  ShipmentAddress pickupAddress;
@override final  ShipmentAddress deliveryAddress;
 final  List<ShipmentStatusUpdate> _statusHistory;
@override List<ShipmentStatusUpdate> get statusHistory {
  if (_statusHistory is EqualUnmodifiableListView) return _statusHistory;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_statusHistory);
}

@override final  DateTime estimatedDelivery;
@override final  DateTime? actualDelivery;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;

/// Create a copy of Shipment
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ShipmentCopyWith<_Shipment> get copyWith => __$ShipmentCopyWithImpl<_Shipment>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ShipmentToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Shipment&&(identical(other.id, id) || other.id == id)&&(identical(other.orderId, orderId) || other.orderId == orderId)&&(identical(other.transporterId, transporterId) || other.transporterId == transporterId)&&(identical(other.status, status) || other.status == status)&&(identical(other.pickupAddress, pickupAddress) || other.pickupAddress == pickupAddress)&&(identical(other.deliveryAddress, deliveryAddress) || other.deliveryAddress == deliveryAddress)&&const DeepCollectionEquality().equals(other._statusHistory, _statusHistory)&&(identical(other.estimatedDelivery, estimatedDelivery) || other.estimatedDelivery == estimatedDelivery)&&(identical(other.actualDelivery, actualDelivery) || other.actualDelivery == actualDelivery)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,orderId,transporterId,status,pickupAddress,deliveryAddress,const DeepCollectionEquality().hash(_statusHistory),estimatedDelivery,actualDelivery,createdAt,updatedAt);

@override
String toString() {
  return 'Shipment(id: $id, orderId: $orderId, transporterId: $transporterId, status: $status, pickupAddress: $pickupAddress, deliveryAddress: $deliveryAddress, statusHistory: $statusHistory, estimatedDelivery: $estimatedDelivery, actualDelivery: $actualDelivery, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$ShipmentCopyWith<$Res> implements $ShipmentCopyWith<$Res> {
  factory _$ShipmentCopyWith(_Shipment value, $Res Function(_Shipment) _then) = __$ShipmentCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: '_id') String id, String orderId, String transporterId, ShipmentStatus status, ShipmentAddress pickupAddress, ShipmentAddress deliveryAddress, List<ShipmentStatusUpdate> statusHistory, DateTime estimatedDelivery, DateTime? actualDelivery, DateTime createdAt, DateTime updatedAt
});


@override $ShipmentAddressCopyWith<$Res> get pickupAddress;@override $ShipmentAddressCopyWith<$Res> get deliveryAddress;

}
/// @nodoc
class __$ShipmentCopyWithImpl<$Res>
    implements _$ShipmentCopyWith<$Res> {
  __$ShipmentCopyWithImpl(this._self, this._then);

  final _Shipment _self;
  final $Res Function(_Shipment) _then;

/// Create a copy of Shipment
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? orderId = null,Object? transporterId = null,Object? status = null,Object? pickupAddress = null,Object? deliveryAddress = null,Object? statusHistory = null,Object? estimatedDelivery = null,Object? actualDelivery = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_Shipment(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,orderId: null == orderId ? _self.orderId : orderId // ignore: cast_nullable_to_non_nullable
as String,transporterId: null == transporterId ? _self.transporterId : transporterId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ShipmentStatus,pickupAddress: null == pickupAddress ? _self.pickupAddress : pickupAddress // ignore: cast_nullable_to_non_nullable
as ShipmentAddress,deliveryAddress: null == deliveryAddress ? _self.deliveryAddress : deliveryAddress // ignore: cast_nullable_to_non_nullable
as ShipmentAddress,statusHistory: null == statusHistory ? _self._statusHistory : statusHistory // ignore: cast_nullable_to_non_nullable
as List<ShipmentStatusUpdate>,estimatedDelivery: null == estimatedDelivery ? _self.estimatedDelivery : estimatedDelivery // ignore: cast_nullable_to_non_nullable
as DateTime,actualDelivery: freezed == actualDelivery ? _self.actualDelivery : actualDelivery // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

/// Create a copy of Shipment
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ShipmentAddressCopyWith<$Res> get pickupAddress {
  
  return $ShipmentAddressCopyWith<$Res>(_self.pickupAddress, (value) {
    return _then(_self.copyWith(pickupAddress: value));
  });
}/// Create a copy of Shipment
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ShipmentAddressCopyWith<$Res> get deliveryAddress {
  
  return $ShipmentAddressCopyWith<$Res>(_self.deliveryAddress, (value) {
    return _then(_self.copyWith(deliveryAddress: value));
  });
}
}

// dart format on
