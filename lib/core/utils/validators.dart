class MyValidators {
  static String? displayNamevalidator(String? value) {
    if (value == null || value.isEmpty) return 'Name is required';
    if (value.length < 3) return 'Name must be at least 3 characters';
    return null;
  }

  static String? emailValidator(String? value) {
    if (value == null || value.isEmpty) return 'Email is required';
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) return 'Invalid email';
    return null;
  }

  static String? passwordValidator(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  static String? repeatPasswordValidator({String? value, required String password}) {
    if (value != password) return 'Passwords do not match';
    return null;
  }
}
