// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_profile.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ProfileUser {

 String get id; String get email; String get role; String? get phone; String? get fullName; String? get avatarUrl; bool get isVerified; bool get isActive;
/// Create a copy of ProfileUser
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProfileUserCopyWith<ProfileUser> get copyWith => _$ProfileUserCopyWithImpl<ProfileUser>(this as ProfileUser, _$identity);

  /// Serializes this ProfileUser to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProfileUser&&(identical(other.id, id) || other.id == id)&&(identical(other.email, email) || other.email == email)&&(identical(other.role, role) || other.role == role)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.isVerified, isVerified) || other.isVerified == isVerified)&&(identical(other.isActive, isActive) || other.isActive == isActive));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,email,role,phone,fullName,avatarUrl,isVerified,isActive);

@override
String toString() {
  return 'ProfileUser(id: $id, email: $email, role: $role, phone: $phone, fullName: $fullName, avatarUrl: $avatarUrl, isVerified: $isVerified, isActive: $isActive)';
}


}

/// @nodoc
abstract mixin class $ProfileUserCopyWith<$Res>  {
  factory $ProfileUserCopyWith(ProfileUser value, $Res Function(ProfileUser) _then) = _$ProfileUserCopyWithImpl;
@useResult
$Res call({
 String id, String email, String role, String? phone, String? fullName, String? avatarUrl, bool isVerified, bool isActive
});




}
/// @nodoc
class _$ProfileUserCopyWithImpl<$Res>
    implements $ProfileUserCopyWith<$Res> {
  _$ProfileUserCopyWithImpl(this._self, this._then);

  final ProfileUser _self;
  final $Res Function(ProfileUser) _then;

/// Create a copy of ProfileUser
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? email = null,Object? role = null,Object? phone = freezed,Object? fullName = freezed,Object? avatarUrl = freezed,Object? isVerified = null,Object? isActive = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,fullName: freezed == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String?,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,isVerified: null == isVerified ? _self.isVerified : isVerified // ignore: cast_nullable_to_non_nullable
as bool,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [ProfileUser].
extension ProfileUserPatterns on ProfileUser {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProfileUser value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProfileUser() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProfileUser value)  $default,){
final _that = this;
switch (_that) {
case _ProfileUser():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProfileUser value)?  $default,){
final _that = this;
switch (_that) {
case _ProfileUser() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String email,  String role,  String? phone,  String? fullName,  String? avatarUrl,  bool isVerified,  bool isActive)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProfileUser() when $default != null:
return $default(_that.id,_that.email,_that.role,_that.phone,_that.fullName,_that.avatarUrl,_that.isVerified,_that.isActive);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String email,  String role,  String? phone,  String? fullName,  String? avatarUrl,  bool isVerified,  bool isActive)  $default,) {final _that = this;
switch (_that) {
case _ProfileUser():
return $default(_that.id,_that.email,_that.role,_that.phone,_that.fullName,_that.avatarUrl,_that.isVerified,_that.isActive);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String email,  String role,  String? phone,  String? fullName,  String? avatarUrl,  bool isVerified,  bool isActive)?  $default,) {final _that = this;
switch (_that) {
case _ProfileUser() when $default != null:
return $default(_that.id,_that.email,_that.role,_that.phone,_that.fullName,_that.avatarUrl,_that.isVerified,_that.isActive);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ProfileUser implements ProfileUser {
  const _ProfileUser({required this.id, required this.email, required this.role, this.phone, this.fullName, this.avatarUrl, this.isVerified = false, this.isActive = true});
  factory _ProfileUser.fromJson(Map<String, dynamic> json) => _$ProfileUserFromJson(json);

@override final  String id;
@override final  String email;
@override final  String role;
@override final  String? phone;
@override final  String? fullName;
@override final  String? avatarUrl;
@override@JsonKey() final  bool isVerified;
@override@JsonKey() final  bool isActive;

/// Create a copy of ProfileUser
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProfileUserCopyWith<_ProfileUser> get copyWith => __$ProfileUserCopyWithImpl<_ProfileUser>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProfileUserToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProfileUser&&(identical(other.id, id) || other.id == id)&&(identical(other.email, email) || other.email == email)&&(identical(other.role, role) || other.role == role)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.isVerified, isVerified) || other.isVerified == isVerified)&&(identical(other.isActive, isActive) || other.isActive == isActive));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,email,role,phone,fullName,avatarUrl,isVerified,isActive);

@override
String toString() {
  return 'ProfileUser(id: $id, email: $email, role: $role, phone: $phone, fullName: $fullName, avatarUrl: $avatarUrl, isVerified: $isVerified, isActive: $isActive)';
}


}

