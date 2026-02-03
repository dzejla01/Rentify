// lib/helpers/validation_helper.dart

class ValidationHelper {
  ValidationHelper._();

  static final RegExp _emailRegex = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");

  static final RegExp _usernameAllowed = RegExp(r'^[a-zA-Z0-9._]+$');

  static final RegExp _phoneChars = RegExp(r'^\+?[0-9()\-\s]{6,}$');

  // ==========
  // VALIDATORS
  // ==========

  static String? emailValidator(String? value, {bool required = true}) {
    final v = value?.trim() ?? '';
    if (!required && v.isEmpty) return null;
    if (v.isEmpty) return 'Email je obavezan.';
    if (!_emailRegex.hasMatch(v)) return 'Unesi ispravan email (npr. ime.prezime@domena.com).';
    return null;
  }

  static String? usernameValidator(
    String? value, {
    bool required = true,
    int min = 3,
    int max = 20,
  }) {
    final v = value?.trim() ?? '';
    if (!required && v.isEmpty) return null;
    if (v.isEmpty) return 'Username je obavezan.';
    if (v.length < min || v.length > max) {
      return 'Username mora imati između $min i $max karaktera.';
    }
    if (!_usernameAllowed.hasMatch(v)) {
      return 'Username smije sadržati slova, brojeve, "." i "_".';
    }
    if (v.startsWith('.') || v.startsWith('_') || v.endsWith('.') || v.endsWith('_')) {
      return 'Username ne smije početi ili završiti sa "." ili "_".';
    }
    if (v.contains('..') || v.contains('__') || v.contains('._') || v.contains('_.')) {
      return 'Username ne smije imati duple znakove (.., __, ._, _.)';
    }
    return null;
  }

  static String? phoneValidator(
    String? value, {
    bool required = false,
    int minDigits = 7,
    int maxDigits = 15,
  }) {
    final v = value?.trim() ?? '';
    if (!required && v.isEmpty) return null;
    if (v.isEmpty) return 'Telefon je obavezan.';

    if (!_phoneChars.hasMatch(v)) {
      return 'Unesi ispravan broj telefona.';
    }

    final digits = _onlyDigits(v);
    if (digits.length < minDigits || digits.length > maxDigits) {
      return 'Telefon mora imati između $minDigits i $maxDigits cifara.';
    }

    if (v.contains('+') && !v.startsWith('+')) {
      return 'Znak + može biti samo na početku.';
    }

    return null;
  }

  static String _onlyDigits(String value) => value.replaceAll(RegExp(r'\D'), '');
}
