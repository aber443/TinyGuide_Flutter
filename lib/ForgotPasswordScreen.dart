import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'LoginScreen.dart';
import 'validators.dart';

enum ForgotPasswordStep { phone, verification, resetPassword, completed }

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final GlobalKey<FormState> phoneFormKey = GlobalKey<FormState>();

  final GlobalKey<FormState> codeFormKey = GlobalKey<FormState>();

  final GlobalKey<FormState> passwordFormKey = GlobalKey<FormState>();

  final TextEditingController phoneController = TextEditingController();

  final TextEditingController codeController = TextEditingController();

  final TextEditingController newPasswordController = TextEditingController();

  final TextEditingController confirmPasswordController =
      TextEditingController();

  final FocusNode phoneFocusNode = FocusNode();
  final FocusNode codeFocusNode = FocusNode();
  final FocusNode newPasswordFocusNode = FocusNode();
  final FocusNode confirmPasswordFocusNode = FocusNode();

  ForgotPasswordStep currentStep = ForgotPasswordStep.phone;

  bool obscureNewPassword = true;
  bool obscureConfirmPassword = true;
  bool isLoading = false;

  String selectedFlag = '';
  String selectedCountry = '';

  final Map<String, Map<String, String>> supportedCountries = {
    '967': {'flag': '🇾🇪', 'name': 'اليمن'},
    '966': {'flag': '🇸🇦', 'name': 'السعودية'},
    '971': {'flag': '🇦🇪', 'name': 'الإمارات'},
    '968': {'flag': '🇴🇲', 'name': 'عُمان'},
    '965': {'flag': '🇰🇼', 'name': 'الكويت'},
    '974': {'flag': '🇶🇦', 'name': 'قطر'},
    '973': {'flag': '🇧🇭', 'name': 'البحرين'},
  };

  void detectCountry(String value) {
    final String phone = Validators.cleanPhoneNumber(value);

    String flag = '';
    String country = '';

    for (final entry in supportedCountries.entries) {
      if (phone.startsWith(entry.key)) {
        flag = entry.value['flag'] ?? '';
        country = entry.value['name'] ?? '';
        break;
      }
    }

    setState(() {
      selectedFlag = flag;
      selectedCountry = country;
    });
  }

  Future<void> sendVerificationCode() async {
    FocusScope.of(context).unfocus();

    final bool valid = phoneFormKey.currentState?.validate() ?? false;

    if (!valid) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    /*
      مستقبلًا مع Laravel:

      POST /api/forgot-password/request-code

      {
        "phone": Validators.cleanPhoneNumber(
          phoneController.text,
        )
      }

      Laravel:
      - يتحقق من الحساب.
      - ينشئ OTP.
      - يحدد وقت انتهاء للرمز.
      - يرسله عبر مزود SMS.
      - يطبق Rate Limiting.
    */

    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    setState(() {
      isLoading = false;
      currentStep = ForgotPasswordStep.verification;
    });
  }

  Future<void> verifyCode() async {
    FocusScope.of(context).unfocus();

    final bool valid = codeFormKey.currentState?.validate() ?? false;

    if (!valid) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    /*
      مستقبلًا مع Laravel:

      POST /api/forgot-password/verify-code

      {
        "phone": cleanedPhone,
        "code": codeController.text
      }

      Laravel يتحقق من:
      - صحة الرمز.
      - عدم انتهاء صلاحيته.
      - عدد المحاولات.
    */

    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    setState(() {
      isLoading = false;
      currentStep = ForgotPasswordStep.resetPassword;
    });
  }

  Future<void> resetPassword() async {
    FocusScope.of(context).unfocus();

    final bool valid = passwordFormKey.currentState?.validate() ?? false;

    if (!valid) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    /*
      مستقبلًا مع Laravel:

      POST /api/forgot-password/reset

      {
        "phone": cleanedPhone,
        "code": codeController.text,
        "password":
            newPasswordController.text,
        "password_confirmation":
            confirmPasswordController.text
      }

      Laravel يقوم بـ:
      - التحقق النهائي من OTP.
      - Hash لكلمة المرور الجديدة.
      - تحديث users.password.
      - إلغاء رمز OTP بعد استخدامه.
      - إلغاء الجلسات القديمة عند الحاجة.
    */

    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    setState(() {
      isLoading = false;
      currentStep = ForgotPasswordStep.completed;
    });
  }

  Future<void> resendCode() async {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم طلب إرسال رمز جديد', textAlign: TextAlign.center),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );

    /*
      مستقبلًا:
      نستدعي request-code مرة أخرى
      مع Rate Limit من Laravel.
    */
  }

  void goToLogin() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  void handleBack() {
    if (currentStep == ForgotPasswordStep.phone) {
      Navigator.pop(context);
      return;
    }

    setState(() {
      switch (currentStep) {
        case ForgotPasswordStep.phone:
          break;

        case ForgotPasswordStep.verification:
          currentStep = ForgotPasswordStep.phone;
          break;

        case ForgotPasswordStep.resetPassword:
          currentStep = ForgotPasswordStep.verification;
          break;

        case ForgotPasswordStep.completed:
          currentStep = ForgotPasswordStep.resetPassword;
          break;
      }
    });
  }

  @override
  void dispose() {
    phoneController.dispose();
    codeController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();

    phoneFocusNode.dispose();
    codeFocusNode.dispose();
    newPasswordFocusNode.dispose();
    confirmPasswordFocusNode.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double width = constraints.maxWidth;

            final double height = constraints.maxHeight;

            final bool isSmall = width < 360 || height < 650;

            final bool isTablet = width >= 600;

            final double horizontalPadding = isSmall
                ? 18
                : isTablet
                ? 40
                : 26;

            return Directionality(
              textDirection: TextDirection.rtl,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: 16,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 560),
                    child: Column(
                      children: [
                        if (currentStep != ForgotPasswordStep.completed)
                          _buildHeader(primaryColor),

                        SizedBox(height: isSmall ? 18 : 28),

                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: _buildCurrentStep(
                            primaryColor,
                            isSmall,
                            isTablet,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(Color primaryColor) {
    return Row(
      children: [
        IconButton(
          onPressed: handleBack,
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xff2C4A5A),
          ),
        ),
        const Expanded(
          child: Text(
            'استعادة كلمة المرور',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.bold,
              color: Color(0xff2C4A5A),
            ),
          ),
        ),
        const SizedBox(width: 48),
      ],
    );
  }

  Widget _buildCurrentStep(Color primaryColor, bool isSmall, bool isTablet) {
    switch (currentStep) {
      case ForgotPasswordStep.phone:
        return _buildPhoneStep(primaryColor, isSmall, isTablet);

      case ForgotPasswordStep.verification:
        return _buildVerificationStep(primaryColor, isSmall, isTablet);

      case ForgotPasswordStep.resetPassword:
        return _buildResetPasswordStep(primaryColor, isSmall, isTablet);

      case ForgotPasswordStep.completed:
        return _buildCompletedStep(primaryColor, isSmall);
    }
  }

  Widget _buildPhoneStep(Color primaryColor, bool isSmall, bool isTablet) {
    return Form(
      key: phoneFormKey,
      child: Column(
        key: const ValueKey('phone-step'),
        children: [
          _buildTopIcon(Icons.lock_reset_rounded, primaryColor, isSmall),

          const SizedBox(height: 20),

          Text(
            'نسيت كلمة المرور؟',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isSmall ? 25 : 29,
              fontWeight: FontWeight.bold,
              color: const Color(0xff2C4A5A),
            ),
          ),

          const SizedBox(height: 10),

          Text(
            'أدخل رقم الهاتف المرتبط بحسابك،\nوسنرسل لك رمزًا للتحقق.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isSmall ? 13 : 15,
              height: 1.6,
              fontWeight: FontWeight.w500,
              color: const Color(0xff6D7A80),
            ),
          ),

          SizedBox(height: isSmall ? 25 : 35),

          TextFormField(
            controller: phoneController,
            focusNode: phoneFocusNode,
            keyboardType: TextInputType.phone,
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.right,
            validator: Validators.supportedPhone,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9+\-\s]')),
              LengthLimitingTextInputFormatter(16),
            ],
            onChanged: detectCountry,
            decoration: _inputDecoration(
              hintText: 'رقم الهاتف',
              primaryColor: primaryColor,
              prefixIcon: Icons.phone_outlined,
              suffix: selectedFlag.isEmpty
                  ? const Icon(Icons.flag_outlined, color: Color(0xff9AA7AB))
                  : Text(selectedFlag, style: const TextStyle(fontSize: 26)),
            ),
          ),

          if (selectedCountry.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 7, right: 8),
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'الدولة: $selectedCountry',
                  style: TextStyle(
                    color: primaryColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

          const SizedBox(height: 24),

          _buildMainButton(
            text: 'إرسال رمز التحقق',
            onPressed: sendVerificationCode,
            primaryColor: primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationStep(
    Color primaryColor,
    bool isSmall,
    bool isTablet,
  ) {
    final String displayedPhone = phoneController.text.trim();

    return Form(
      key: codeFormKey,
      child: Column(
        key: const ValueKey('verification-step'),
        children: [
          _buildTopIcon(Icons.sms_outlined, primaryColor, isSmall),

          const SizedBox(height: 20),

          Text(
            'أدخل رمز التحقق',
            style: TextStyle(
              fontSize: isSmall ? 25 : 29,
              fontWeight: FontWeight.bold,
              color: const Color(0xff2C4A5A),
            ),
          ),

          const SizedBox(height: 10),

          Text(
            'أدخل الرمز المكوّن من 6 أرقام\nالمرسل إلى $displayedPhone',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isSmall ? 13 : 15,
              height: 1.6,
              color: const Color(0xff6D7A80),
              fontWeight: FontWeight.w500,
            ),
          ),

          SizedBox(height: isSmall ? 25 : 35),

          TextFormField(
            controller: codeController,
            focusNode: codeFocusNode,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            maxLength: 6,
            validator: Validators.verificationCode,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(6),
            ],
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: 7,
              color: Color(0xff2C4A5A),
            ),
            decoration: _inputDecoration(
              hintText: '------',
              primaryColor: primaryColor,
              prefixIcon: Icons.verified_outlined,
            ).copyWith(counterText: ''),
          ),

          const SizedBox(height: 14),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'لم يصلك الرمز؟ ',
                style: TextStyle(color: Color(0xff6D7A80), fontSize: 14),
              ),
              TextButton(
                onPressed: resendCode,
                child: Text(
                  'إعادة الإرسال',
                  style: TextStyle(
                    color: primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          _buildMainButton(
            text: 'تحقق من الرمز',
            onPressed: verifyCode,
            primaryColor: primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildResetPasswordStep(
    Color primaryColor,
    bool isSmall,
    bool isTablet,
  ) {
    return Form(
      key: passwordFormKey,
      child: Column(
        key: const ValueKey('reset-password-step'),
        children: [
          _buildTopIcon(Icons.password_rounded, primaryColor, isSmall),

          const SizedBox(height: 20),

          Text(
            'كلمة مرور جديدة',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isSmall ? 25 : 29,
              fontWeight: FontWeight.bold,
              color: const Color(0xff2C4A5A),
            ),
          ),

          const SizedBox(height: 10),

          Text(
            'أنشئ كلمة مرور جديدة مكوّنة من 6 أرقام.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isSmall ? 13 : 15,
              height: 1.6,
              color: const Color(0xff6D7A80),
              fontWeight: FontWeight.w500,
            ),
          ),

          SizedBox(height: isSmall ? 25 : 35),

          TextFormField(
            controller: newPasswordController,
            focusNode: newPasswordFocusNode,
            obscureText: obscureNewPassword,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.right,
            maxLength: 6,
            validator: Validators.sixDigitPassword,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(6),
            ],
            onChanged: (_) {
              if (confirmPasswordController.text.isNotEmpty) {
                passwordFormKey.currentState?.validate();
              }
            },
            decoration: _inputDecoration(
              hintText: 'كلمة المرور الجديدة',
              primaryColor: primaryColor,
              prefixIcon: Icons.lock_outline,
              suffix: IconButton(
                onPressed: () {
                  setState(() {
                    obscureNewPassword = !obscureNewPassword;
                  });
                },
                icon: Icon(
                  obscureNewPassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: const Color(0xff607D83),
                ),
              ),
            ).copyWith(counterText: ''),
          ),

          const SizedBox(height: 16),

          TextFormField(
            controller: confirmPasswordController,
            focusNode: confirmPasswordFocusNode,
            obscureText: obscureConfirmPassword,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.right,
            maxLength: 6,
            validator: (value) {
              return Validators.confirmPassword(
                value,
                newPasswordController.text,
              );
            },
            autovalidateMode: AutovalidateMode.onUserInteraction,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(6),
            ],
            decoration: _inputDecoration(
              hintText: 'تأكيد كلمة المرور',
              primaryColor: primaryColor,
              prefixIcon: Icons.lock_reset_outlined,
              suffix: IconButton(
                onPressed: () {
                  setState(() {
                    obscureConfirmPassword = !obscureConfirmPassword;
                  });
                },
                icon: Icon(
                  obscureConfirmPassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: const Color(0xff607D83),
                ),
              ),
            ).copyWith(counterText: ''),
          ),

          const SizedBox(height: 26),

          _buildMainButton(
            text: 'إعادة تعيين كلمة المرور',
            onPressed: resetPassword,
            primaryColor: primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildCompletedStep(Color primaryColor, bool isSmall) {
    return Padding(
      key: const ValueKey('completed-step'),
      padding: EdgeInsets.only(top: isSmall ? 60 : 100),
      child: Column(
        children: [
          Container(
            width: isSmall ? 110 : 130,
            height: isSmall ? 110 : 130,
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.14),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_circle_rounded,
              size: isSmall ? 75 : 90,
              color: primaryColor,
            ),
          ),

          const SizedBox(height: 28),

          Text(
            'تمت إعادة التعيين بنجاح',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isSmall ? 24 : 28,
              fontWeight: FontWeight.bold,
              color: const Color(0xff2C4A5A),
            ),
          ),

          const SizedBox(height: 12),

          const Text(
            'يمكنك الآن تسجيل الدخول باستخدام\nكلمة المرور الجديدة.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              height: 1.7,
              color: Color(0xff6D7A80),
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 35),

          _buildMainButton(
            text: 'العودة لتسجيل الدخول',
            onPressed: goToLogin,
            primaryColor: primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildTopIcon(IconData icon, Color primaryColor, bool isSmall) {
    final double size = isSmall ? 90 : 110;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.12),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: isSmall ? 48 : 58, color: primaryColor),
    );
  }

  InputDecoration _inputDecoration({
    required String hintText,
    required Color primaryColor,
    required IconData prefixIcon,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintTextDirection: TextDirection.rtl,
      hintStyle: const TextStyle(color: Color(0xff9AA7AB), fontSize: 16),
      errorStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
      prefixIcon: Icon(prefixIcon, color: primaryColor),
      suffixIcon: suffix == null
          ? null
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Center(widthFactor: 1, child: suffix),
            ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xffD7E7E7), width: 1.3),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.red, width: 1.3),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
    );
  }

  Widget _buildMainButton({
    required String text,
    required VoidCallback onPressed,
    required Color primaryColor,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          disabledBackgroundColor: primaryColor.withOpacity(0.55),
        ),
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : Text(
                text,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}
