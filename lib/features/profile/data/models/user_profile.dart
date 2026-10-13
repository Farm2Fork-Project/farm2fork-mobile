// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_profile.freezed.dart';
part 'user_profile.g.dart';

/// The signed-in user as returned by `GET /auth/me/profile` (`user`).
@freezed
abstract class ProfileUser with _$ProfileUser {
  const factory ProfileUser({
    required String id,
    required String email,
    required String role,
    String? phone,
    String? fullName,
    String? avatarUrl,
    @Default(false) bool isVerified,
    @Default(true) bool isActive,
  }) = _ProfileUser;

  factory ProfileUser.fromJson(Map<String, dynamic> json) =>
      _$ProfileUserFromJson(json);
}

/// Pickup address summary on a farmer profile. Read-only here: it is edited
/// through `PATCH /farmers/me/farm-location`.
@freezed
abstract class FarmLocationSummary with _$FarmLocationSummary {
  const factory FarmLocationSummary({
    String? address,
    String? city,
    String? province,
    double? lat,
    double? lng,
    @Default(false) bool complete,
  }) = _FarmLocationSummary;

  factory FarmLocationSummary.fromJson(Map<String, dynamic> json) =>
      _$FarmLocationSummaryFromJson(json);
}

/// Role-specific details (`profile`), discriminated by `kind`. CNIC only ever
/// arrives masked and is never editable.
@Freezed(unionKey: 'kind', fallbackUnion: 'other')
sealed class ProfileDetails with _$ProfileDetails {
  @FreezedUnionValue('buyer')
  const factory ProfileDetails.buyer({
    String? cnicMasked,
    String? businessName,
    String? businessType,
  }) = BuyerProfileDetails;

  @FreezedUnionValue('farmer')
  const factory ProfileDetails.farmer({
    String? cnicMasked,
    String? farmName,
    @Default(<String>[]) List<String> cropTypes,
    double? landSizeAcres,
    FarmLocationSummary? farmLocation,
  }) = FarmerProfileDetails;

  @FreezedUnionValue('transporter')
  const factory ProfileDetails.transporter({
    String? cnicMasked,
    String? vehicleType,
    String? vehicleNumber,
    @Default(<String>[]) List<String> serviceAreas,
  }) = TransporterProfileDetails;

  /// financial_partner and admin: shown read-only on mobile.
  const factory ProfileDetails.other({
    String? cnicMasked,
    String? institutionName,
    String? institutionType,
  }) = OtherProfileDetails;

  factory ProfileDetails.fromJson(Map<String, dynamic> json) =>
      _$ProfileDetailsFromJson(json);
}

extension ProfileDetailsCnic on ProfileDetails {
  String? get maskedCnic => switch (this) {
    BuyerProfileDetails(:final cnicMasked) => cnicMasked,
    FarmerProfileDetails(:final cnicMasked) => cnicMasked,
    TransporterProfileDetails(:final cnicMasked) => cnicMasked,
    OtherProfileDetails(:final cnicMasked) => cnicMasked,
  };
}

@freezed
abstract class UserProfile with _$UserProfile {
  const factory UserProfile({
    required ProfileUser user,
    required String displayName,
    required ProfileDetails profile,
  }) = _UserProfile;

  factory UserProfile.fromJson(Map<String, dynamic> json) =>
      _$UserProfileFromJson(json);
}

/// Body of `PATCH /auth/me/profile`. Only changed fields are set; the backend
/// rejects fields that belong to another role.
@freezed
abstract class ProfileUpdate with _$ProfileUpdate {
  @JsonSerializable(includeIfNull: false)
  const factory ProfileUpdate({
    String? fullName,
    String? phone,
    String? businessName,
    String? businessType,
    String? farmName,
    List<String>? cropTypes,
    double? landSizeAcres,
    String? vehicleType,
    String? vehicleNumber,
    List<String>? serviceAreas,
  }) = _ProfileUpdate;

  factory ProfileUpdate.fromJson(Map<String, dynamic> json) =>
      _$ProfileUpdateFromJson(json);
}

extension ProfileUpdateX on ProfileUpdate {
  bool get isEmpty => toJson().isEmpty;
}

/// A cropped, compressed photo ready for `PUT /auth/me/avatar`.
class AvatarUpload {
  const AvatarUpload({required this.bytes, this.fileName = 'avatar.jpg'});

  final List<int> bytes;
  final String fileName;
}
