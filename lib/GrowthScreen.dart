import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class GrowthScreen extends StatefulWidget {
  final String childName;
  final DateTime birthDate;
  final String gender;
  final String? childImagePath;

  const GrowthScreen({
    super.key,
    required this.childName,
    required this.birthDate,
    required this.gender,
    this.childImagePath,
  });

  @override
  State<GrowthScreen> createState() => _GrowthScreenState();
}

class _GrowthScreenState extends State<GrowthScreen> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController heightController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController bmiController = TextEditingController();

  DateTime? recordDate;

  String? dateError;

  bool isSaving = false;


  DateTime dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  void calculateBmi() {
    final double? heightCm = double.tryParse(heightController.text.trim());
    final double? weightKg = double.tryParse(weightController.text.trim());

    if (heightCm == null ||
        weightKg == null ||
        heightCm <= 0 ||
        weightKg <= 0) {
      bmiController.clear();
      return;
    }

    final double heightMeters = heightCm / 100;
    final double bmi = weightKg / (heightMeters * heightMeters);

    bmiController.text = bmi.toStringAsFixed(1);
  }

  String? validateHeight(String? value) {
    final String text = value?.trim() ?? '';

    if (text.isEmpty) {
      return 'مطلوب';
    }

    final double? height = double.tryParse(text);

    if (height == null) {
      return 'رقم غير صحيح';
    }

    if (height <= 0) {
      return 'الطول غير صحيح';
    }

    if (height > 250) {
      return 'تحقق من الطول';
    }

    return null;
  }

  String? validateWeight(String? value) {
    final String text = value?.trim() ?? '';

    if (text.isEmpty) {
      return 'مطلوب';
    }

    final double? weight = double.tryParse(text);

    if (weight == null) {
      return 'رقم غير صحيح';
    }

    if (weight <= 0) {
      return 'الوزن غير صحيح';
    }

    if (weight > 300) {
      return 'تحقق من الوزن';
    }

    return null;
  }

  String formatDate(DateTime? date) {
    if (date == null) {
      return '';
    }

    final String day = date.day.toString().padLeft(2, '0');
    final String month = date.month.toString().padLeft(2, '0');

    return '$day/$month/${date.year}';
  }

  String formatApiDate(DateTime date) {
    final String month = date.month.toString().padLeft(2, '0');
    final String day = date.day.toString().padLeft(2, '0');

    return '${date.year}-$month-$day';
  }

  Future<void> selectRecordDate() async {
    final DateTime today = dateOnly(DateTime.now());
    final DateTime birth = dateOnly(widget.birthDate);

    DateTime initialDate = recordDate ?? today;

    if (initialDate.isBefore(birth)) {
      initialDate = birth;
    }

    if (initialDate.isAfter(today)) {
      initialDate = today;
    }

    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: birth,
      lastDate: today,
      helpText: 'اختيار تاريخ القياس',
      cancelText: 'إلغاء',
      confirmText: 'اختيار',
    );

    if (selectedDate == null) {
      return;
    }

    setState(() {
      recordDate = selectedDate;
      dateError = null;
    });
  }

  bool validateDate() {
    setState(() {
      dateError = recordDate == null ? 'مطلوب' : null;
    });

    return dateError == null;
  }

  Future<void> saveGrowthInformation() async {
    if (isSaving) {
      return;
    }

    FocusScope.of(context).unfocus();

    final bool formIsValid = formKey.currentState?.validate() ?? false;
    final bool dateIsValid = validateDate();

    if (!formIsValid || !dateIsValid) {
      return;
    }

    calculateBmi();

    setState(() {
      isSaving = true;
    });

    final double height = double.parse(heightController.text.trim());
    final double weight = double.parse(weightController.text.trim());
    final double bmi = double.parse(bmiController.text.trim());

    /*
      مستقبلًا عند ربط Laravel:

      POST /api/children/{childId}/growth-records

      Authorization: Bearer TOKEN

      {
        "height_cm": height,
        "weight_kg": weight,
        "bmi": bmi,
        "record_date":
            formatApiDate(recordDate!)
      }

      Laravel يقدر يعيد حساب BMI
      من الطول والوزن للتحقق من القيمة.
    */

    debugPrint('Height: $height cm');
    debugPrint('Weight: $weight kg');
    debugPrint('BMI: $bmi');
    debugPrint('Date: ${formatApiDate(recordDate!)}');

    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) {
      return;
    }

    heightController.clear();
    weightController.clear();
    bmiController.clear();

    setState(() {
      isSaving = false;

      recordDate = null;
      dateError = null;

      formKey = GlobalKey<FormState>();
    });

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'تم حفظ بيانات النمو بنجاح',
          textAlign: TextAlign.center,
        ),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  void dispose() {
    heightController.dispose();
    weightController.dispose();
    bmiController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    final Color primaryColor = theme.primaryColor;
    final Color darkColor = theme.colorScheme.onSurface;
    final Color cardColor = theme.cardColor;

    final bool isDark = theme.brightness == Brightness.dark;

    // نحافظ على درجات Light الأصلية كما هي.
    final Color borderColor = isDark
        ? darkColor.withOpacity(0.14)
        : const Color(0xffD7E7E7);

    final Color hintColor = isDark
        ? darkColor.withOpacity(0.52)
        : const Color(0xff8A989D);


    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double screenWidth = constraints.maxWidth;
            final double screenHeight = constraints.maxHeight;

            final bool isVerySmall = screenWidth < 390;
            final bool isSmallScreen =
                screenWidth < 430 || screenHeight < 650;
            final bool isTablet = screenWidth >= 600;

            final double horizontalPadding = isVerySmall
                ? 14
                : isTablet
                ? 36
                : 20;

            return Directionality(
              textDirection: TextDirection.rtl,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: isSmallScreen ? 12 : 16,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 720),
                    child: Form(
                      key: formKey,
                      child: Column(
                        children: [
                          // =====================
                          // Header
                          // =====================
                          SizedBox(
                            height: 48,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Text(
                                  'تسجيل بيانات النمو',
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: isVerySmall ? 17 : 21,
                                    fontWeight: FontWeight.bold,
                                    color: darkColor,
                                  ),
                                ),

                                Align(
                                  alignment:
                                  AlignmentDirectional.centerStart,
                                  child: IconButton(
                                    onPressed: isSaving
                                        ? null
                                        : () {
                                      Navigator.pop(context);
                                    },
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(
                                      minWidth: 44,
                                      minHeight: 44,
                                    ),
                                    icon: Icon(
                                      Icons.arrow_back_ios_new_rounded,
                                      color: darkColor,
                                      size: 22,
                                    ),
                                  ),
                                ),

                                Align(
                                  alignment:
                                  AlignmentDirectional.centerEnd,
                                  child: SizedBox(
                                    height: 44,
                                    child: ElevatedButton(
                                      onPressed: isSaving
                                          ? null
                                          : saveGrowthInformation,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: primaryColor,
                                        foregroundColor: Colors.white,
                                        padding: EdgeInsets.symmetric(
                                          horizontal:
                                          isVerySmall ? 12 : 18,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                          BorderRadius.circular(12),
                                        ),
                                        elevation: 0,
                                      ),
                                      child: isSaving
                                          ? const SizedBox(
                                        width: 21,
                                        height: 21,
                                        child:
                                        CircularProgressIndicator(
                                          strokeWidth: 2.3,
                                          color: Colors.white,
                                        ),
                                      )
                                          : Text(
                                        'حفظ',
                                        style: TextStyle(
                                          fontSize:
                                          isVerySmall ? 14 : 16,
                                          fontWeight:
                                          FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: isSmallScreen ? 35 : 45),


                          Row(
                            children: [
                              Icon(
                                Icons.bar_chart_rounded,
                                color: primaryColor,
                                size: 25,
                              ),
                              const SizedBox(width: 7),
                              Text(
                                'بيانات النمو',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: darkColor,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 18),

                          // =====================
                          // Height + Weight
                          // =====================
                          _responsivePair(
                            isVerySmall: isVerySmall,
                            first: TextFormField(
                              controller: heightController,
                              enabled: !isSaving,
                              style: TextStyle(color: darkColor),
                              keyboardType:
                              const TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                              textAlign: TextAlign.right,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                  RegExp(r'^\d{0,3}(\.\d{0,1})?'),
                                ),
                              ],
                              validator: validateHeight,
                              autovalidateMode:
                              AutovalidateMode.onUserInteraction,
                              onChanged: (_) {
                                calculateBmi();
                                setState(() {});
                              },
                              decoration: growthInputDecoration(
                                label: 'الطول',
                                hint: 'أدخل الطول',
                                suffix: 'cm',
                                icon: Icons.straighten_rounded,
                                errorText: null,
                                primaryColor: primaryColor,
                                borderColor: borderColor,
                                hintColor: hintColor,
                                fieldColor: cardColor,
                              ),
                            ),
                            second: TextFormField(
                              controller: weightController,
                              enabled: !isSaving,
                              style: TextStyle(color: darkColor),
                              keyboardType:
                              const TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                              textAlign: TextAlign.right,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                  RegExp(r'^\d{0,3}(\.\d{0,1})?'),
                                ),
                              ],
                              validator: validateWeight,
                              autovalidateMode:
                              AutovalidateMode.onUserInteraction,
                              onChanged: (_) {
                                calculateBmi();
                                setState(() {});
                              },
                              decoration: growthInputDecoration(
                                label: 'الوزن',
                                hint: 'أدخل الوزن',
                                suffix: 'kg',
                                icon: Icons.monitor_weight_outlined,
                                errorText: null,
                                primaryColor: primaryColor,
                                borderColor: borderColor,
                                hintColor: hintColor,
                                fieldColor: cardColor,
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // =====================
                          // BMI
                          // =====================
                          TextFormField(
                            controller: bmiController,
                            readOnly: true,
                            enableInteractiveSelection: false,
                            textAlign: TextAlign.right,
                            style: TextStyle(color: darkColor),
                            decoration: growthInputDecoration(
                              label: 'مؤشر كتلة الجسم',
                              hint:
                              'يُحسب تلقائيًا بعد إدخال الطول والوزن',
                              suffix: 'kg/m²',
                              icon: Icons.calculate_outlined,
                              errorText: null,
                              primaryColor: primaryColor,
                              borderColor: borderColor,
                              hintColor: hintColor,
                              fieldColor: cardColor,
                            ).copyWith(
                              fillColor: isDark
                                  ? const Color(0xff182326)
                                  : const Color(0xffF3F8F8),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // =====================
                          // Record Date
                          // =====================
                          InkWell(
                            onTap:
                            isSaving ? null : selectRecordDate,
                            borderRadius: BorderRadius.circular(14),
                            child: InputDecorator(
                              decoration: growthInputDecoration(
                                label: 'تاريخ القياس',
                                hint: 'اختر تاريخ القياس',
                                suffix: null,
                                icon:
                                Icons.calendar_month_outlined,
                                errorText: dateError,
                                primaryColor: primaryColor,
                                borderColor: borderColor,
                                hintColor: hintColor,
                                fieldColor: cardColor,
                              ),
                              child: Text(
                                recordDate == null
                                    ? 'اختر تاريخ القياس'
                                    : formatDate(recordDate),
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: recordDate == null
                                      ? hintColor
                                      : darkColor,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 270),

                          // =====================
                          // Info
                          // =====================
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 13,
                            ),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xff18272A)
                                  : const Color(0xffEEF7FA),
                              borderRadius:
                              BorderRadius.circular(13),
                            ),
                            child: Row(
                              mainAxisAlignment:
                              MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.info_outline_rounded,
                                  color: primaryColor,
                                  size: 20,
                                ),
                                const SizedBox(width: 7),
                                Flexible(
                                  child: Text(
                                    'يرجى التأكد من صحة القياسات قبل الحفظ',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: darkColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 25),
                        ],
                      ),
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

  Widget _responsivePair({
    required bool isVerySmall,
    required Widget first,
    required Widget second,
  }) {
    if (isVerySmall) {
      return Column(
        children: [
          first,
          const SizedBox(height: 16),
          second,
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: first),
        const SizedBox(width: 10),
        Expanded(child: second),
      ],
    );
  }

  InputDecoration growthInputDecoration({
    required String label,
    required String hint,
    required String? suffix,
    required IconData icon,
    required String? errorText,
    required Color primaryColor,
    required Color borderColor,
    required Color hintColor,
    required Color fieldColor,
  }) {
    final ThemeData theme = Theme.of(context);

    final bool isDark =
        theme.brightness == Brightness.dark;

    final Color textColor =
        theme.colorScheme.onSurface;

    final Color labelColor = isDark
        ? textColor.withOpacity(0.70)
        : const Color(0xff6F8086);

    final Color suffixColor = isDark
        ? textColor.withOpacity(0.70)
        : const Color(0xff5C6E75);

    return InputDecoration(
      labelText: label,
      hintText: hint,
      hintTextDirection: TextDirection.rtl,
      floatingLabelBehavior:
      FloatingLabelBehavior.auto,

      labelStyle: TextStyle(
        color: labelColor,
        fontSize: 14,
      ),

      floatingLabelStyle: TextStyle(
        color: primaryColor,
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),

      hintStyle: TextStyle(
        color: hintColor,
        fontSize: 14,
      ),

      suffixText: suffix,

      suffixStyle: TextStyle(
        color: suffixColor,
        fontSize: 13,
        fontWeight: FontWeight.bold,
      ),

      errorText: errorText,

      errorStyle: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
      ),

      prefixIcon: Icon(
        icon,
        color: primaryColor,
      ),

      filled: true,
      fillColor: fieldColor,

      contentPadding:
      const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 18,
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(14),
        borderSide: BorderSide(
          color: borderColor,
          width: 1.3,
        ),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(14),
        borderSide: BorderSide(
          color: primaryColor,
          width: 2,
        ),
      ),

      errorBorder: OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Colors.red,
          width: 1.3,
        ),
      ),

      focusedErrorBorder:
      OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Colors.red,
          width: 2,
        ),
      ),
    );
  }
}