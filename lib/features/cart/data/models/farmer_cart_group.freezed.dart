// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'farmer_cart_group.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$FarmerCartGroup {

 String get farmerId; String get farmerName; String get farmName; List<CartItem> get items; CartPricingConfig get pricingConfig;
/// Create a copy of FarmerCartGroup
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FarmerCartGroupCopyWith<FarmerCartGroup> get copyWith => _$FarmerCartGroupCopyWithImpl<FarmerCartGroup>(this as FarmerCartGroup, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FarmerCartGroup&&(identical(other.farmerId, farmerId) || other.farmerId == farmerId)&&(identical(other.farmerName, farmerName) || other.farmerName == farmerName)&&(identical(other.farmName, farmName) || other.farmName == farmName)&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.pricingConfig, pricingConfig) || other.pricingConfig == pricingConfig));
}


@override
int get hashCode => Object.hash(runtimeType,farmerId,farmerName,farmName,const DeepCollectionEquality().hash(items),pricingConfig);

@override
String toString() {
  return 'FarmerCartGroup(farmerId: $farmerId, farmerName: $farmerName, farmName: $farmName, items: $items, pricingConfig: $pricingConfig)';
}


}

/// @nodoc
abstract mixin class $FarmerCartGroupCopyWith<$Res>  {
  factory $FarmerCartGroupCopyWith(FarmerCartGroup value, $Res Function(FarmerCartGroup) _then) = _$FarmerCartGroupCopyWithImpl;
@useResult
$Res call({
 String farmerId, String farmerName, String farmName, List<CartItem> items, CartPricingConfig pricingConfig
});




}
/// @nodoc
class _$FarmerCartGroupCopyWithImpl<$Res>
    implements $FarmerCartGroupCopyWith<$Res> {
  _$FarmerCartGroupCopyWithImpl(this._self, this._then);

  final FarmerCartGroup _self;
  final $Res Function(FarmerCartGroup) _then;

/// Create a copy of FarmerCartGroup
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? farmerId = null,Object? farmerName = null,Object? farmName = null,Object? items = null,Object? pricingConfig = null,}) {
  return _then(_self.copyWith(
farmerId: null == farmerId ? _self.farmerId : farmerId // ignore: cast_nullable_to_non_nullable
as String,farmerName: null == farmerName ? _self.farmerName : farmerName // ignore: cast_nullable_to_non_nullable
as String,farmName: null == farmName ? _self.farmName : farmName // ignore: cast_nullable_to_non_nullable
as String,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<CartItem>,pricingConfig: null == pricingConfig ? _self.pricingConfig : pricingConfig // ignore: cast_nullable_to_non_nullable
as CartPricingConfig,
  ));
}

}


/// Adds pattern-matching-related methods to [FarmerCartGroup].
extension FarmerCartGroupPatterns on FarmerCartGroup {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FarmerCartGroup value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FarmerCartGroup() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FarmerCartGroup value)  $default,){
final _that = this;
switch (_that) {
case _FarmerCartGroup():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FarmerCartGroup value)?  $default,){
final _that = this;
switch (_that) {
case _FarmerCartGroup() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String farmerId,  String farmerName,  String farmName,  List<CartItem> items,  CartPricingConfig pricingConfig)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FarmerCartGroup() when $default != null:
return $default(_that.farmerId,_that.farmerName,_that.farmName,_that.items,_that.pricingConfig);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String farmerId,  String farmerName,  String farmName,  List<CartItem> items,  CartPricingConfig pricingConfig)  $default,) {final _that = this;
switch (_that) {
case _FarmerCartGroup():
return $default(_that.farmerId,_that.farmerName,_that.farmName,_that.items,_that.pricingConfig);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String farmerId,  String farmerName,  String farmName,  List<CartItem> items,  CartPricingConfig pricingConfig)?  $default,) {final _that = this;
switch (_that) {
case _FarmerCartGroup() when $default != null:
return $default(_that.farmerId,_that.farmerName,_that.farmName,_that.items,_that.pricingConfig);case _:
  return null;

}
}

}

/// @nodoc


class _FarmerCartGroup extends FarmerCartGroup {
  const _FarmerCartGroup({required this.farmerId, required this.farmerName, required this.farmName, required final  List<CartItem> items, this.pricingConfig = CartPricingConfig.fallback}): _items = items,super._();
  

@override final  String farmerId;
@override final  String farmerName;
@override final  String farmName;
 final  List<CartItem> _items;
@override List<CartItem> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override@JsonKey() final  CartPricingConfig pricingConfig;

/// Create a copy of FarmerCartGroup
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FarmerCartGroupCopyWith<_FarmerCartGroup> get copyWith => __$FarmerCartGroupCopyWithImpl<_FarmerCartGroup>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FarmerCartGroup&&(identical(other.farmerId, farmerId) || other.farmerId == farmerId)&&(identical(other.farmerName, farmerName) || other.farmerName == farmerName)&&(identical(other.farmName, farmName) || other.farmName == farmName)&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.pricingConfig, pricingConfig) || other.pricingConfig == pricingConfig));
}


@override
int get hashCode => Object.hash(runtimeType,farmerId,farmerName,farmName,const DeepCollectionEquality().hash(_items),pricingConfig);

@override
String toString() {
  return 'FarmerCartGroup(farmerId: $farmerId, farmerName: $farmerName, farmName: $farmName, items: $items, pricingConfig: $pricingConfig)';
}


}

/// @nodoc
abstract mixin class _$FarmerCartGroupCopyWith<$Res> implements $FarmerCartGroupCopyWith<$Res> {
  factory _$FarmerCartGroupCopyWith(_FarmerCartGroup value, $Res Function(_FarmerCartGroup) _then) = __$FarmerCartGroupCopyWithImpl;
@override @useResult
$Res call({
 String farmerId, String farmerName, String farmName, List<CartItem> items, CartPricingConfig pricingConfig
});




}
/// @nodoc
class __$FarmerCartGroupCopyWithImpl<$Res>
    implements _$FarmerCartGroupCopyWith<$Res> {
  __$FarmerCartGroupCopyWithImpl(this._self, this._then);

  final _FarmerCartGroup _self;
  final $Res Function(_FarmerCartGroup) _then;

/// Create a copy of FarmerCartGroup
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? farmerId = null,Object? farmerName = null,Object? farmName = null,Object? items = null,Object? pricingConfig = null,}) {
  return _then(_FarmerCartGroup(
farmerId: null == farmerId ? _self.farmerId : farmerId // ignore: cast_nullable_to_non_nullable
as String,farmerName: null == farmerName ? _self.farmerName : farmerName // ignore: cast_nullable_to_non_nullable
as String,farmName: null == farmName ? _self.farmName : farmName // ignore: cast_nullable_to_non_nullable
as String,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<CartItem>,pricingConfig: null == pricingConfig ? _self.pricingConfig : pricingConfig // ignore: cast_nullable_to_non_nullable
as CartPricingConfig,
  ));
}


}

// dart format on
