class InputValidator {
  static const int minPasswordLength = 8;

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
}
