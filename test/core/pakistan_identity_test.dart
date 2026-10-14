import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:farm2fork_mobile/core/utils/avatar_url.dart';
import 'package:farm2fork_mobile/core/utils/pakistan_identity.dart';

void main() {
  group('CNIC', () {
    test('formats progressively and caps at 13 digits', () {
      expect(formatCnic('3520'), '3520');
      expect(formatCnic('352021'), '35202-1');
      expect(formatCnic('35202123456'), '35202-123456');
      expect(formatCnic('3520212345671'), '35202-1234567-1');
      expect(formatCnic('3520212345671999'), '35202-1234567-1');
      expect(formatCnic('35202-1234567-1'), '35202-1234567-1');
    });

    test('is complete at exactly 13 digits', () {
      expect(isCompleteCnic('35202-1234567-1'), isTrue);
      expect(isCompleteCnic('35202-1234567'), isFalse);
    });

    test('the input formatter strips letters and inserts dashes', () {
      const formatter = CnicInputFormatter();
      final result = formatter.formatEditUpdate(
        TextEditingValue.empty,
        const TextEditingValue(
          text: '35202a1234567b1',
          selection: TextSelection.collapsed(offset: 15),
        ),
      );
      expect(result.text, '35202-1234567-1');
      expect(result.selection.baseOffset, 15);
    });
  });

  group('phone', () {
    test('normalises Pakistani formats to E.164', () {
      for (final input in [
        '0300 1234567',
        '03001234567',
        '300-1234567',
        '+92 300 1234567',
        '+923001234567',
        '0092 300 1234567',
        '923001234567',
        '(0300) 123-4567',
      ]) {
        expect(normalizePhone(input), '+923001234567', reason: input);
      }
    });

    test('accepts landlines and other international numbers', () {
      expect(normalizePhone('042 3512 3456'), '+924235123456');
      expect(normalizePhone('+44 20 7946 0958'), '+442079460958');
    });

    test('rejects empty and impossible numbers', () {
      expect(normalizePhone(''), isNull);
      expect(normalizePhone('abc'), isNull);
      expect(normalizePhone('0300 123'), isNull);
      expect(normalizePhone('+92 0300 1234567'), isNull);
    });
  });

  group('password strength', () {
    test('short or single-class passwords are weak', () {
      expect(passwordStrength('abc123'), PasswordStrength.weak);
      expect(passwordStrength('abcdefgh'), PasswordStrength.weak);
    });

    test('mixed passwords are fair, long mixed ones strong', () {
      expect(passwordStrength('abcdefg1'), PasswordStrength.fair);
      expect(passwordStrength('Abcdefg1xy'), PasswordStrength.strong);
    });
  });

  group('avatar urls', () {
    const url =
        'https://res.cloudinary.com/c/image/upload/c_fill,g_auto,w_256,h_256,f_auto,q_auto/v1/farm2fork/avatars/u';

    test('swaps w_256,h_256 for the size bucket the screen needs', () {
      expect(avatarUrlForSize(url, 48, 3), contains('w_192,h_192'));
      expect(avatarUrlForSize(url, 96, 2), contains('w_192,h_192'));
      expect(avatarUrlForSize(url, 64, 1), contains('w_96,h_96'));
      expect(avatarUrlForSize(url, 200, 3), contains('w_512,h_512'));
    });

    test('resolves root-relative development paths against the API origin', () {
      expect(
        resolveAvatarUrl(
          '/api/files/public/a.jpg',
          apiBaseUrl: 'http://10.0.2.2:3000/api',
        ),
        'http://10.0.2.2:3000/api/files/public/a.jpg',
      );
      expect(resolveAvatarUrl(url), url);
    });

    test('initials use first and last name', () {
      expect(initialsFor('Ayesha Khan'), 'AK');
      expect(initialsFor('  junaid  '), 'J');
      expect(initialsFor('Ali Raza Khan'), 'AK');
      expect(initialsFor(''), '?');
    });
  });
}
