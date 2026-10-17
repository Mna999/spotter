class InputValidator {
  static const int minPasswordLength = 8;

  static const int minAge = 16;
  static const int maxAge = 100;
  static const int minHeightCm = 100;
  static const int maxHeightCm = 250;
  static const int minWeightKg = 30;
  static const int maxWeightKg = 300;


  static final RegExp _emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

  static String? validateName(String? value) {
    if (value == null) return 'Enter your name.';
    if (value.trim().isEmpty) return 'Enter your name.';
    if (value.trim().length <= 3)
      return 'Name must be at least 3 characters long';
    return null;
  }

  static String? validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return 'Enter your email address.';
    if (!_emailRegex.hasMatch(email)) {
      return "That email address isn't valid. Check it and try again.";
    }
    return null;
  }

  static String? validatePassword(String? value) {
    final password = value ?? '';
    if (password.isEmpty) return 'Enter a password.';
    if (password.runes.length < minPasswordLength) {
      return 'Password must be at least $minPasswordLength characters.';
    }
    return null;
  }

    static String? validateAge(String? value) {
    final age = int.tryParse(value?.trim() ?? '');
    if (age == null) return 'Enter your age.';
    if (age < minAge || age > maxAge) {
      return 'Age must be between $minAge and $maxAge.';
    }
    return null;
  }

  static String? validateHeight(String? value) {
    final height = double.tryParse(value?.trim() ?? '');
    if (height == null) return 'Enter your height in cm.';
    if (height < minHeightCm || height > maxHeightCm) {
      return 'Height must be between $minHeightCm and $maxHeightCm cm.';
    }
    return null;
  }

  static String? validateWeight(String? value) {
    final weight = double.tryParse(value?.trim() ?? '');
    if (weight == null) return 'Enter your weight in kg.';
    if (weight < minWeightKg || weight > maxWeightKg) {
      return 'Weight must be between $minWeightKg and $maxWeightKg kg.';
    }
    return null;
  }
}