/// @nodoc
abstract mixin class _$ProfileUserCopyWith<$Res> implements $ProfileUserCopyWith<$Res> {
  factory _$ProfileUserCopyWith(_ProfileUser value, $Res Function(_ProfileUser) _then) = __$ProfileUserCopyWithImpl;
@override @useResult
$Res call({
 String id, String email, String role, String? phone, String? fullName, String? avatarUrl, bool isVerified, bool isActive
});




}
/// @nodoc
class __$ProfileUserCopyWithImpl<$Res>
    implements _$ProfileUserCopyWith<$Res> {
  __$ProfileUserCopyWithImpl(this._self, this._then);

  final _ProfileUser _self;
  final $Res Function(_ProfileUser) _then;

/// Create a copy of ProfileUser
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? email = null,Object? role = null,Object? phone = freezed,Object? fullName = freezed,Object? avatarUrl = freezed,Object? isVerified = null,Object? isActive = null,}) {
  return _then(_ProfileUser(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,fullName: freezed == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String?,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,isVerified: null == isVerified ? _self.isVerified : isVerified // ignore: cast_nullable_to_non_nullable
as bool,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$FarmLocationSummary {

 String? get address; String? get city; String? get province; double? get lat; double? get lng; bool get complete;
/// Create a copy of FarmLocationSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FarmLocationSummaryCopyWith<FarmLocationSummary> get copyWith => _$FarmLocationSummaryCopyWithImpl<FarmLocationSummary>(this as FarmLocationSummary, _$identity);

  /// Serializes this FarmLocationSummary to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FarmLocationSummary&&(identical(other.address, address) || other.address == address)&&(identical(other.city, city) || other.city == city)&&(identical(other.province, province) || other.province == province)&&(identical(other.lat, lat) || other.lat == lat)&&(identical(other.lng, lng) || other.lng == lng)&&(identical(other.complete, complete) || other.complete == complete));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,address,city,province,lat,lng,complete);

@override
String toString() {
  return 'FarmLocationSummary(address: $address, city: $city, province: $province, lat: $lat, lng: $lng, complete: $complete)';
}


}

/// @nodoc
abstract mixin class $FarmLocationSummaryCopyWith<$Res>  {
  factory $FarmLocationSummaryCopyWith(FarmLocationSummary value, $Res Function(FarmLocationSummary) _then) = _$FarmLocationSummaryCopyWithImpl;
@useResult
$Res call({
 String? address, String? city, String? province, double? lat, double? lng, bool complete
});




}
/// @nodoc
class _$FarmLocationSummaryCopyWithImpl<$Res>
    implements $FarmLocationSummaryCopyWith<$Res> {
  _$FarmLocationSummaryCopyWithImpl(this._self, this._then);

  final FarmLocationSummary _self;
  final $Res Function(FarmLocationSummary) _then;

/// Create a copy of FarmLocationSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? address = freezed,Object? city = freezed,Object? province = freezed,Object? lat = freezed,Object? lng = freezed,Object? complete = null,}) {
  return _then(_self.copyWith(
address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,city: freezed == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String?,province: freezed == province ? _self.province : province // ignore: cast_nullable_to_non_nullable
as String?,lat: freezed == lat ? _self.lat : lat // ignore: cast_nullable_to_non_nullable
as double?,lng: freezed == lng ? _self.lng : lng // ignore: cast_nullable_to_non_nullable
as double?,complete: null == complete ? _self.complete : complete // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [FarmLocationSummary].
extension FarmLocationSummaryPatterns on FarmLocationSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FarmLocationSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FarmLocationSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FarmLocationSummary value)  $default,){
final _that = this;
switch (_that) {
case _FarmLocationSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FarmLocationSummary value)?  $default,){
final _that = this;
switch (_that) {
case _FarmLocationSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? address,  String? city,  String? province,  double? lat,  double? lng,  bool complete)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FarmLocationSummary() when $default != null:
return $default(_that.address,_that.city,_that.province,_that.lat,_that.lng,_that.complete);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? address,  String? city,  String? province,  double? lat,  double? lng,  bool complete)  $default,) {final _that = this;
switch (_that) {
case _FarmLocationSummary():
return $default(_that.address,_that.city,_that.province,_that.lat,_that.lng,_that.complete);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? address,  String? city,  String? province,  double? lat,  double? lng,  bool complete)?  $default,) {final _that = this;
switch (_that) {
case _FarmLocationSummary() when $default != null:
return $default(_that.address,_that.city,_that.province,_that.lat,_that.lng,_that.complete);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FarmLocationSummary implements FarmLocationSummary {
  const _FarmLocationSummary({this.address, this.city, this.province, this.lat, this.lng, this.complete = false});
  factory _FarmLocationSummary.fromJson(Map<String, dynamic> json) => _$FarmLocationSummaryFromJson(json);

@override final  String? address;
@override final  String? city;
@override final  String? province;
@override final  double? lat;
@override final  double? lng;
@override@JsonKey() final  bool complete;

/// Create a copy of FarmLocationSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FarmLocationSummaryCopyWith<_FarmLocationSummary> get copyWith => __$FarmLocationSummaryCopyWithImpl<_FarmLocationSummary>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FarmLocationSummaryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FarmLocationSummary&&(identical(other.address, address) || other.address == address)&&(identical(other.city, city) || other.city == city)&&(identical(other.province, province) || other.province == province)&&(identical(other.lat, lat) || other.lat == lat)&&(identical(other.lng, lng) || other.lng == lng)&&(identical(other.complete, complete) || other.complete == complete));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,address,city,province,lat,lng,complete);

@override
String toString() {
  return 'FarmLocationSummary(address: $address, city: $city, province: $province, lat: $lat, lng: $lng, complete: $complete)';
}


}

/// @nodoc
abstract mixin class _$FarmLocationSummaryCopyWith<$Res> implements $FarmLocationSummaryCopyWith<$Res> {
  factory _$FarmLocationSummaryCopyWith(_FarmLocationSummary value, $Res Function(_FarmLocationSummary) _then) = __$FarmLocationSummaryCopyWithImpl;
@override @useResult
$Res call({
 String? address, String? city, String? province, double? lat, double? lng, bool complete
});




}
/// @nodoc
class __$FarmLocationSummaryCopyWithImpl<$Res>
    implements _$FarmLocationSummaryCopyWith<$Res> {
  __$FarmLocationSummaryCopyWithImpl(this._self, this._then);

  final _FarmLocationSummary _self;
  final $Res Function(_FarmLocationSummary) _then;

/// Create a copy of FarmLocationSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? address = freezed,Object? city = freezed,Object? province = freezed,Object? lat = freezed,Object? lng = freezed,Object? complete = null,}) {
  return _then(_FarmLocationSummary(
address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,city: freezed == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String?,province: freezed == province ? _self.province : province // ignore: cast_nullable_to_non_nullable
as String?,lat: freezed == lat ? _self.lat : lat // ignore: cast_nullable_to_non_nullable
as double?,lng: freezed == lng ? _self.lng : lng // ignore: cast_nullable_to_non_nullable
as double?,complete: null == complete ? _self.complete : complete // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

ProfileDetails _$ProfileDetailsFromJson(
  Map<String, dynamic> json
) {
        switch (json['kind']) {
                  case 'buyer':
          return BuyerProfileDetails.fromJson(
            json
          );
                case 'farmer':
          return FarmerProfileDetails.fromJson(
            json
          );
                case 'transporter':
          return TransporterProfileDetails.fromJson(
            json
          );
        
          default:
            return OtherProfileDetails.fromJson(
  json
);
        }
      
}

/// @nodoc
mixin _$ProfileDetails {

 String? get cnicMasked;
/// Create a copy of ProfileDetails
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProfileDetailsCopyWith<ProfileDetails> get copyWith => _$ProfileDetailsCopyWithImpl<ProfileDetails>(this as ProfileDetails, _$identity);

  /// Serializes this ProfileDetails to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProfileDetails&&(identical(other.cnicMasked, cnicMasked) || other.cnicMasked == cnicMasked));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,cnicMasked);

@override
String toString() {
  return 'ProfileDetails(cnicMasked: $cnicMasked)';
}


}

/// @nodoc
abstract mixin class $ProfileDetailsCopyWith<$Res>  {
  factory $ProfileDetailsCopyWith(ProfileDetails value, $Res Function(ProfileDetails) _then) = _$ProfileDetailsCopyWithImpl;
@useResult
$Res call({
 String? cnicMasked
});




}
/// @nodoc
class _$ProfileDetailsCopyWithImpl<$Res>
    implements $ProfileDetailsCopyWith<$Res> {
  _$ProfileDetailsCopyWithImpl(this._self, this._then);

  final ProfileDetails _self;
  final $Res Function(ProfileDetails) _then;

/// Create a copy of ProfileDetails
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? cnicMasked = freezed,}) {
  return _then(_self.copyWith(
cnicMasked: freezed == cnicMasked ? _self.cnicMasked : cnicMasked // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ProfileDetails].
extension ProfileDetailsPatterns on ProfileDetails {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( BuyerProfileDetails value)?  buyer,TResult Function( FarmerProfileDetails value)?  farmer,TResult Function( TransporterProfileDetails value)?  transporter,TResult Function( OtherProfileDetails value)?  other,required TResult orElse(),}){
final _that = this;
switch (_that) {
case BuyerProfileDetails() when buyer != null:
return buyer(_that);case FarmerProfileDetails() when farmer != null:
return farmer(_that);case TransporterProfileDetails() when transporter != null:
return transporter(_that);case OtherProfileDetails() when other != null:
return other(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( BuyerProfileDetails value)  buyer,required TResult Function( FarmerProfileDetails value)  farmer,required TResult Function( TransporterProfileDetails value)  transporter,required TResult Function( OtherProfileDetails value)  other,}){
final _that = this;
switch (_that) {
case BuyerProfileDetails():
return buyer(_that);case FarmerProfileDetails():
return farmer(_that);case TransporterProfileDetails():
return transporter(_that);case OtherProfileDetails():
return other(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( BuyerProfileDetails value)?  buyer,TResult? Function( FarmerProfileDetails value)?  farmer,TResult? Function( TransporterProfileDetails value)?  transporter,TResult? Function( OtherProfileDetails value)?  other,}){
final _that = this;
switch (_that) {
case BuyerProfileDetails() when buyer != null:
return buyer(_that);case FarmerProfileDetails() when farmer != null:
return farmer(_that);case TransporterProfileDetails() when transporter != null:
return transporter(_that);case OtherProfileDetails() when other != null:
return other(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String? cnicMasked,  String? businessName,  String? businessType)?  buyer,TResult Function( String? cnicMasked,  String? farmName,  List<String> cropTypes,  double? landSizeAcres,  FarmLocationSummary? farmLocation)?  farmer,TResult Function( String? cnicMasked,  String? vehicleType,  String? vehicleNumber,  List<String> serviceAreas)?  transporter,TResult Function( String? cnicMasked,  String? institutionName,  String? institutionType)?  other,required TResult orElse(),}) {final _that = this;
switch (_that) {
case BuyerProfileDetails() when buyer != null:
return buyer(_that.cnicMasked,_that.businessName,_that.businessType);case FarmerProfileDetails() when farmer != null:
return farmer(_that.cnicMasked,_that.farmName,_that.cropTypes,_that.landSizeAcres,_that.farmLocation);case TransporterProfileDetails() when transporter != null:
return transporter(_that.cnicMasked,_that.vehicleType,_that.vehicleNumber,_that.serviceAreas);case OtherProfileDetails() when other != null:
return other(_that.cnicMasked,_that.institutionName,_that.institutionType);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String? cnicMasked,  String? businessName,  String? businessType)  buyer,required TResult Function( String? cnicMasked,  String? farmName,  List<String> cropTypes,  double? landSizeAcres,  FarmLocationSummary? farmLocation)  farmer,required TResult Function( String? cnicMasked,  String? vehicleType,  String? vehicleNumber,  List<String> serviceAreas)  transporter,required TResult Function( String? cnicMasked,  String? institutionName,  String? institutionType)  other,}) {final _that = this;
switch (_that) {
case BuyerProfileDetails():
return buyer(_that.cnicMasked,_that.businessName,_that.businessType);case FarmerProfileDetails():
return farmer(_that.cnicMasked,_that.farmName,_that.cropTypes,_that.landSizeAcres,_that.farmLocation);case TransporterProfileDetails():
return transporter(_that.cnicMasked,_that.vehicleType,_that.vehicleNumber,_that.serviceAreas);case OtherProfileDetails():
return other(_that.cnicMasked,_that.institutionName,_that.institutionType);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String? cnicMasked,  String? businessName,  String? businessType)?  buyer,TResult? Function( String? cnicMasked,  String? farmName,  List<String> cropTypes,  double? landSizeAcres,  FarmLocationSummary? farmLocation)?  farmer,TResult? Function( String? cnicMasked,  String? vehicleType,  String? vehicleNumber,  List<String> serviceAreas)?  transporter,TResult? Function( String? cnicMasked,  String? institutionName,  String? institutionType)?  other,}) {final _that = this;
switch (_that) {
case BuyerProfileDetails() when buyer != null:
return buyer(_that.cnicMasked,_that.businessName,_that.businessType);case FarmerProfileDetails() when farmer != null:
return farmer(_that.cnicMasked,_that.farmName,_that.cropTypes,_that.landSizeAcres,_that.farmLocation);case TransporterProfileDetails() when transporter != null:
return transporter(_that.cnicMasked,_that.vehicleType,_that.vehicleNumber,_that.serviceAreas);case OtherProfileDetails() when other != null:
return other(_that.cnicMasked,_that.institutionName,_that.institutionType);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class BuyerProfileDetails implements ProfileDetails {
  const BuyerProfileDetails({this.cnicMasked, this.businessName, this.businessType, final  String? $type}): $type = $type ?? 'buyer';
  factory BuyerProfileDetails.fromJson(Map<String, dynamic> json) => _$BuyerProfileDetailsFromJson(json);

@override final  String? cnicMasked;
 final  String? businessName;
 final  String? businessType;

@JsonKey(name: 'kind')
final String $type;


/// Create a copy of ProfileDetails
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BuyerProfileDetailsCopyWith<BuyerProfileDetails> get copyWith => _$BuyerProfileDetailsCopyWithImpl<BuyerProfileDetails>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BuyerProfileDetailsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BuyerProfileDetails&&(identical(other.cnicMasked, cnicMasked) || other.cnicMasked == cnicMasked)&&(identical(other.businessName, businessName) || other.businessName == businessName)&&(identical(other.businessType, businessType) || other.businessType == businessType));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,cnicMasked,businessName,businessType);

@override
String toString() {
  return 'ProfileDetails.buyer(cnicMasked: $cnicMasked, businessName: $businessName, businessType: $businessType)';
}


}

/// @nodoc
abstract mixin class $BuyerProfileDetailsCopyWith<$Res> implements $ProfileDetailsCopyWith<$Res> {
  factory $BuyerProfileDetailsCopyWith(BuyerProfileDetails value, $Res Function(BuyerProfileDetails) _then) = _$BuyerProfileDetailsCopyWithImpl;
@override @useResult
$Res call({
 String? cnicMasked, String? businessName, String? businessType
});




}
/// @nodoc
class _$BuyerProfileDetailsCopyWithImpl<$Res>
    implements $BuyerProfileDetailsCopyWith<$Res> {
  _$BuyerProfileDetailsCopyWithImpl(this._self, this._then);

  final BuyerProfileDetails _self;
  final $Res Function(BuyerProfileDetails) _then;

/// Create a copy of ProfileDetails
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? cnicMasked = freezed,Object? businessName = freezed,Object? businessType = freezed,}) {
  return _then(BuyerProfileDetails(
cnicMasked: freezed == cnicMasked ? _self.cnicMasked : cnicMasked // ignore: cast_nullable_to_non_nullable
as String?,businessName: freezed == businessName ? _self.businessName : businessName // ignore: cast_nullable_to_non_nullable
as String?,businessType: freezed == businessType ? _self.businessType : businessType // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
@JsonSerializable()

class FarmerProfileDetails implements ProfileDetails {
  const FarmerProfileDetails({this.cnicMasked, this.farmName, final  List<String> cropTypes = const <String>[], this.landSizeAcres, this.farmLocation, final  String? $type}): _cropTypes = cropTypes,$type = $type ?? 'farmer';
  factory FarmerProfileDetails.fromJson(Map<String, dynamic> json) => _$FarmerProfileDetailsFromJson(json);

@override final  String? cnicMasked;
 final  String? farmName;
 final  List<String> _cropTypes;
@JsonKey() List<String> get cropTypes {
  if (_cropTypes is EqualUnmodifiableListView) return _cropTypes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_cropTypes);
}

 final  double? landSizeAcres;
 final  FarmLocationSummary? farmLocation;

@JsonKey(name: 'kind')
final String $type;


/// Create a copy of ProfileDetails
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FarmerProfileDetailsCopyWith<FarmerProfileDetails> get copyWith => _$FarmerProfileDetailsCopyWithImpl<FarmerProfileDetails>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FarmerProfileDetailsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FarmerProfileDetails&&(identical(other.cnicMasked, cnicMasked) || other.cnicMasked == cnicMasked)&&(identical(other.farmName, farmName) || other.farmName == farmName)&&const DeepCollectionEquality().equals(other._cropTypes, _cropTypes)&&(identical(other.landSizeAcres, landSizeAcres) || other.landSizeAcres == landSizeAcres)&&(identical(other.farmLocation, farmLocation) || other.farmLocation == farmLocation));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,cnicMasked,farmName,const DeepCollectionEquality().hash(_cropTypes),landSizeAcres,farmLocation);

@override
String toString() {
  return 'ProfileDetails.farmer(cnicMasked: $cnicMasked, farmName: $farmName, cropTypes: $cropTypes, landSizeAcres: $landSizeAcres, farmLocation: $farmLocation)';
}


}

/// @nodoc
abstract mixin class $FarmerProfileDetailsCopyWith<$Res> implements $ProfileDetailsCopyWith<$Res> {
  factory $FarmerProfileDetailsCopyWith(FarmerProfileDetails value, $Res Function(FarmerProfileDetails) _then) = _$FarmerProfileDetailsCopyWithImpl;
@override @useResult
$Res call({
 String? cnicMasked, String? farmName, List<String> cropTypes, double? landSizeAcres, FarmLocationSummary? farmLocation
});


$FarmLocationSummaryCopyWith<$Res>? get farmLocation;

}
/// @nodoc
class _$FarmerProfileDetailsCopyWithImpl<$Res>
    implements $FarmerProfileDetailsCopyWith<$Res> {
  _$FarmerProfileDetailsCopyWithImpl(this._self, this._then);

  final FarmerProfileDetails _self;
  final $Res Function(FarmerProfileDetails) _then;

/// Create a copy of ProfileDetails
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? cnicMasked = freezed,Object? farmName = freezed,Object? cropTypes = null,Object? landSizeAcres = freezed,Object? farmLocation = freezed,}) {
  return _then(FarmerProfileDetails(
cnicMasked: freezed == cnicMasked ? _self.cnicMasked : cnicMasked // ignore: cast_nullable_to_non_nullable
as String?,farmName: freezed == farmName ? _self.farmName : farmName // ignore: cast_nullable_to_non_nullable
as String?,cropTypes: null == cropTypes ? _self._cropTypes : cropTypes // ignore: cast_nullable_to_non_nullable
as List<String>,landSizeAcres: freezed == landSizeAcres ? _self.landSizeAcres : landSizeAcres // ignore: cast_nullable_to_non_nullable
as double?,farmLocation: freezed == farmLocation ? _self.farmLocation : farmLocation // ignore: cast_nullable_to_non_nullable
as FarmLocationSummary?,
  ));
}

/// Create a copy of ProfileDetails
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FarmLocationSummaryCopyWith<$Res>? get farmLocation {
    if (_self.farmLocation == null) {
    return null;
  }

  return $FarmLocationSummaryCopyWith<$Res>(_self.farmLocation!, (value) {
    return _then(_self.copyWith(farmLocation: value));
  });
}
}

/// @nodoc
@JsonSerializable()

class TransporterProfileDetails implements ProfileDetails {
  const TransporterProfileDetails({this.cnicMasked, this.vehicleType, this.vehicleNumber, final  List<String> serviceAreas = const <String>[], final  String? $type}): _serviceAreas = serviceAreas,$type = $type ?? 'transporter';
  factory TransporterProfileDetails.fromJson(Map<String, dynamic> json) => _$TransporterProfileDetailsFromJson(json);

@override final  String? cnicMasked;
 final  String? vehicleType;
 final  String? vehicleNumber;
 final  List<String> _serviceAreas;
@JsonKey() List<String> get serviceAreas {
  if (_serviceAreas is EqualUnmodifiableListView) return _serviceAreas;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_serviceAreas);
}


@JsonKey(name: 'kind')
final String $type;


/// Create a copy of ProfileDetails
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TransporterProfileDetailsCopyWith<TransporterProfileDetails> get copyWith => _$TransporterProfileDetailsCopyWithImpl<TransporterProfileDetails>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TransporterProfileDetailsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TransporterProfileDetails&&(identical(other.cnicMasked, cnicMasked) || other.cnicMasked == cnicMasked)&&(identical(other.vehicleType, vehicleType) || other.vehicleType == vehicleType)&&(identical(other.vehicleNumber, vehicleNumber) || other.vehicleNumber == vehicleNumber)&&const DeepCollectionEquality().equals(other._serviceAreas, _serviceAreas));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,cnicMasked,vehicleType,vehicleNumber,const DeepCollectionEquality().hash(_serviceAreas));

@override
String toString() {
  return 'ProfileDetails.transporter(cnicMasked: $cnicMasked, vehicleType: $vehicleType, vehicleNumber: $vehicleNumber, serviceAreas: $serviceAreas)';
}


}

/// @nodoc
abstract mixin class $TransporterProfileDetailsCopyWith<$Res> implements $ProfileDetailsCopyWith<$Res> {
  factory $TransporterProfileDetailsCopyWith(TransporterProfileDetails value, $Res Function(TransporterProfileDetails) _then) = _$TransporterProfileDetailsCopyWithImpl;
@override @useResult
$Res call({
 String? cnicMasked, String? vehicleType, String? vehicleNumber, List<String> serviceAreas
});




}
/// @nodoc
class _$TransporterProfileDetailsCopyWithImpl<$Res>
    implements $TransporterProfileDetailsCopyWith<$Res> {
  _$TransporterProfileDetailsCopyWithImpl(this._self, this._then);

  final TransporterProfileDetails _self;
  final $Res Function(TransporterProfileDetails) _then;

/// Create a copy of ProfileDetails
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? cnicMasked = freezed,Object? vehicleType = freezed,Object? vehicleNumber = freezed,Object? serviceAreas = null,}) {
  return _then(TransporterProfileDetails(
cnicMasked: freezed == cnicMasked ? _self.cnicMasked : cnicMasked // ignore: cast_nullable_to_non_nullable
as String?,vehicleType: freezed == vehicleType ? _self.vehicleType : vehicleType // ignore: cast_nullable_to_non_nullable
as String?,vehicleNumber: freezed == vehicleNumber ? _self.vehicleNumber : vehicleNumber // ignore: cast_nullable_to_non_nullable
as String?,serviceAreas: null == serviceAreas ? _self._serviceAreas : serviceAreas // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

/// @nodoc
@JsonSerializable()

class OtherProfileDetails implements ProfileDetails {
  const OtherProfileDetails({this.cnicMasked, this.institutionName, this.institutionType, final  String? $type}): $type = $type ?? 'other';
  factory OtherProfileDetails.fromJson(Map<String, dynamic> json) => _$OtherProfileDetailsFromJson(json);

@override final  String? cnicMasked;
 final  String? institutionName;
 final  String? institutionType;

@JsonKey(name: 'kind')
final String $type;


/// Create a copy of ProfileDetails
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OtherProfileDetailsCopyWith<OtherProfileDetails> get copyWith => _$OtherProfileDetailsCopyWithImpl<OtherProfileDetails>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OtherProfileDetailsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OtherProfileDetails&&(identical(other.cnicMasked, cnicMasked) || other.cnicMasked == cnicMasked)&&(identical(other.institutionName, institutionName) || other.institutionName == institutionName)&&(identical(other.institutionType, institutionType) || other.institutionType == institutionType));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,cnicMasked,institutionName,institutionType);

@override
String toString() {
  return 'ProfileDetails.other(cnicMasked: $cnicMasked, institutionName: $institutionName, institutionType: $institutionType)';
}


}

/// @nodoc
abstract mixin class $OtherProfileDetailsCopyWith<$Res> implements $ProfileDetailsCopyWith<$Res> {
  factory $OtherProfileDetailsCopyWith(OtherProfileDetails value, $Res Function(OtherProfileDetails) _then) = _$OtherProfileDetailsCopyWithImpl;
@override @useResult
$Res call({
 String? cnicMasked, String? institutionName, String? institutionType
});




}
/// @nodoc
class _$OtherProfileDetailsCopyWithImpl<$Res>
    implements $OtherProfileDetailsCopyWith<$Res> {
  _$OtherProfileDetailsCopyWithImpl(this._self, this._then);

  final OtherProfileDetails _self;
  final $Res Function(OtherProfileDetails) _then;

/// Create a copy of ProfileDetails
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? cnicMasked = freezed,Object? institutionName = freezed,Object? institutionType = freezed,}) {
  return _then(OtherProfileDetails(
cnicMasked: freezed == cnicMasked ? _self.cnicMasked : cnicMasked // ignore: cast_nullable_to_non_nullable
as String?,institutionName: freezed == institutionName ? _self.institutionName : institutionName // ignore: cast_nullable_to_non_nullable
as String?,institutionType: freezed == institutionType ? _self.institutionType : institutionType // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$UserProfile {

 ProfileUser get user; String get displayName; ProfileDetails get profile;
/// Create a copy of UserProfile
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserProfileCopyWith<UserProfile> get copyWith => _$UserProfileCopyWithImpl<UserProfile>(this as UserProfile, _$identity);

  /// Serializes this UserProfile to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserProfile&&(identical(other.user, user) || other.user == user)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.profile, profile) || other.profile == profile));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,user,displayName,profile);

@override
String toString() {
  return 'UserProfile(user: $user, displayName: $displayName, profile: $profile)';
}


}

/// @nodoc
abstract mixin class $UserProfileCopyWith<$Res>  {
  factory $UserProfileCopyWith(UserProfile value, $Res Function(UserProfile) _then) = _$UserProfileCopyWithImpl;
@useResult
$Res call({
 ProfileUser user, String displayName, ProfileDetails profile
});


$ProfileUserCopyWith<$Res> get user;$ProfileDetailsCopyWith<$Res> get profile;

}
/// @nodoc
class _$UserProfileCopyWithImpl<$Res>
    implements $UserProfileCopyWith<$Res> {
  _$UserProfileCopyWithImpl(this._self, this._then);

  final UserProfile _self;
  final $Res Function(UserProfile) _then;

/// Create a copy of UserProfile
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? user = null,Object? displayName = null,Object? profile = null,}) {
  return _then(_self.copyWith(
user: null == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as ProfileUser,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,profile: null == profile ? _self.profile : profile // ignore: cast_nullable_to_non_nullable
as ProfileDetails,
  ));
}
/// Create a copy of UserProfile
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProfileUserCopyWith<$Res> get user {
  
  return $ProfileUserCopyWith<$Res>(_self.user, (value) {
    return _then(_self.copyWith(user: value));
  });
}/// Create a copy of UserProfile
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProfileDetailsCopyWith<$Res> get profile {
  
  return $ProfileDetailsCopyWith<$Res>(_self.profile, (value) {
    return _then(_self.copyWith(profile: value));
  });
}
}


/// Adds pattern-matching-related methods to [UserProfile].
extension UserProfilePatterns on UserProfile {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserProfile value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserProfile() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserProfile value)  $default,){
final _that = this;
switch (_that) {
case _UserProfile():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserProfile value)?  $default,){
final _that = this;
switch (_that) {
case _UserProfile() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ProfileUser user,  String displayName,  ProfileDetails profile)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserProfile() when $default != null:
return $default(_that.user,_that.displayName,_that.profile);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ProfileUser user,  String displayName,  ProfileDetails profile)  $default,) {final _that = this;
switch (_that) {
case _UserProfile():
return $default(_that.user,_that.displayName,_that.profile);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ProfileUser user,  String displayName,  ProfileDetails profile)?  $default,) {final _that = this;
switch (_that) {
case _UserProfile() when $default != null:
return $default(_that.user,_that.displayName,_that.profile);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UserProfile implements UserProfile {
  const _UserProfile({required this.user, required this.displayName, required this.profile});
  factory _UserProfile.fromJson(Map<String, dynamic> json) => _$UserProfileFromJson(json);

@override final  ProfileUser user;
@override final  String displayName;
@override final  ProfileDetails profile;

/// Create a copy of UserProfile
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserProfileCopyWith<_UserProfile> get copyWith => __$UserProfileCopyWithImpl<_UserProfile>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserProfileToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserProfile&&(identical(other.user, user) || other.user == user)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.profile, profile) || other.profile == profile));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,user,displayName,profile);

