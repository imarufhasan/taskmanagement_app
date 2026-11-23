class Validators {
  static String? required(String? val, [String fieldName = 'This field']) {
    if (val == null || val.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  static String? email(String? val) {
    if (val == null || val.trim().isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(val.trim())) {
      return 'Enter a valid email address';
    }
    return null;
  }

  static String? password(String? val) {
    if (val == null || val.isEmpty) {
      return 'Password is required';
    }
    if (val.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  static String? confirmPassword(String? val, String? original) {
    if (val == null || val.isEmpty) {
      return 'Please confirm your password';
    }
    if (val != original) {
      return 'Passwords do not match';
    }
    return null;
  }
}
