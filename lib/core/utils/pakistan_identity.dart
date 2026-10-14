import 'package:flutter/services.dart';

/// Digits only, e.g. `35202-1234567-1` -> `3520212345671`.
String cnicDigits(String value) => value.replaceAll(RegExp(r'\D'), '');

/// Progressive `12345-1234567-1` formatting. Extra digits beyond 13 are dropped.
String formatCnic(String value) {
  final digits = cnicDigits(value);
  final capped = digits.length > 13 ? digits.substring(0, 13) : digits;
  final buffer = StringBuffer();
  for (var i = 0; i < capped.length; i++) {
    if (i == 5 || i == 12) buffer.write('-');
    buffer.write(capped[i]);
  }
  return buffer.toString();
}

bool isCompleteCnic(String value) => cnicDigits(value).length == 13;

/// Normalises what a user types into E.164, or returns null when it cannot be a
/// phone number. Pakistani national formats (`0300 1234567`, `300-1234567`,
/// `0092 300 1234567`, `+92 300 1234567`) become `+923001234567`. Other
/// `+`-prefixed international numbers pass through if they are valid E.164.
String? normalizePhone(String input) {
  final trimmed = input.trim();
  if (trimmed.isEmpty) return null;
  final hasPlus = trimmed.startsWith('+');
  var digits = trimmed.replaceAll(RegExp(r'\D'), '');
  if (digits.isEmpty) return null;

  if (hasPlus) {
    if (digits.startsWith('92')) return _pakistani(digits.substring(2));
    return RegExp(r'^[1-9]\d{7,14}$').hasMatch(digits) ? '+$digits' : null;
  }
  if (digits.startsWith('0092')) return _pakistani(digits.substring(4));
  if (digits.startsWith('92') && digits.length >= 11) {
    return _pakistani(digits.substring(2));
  }
  if (digits.startsWith('0')) digits = digits.substring(1);
  return _pakistani(digits);
}

// National significant number: 9 or 10 digits, never starting with 0.
String? _pakistani(String national) {
  if (!RegExp(r'^[1-9]\d{8,9}$').hasMatch(national)) return null;
  return '+92$national';
}

enum PasswordStrength { weak, fair, strong }

/// A deliberately simple, explainable estimate: length plus character variety.
/// The hard rule (>= 8 characters) lives in the validator, not here.
PasswordStrength passwordStrength(String password) {
  if (password.length < 8) return PasswordStrength.weak;
  final classes = [
    RegExp(r'[a-z]'),
    RegExp(r'[A-Z]'),
    RegExp(r'\d'),
    RegExp(r'[^A-Za-z0-9]'),
  ].where((r) => r.hasMatch(password)).length;
  if (password.length >= 12 && classes >= 3) return PasswordStrength.strong;
  if (password.length >= 10 && classes >= 3) return PasswordStrength.strong;
  if (classes >= 2) return PasswordStrength.fair;
  return PasswordStrength.weak;
}

/// Keeps a CNIC field to 13 digits and inserts the dashes while typing.
class CnicInputFormatter extends TextInputFormatter {
  const CnicInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final formatted = formatCnic(newValue.text);
    // Count digits before the caret so it stays put when dashes are inserted.
    final digitsBeforeCaret = cnicDigits(
      newValue.text.substring(
        0,
        newValue.selection.baseOffset.clamp(0, newValue.text.length),
      ),
    ).length.clamp(0, 13);
    var offset = digitsBeforeCaret;
    if (digitsBeforeCaret > 5) offset++;
    if (digitsBeforeCaret > 12) offset++;
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(
        offset: offset.clamp(0, formatted.length),
      ),
    );
  }
}
