import 'dart:convert';
import 'package:farm2fork_mobile/core/error/api_exception.dart';
import 'package:farm2fork_mobile/features/auth/data/models/auth_user.dart';
import 'package:farm2fork_mobile/app/navigation/app_nav_config.dart';
import 'package:farm2fork_mobile/features/profile/data/models/user_profile.dart';
import 'package:farm2fork_mobile/features/profile/data/repositories/profile_repository.dart';

/// In-memory profile for `USE_MOCKS` builds. Seeded from the signed-in mock
/// user; edits and photo changes live until the app restarts.
class MockProfileRepository implements ProfileRepository {
  MockProfileRepository(this._currentUser);

  final AuthUser? Function() _currentUser;
  UserProfile? _profile;

  UserProfile get _current {
    final existing = _profile;
    if (existing != null) return existing;
    final user = _currentUser();
    if (user == null) throw const ApiException(ApiErrorKind.unauthorized);
    return _profile = UserProfile(
      user: ProfileUser(
        id: user.id,
        email: user.email,
        role: AuthUser.roleToBackend(user.role),
        phone: user.phone,
        fullName: user.fullName,
        avatarUrl: user.avatarUrl,
        isVerified: user.isVerified,
        isActive: user.isActive,
      ),
      displayName: user.displayName,
      profile: _detailsFor(user.role),
    );
  }

  ProfileDetails _detailsFor(AppUserRole role) => switch (role) {
    AppUserRole.buyer => const ProfileDetails.buyer(
      cnicMasked: '*********5671',
      businessName: 'Fresh Mart',
      businessType: 'retailer',
    ),
    AppUserRole.farmer => const ProfileDetails.farmer(
      cnicMasked: '*********5671',
      farmName: 'Green Acres',
      cropTypes: ['Wheat', 'Tomatoes'],
      landSizeAcres: 12.5,
      farmLocation: FarmLocationSummary(
        address: 'Chak 5, Canal Road',
        city: 'Multan',
        province: 'Punjab',
        lat: 30.1575,
        lng: 71.5249,
        complete: true,
      ),
    ),
    AppUserRole.transporter => const ProfileDetails.transporter(
      cnicMasked: '*********5671',
      vehicleType: 'van',
      vehicleNumber: 'LEA-1234',
      serviceAreas: ['Lahore', 'Faisalabad'],
    ),
    _ => const ProfileDetails.other(cnicMasked: '*********5671'),
  };

  @override
  Future<UserProfile> fetch() async => _current;

  @override
  Future<UserProfile> update(ProfileUpdate update) async {
    final current = _current;
    final user = current.user.copyWith(
      fullName: update.fullName ?? current.user.fullName,
      phone: update.phone ?? current.user.phone,
    );
    final details = switch (current.profile) {
      final BuyerProfileDetails d => d.copyWith(
        businessName: update.businessName ?? d.businessName,
        businessType: update.businessType ?? d.businessType,
      ),
      final FarmerProfileDetails d => d.copyWith(
        farmName: update.farmName ?? d.farmName,
        cropTypes: update.cropTypes ?? d.cropTypes,
        landSizeAcres: update.landSizeAcres ?? d.landSizeAcres,
      ),
      final TransporterProfileDetails d => d.copyWith(
        vehicleType: update.vehicleType ?? d.vehicleType,
        vehicleNumber: update.vehicleNumber ?? d.vehicleNumber,
        serviceAreas: update.serviceAreas ?? d.serviceAreas,
      ),
      final other => other,
    };
    return _profile = UserProfile(
      user: user,
      displayName: _displayName(user, details),
      profile: details,
    );
  }

  @override
  Future<UserProfile> uploadAvatar(AvatarUpload upload) async {
    final current = _current;
    final url = 'data:image/jpeg;base64,${base64Encode(upload.bytes)}';
    return _profile = UserProfile(
      user: current.user.copyWith(avatarUrl: url),
      displayName: current.displayName,
      profile: current.profile,
    );
  }

  @override
  Future<UserProfile> removeAvatar() async {
    final current = _current;
    return _profile = UserProfile(
      user: current.user.copyWith(avatarUrl: null),
      displayName: current.displayName,
      profile: current.profile,
    );
  }

  String _displayName(ProfileUser user, ProfileDetails details) {
    final name = user.fullName?.trim();
    if (name != null && name.isNotEmpty) return name;
    return switch (details) {
      BuyerProfileDetails(:final businessName?) => businessName,
      FarmerProfileDetails(:final farmName?) => farmName,
      _ => user.email.split('@').first,
    };
  }
}
