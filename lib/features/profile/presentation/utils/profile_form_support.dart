import 'package:farm2fork_mobile/core/utils/pakistan_identity.dart';
import 'package:farm2fork_mobile/features/profile/data/models/user_profile.dart';

/// Everything the edit form can change, as the text the user sees. Role fields
/// that do not apply to the signed-in role are simply ignored by [diffProfile].
class ProfileFormValues {
  const ProfileFormValues({
    this.fullName = '',
    this.phone = '',
    this.businessName = '',
    this.businessType = '',
    this.farmName = '',
    this.cropTypes = '',
    this.landSize = '',
    this.vehicleType = '',
    this.vehicleNumber = '',
    this.serviceAreas = '',
  });

  final String fullName;
  final String phone;
  final String businessName;
  final String businessType;
  final String farmName;
  final String cropTypes;
  final String landSize;
  final String vehicleType;
  final String vehicleNumber;
  final String serviceAreas;
}

List<String> _splitList(String value) => value
    .split(RegExp(r'[,،]'))
    .map((e) => e.trim())
    .where((e) => e.isNotEmpty)
    .toList(growable: false);

/// The form's starting values for [profile].
ProfileFormValues formValuesFor(UserProfile profile) {
  final user = profile.user;
  final base = ProfileFormValues(
    fullName: user.fullName ?? '',
    phone: user.phone ?? '',
  );
  return switch (profile.profile) {
    BuyerProfileDetails(:final businessName, :final businessType) =>
      ProfileFormValues(
        fullName: base.fullName,
        phone: base.phone,
        businessName: businessName ?? '',
        businessType: businessType ?? 'individual',
      ),
    FarmerProfileDetails(
      :final farmName,
      :final cropTypes,
      :final landSizeAcres,
    ) =>
      ProfileFormValues(
        fullName: base.fullName,
        phone: base.phone,
        farmName: farmName ?? '',
        cropTypes: cropTypes.join(', '),
        landSize: landSizeAcres == null ? '' : _acres(landSizeAcres),
      ),
    TransporterProfileDetails(
      :final vehicleType,
      :final vehicleNumber,
      :final serviceAreas,
    ) =>
      ProfileFormValues(
        fullName: base.fullName,
        phone: base.phone,
        vehicleType: vehicleType ?? '',
        vehicleNumber: vehicleNumber ?? '',
        serviceAreas: serviceAreas.join(', '),
      ),
    OtherProfileDetails() => base,
  };
}

String _acres(double value) =>
    value == value.roundToDouble() ? value.toInt().toString() : '$value';

/// Only what changed from [baseline] to [current], ready for the PATCH body.
/// Phone is normalised to E.164 before it is compared and sent.
ProfileUpdate diffProfile(UserProfile baseline, ProfileFormValues current) {
  final start = formValuesFor(baseline);
  String t(String v) => v.trim();

  String? changed(String before, String after) =>
      t(before) == t(after) ? null : t(after);

  final phoneBefore = normalizePhone(start.phone) ?? t(start.phone);
  final phoneAfter = normalizePhone(current.phone) ?? t(current.phone);
  final phone = phoneBefore == phoneAfter || phoneAfter.isEmpty
      ? null
      : phoneAfter;
  final fullName = changed(start.fullName, current.fullName);

  return switch (baseline.profile) {
    BuyerProfileDetails() => ProfileUpdate(
      fullName: fullName,
      phone: phone,
      businessName: current.businessType == 'individual'
          ? null
          : changed(start.businessName, current.businessName),
      businessType: changed(start.businessType, current.businessType),
    ),
    FarmerProfileDetails() => ProfileUpdate(
      fullName: fullName,
      phone: phone,
      farmName: changed(start.farmName, current.farmName),
      cropTypes:
          _splitList(start.cropTypes).join('\u0000') ==
              _splitList(current.cropTypes).join('\u0000')
          ? null
          : _splitList(current.cropTypes),
      landSizeAcres: t(start.landSize) == t(current.landSize)
          ? null
          : double.tryParse(t(current.landSize)),
    ),
    TransporterProfileDetails() => ProfileUpdate(
      fullName: fullName,
      phone: phone,
      vehicleType: changed(start.vehicleType, current.vehicleType),
      vehicleNumber: changed(start.vehicleNumber, current.vehicleNumber),
      serviceAreas:
          _splitList(start.serviceAreas).join('\u0000') ==
              _splitList(current.serviceAreas).join('\u0000')
          ? null
          : _splitList(current.serviceAreas),
    ),
    OtherProfileDetails() => ProfileUpdate(fullName: fullName, phone: phone),
  };
}

const profileFieldNames = [
  'fullName',
  'phone',
  'businessName',
  'businessType',
  'farmName',
  'cropTypes',
  'landSizeAcres',
  'vehicleType',
  'vehicleNumber',
  'serviceAreas',
];

/// Which fields the backend rejected. Its 400 body joins class-validator
/// messages with ", ", each starting with the property name
/// (`phone must be a valid phone number`).
Set<String> rejectedProfileFields(String? serverMessage) {
  if (serverMessage == null) return const {};
  final found = <String>{};
  for (final part in serverMessage.split(', ')) {
    for (final name in profileFieldNames) {
      if (part.startsWith(name)) {
        found.add(name);
        break;
      }
    }
  }
  return found;
}