@override
String toString() {
  return 'UserProfile(user: $user, displayName: $displayName, profile: $profile)';
}


}

/// @nodoc
abstract mixin class _$UserProfileCopyWith<$Res> implements $UserProfileCopyWith<$Res> {
  factory _$UserProfileCopyWith(_UserProfile value, $Res Function(_UserProfile) _then) = __$UserProfileCopyWithImpl;
@override @useResult
$Res call({
 ProfileUser user, String displayName, ProfileDetails profile
});


@override $ProfileUserCopyWith<$Res> get user;@override $ProfileDetailsCopyWith<$Res> get profile;

}
/// @nodoc
class __$UserProfileCopyWithImpl<$Res>
    implements _$UserProfileCopyWith<$Res> {
  __$UserProfileCopyWithImpl(this._self, this._then);

  final _UserProfile _self;
  final $Res Function(_UserProfile) _then;

/// Create a copy of UserProfile
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? user = null,Object? displayName = null,Object? profile = null,}) {
  return _then(_UserProfile(
user: null == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as ProfileUser,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,profile: null == profile ? _self.profile : profile // ignore: cast_nullable_to_non_nullable
as ProfileDetails,
  ));
}

/// Create a copy of UserProfile
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProfileUserCopyWith<$Res> get user {
  
  return $ProfileUserCopyWith<$Res>(_self.user, (value) {
    return _then(_self.copyWith(user: value));
  });
}/// Create a copy of UserProfile
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProfileDetailsCopyWith<$Res> get profile {
  
  return $ProfileDetailsCopyWith<$Res>(_self.profile, (value) {
    return _then(_self.copyWith(profile: value));
  });
}
}


