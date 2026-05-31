import 'package:farm2fork_mobile/features/auth/data/models/auth_user.dart';

sealed class SignUpRequest {
  const SignUpRequest({
    required this.name,
    required this.email,
    required this.password,
  });
  final String name;
  final String email;
  final String password;
}

class BuyerSignUpRequest extends SignUpRequest {
  const BuyerSignUpRequest({
    required super.name,
    required super.email,
    required super.password,
    this.phone,
  });
  final String? phone;
}

class FarmerSignUpRequest extends SignUpRequest {
  const FarmerSignUpRequest({
    required super.name,
    required super.email,
    required super.password,
    required this.farmName,
    required this.location,
    required this.farmSize,
    required this.cropTypes,
    this.certifications = const [],
  });
  final String farmName;
  final String location;
  final String farmSize;
  final List<String> cropTypes;
  final List<String> certifications;
}

class TransporterSignUpRequest extends SignUpRequest {
  const TransporterSignUpRequest({
    required super.name,
    required super.email,
    required super.password,
    required this.vehicleType,
    required this.vehicleLicense,
    required this.serviceArea,
    this.cnic,
    this.availabilityStatus = 'available',
  });
  final String vehicleType;
  final String vehicleLicense;
  final String serviceArea;
  final String? cnic;
  final String availabilityStatus;
}

abstract class AuthRepository {
  Future<AuthUser?> restoreSession();
  Future<AuthUser> signIn({required String email, required String password});
  Future<AuthUser> signUp({required SignUpRequest request});
  Future<void> signOut();
}
