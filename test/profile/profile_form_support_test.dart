import 'package:flutter_test/flutter_test.dart';
import 'package:farm2fork_mobile/features/profile/data/models/user_profile.dart';
import 'package:farm2fork_mobile/features/profile/presentation/utils/profile_form_support.dart';

UserProfile _profile(ProfileDetails details, {String role = 'buyer'}) =>
    UserProfile(
      user: ProfileUser(
        id: 'u1',
        email: 'a@b.com',
        role: role,
        fullName: 'Ayesha Khan',
        phone: '+923001234567',
      ),
      displayName: 'Ayesha Khan',
      profile: details,
    );

void main() {
  group('diffProfile', () {
    final buyer = _profile(
      const ProfileDetails.buyer(
        businessName: 'Khan Traders',
        businessType: 'retailer',
      ),
    );

    test('sends nothing when nothing changed', () {
      expect(diffProfile(buyer, formValuesFor(buyer)).isEmpty, isTrue);
    });

    test('sends only changed fields', () {
      final values = ProfileFormValues(
        fullName: 'Ayesha K.',
        phone: '+923001234567',
        businessName: 'Khan Traders',
        businessType: 'retailer',
      );
      expect(diffProfile(buyer, values).toJson(), {'fullName': 'Ayesha K.'});
    });

    test('normalises a typed phone and ignores a no-op reformat', () {
      final changed = diffProfile(
        buyer,
        const ProfileFormValues(
          fullName: 'Ayesha Khan',
          phone: '0311 7654321',
          businessName: 'Khan Traders',
          businessType: 'retailer',
        ),
      );
      expect(changed.toJson(), {'phone': '+923117654321'});

      final same = diffProfile(
        buyer,
        const ProfileFormValues(
          fullName: 'Ayesha Khan',
          phone: '0300 1234567',
          businessName: 'Khan Traders',
          businessType: 'retailer',
        ),
      );
      expect(same.isEmpty, isTrue);
    });

    test('switching a buyer to individual does not send a business name', () {
      final update = diffProfile(
        buyer,
        const ProfileFormValues(
          fullName: 'Ayesha Khan',
          phone: '+923001234567',
          businessName: 'Something else',
          businessType: 'individual',
        ),
      );
      expect(update.toJson(), {'businessType': 'individual'});
    });

    test('farmers compare crop lists and acres, not raw text', () {
      final farmer = _profile(
        const ProfileDetails.farmer(
          farmName: 'Green Acres',
          cropTypes: ['Wheat', 'Tomatoes'],
          landSizeAcres: 12.5,
        ),
        role: 'farmer',
      );
      final start = formValuesFor(farmer);
      expect(start.cropTypes, 'Wheat, Tomatoes');
      expect(start.landSize, '12.5');

      final reformatted = ProfileFormValues(
        fullName: 'Ayesha Khan',
        phone: '+923001234567',
        farmName: 'Green Acres',
        cropTypes: ' Wheat ,Tomatoes,',
        landSize: '12.5',
      );
      expect(diffProfile(farmer, reformatted).isEmpty, isTrue);

      final edited = ProfileFormValues(
        fullName: 'Ayesha Khan',
        phone: '+923001234567',
        farmName: 'Green Acres',
        cropTypes: 'Wheat, Rice',
        landSize: '20',
      );
      expect(diffProfile(farmer, edited).toJson(), {
        'cropTypes': ['Wheat', 'Rice'],
        'landSizeAcres': 20.0,
      });
    });

    test('transporters only send vehicle fields that changed', () {
      final transporter = _profile(
        const ProfileDetails.transporter(
          vehicleType: 'van',
          vehicleNumber: 'LEA-1234',
          serviceAreas: ['Lahore'],
        ),
        role: 'transporter',
      );
      final update = diffProfile(
        transporter,
        const ProfileFormValues(
          fullName: 'Ayesha Khan',
          phone: '+923001234567',
          vehicleType: 'truck',
          vehicleNumber: 'LEA-1234',
          serviceAreas: 'Lahore',
        ),
      );
      expect(update.toJson(), {'vehicleType': 'truck'});
    });
  });

  group('rejectedProfileFields', () {
    test('finds field names in the backend validation message', () {
      expect(
        rejectedProfileFields(
          'fullName must be longer than or equal to 2 characters, '
          'phone must be a valid phone number',
        ),
        {'fullName', 'phone'},
      );
      expect(
        rejectedProfileFields('farmName cannot be edited for the buyer role'),
        {'farmName'},
      );
    });

    test('is empty for messages that name no field', () {
      expect(rejectedProfileFields('Request body is empty'), isEmpty);
      expect(rejectedProfileFields(null), isEmpty);
    });
  });

  test('UserProfile parses the documented backend response', () {
    final profile = UserProfile.fromJson({
      'user': {
        'id': 'u1',
        'email': 'a@b.com',
        'role': 'farmer',
        'phone': '+923001234567',
        'fullName': 'Ayesha Khan',
        'avatarUrl':
            'https://res.cloudinary.com/c/image/upload/c_fill,g_auto,w_256,h_256,f_auto,q_auto/v1/farm2fork/avatars/u1',
        'isVerified': true,
        'isActive': true,
      },
      'displayName': 'Ayesha Khan',
      'profile': {
        'kind': 'farmer',
        'cnicMasked': '*********5671',
        'farmName': 'Green Acres',
        'cropTypes': ['Wheat'],
        'landSizeAcres': 12.5,
        'farmLocation': {
          'address': 'Chak 5',
          'city': 'Multan',
          'province': 'Punjab',
          'lat': 30.1,
          'lng': 71.5,
          'complete': true,
        },
      },
    });
    expect(profile.displayName, 'Ayesha Khan');
    expect(profile.user.avatarUrl, contains('w_256,h_256'));
    final details = profile.profile as FarmerProfileDetails;
    expect(details.farmName, 'Green Acres');
    expect(details.farmLocation?.complete, isTrue);
    expect(profile.profile.maskedCnic, '*********5671');
  });

  test(
    'financial partners and unknown kinds fall back to read-only details',
    () {
      final profile = UserProfile.fromJson({
        'user': {'id': 'u', 'email': 'f@b.com', 'role': 'financial_partner'},
        'displayName': 'F',
        'profile': {'kind': 'financial_partner', 'institutionName': 'MFB'},
      });
      expect(profile.profile, isA<OtherProfileDetails>());
    },
  );
}