/// @nodoc
mixin _$ProfileUpdate {

 String? get fullName; String? get phone; String? get businessName; String? get businessType; String? get farmName; List<String>? get cropTypes; double? get landSizeAcres; String? get vehicleType; String? get vehicleNumber; List<String>? get serviceAreas;
/// Create a copy of ProfileUpdate
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProfileUpdateCopyWith<ProfileUpdate> get copyWith => _$ProfileUpdateCopyWithImpl<ProfileUpdate>(this as ProfileUpdate, _$identity);

  /// Serializes this ProfileUpdate to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProfileUpdate&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.businessName, businessName) || other.businessName == businessName)&&(identical(other.businessType, businessType) || other.businessType == businessType)&&(identical(other.farmName, farmName) || other.farmName == farmName)&&const DeepCollectionEquality().equals(other.cropTypes, cropTypes)&&(identical(other.landSizeAcres, landSizeAcres) || other.landSizeAcres == landSizeAcres)&&(identical(other.vehicleType, vehicleType) || other.vehicleType == vehicleType)&&(identical(other.vehicleNumber, vehicleNumber) || other.vehicleNumber == vehicleNumber)&&const DeepCollectionEquality().equals(other.serviceAreas, serviceAreas));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,fullName,phone,businessName,businessType,farmName,const DeepCollectionEquality().hash(cropTypes),landSizeAcres,vehicleType,vehicleNumber,const DeepCollectionEquality().hash(serviceAreas));

@override
String toString() {
  return 'ProfileUpdate(fullName: $fullName, phone: $phone, businessName: $businessName, businessType: $businessType, farmName: $farmName, cropTypes: $cropTypes, landSizeAcres: $landSizeAcres, vehicleType: $vehicleType, vehicleNumber: $vehicleNumber, serviceAreas: $serviceAreas)';
}


}

