// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ProfileUser _$ProfileUserFromJson(Map<String, dynamic> json) => _ProfileUser(
  id: json['id'] as String,
  email: json['email'] as String,
  role: json['role'] as String,
  phone: json['phone'] as String?,
  fullName: json['fullName'] as String?,
  avatarUrl: json['avatarUrl'] as String?,
  isVerified: json['isVerified'] as bool? ?? false,
  isActive: json['isActive'] as bool? ?? true,
);

Map<String, dynamic> _$ProfileUserToJson(_ProfileUser instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'role': instance.role,
      'phone': instance.phone,
      'fullName': instance.fullName,
      'avatarUrl': instance.avatarUrl,
      'isVerified': instance.isVerified,
      'isActive': instance.isActive,
    };

_FarmLocationSummary _$FarmLocationSummaryFromJson(Map<String, dynamic> json) =>
    _FarmLocationSummary(
      address: json['address'] as String?,
      city: json['city'] as String?,
      province: json['province'] as String?,
      lat: (json['lat'] as num?)?.toDouble(),
      lng: (json['lng'] as num?)?.toDouble(),
      complete: json['complete'] as bool? ?? false,
    );

Map<String, dynamic> _$FarmLocationSummaryToJson(
  _FarmLocationSummary instance,
) => <String, dynamic>{
  'address': instance.address,
  'city': instance.city,
  'province': instance.province,
  'lat': instance.lat,
  'lng': instance.lng,
  'complete': instance.complete,
};

BuyerProfileDetails _$BuyerProfileDetailsFromJson(Map<String, dynamic> json) =>
    BuyerProfileDetails(
      cnicMasked: json['cnicMasked'] as String?,
      businessName: json['businessName'] as String?,
      businessType: json['businessType'] as String?,
      $type: json['kind'] as String?,
    );

Map<String, dynamic> _$BuyerProfileDetailsToJson(
  BuyerProfileDetails instance,
) => <String, dynamic>{
  'cnicMasked': instance.cnicMasked,
  'businessName': instance.businessName,
  'businessType': instance.businessType,
  'kind': instance.$type,
};

FarmerProfileDetails _$FarmerProfileDetailsFromJson(
  Map<String, dynamic> json,
) => FarmerProfileDetails(
  cnicMasked: json['cnicMasked'] as String?,
  farmName: json['farmName'] as String?,
  cropTypes:
      (json['cropTypes'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
  landSizeAcres: (json['landSizeAcres'] as num?)?.toDouble(),
  farmLocation: json['farmLocation'] == null
      ? null
      : FarmLocationSummary.fromJson(
          json['farmLocation'] as Map<String, dynamic>,
        ),
  $type: json['kind'] as String?,
);

Map<String, dynamic> _$FarmerProfileDetailsToJson(
  FarmerProfileDetails instance,
) => <String, dynamic>{
  'cnicMasked': instance.cnicMasked,
  'farmName': instance.farmName,
  'cropTypes': instance.cropTypes,
  'landSizeAcres': instance.landSizeAcres,
  'farmLocation': instance.farmLocation,
  'kind': instance.$type,
};

TransporterProfileDetails _$TransporterProfileDetailsFromJson(
  Map<String, dynamic> json,
) => TransporterProfileDetails(
  cnicMasked: json['cnicMasked'] as String?,
  vehicleType: json['vehicleType'] as String?,
  vehicleNumber: json['vehicleNumber'] as String?,
  serviceAreas:
      (json['serviceAreas'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const <String>[],
  $type: json['kind'] as String?,
);

Map<String, dynamic> _$TransporterProfileDetailsToJson(
  TransporterProfileDetails instance,
) => <String, dynamic>{
  'cnicMasked': instance.cnicMasked,
  'vehicleType': instance.vehicleType,
  'vehicleNumber': instance.vehicleNumber,
  'serviceAreas': instance.serviceAreas,
  'kind': instance.$type,
};

OtherProfileDetails _$OtherProfileDetailsFromJson(Map<String, dynamic> json) =>
    OtherProfileDetails(
      cnicMasked: json['cnicMasked'] as String?,
      institutionName: json['institutionName'] as String?,
      institutionType: json['institutionType'] as String?,
      $type: json['kind'] as String?,
    );

Map<String, dynamic> _$OtherProfileDetailsToJson(
  OtherProfileDetails instance,
) => <String, dynamic>{
  'cnicMasked': instance.cnicMasked,
  'institutionName': instance.institutionName,
  'institutionType': instance.institutionType,
  'kind': instance.$type,
};

_UserProfile _$UserProfileFromJson(Map<String, dynamic> json) => _UserProfile(
  user: ProfileUser.fromJson(json['user'] as Map<String, dynamic>),
  displayName: json['displayName'] as String,
  profile: ProfileDetails.fromJson(json['profile'] as Map<String, dynamic>),
);

Map<String, dynamic> _$UserProfileToJson(_UserProfile instance) =>
    <String, dynamic>{
      'user': instance.user,
      'displayName': instance.displayName,
      'profile': instance.profile,
    };

_ProfileUpdate _$ProfileUpdateFromJson(Map<String, dynamic> json) =>
    _ProfileUpdate(
      fullName: json['fullName'] as String?,
      phone: json['phone'] as String?,
      businessName: json['businessName'] as String?,
      businessType: json['businessType'] as String?,
      farmName: json['farmName'] as String?,
      cropTypes: (json['cropTypes'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      landSizeAcres: (json['landSizeAcres'] as num?)?.toDouble(),
      vehicleType: json['vehicleType'] as String?,
      vehicleNumber: json['vehicleNumber'] as String?,
      serviceAreas: (json['serviceAreas'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$ProfileUpdateToJson(_ProfileUpdate instance) =>
    <String, dynamic>{
      'fullName': ?instance.fullName,
      'phone': ?instance.phone,
      'businessName': ?instance.businessName,
      'businessType': ?instance.businessType,
      'farmName': ?instance.farmName,
      'cropTypes': ?instance.cropTypes,
      'landSizeAcres': ?instance.landSizeAcres,
      'vehicleType': ?instance.vehicleType,
      'vehicleNumber': ?instance.vehicleNumber,
      'serviceAreas': ?instance.serviceAreas,
    };
