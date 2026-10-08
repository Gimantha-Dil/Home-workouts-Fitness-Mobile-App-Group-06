class Validators {
  static bool isValidEmail(String? email) {
    if (email == null) return false;
    final cleaned = email.trim().toLowerCase();
    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]{2,}$');
    return emailRegex.hasMatch(cleaned);
  }

  static bool isValidPassword(String? password) {
    if (password == null) return false;
    final passwordRegex = RegExp(r'^(?=.*[0-9]).{8,}$');
    return passwordRegex.hasMatch(password);
  }

  static bool passwordsMatch(String? password, String? confirmPassword) {
    return password != null && password == confirmPassword;
  }
}
