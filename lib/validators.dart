class Validators {
  // =========================
  // Name Validator
  // =========================

  static String? arabicName(String? value) {
    final String name = value?.trim() ?? '';

    if (name.isEmpty) return 'مطلوب';
    if (name.length < 2) return 'الاسم قصير';
    if (name.length > 20) return 'الاسم طويل';

    final RegExp nameRegex = RegExp(r'^[A-Za-z\u0621-\u064A ]+$');

    if (!nameRegex.hasMatch(name)) {
      return 'حروف فقط';
    }

    if (name.contains('  ')) {
      return 'الاسم غير صحيح';
    }

    final RegExp repeatedLetters = RegExp(r'(.)\1{3,}');

    if (repeatedLetters.hasMatch(name)) {
      return 'الاسم غير صحيح';
    }

    return null;
  }

  static String? arabicText({
    required String? value,
    int minLength = 2,
    int maxLength = 50,
  }) {
    final String text = value?.trim() ?? '';

    if (text.isEmpty) return 'مطلوب';
    if (text.length < minLength) return 'النص قصير';
    if (text.length > maxLength) return 'النص طويل';

    final RegExp textRegex = RegExp(r'^[A-Za-z\u0621-\u064A0-9 ]+$');

    if (!textRegex.hasMatch(text)) {
      return 'أدخل حروف وأرقام فقط';
    }

    if (text.contains('  ')) {
      return 'النص غير صحيح';
    }

    return null;
  }

  // =========================
  // Phone Helpers
  // =========================

  static String cleanPhoneNumber(String value) {
    String phone = value
        .trim()
        .replaceAll(' ', '')
        .replaceAll('-', '')
        .replaceAll('(', '')
        .replaceAll(')', '');

    if (phone.startsWith('+')) {
      phone = phone.substring(1);
    }

    if (phone.startsWith('00')) {
      phone = phone.substring(2);
    }

    return phone;
  }

  // =========================
  // Phone Validator
  // =========================

  static String? supportedPhone(String? value) {
    final String phone = cleanPhoneNumber(value ?? '');

    if (phone.isEmpty) {
      return 'مطلوب';
    }

    // رقم الهاتف اليمني المحلي: 9 أرقام
    if (!RegExp(r'^\d{9}$').hasMatch(phone)) {
      return 'أدخل رقم هاتف يمني من 9 أرقام';
    }

    return null;
  }

  // =========================
  // Password Validator
  // =========================

  static String? sixDigitPassword(String? value) {
    final String password = value ?? '';

    if (password.isEmpty) {
      return 'مطلوب';
    }

    if (!RegExp(r'^\d{6}$').hasMatch(password)) {
      return '6 أرقام فقط';
    }

    return null;
  }

  // =========================
  // Verification Code
  // =========================

  static String? verificationCode(String? value) {
    final String code = value?.trim() ?? '';

    if (code.isEmpty) {
      return 'مطلوب';
    }

    if (!RegExp(r'^\d{6}$').hasMatch(code)) {
      return 'الرمز 6 أرقام';
    }

    return null;
  }

  // =========================
  // Confirm Password
  // =========================

  static String? confirmPassword(String? value, String password) {
    final String confirm = value ?? '';

    if (confirm.isEmpty) {
      return 'مطلوب';
    }

    if (confirm != password) {
      return 'غير متطابقة';
    }

    return null;
  }

  // =========================
  // Child Age Validation
  // =========================

  static bool isChildAgeValid(DateTime birthDate) {
    final DateTime today = DateTime.now();

    int age = today.year - birthDate.year;

    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }

    return age >= 1 && age <= 12;
  }

  static DateTime latestChildBirthDate() {
    final DateTime today = DateTime.now();

    return DateTime(today.year - 1, today.month, today.day);
  }

  static DateTime earliestChildBirthDate() {
    final DateTime today = DateTime.now();

    return DateTime(today.year - 13, today.month, today.day + 1);
  }

  static String? glucoseReading(String? value) {
    final String reading = value?.trim() ?? '';

    if (reading.isEmpty) {
      return 'مطلوب';
    }

    final double? number = double.tryParse(reading);

    if (number == null) {
      return 'رقم غير صحيح';
    }

    if (number <= 0) {
      return 'القراءة غير صحيحة';
    }

    if (number > 999) {
      return 'القراءة غير صحيحة';
    }

    return null;
  }
}
