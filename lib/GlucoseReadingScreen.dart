import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'validators.dart';

class GlucoseReadingScreen extends StatefulWidget {
  final String childName;
  final DateTime birthDate;
  final String gender;
  final String? childImagePath;

  const GlucoseReadingScreen({
    super.key,
    required this.childName,
    required this.birthDate,
    required this.gender,
    this.childImagePath,
  });

  @override
  State<GlucoseReadingScreen> createState() =>
      _GlucoseReadingScreenState();
}

class _GlucoseReadingScreenState
    extends State<GlucoseReadingScreen> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController glucoseLevelController =
  TextEditingController();

  String? selectedReadingType;
  String? selectedMeal;

  DateTime? readingDate;
  TimeOfDay? readingTime;

  String? readingTypeError;
  String? readingDateError;
  String? readingTimeError;
  String? mealError;

  bool isSaving = false;

  final List<String> readingTypes = [
    'قبل الوجبة',
    'بعد الوجبة',
    'صائم',
    'قبل النوم',
    'بعد الاستيقاظ',
    'قراءة عشوائية',
  ];

  final List<String> meals = [
    'الفطور',
    'الغداء',
    'العشاء',
    'وجبة خفيفة',
    'بدون وجبة',
  ];

  DateTime dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  String formatDate(DateTime? date) {
    if (date == null) {
      return '';
    }

    final String day =
    date.day.toString().padLeft(2, '0');

    final String month =
    date.month.toString().padLeft(2, '0');

    return '$day/$month/${date.year}';
  }

  String formatApiDate(DateTime date) {
    final String month =
    date.month.toString().padLeft(2, '0');

    final String day =
    date.day.toString().padLeft(2, '0');

    return '${date.year}-$month-$day';
  }

  String formatApiTime(TimeOfDay time) {
    final String hour =
    time.hour.toString().padLeft(2, '0');

    final String minute =
    time.minute.toString().padLeft(2, '0');

    return '$hour:$minute:00';
  }

  String formatTime(TimeOfDay? time) {
    if (time == null) {
      return '';
    }

    final int hour =
    time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;

    final String minute =
    time.minute.toString().padLeft(2, '0');

    final String period =
    time.period == DayPeriod.am ? 'ص' : 'م';

    return '$hour:$minute $period';
  }

  bool isToday(DateTime date) {
    final DateTime today = dateOnly(DateTime.now());

    return dateOnly(date) == today;
  }

  bool isFutureTimeToday() {
    if (readingDate == null ||
        readingTime == null ||
        !isToday(readingDate!)) {
      return false;
    }

    final DateTime now = DateTime.now();

    final DateTime selectedDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      readingTime!.hour,
      readingTime!.minute,
    );

    return selectedDateTime.isAfter(now);
  }

  Future<void> selectReadingDate() async {
    final DateTime today = dateOnly(DateTime.now());

    final DateTime childBirthDate =
    dateOnly(widget.birthDate);

    DateTime initialDate = readingDate ?? today;

    if (initialDate.isBefore(childBirthDate)) {
      initialDate = childBirthDate;
    }

    if (initialDate.isAfter(today)) {
      initialDate = today;
    }

    final DateTime? selectedDate =
    await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: childBirthDate,
      lastDate: today,
      helpText: 'اختيار تاريخ القراءة',
      cancelText: 'إلغاء',
      confirmText: 'اختيار',
    );

    if (selectedDate == null) {
      return;
    }

    setState(() {
      readingDate = selectedDate;
      readingDateError = null;

      if (readingTime != null &&
          isFutureTimeToday()) {
        readingTime = null;
        readingTimeError = null;
      }
    });
  }

  Future<void> selectReadingTime() async {
    final TimeOfDay? selectedTime =
    await showTimePicker(
      context: context,
      initialTime:
      readingTime ?? TimeOfDay.now(),
      helpText: 'اختيار وقت القراءة',
      cancelText: 'إلغاء',
      confirmText: 'اختيار',
    );

    if (selectedTime == null) {
      return;
    }

    setState(() {
      readingTime = selectedTime;

      if (readingDate != null &&
          isFutureTimeToday()) {
        readingTimeError =
        'لا يمكن اختيار وقت مستقبلي';
      } else {
        readingTimeError = null;
      }
    });
  }

  bool validateInformation() {
    final bool formIsValid =
        formKey.currentState?.validate() ?? false;

    setState(() {
      readingTypeError =
      selectedReadingType == null
          ? 'مطلوب'
          : null;

      readingDateError =
      readingDate == null ? 'مطلوب' : null;

      if (readingTime == null) {
        readingTimeError = 'مطلوب';
      } else if (isFutureTimeToday()) {
        readingTimeError =
        'لا يمكن اختيار وقت مستقبلي';
      } else {
        readingTimeError = null;
      }

      mealError =
      selectedMeal == null ? 'مطلوب' : null;
    });

    return formIsValid &&
        readingTypeError == null &&
        readingDateError == null &&
        readingTimeError == null &&
        mealError == null;
  }

  Future<void> saveReading() async {
    if (isSaving) {
      return;
    }

    FocusScope.of(context).unfocus();

    if (!validateInformation()) {
      return;
    }

    setState(() {
      isSaving = true;
    });

    final double glucoseLevel = double.parse(
      glucoseLevelController.text.trim(),
    );

    /*
      ==========================================
      مستقبلًا عند ربط Laravel
      ==========================================

      POST /api/children/{childId}/glucose-readings

      Header:
      Authorization: Bearer TOKEN

      {
        "reading_type": selectedReadingType,
        "glucose_level": glucoseLevel,
        "unit": "mg/dL",
        "reading_date":
            formatApiDate(readingDate!),
        "reading_time":
            formatApiTime(readingTime!),
        "meal": selectedMeal
      }

      Laravel يأخذ child_id من المسار
      ويتأكد أن الطفل تابع للمستخدم الحالي.
    */

    debugPrint(
      'Reading type: $selectedReadingType',
    );

    debugPrint(
      'Glucose: $glucoseLevel mg/dL',
    );

    debugPrint(
      'Date: ${formatApiDate(readingDate!)}',
    );

    debugPrint(
      'Time: ${formatApiTime(readingTime!)}',
    );

    debugPrint('Meal: $selectedMeal');

    await Future.delayed(
      const Duration(seconds: 2),
    );

    if (!mounted) {
      return;
    }

    glucoseLevelController.clear();

    setState(() {
      isSaving = false;

      selectedReadingType = null;
      readingDate = null;
      readingTime = null;
      selectedMeal = null;

      readingTypeError = null;
      readingDateError = null;
      readingTimeError = null;
      mealError = null;

      formKey = GlobalKey<FormState>();
    });

    ScaffoldMessenger.of(context)
        .hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'تم حفظ قراءة السكر بنجاح',
          textAlign: TextAlign.center,
        ),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  void dispose() {
    glucoseLevelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    final Color primaryColor =
        theme.primaryColor;

    final Color darkColor =
        theme.colorScheme.onSurface;

    final Color cardColor =
        theme.cardColor;

    final bool isDark =
        theme.brightness == Brightness.dark;

    final Color hintColor = isDark
        ? darkColor.withOpacity(0.52)
        : const Color(0xff8A989D);

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double screenWidth =
                constraints.maxWidth;

            final double screenHeight =
                constraints.maxHeight;

            final bool isVerySmall =
                screenWidth < 390;

            final bool isSmallScreen =
                screenWidth < 430 ||
                    screenHeight < 650;

            final bool isTablet =
                screenWidth >= 600;

            final double horizontalPadding =
            isVerySmall
                ? 14
                : isTablet
                ? 36
                : 20;

            return Directionality(
              textDirection: TextDirection.rtl,
              child: SingleChildScrollView(
                physics:
                const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical:
                  isSmallScreen ? 12 : 16,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints:
                    const BoxConstraints(
                      maxWidth: 720,
                    ),
                    child: Form(
                      key: formKey,
                      child: Column(
                        children: [
                          // العنوان والسهم وزر الحفظ
                          // بنفس تنسيق الواجهات السابقة.
                          SizedBox(
                            height: 48,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Padding(
                                  padding:
                                  const EdgeInsets.symmetric(
                                    horizontal: 75,
                                  ),
                                  child: Text(
                                    'تسجيل قراءة السكر',
                                    textAlign:
                                    TextAlign.center,
                                    maxLines: 1,
                                    overflow:
                                    TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize:
                                      isVerySmall ? 17 : 21,
                                      fontWeight:
                                      FontWeight.bold,
                                      color: darkColor,
                                    ),
                                  ),
                                ),

                                Align(
                                  alignment:
                                  AlignmentDirectional
                                      .centerStart,
                                  child: IconButton(
                                    onPressed: isSaving
                                        ? null
                                        : () {
                                      Navigator.pop(
                                        context,
                                      );
                                    },
                                    padding: EdgeInsets.zero,
                                    constraints:
                                    const BoxConstraints(
                                      minWidth: 44,
                                      minHeight: 44,
                                    ),
                                    icon: Icon(
                                      Icons
                                          .arrow_back_ios_new_rounded,
                                      color: darkColor,
                                      size: 22,
                                    ),
                                  ),
                                ),

                                Align(
                                  alignment:
                                  AlignmentDirectional
                                      .centerEnd,
                                  child: SizedBox(
                                    height: 44,
                                    child: ElevatedButton(
                                      onPressed: isSaving
                                          ? null
                                          : saveReading,
                                      style:
                                      ElevatedButton
                                          .styleFrom(
                                        backgroundColor:
                                        primaryColor,
                                        foregroundColor:
                                        Colors.white,
                                        padding:
                                        EdgeInsets.symmetric(
                                          horizontal:
                                          isVerySmall
                                              ? 14
                                              : 18,
                                        ),
                                        shape:
                                        RoundedRectangleBorder(
                                          borderRadius:
                                          BorderRadius
                                              .circular(12),
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
                                          isVerySmall
                                              ? 14
                                              : 16,
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

                          // العبارة التوضيحية
                          SizedBox(
                            height:
                            isSmallScreen ? 16 : 22,
                          ),

                          Text(
                            'سجّل مستوى السكر لطفلك للحفاظ على متابعة دقيقة',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize:
                              isSmallScreen ? 12 : 13,
                              color: hintColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),

                          SizedBox(
                            height:
                            isSmallScreen ? 40 : 48,
                          ),

                          // نصائح مهمة
                          Container(
                            width: double.infinity,
                            padding:
                            const EdgeInsets.symmetric(
                              horizontal: 15,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xff2A281E)
                                  : const Color(0xffFFF9E8),
                              borderRadius:
                              BorderRadius.circular(15),
                              border: Border.all(
                                color: isDark
                                    ? const Color(0xff5B5130)
                                    : const Color(0xffF1E4B8),
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons
                                      .lightbulb_outline_rounded,
                                  color: Color(0xffD7A82C),
                                  size: 25,
                                ),

                                const SizedBox(width: 10),

                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'نصائح مهمة',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight:
                                          FontWeight.bold,
                                          color: darkColor,
                                        ),
                                      ),

                                      const SizedBox(height: 7),

                                      Text(
                                        '• اغسل يديك قبل القياس.\n'
                                            '• تأكد من جاهزية جهاز القياس.\n'
                                            '• سجّل القراءة فور القياس لتوثيقها بدقة.',
                                        style: TextStyle(
                                          fontSize: 12.5,
                                          height: 1.7,
                                          color: isDark
                                              ? darkColor
                                              .withOpacity(0.70)
                                              : const Color(
                                            0xff66777D,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 22),

                          // عنوان بيانات قراءة السكر
                          Row(
                            children: [
                              Icon(
                                Icons.monitor_heart_outlined,
                                color: primaryColor,
                                size: 25,
                              ),

                              const SizedBox(width: 7),

                              Text(
                                'بيانات قراءة السكر',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: darkColor,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 17),

                          // نوع القراءة ومستوى السكر
                          if (isVerySmall)
                            Column(
                              children: [
                                _buildReadingTypeField(
                                  primaryColor: primaryColor,
                                  cardColor: cardColor,
                                  textColor: darkColor,
                                ),

                                const SizedBox(height: 16),

                                _buildGlucoseField(
                                  primaryColor: primaryColor,
                                  cardColor: cardColor,
                                  textColor: darkColor,
                                ),
                              ],
                            )
                          else
                            Row(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child:
                                  _buildReadingTypeField(
                                    primaryColor: primaryColor,
                                    cardColor: cardColor,
                                    textColor: darkColor,
                                  ),
                                ),

                                const SizedBox(width: 10),

                                Expanded(
                                  child: _buildGlucoseField(
                                    primaryColor: primaryColor,
                                    cardColor: cardColor,
                                    textColor: darkColor,
                                  ),
                                ),
                              ],
                            ),

                          const SizedBox(height: 16),

                          // وقت القراءة وتاريخ القراءة
                          if (isVerySmall)
                            Column(
                              children: [
                                _buildTimeField(
                                  primaryColor: primaryColor,
                                  hintColor: hintColor,
                                  darkColor: darkColor,
                                  cardColor: cardColor,
                                ),

                                const SizedBox(height: 16),

                                _buildDateField(
                                  primaryColor: primaryColor,
                                  hintColor: hintColor,
                                  darkColor: darkColor,
                                  cardColor: cardColor,
                                ),
                              ],
                            )
                          else
                            Row(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: _buildTimeField(
                                    primaryColor: primaryColor,
                                    hintColor: hintColor,
                                    darkColor: darkColor,
                                    cardColor: cardColor,
                                  ),
                                ),

                                const SizedBox(width: 10),

                                Expanded(
                                  child: _buildDateField(
                                    primaryColor: primaryColor,
                                    hintColor: hintColor,
                                    darkColor: darkColor,
                                    cardColor: cardColor,
                                  ),
                                ),
                              ],
                            ),

                          const SizedBox(height: 16),

                          // الوجبة المرتبطة
                          Directionality(
                            textDirection: TextDirection.rtl,
                            child:
                            DropdownButtonFormField<String>(
                              value: selectedMeal,
                              isExpanded: true,
                              dropdownColor: cardColor,
                              style: TextStyle(
                                color: darkColor,
                                fontSize: 13,
                              ),
                              iconEnabledColor: darkColor,
                              alignment:
                              AlignmentDirectional.centerStart,
                              decoration:
                              glucoseInputDecoration(
                                label: 'الوجبة المرتبطة',
                                hint: 'اختر الوجبة',
                                icon: Icons.restaurant_outlined,
                                errorText: mealError,
                                primaryColor: primaryColor,
                                fieldColor: cardColor,
                              ),
                              items: meals.map((meal) {
                                return DropdownMenuItem<String>(
                                  value: meal,
                                  child: SizedBox(
                                    width: double.infinity,
                                    child: Text(
                                      meal,
                                      textAlign: TextAlign.right,
                                      overflow:
                                      TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: darkColor,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: isSaving
                                  ? null
                                  : (value) {
                                setState(() {
                                  selectedMeal = value;
                                  mealError = null;
                                });
                              },
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

  Widget _buildReadingTypeField({
    required Color primaryColor,
    required Color cardColor,
    required Color textColor,
  }) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: DropdownButtonFormField<String>(
        value: selectedReadingType,
        isExpanded: true,
        dropdownColor: cardColor,
        style: TextStyle(
          color: textColor,
          fontSize: 13,
        ),
        iconEnabledColor: textColor,
        alignment: AlignmentDirectional.centerStart,
        decoration: glucoseInputDecoration(
          label: 'نوع القراءة',
          hint: 'اختر نوع القراءة',
          icon: Icons.assignment_outlined,
          errorText: readingTypeError,
          primaryColor: primaryColor,
          fieldColor: cardColor,
        ),
        items: readingTypes.map((type) {
          return DropdownMenuItem<String>(
            value: type,
            child: SizedBox(
              width: double.infinity,
              child: Text(
                type,
                textAlign: TextAlign.right,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  color: textColor,
                ),
              ),
            ),
          );
        }).toList(),
        onChanged: isSaving
            ? null
            : (value) {
          setState(() {
            selectedReadingType = value;
            readingTypeError = null;
          });
        },
      ),
    );
  }

  Widget _buildGlucoseField({
    required Color primaryColor,
    required Color cardColor,
    required Color textColor,
  }) {
    return TextFormField(
      controller: glucoseLevelController,
      enabled: !isSaving,
      textAlign: TextAlign.right,
      style: TextStyle(
        color: textColor,
      ),
      keyboardType:
      const TextInputType.numberWithOptions(
        decimal: true,
      ),
      inputFormatters: [
        FilteringTextInputFormatter.allow(
          RegExp(r'^\d{0,3}(\.\d{0,1})?'),
        ),
      ],
      autovalidateMode:
      AutovalidateMode.onUserInteraction,
      validator: Validators.glucoseReading,
      decoration: glucoseInputDecoration(
        label: 'مستوى السكر',
        hint: 'أدخل القراءة',
        icon: Icons.water_drop_outlined,
        errorText: null,
        suffixText: 'mg/dL',
        primaryColor: primaryColor,
        fieldColor: cardColor,
      ),
    );
  }

  Widget _buildTimeField({
    required Color primaryColor,
    required Color hintColor,
    required Color darkColor,
    required Color cardColor,
  }) {
    return InkWell(
      onTap: isSaving ? null : selectReadingTime,
      borderRadius: BorderRadius.circular(14),
      child: InputDecorator(
        decoration: glucoseInputDecoration(
          label: 'وقت القراءة',
          hint: 'اختر الوقت',
          icon: Icons.access_time_rounded,
          errorText: readingTimeError,
          primaryColor: primaryColor,
          fieldColor: cardColor,
        ),
        child: Text(
          readingTime == null
              ? 'اختر الوقت'
              : formatTime(readingTime),
          textAlign: TextAlign.right,
          style: TextStyle(
            fontSize: 13,
            color: readingTime == null
                ? hintColor
                : darkColor,
          ),
        ),
      ),
    );
  }

  Widget _buildDateField({
    required Color primaryColor,
    required Color hintColor,
    required Color darkColor,
    required Color cardColor,
  }) {
    return InkWell(
      onTap: isSaving ? null : selectReadingDate,
      borderRadius: BorderRadius.circular(14),
      child: InputDecorator(
        decoration: glucoseInputDecoration(
          label: 'تاريخ القراءة',
          hint: 'اختر التاريخ',
          icon: Icons.calendar_month_outlined,
          errorText: readingDateError,
          primaryColor: primaryColor,
          fieldColor: cardColor,
        ),
        child: Text(
          readingDate == null
              ? 'اختر التاريخ'
              : formatDate(readingDate),
          textAlign: TextAlign.right,
          style: TextStyle(
            fontSize: 13,
            color: readingDate == null
                ? hintColor
                : darkColor,
          ),
        ),
      ),
    );
  }

  InputDecoration glucoseInputDecoration({
    required String label,
    required String hint,
    required IconData icon,
    required String? errorText,
    required Color primaryColor,
    required Color fieldColor,
    String? suffixText,
  }) {
    final ThemeData theme = Theme.of(context);

    final bool isDark =
        theme.brightness == Brightness.dark;

    final Color textColor =
        theme.colorScheme.onSurface;

    final Color borderColor = isDark
        ? textColor.withOpacity(0.14)
        : const Color(0xffD7E7E7);

    final Color hintColor = isDark
        ? textColor.withOpacity(0.52)
        : const Color(0xff8A989D);

    final Color labelColor = isDark
        ? textColor.withOpacity(0.70)
        : const Color(0xff6F8086);

    final Color suffixColor = isDark
        ? textColor.withOpacity(0.70)
        : const Color(0xff66777D);

    return InputDecoration(
      labelText: label,
      hintText: hint,
      hintTextDirection: TextDirection.rtl,
      suffixText: suffixText,

      floatingLabelBehavior:
      FloatingLabelBehavior.auto,

      labelStyle: TextStyle(
        color: labelColor,
        fontSize: 13,
      ),

      floatingLabelStyle: TextStyle(
        color: primaryColor,
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),

      hintStyle: TextStyle(
        color: hintColor,
        fontSize: 12,
      ),

      suffixStyle: TextStyle(
        color: suffixColor,
        fontSize: 11,
        fontWeight: FontWeight.w600,
      ),

      errorText: errorText,

      errorStyle: const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w500,
      ),

      prefixIcon: Icon(
        icon,
        color: primaryColor,
        size: 21,
      ),

      filled: true,
      fillColor: fieldColor,

      contentPadding:
      const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 17,
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: borderColor,
          width: 1.3,
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
          width: 1.3,
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