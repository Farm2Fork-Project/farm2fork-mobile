/// Self-service roles a user can choose at onboarding. admin and
/// financial_partner are provisioned by the backend (allowlist), never here.
enum OnboardingRole { farmer, buyer, transporter }

extension OnboardingRolePath on OnboardingRole {
  /// Path segment for POST /auth/firebase/onboard/{role}.
  String get backendPath => switch (this) {
    OnboardingRole.farmer => 'farmer',
    OnboardingRole.buyer => 'buyer',
    OnboardingRole.transporter => 'transporter',
  };
}

/// How the Firebase identity is established for onboarding.
sealed class OnboardingCredential {
  const OnboardingCredential();
}

/// The user already completed Google sign-in; reuse that Firebase session.
class GoogleOnboardingCredential extends OnboardingCredential {
  const GoogleOnboardingCredential();
}

/// Create a new Firebase email/password account as part of onboarding.
class EmailPasswordOnboardingCredential extends OnboardingCredential {
  const EmailPasswordOnboardingCredential({
    required this.email,
    required this.password,
  });

  final String email;
  final String password;
}

/// A completed onboarding form. [toProfileJson] yields the role-specific body
/// (excluding idToken/phone, which the repository adds) for the backend DTO.
sealed class OnboardingRequest {
  const OnboardingRequest({
    required this.credential,
    required this.cnic,
    this.phone,
  });

  final OnboardingCredential credential;
  final String cnic;
  final String? phone;

  OnboardingRole get role;

  Map<String, dynamic> toProfileJson();
}

class FarmerOnboardingRequest extends OnboardingRequest {
  const FarmerOnboardingRequest({
    required super.credential,
    required super.cnic,
    super.phone,
    required this.farmName,
    this.farmLocationAddress,
    this.cropTypes = const [],
    this.landSizeAcres,
    this.bankName,
    this.bankAccountNumber,
    this.bankAccountTitle,
  });

  final String farmName;
  final String? farmLocationAddress;
  final List<String> cropTypes;
  final double? landSizeAcres;
  final String? bankName;
  final String? bankAccountNumber;
  final String? bankAccountTitle;

  @override
  OnboardingRole get role => OnboardingRole.farmer;

  @override
  Map<String, dynamic> toProfileJson() {
    final hasBank =
        (bankName ?? bankAccountNumber ?? bankAccountTitle) != null;
    return {
      'farmName': farmName,
      'cnic': cnic,
      if (farmLocationAddress != null && farmLocationAddress!.isNotEmpty)
        'farmLocation': {'address': farmLocationAddress},
      if (cropTypes.isNotEmpty) 'cropTypes': cropTypes,
      if (landSizeAcres != null) 'landSizeAcres': landSizeAcres,
      if (hasBank)
        'bankAccountDetails': {
          if (bankName != null) 'bankName': bankName,
          if (bankAccountNumber != null) 'accountNumber': bankAccountNumber,
          if (bankAccountTitle != null) 'accountTitle': bankAccountTitle,
        },
    };
  }
}

class BuyerOnboardingRequest extends OnboardingRequest {
  const BuyerOnboardingRequest({
    required super.credential,
    required super.cnic,
    super.phone,
    required this.businessName,
    required this.businessType,
    this.addresses = const [],
  });

  final String businessName;

  /// Backend enum: individual | retailer | restaurant | wholesaler.
  final String businessType;
  final List<Map<String, dynamic>> addresses;

  @override
  OnboardingRole get role => OnboardingRole.buyer;

  @override
  Map<String, dynamic> toProfileJson() => {
    'businessName': businessName,
    'businessType': businessType,
    'cnic': cnic,
    if (addresses.isNotEmpty) 'addresses': addresses,
  };
}

class TransporterOnboardingRequest extends OnboardingRequest {
  const TransporterOnboardingRequest({
    required super.credential,
    required super.cnic,
    super.phone,
    required this.vehicleType,
    required this.vehicleNumber,
    required this.licenseNumber,
    this.serviceAreas = const [],
  });

  /// Backend enum: bike | rickshaw | van | truck.
  final String vehicleType;
  final String vehicleNumber;
  final String licenseNumber;
  final List<String> serviceAreas;

  @override
  OnboardingRole get role => OnboardingRole.transporter;

  @override
  Map<String, dynamic> toProfileJson() => {
    'vehicleType': vehicleType,
    'vehicleNumber': vehicleNumber,
    'licenseNumber': licenseNumber,
    'cnic': cnic,
    if (serviceAreas.isNotEmpty) 'serviceAreas': serviceAreas,
  };
}
