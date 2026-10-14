import 'package:farm2fork_mobile/core/location/geo_point.dart';
import 'package:farm2fork_mobile/features/auth/data/models/onboarding_request.dart';

/// Every value the stepped sign-up collects, stored as the text the user typed
/// (choice fields hold their backend enum value). Held in [OnboardingSession]
/// so going back, or leaving the flow and returning, keeps what was entered.
enum OnboardingField {
  email,
  password,
  fullName,
  businessName,
  businessType,
  farmName,
  cropTypes,
  landSize,
  address,
  city,
  province,
  vehicleType,
  vehicleNumber,
  licenseNumber,
  serviceAreas,
  cnic,
  phone,
}

enum OnboardingStep { role, account, details, pickup, identity }

class OnboardingDraft {
  const OnboardingDraft({this.role, this.values = const {}, this.farmPin});

  final OnboardingRole? role;
  final Map<OnboardingField, String> values;

  /// Farmers' map pin (not text, so it lives beside [values]).
  final GeoPoint? farmPin;

  String value(OnboardingField field) => values[field] ?? '';

  OnboardingDraft copyWith({
    OnboardingRole? role,
    Map<OnboardingField, String>? values,
    GeoPoint? farmPin,
  }) => OnboardingDraft(
    role: role ?? this.role,
    values: values ?? this.values,
    farmPin: farmPin ?? this.farmPin,
  );
}

/// The steps for [role]: Role -> Account (new email accounts only) -> Details
/// -> Pickup (farmers only) -> Identity. Before a role is chosen the typical
/// length is assumed.
List<OnboardingStep> onboardingStepsFor(
  OnboardingRole? role, {
  required bool needsAccount,
}) => [
  OnboardingStep.role,
  if (needsAccount) OnboardingStep.account,
  OnboardingStep.details,
  if (role == OnboardingRole.farmer) OnboardingStep.pickup,
  OnboardingStep.identity,
];