/// @nodoc
abstract mixin class $ProfileUpdateCopyWith<$Res>  {
  factory $ProfileUpdateCopyWith(ProfileUpdate value, $Res Function(ProfileUpdate) _then) = _$ProfileUpdateCopyWithImpl;
@useResult
$Res call({
 String? fullName, String? phone, String? businessName, String? businessType, String? farmName, List<String>? cropTypes, double? landSizeAcres, String? vehicleType, String? vehicleNumber, List<String>? serviceAreas
});




}
/// @nodoc
class _$ProfileUpdateCopyWithImpl<$Res>
    implements $ProfileUpdateCopyWith<$Res> {
  _$ProfileUpdateCopyWithImpl(this._self, this._then);

  final ProfileUpdate _self;
  final $Res Function(ProfileUpdate) _then;

/// Create a copy of ProfileUpdate
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? fullName = freezed,Object? phone = freezed,Object? businessName = freezed,Object? businessType = freezed,Object? farmName = freezed,Object? cropTypes = freezed,Object? landSizeAcres = freezed,Object? vehicleType = freezed,Object? vehicleNumber = freezed,Object? serviceAreas = freezed,}) {
  return _then(_self.copyWith(
fullName: freezed == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,businessName: freezed == businessName ? _self.businessName : businessName // ignore: cast_nullable_to_non_nullable
as String?,businessType: freezed == businessType ? _self.businessType : businessType // ignore: cast_nullable_to_non_nullable
as String?,farmName: freezed == farmName ? _self.farmName : farmName // ignore: cast_nullable_to_non_nullable
as String?,cropTypes: freezed == cropTypes ? _self.cropTypes : cropTypes // ignore: cast_nullable_to_non_nullable
as List<String>?,landSizeAcres: freezed == landSizeAcres ? _self.landSizeAcres : landSizeAcres // ignore: cast_nullable_to_non_nullable
as double?,vehicleType: freezed == vehicleType ? _self.vehicleType : vehicleType // ignore: cast_nullable_to_non_nullable
as String?,vehicleNumber: freezed == vehicleNumber ? _self.vehicleNumber : vehicleNumber // ignore: cast_nullable_to_non_nullable
as String?,serviceAreas: freezed == serviceAreas ? _self.serviceAreas : serviceAreas // ignore: cast_nullable_to_non_nullable
as List<String>?,
  ));
}

}


