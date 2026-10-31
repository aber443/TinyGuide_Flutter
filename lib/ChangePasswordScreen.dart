import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _currentPasswordController =
  TextEditingController();

  final TextEditingController _newPasswordController =
  TextEditingController();

  final TextEditingController _confirmPasswordController =
  TextEditingController();

  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  bool _isLoading = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validateSixDigits(String? value) {
    if (value == null || value.isEmpty) {
      return 'هذا الحقل مطلوب';
    }

    if (value.length != 6) {
      return 'كلمة المرور يجب أن تكون 6 أرقام';
    }

    if (!RegExp(r'^[0-9]{6}$').hasMatch(value)) {
      return 'استخدمي أرقام فقط';
    }

    return null;
  }

  Future<void> _changePassword() async {
    FocusScope.of(context).unfocus();

    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    if (_newPasswordController.text !=
        _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'كلمة المرور الجديدة غير متطابقة',
            textAlign: TextAlign.center,
          ),
        ),
      );
      return;
    }

    if (_currentPasswordController.text ==
        _newPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'اختاري كلمة مرور جديدة مختلفة عن الحالية',
            textAlign: TextAlign.center,
          ),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // لاحقًا هنا سيتم الربط مع Laravel
    // لتغيير كلمة المرور فعليًا في قاعدة البيانات.
    await Future.delayed(
      const Duration(seconds: 1),
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'تم تغيير كلمة المرور بنجاح',
          textAlign: TextAlign.center,
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    final Color primaryColor = theme.primaryColor;
    final Color textColor = theme.colorScheme.onSurface;
    final Color secondaryTextColor =
    theme.colorScheme.onSurface.withOpacity(0.65);

    return Scaffold(
      body: SafeArea(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 18,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 560,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // =========================
                      // Header
                      // =========================
                      Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: textColor,
                            ),
                          ),

                          Expanded(
                            child: Text(
                              'تغيير كلمة المرور',
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                          ),

                          const SizedBox(width: 48),
                        ],
                      ),

                      const SizedBox(height: 35),

                      Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.lock_reset_rounded,
                          size: 58,
                          color: primaryColor,
                        ),
                      ),

                      const SizedBox(height: 25),

                      Text(
                        'تحديث كلمة المرور',
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        'أدخلي كلمة المرور الحالية ثم اختاري\n'
                            'كلمة مرور جديدة مكوّنة من 6 أرقام.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.6,
                          color: secondaryTextColor,
                        ),
                      ),

                      const SizedBox(height: 32),

                      TextFormField(
                        controller: _currentPasswordController,
                        obscureText: _obscureCurrentPassword,
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                        validator: _validateSixDigits,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(6),
                        ],
                        style: TextStyle(
                          color: textColor,
                        ),
                        decoration: _inputDecoration(
                          hintText: 'كلمة المرور الحالية',
                          primaryColor: primaryColor,
                          icon: Icons.lock_outline,
                          obscure: _obscureCurrentPassword,
                          onVisibilityPressed: () {
                            setState(() {
                              _obscureCurrentPassword =
                              !_obscureCurrentPassword;
                            });
                          },
                        ),
                      ),

                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _newPasswordController,
                        obscureText: _obscureNewPassword,
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                        validator: _validateSixDigits,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(6),
                        ],
                        style: TextStyle(
                          color: textColor,
                        ),
                        decoration: _inputDecoration(
                          hintText: 'كلمة المرور الجديدة',
                          primaryColor: primaryColor,
                          icon: Icons.password_rounded,
                          obscure: _obscureNewPassword,
                          onVisibilityPressed: () {
                            setState(() {
                              _obscureNewPassword =
                              !_obscureNewPassword;
                            });
                          },
                        ),
                      ),

                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: _obscureConfirmPassword,
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                        validator: (value) {
                          final String? error =
                          _validateSixDigits(value);

                          if (error != null) {
                            return error;
                          }

                          if (value !=
                              _newPasswordController.text) {
                            return 'كلمة المرور غير متطابقة';
                          }

                          return null;
                        },
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(6),
                        ],
                        style: TextStyle(
                          color: textColor,
                        ),
                        decoration: _inputDecoration(
                          hintText: 'تأكيد كلمة المرور الجديدة',
                          primaryColor: primaryColor,
                          icon: Icons.lock_reset_outlined,
                          obscure: _obscureConfirmPassword,
                          onVisibilityPressed: () {
                            setState(() {
                              _obscureConfirmPassword =
                              !_obscureConfirmPassword;
                            });
                          },
                        ),
                      ),

                      const SizedBox(height: 28),

                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed:
                          _isLoading ? null : _changePassword,
                          child: _isLoading
                              ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                              : const Text(
                            'حفظ كلمة المرور الجديدة',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hintText,
    required Color primaryColor,
    required IconData icon,
    required bool obscure,
    required VoidCallback onVisibilityPressed,
  }) {
    final ThemeData theme = Theme.of(context);
    final Color textColor = theme.colorScheme.onSurface;

    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(
        color: textColor.withOpacity(0.60),
      ),
      counterText: '',

      filled: true,
      fillColor: theme.cardColor,

      prefixIcon: Icon(
        icon,
        color: primaryColor,
      ),

      suffixIcon: IconButton(
        onPressed: onVisibilityPressed,
        icon: Icon(
          obscure
              ? Icons.visibility_off_outlined
              : Icons.visibility_outlined,
          color: textColor.withOpacity(0.60),
        ),
      ),

      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 18,
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: textColor.withOpacity(0.20),
        ),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: primaryColor,
          width: 2,
        ),
      ),

      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Colors.red,
        ),
      ),

      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Colors.red,
          width: 2,
        ),
      ),
    );
  }
}