/// Adds pattern-matching-related methods to [ProfileUpdate].
extension ProfileUpdatePatterns on ProfileUpdate {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProfileUpdate value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProfileUpdate() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProfileUpdate value)  $default,){
final _that = this;
switch (_that) {
case _ProfileUpdate():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProfileUpdate value)?  $default,){
final _that = this;
switch (_that) {
case _ProfileUpdate() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? fullName,  String? phone,  String? businessName,  String? businessType,  String? farmName,  List<String>? cropTypes,  double? landSizeAcres,  String? vehicleType,  String? vehicleNumber,  List<String>? serviceAreas)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProfileUpdate() when $default != null:
return $default(_that.fullName,_that.phone,_that.businessName,_that.businessType,_that.farmName,_that.cropTypes,_that.landSizeAcres,_that.vehicleType,_that.vehicleNumber,_that.serviceAreas);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? fullName,  String? phone,  String? businessName,  String? businessType,  String? farmName,  List<String>? cropTypes,  double? landSizeAcres,  String? vehicleType,  String? vehicleNumber,  List<String>? serviceAreas)  $default,) {final _that = this;
switch (_that) {
case _ProfileUpdate():
return $default(_that.fullName,_that.phone,_that.businessName,_that.businessType,_that.farmName,_that.cropTypes,_that.landSizeAcres,_that.vehicleType,_that.vehicleNumber,_that.serviceAreas);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? fullName,  String? phone,  String? businessName,  String? businessType,  String? farmName,  List<String>? cropTypes,  double? landSizeAcres,  String? vehicleType,  String? vehicleNumber,  List<String>? serviceAreas)?  $default,) {final _that = this;
switch (_that) {
case _ProfileUpdate() when $default != null:
return $default(_that.fullName,_that.phone,_that.businessName,_that.businessType,_that.farmName,_that.cropTypes,_that.landSizeAcres,_that.vehicleType,_that.vehicleNumber,_that.serviceAreas);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(includeIfNull: false)
class _ProfileUpdate implements ProfileUpdate {
  const _ProfileUpdate({this.fullName, this.phone, this.businessName, this.businessType, this.farmName, final  List<String>? cropTypes, this.landSizeAcres, this.vehicleType, this.vehicleNumber, final  List<String>? serviceAreas}): _cropTypes = cropTypes,_serviceAreas = serviceAreas;
  factory _ProfileUpdate.fromJson(Map<String, dynamic> json) => _$ProfileUpdateFromJson(json);

@override final  String? fullName;
@override final  String? phone;
@override final  String? businessName;
@override final  String? businessType;
@override final  String? farmName;
 final  List<String>? _cropTypes;
@override List<String>? get cropTypes {
  final value = _cropTypes;
  if (value == null) return null;
  if (_cropTypes is EqualUnmodifiableListView) return _cropTypes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override final  double? landSizeAcres;
@override final  String? vehicleType;
@override final  String? vehicleNumber;
 final  List<String>? _serviceAreas;
@override List<String>? get serviceAreas {
  final value = _serviceAreas;
  if (value == null) return null;
  if (_serviceAreas is EqualUnmodifiableListView) return _serviceAreas;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of ProfileUpdate
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProfileUpdateCopyWith<_ProfileUpdate> get copyWith => __$ProfileUpdateCopyWithImpl<_ProfileUpdate>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProfileUpdateToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProfileUpdate&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.businessName, businessName) || other.businessName == businessName)&&(identical(other.businessType, businessType) || other.businessType == businessType)&&(identical(other.farmName, farmName) || other.farmName == farmName)&&const DeepCollectionEquality().equals(other._cropTypes, _cropTypes)&&(identical(other.landSizeAcres, landSizeAcres) || other.landSizeAcres == landSizeAcres)&&(identical(other.vehicleType, vehicleType) || other.vehicleType == vehicleType)&&(identical(other.vehicleNumber, vehicleNumber) || other.vehicleNumber == vehicleNumber)&&const DeepCollectionEquality().equals(other._serviceAreas, _serviceAreas));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,fullName,phone,businessName,businessType,farmName,const DeepCollectionEquality().hash(_cropTypes),landSizeAcres,vehicleType,vehicleNumber,const DeepCollectionEquality().hash(_serviceAreas));

@override
String toString() {
  return 'ProfileUpdate(fullName: $fullName, phone: $phone, businessName: $businessName, businessType: $businessType, farmName: $farmName, cropTypes: $cropTypes, landSizeAcres: $landSizeAcres, vehicleType: $vehicleType, vehicleNumber: $vehicleNumber, serviceAreas: $serviceAreas)';
}


}

/// @nodoc
abstract mixin class _$ProfileUpdateCopyWith<$Res> implements $ProfileUpdateCopyWith<$Res> {
  factory _$ProfileUpdateCopyWith(_ProfileUpdate value, $Res Function(_ProfileUpdate) _then) = __$ProfileUpdateCopyWithImpl;
@override @useResult
$Res call({
 String? fullName, String? phone, String? businessName, String? businessType, String? farmName, List<String>? cropTypes, double? landSizeAcres, String? vehicleType, String? vehicleNumber, List<String>? serviceAreas
});




}
/// @nodoc
class __$ProfileUpdateCopyWithImpl<$Res>
    implements _$ProfileUpdateCopyWith<$Res> {
  __$ProfileUpdateCopyWithImpl(this._self, this._then);

  final _ProfileUpdate _self;
  final $Res Function(_ProfileUpdate) _then;

/// Create a copy of ProfileUpdate
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? fullName = freezed,Object? phone = freezed,Object? businessName = freezed,Object? businessType = freezed,Object? farmName = freezed,Object? cropTypes = freezed,Object? landSizeAcres = freezed,Object? vehicleType = freezed,Object? vehicleNumber = freezed,Object? serviceAreas = freezed,}) {
  return _then(_ProfileUpdate(
fullName: freezed == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,businessName: freezed == businessName ? _self.businessName : businessName // ignore: cast_nullable_to_non_nullable
as String?,businessType: freezed == businessType ? _self.businessType : businessType // ignore: cast_nullable_to_non_nullable
as String?,farmName: freezed == farmName ? _self.farmName : farmName // ignore: cast_nullable_to_non_nullable
as String?,cropTypes: freezed == cropTypes ? _self._cropTypes : cropTypes // ignore: cast_nullable_to_non_nullable
as List<String>?,landSizeAcres: freezed == landSizeAcres ? _self.landSizeAcres : landSizeAcres // ignore: cast_nullable_to_non_nullable
as double?,vehicleType: freezed == vehicleType ? _self.vehicleType : vehicleType // ignore: cast_nullable_to_non_nullable
as String?,vehicleNumber: freezed == vehicleNumber ? _self.vehicleNumber : vehicleNumber // ignore: cast_nullable_to_non_nullable
as String?,serviceAreas: freezed == serviceAreas ? _self._serviceAreas : serviceAreas // ignore: cast_nullable_to_non_nullable
as List<String>?,
  ));
}


}

// dart format on
