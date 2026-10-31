import 'dart:io';
import 'package:flutter/material.dart';
import 'validators.dart';
class ActivityScreen extends StatefulWidget {
  final String childName;
  final DateTime birthDate;
  final String gender;
  final String? childImagePath;

  const ActivityScreen({
    super.key,
    required this.childName,
    required this.birthDate,
    required this.gender,
    this.childImagePath,
  });

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  String? selectedActivity;
  String? selectedDuration;
  String? selectedIntensity;

  DateTime? activityDate;
  TimeOfDay? activityTime;

  final TextEditingController customActivityController =
  TextEditingController();

  final FocusNode customActivityFocusNode = FocusNode();

  bool isOtherActivity = false;
  bool isSaving = false;

  String? dateError;
  String? timeError;

  DateTime dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  bool isToday(DateTime date) {
    return dateOnly(date) == dateOnly(DateTime.now());
  }

  bool isFutureTimeToday() {
    if (activityDate == null ||
        activityTime == null ||
        !isToday(activityDate!)) {
      return false;
    }

    final DateTime now = DateTime.now();

    final DateTime selectedDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      activityTime!.hour,
      activityTime!.minute,
    );

    return selectedDateTime.isAfter(now);
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

  String formatApiTime(TimeOfDay time) {
    final String hour =
    time.hour.toString().padLeft(2, '0');

    final String minute =
    time.minute.toString().padLeft(2, '0');

    return '$hour:$minute:00';
  }

  Future<void> selectActivityDate() async {
    final DateTime today =
    dateOnly(DateTime.now());

    final DateTime childBirthDate =
    dateOnly(widget.birthDate);

    DateTime initialDate =
        activityDate ?? today;

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
      helpText: 'اختيار تاريخ النشاط',
      cancelText: 'إلغاء',
      confirmText: 'اختيار',
    );

    if (selectedDate == null) {
      return;
    }

    setState(() {
      activityDate = selectedDate;
      dateError = null;

      if (activityTime != null &&
          isFutureTimeToday()) {
        activityTime = null;
        timeError = null;
      }
    });
  }

  Future<void> selectActivityTime() async {
    final TimeOfDay? selectedTime =
    await showTimePicker(
      context: context,
      initialTime:
      activityTime ?? TimeOfDay.now(),
      helpText: 'اختيار وقت النشاط',
      cancelText: 'إلغاء',
      confirmText: 'اختيار',
    );

    if (selectedTime == null) {
      return;
    }

    setState(() {
      activityTime = selectedTime;

      if (activityDate != null &&
          isFutureTimeToday()) {
        timeError =
        'لا يمكن اختيار وقت مستقبلي';
      } else {
        timeError = null;
      }
    });
  }

  void selectOtherActivity() {
    setState(() {
      selectedActivity = null;
      isOtherActivity = true;
      customActivityController.clear();
    });

    WidgetsBinding.instance
        .addPostFrameCallback((_) {
      if (mounted) {
        customActivityFocusNode.requestFocus();
      }
    });
  }

  void returnToActivityOptions() {
    FocusScope.of(context).unfocus();

    setState(() {
      selectedActivity = null;
      isOtherActivity = false;
      customActivityController.clear();
    });
  }

  String get finalActivityName {
    if (isOtherActivity) {
      return customActivityController.text.trim();
    }

    return selectedActivity ?? '';
  }

  bool validateDateAndTime() {
    setState(() {
      dateError =
      activityDate == null ? 'مطلوب' : null;

      if (activityTime == null) {
        timeError = 'مطلوب';
      } else if (isFutureTimeToday()) {
        timeError =
        'لا يمكن اختيار وقت مستقبلي';
      } else {
        timeError = null;
      }
    });

    return dateError == null &&
        timeError == null;
  }

  Future<void> saveActivity() async {
    if (isSaving) {
      return;
    }

    FocusScope.of(context).unfocus();

    final bool formIsValid =
        formKey.currentState?.validate() ?? false;

    final bool dateTimeValid =
    validateDateAndTime();

    if (!formIsValid || !dateTimeValid) {
      return;
    }

    setState(() {
      isSaving = true;
    });

    /*
      مستقبلًا عند ربط Laravel:

      POST /api/children/{childId}/activities

      Authorization: Bearer TOKEN

      {
        "activity_name": finalActivityName,
        "duration": selectedDuration,
        "intensity": selectedIntensity,
        "activity_date":
            formatApiDate(activityDate!),
        "activity_time":
            formatApiTime(activityTime!),
      }
    */

    debugPrint(
        'Activity: $finalActivityName');
    debugPrint(
        'Duration: $selectedDuration');
    debugPrint(
        'Intensity: $selectedIntensity');
    debugPrint(
        'Date: ${formatApiDate(activityDate!)}');
    debugPrint(
        'Time: ${formatApiTime(activityTime!)}');

    await Future.delayed(
      const Duration(seconds: 2),
    );

    if (!mounted) {
      return;
    }

    setState(() {
      isSaving = false;

      selectedActivity = null;
      isOtherActivity = false;

      selectedDuration = null;
      selectedIntensity = null;

      activityDate = null;
      activityTime = null;

      dateError = null;
      timeError = null;

      formKey = GlobalKey<FormState>();
    });

    ScaffoldMessenger.of(context)
        .hideCurrentSnackBar();

    ScaffoldMessenger.of(context)
        .showSnackBar(
      const SnackBar(
        content: Text(
          'تم حفظ النشاط بنجاح',
          textAlign: TextAlign.center,
        ),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  void dispose() {
    customActivityController.dispose();
    customActivityFocusNode.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme =
    Theme.of(context);

    final Color primaryColor =
        theme.primaryColor;

    final Color darkColor =
        theme.colorScheme.onSurface;

    final Color cardColor =
        theme.cardColor;

    final Color borderColor =
    theme.brightness == Brightness.dark
        ? darkColor.withOpacity(0.14)
        : const Color(0xffD7E7E7);

    final Color hintColor =
    theme.brightness == Brightness.dark
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
                  horizontal:
                  horizontalPadding,
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
                          SizedBox(
                            height: 48,
                            child: Stack(
                              alignment:
                              Alignment.center,
                              children: [
                                Text(
                                  'تسجيل النشاط',
                                  textAlign:
                                  TextAlign.center,
                                  style: TextStyle(
                                    fontSize:
                                    isVerySmall
                                        ? 18
                                        : 22,
                                    fontWeight:
                                    FontWeight
                                        .bold,
                                    color:
                                    darkColor,
                                  ),
                                ),

                                Align(
                                  alignment:
                                  AlignmentDirectional
                                      .centerStart,
                                  child: IconButton(
                                    onPressed:
                                    isSaving
                                        ? null
                                        : () {
                                      Navigator.pop(
                                        context,
                                      );
                                    },
                                    padding:
                                    EdgeInsets.zero,
                                    constraints:
                                    const BoxConstraints(
                                      minWidth: 44,
                                      minHeight: 44,
                                    ),
                                    icon: Icon(
                                      Icons
                                          .arrow_back_ios_new_rounded,
                                      color:
                                      darkColor,
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
                                    child:
                                    ElevatedButton(
                                      onPressed:
                                      isSaving
                                          ? null
                                          : saveActivity,
                                      style:
                                      ElevatedButton
                                          .styleFrom(
                                        backgroundColor:
                                        primaryColor,
                                        foregroundColor:
                                        Colors
                                            .white,
                                        padding:
                                        EdgeInsets
                                            .symmetric(
                                          horizontal:
                                          isVerySmall
                                              ? 14
                                              : 18,
                                        ),
                                        shape:
                                        RoundedRectangleBorder(
                                          borderRadius:
                                          BorderRadius
                                              .circular(
                                            12,
                                          ),
                                        ),
                                        elevation: 0,
                                      ),
                                      child: isSaving
                                          ? const SizedBox(
                                        width:
                                        21,
                                        height:
                                        21,
                                        child:
                                        CircularProgressIndicator(
                                          strokeWidth:
                                          2.3,
                                          color:
                                          Colors.white,
                                        ),
                                      )
                                          : Text(
                                        'حفظ',
                                        style:
                                        TextStyle(
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

                          SizedBox(
                            height:
                            isSmallScreen
                                ? 35
                                : 45,
                          ),

                          Row(
                            children: [
                              Icon(
                                Icons
                                    .directions_run_rounded,
                                color:
                                primaryColor,
                                size: 24,
                              ),

                              const SizedBox(
                                width: 7,
                              ),

                              Text(
                                'بيانات النشاط',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight:
                                  FontWeight.bold,
                                  color: darkColor,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(
                            height: 16,
                          ),

                          _responsivePair(
                            isVerySmall:
                            isVerySmall,
                            first: _activityField(
                              primaryColor:
                              primaryColor,
                              borderColor:
                              borderColor,
                              fieldColor:
                              cardColor,
                              textColor:
                              darkColor,
                              hintColor:
                              hintColor,
                            ),
                            second:
                            _durationField(
                              primaryColor:
                              primaryColor,
                              borderColor:
                              borderColor,
                              fieldColor:
                              cardColor,
                              textColor:
                              darkColor,
                              hintColor:
                              hintColor,
                            ),
                          ),

                          const SizedBox(
                            height: 16,
                          ),

                          _responsivePair(
                            isVerySmall:
                            isVerySmall,
                            first:
                            _intensityField(
                              primaryColor:
                              primaryColor,
                              borderColor:
                              borderColor,
                              fieldColor:
                              cardColor,
                              textColor:
                              darkColor,
                              hintColor:
                              hintColor,
                            ),
                            second: _dateField(
                              primaryColor:
                              primaryColor,
                              borderColor:
                              borderColor,
                              hintColor:
                              hintColor,
                              darkColor:
                              darkColor,
                              fieldColor:
                              cardColor,
                            ),
                          ),

                          const SizedBox(
                            height: 16,
                          ),

                          _timeField(
                            primaryColor:
                            primaryColor,
                            borderColor:
                            borderColor,
                            hintColor:
                            hintColor,
                            darkColor:
                            darkColor,
                            fieldColor:
                            cardColor,
                          ),

                          const SizedBox(
                            height: 300,
                          ),

                          Container(
                            width:
                            double.infinity,
                            padding:
                            const EdgeInsets
                                .symmetric(
                              horizontal: 14,
                              vertical: 13,
                            ),
                            decoration:
                            BoxDecoration(
                              color: theme
                                  .brightness ==
                                  Brightness.dark
                                  ? primaryColor
                                  .withOpacity(
                                  0.08)
                                  : const Color(
                                  0xffEEF7FA),
                              borderRadius:
                              BorderRadius
                                  .circular(
                                13,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment:
                              MainAxisAlignment
                                  .center,
                              children: [
                                Icon(
                                  Icons
                                      .info_outline_rounded,
                                  color:
                                  primaryColor,
                                  size: 20,
                                ),

                                const SizedBox(
                                  width: 7,
                                ),

                                Flexible(
                                  child: Text(
                                    'يرجى التأكد من صحة البيانات قبل الحفظ',
                                    textAlign:
                                    TextAlign
                                        .center,
                                    style:
                                    TextStyle(
                                      fontSize: 13,
                                      color:
                                      darkColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(
                            height: 25,
                          ),
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
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Expanded(child: first),
        const SizedBox(width: 10),
        Expanded(child: second),
      ],
    );
  }

  Widget _activityField({
    required Color primaryColor,
    required Color borderColor,
    required Color fieldColor,
    required Color textColor,
    required Color hintColor,
  }) {
    if (isOtherActivity) {
      return TextFormField(
        controller:
        customActivityController,
        focusNode:
        customActivityFocusNode,
        enabled: !isSaving,
        autofocus: true,
        textAlign: TextAlign.right,
        style: TextStyle(
          color: textColor,
        ),
        autovalidateMode:
        AutovalidateMode
            .onUserInteraction,
        validator: (value) {
          return Validators.arabicText(
            value: value,
            minLength: 2,
            maxLength: 50,
          );
        },
        decoration: inputDecoration(
          icon:
          Icons.directions_run_rounded,
          borderColor: borderColor,
          primaryColor: primaryColor,
          errorText: null,
          fieldColor: fieldColor,
        ).copyWith(
          hintText: 'اكتب اسم النشاط',
          hintStyle: TextStyle(
            color: hintColor,
          ),
          hintTextDirection:
          TextDirection.rtl,
          suffixIcon: IconButton(
            tooltip: 'الرجوع للخيارات',
            onPressed: isSaving
                ? null
                : returnToActivityOptions,
            icon: Icon(
              Icons
                  .keyboard_arrow_down_rounded,
              color: textColor,
            ),
          ),
        ),
      );
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child:
      DropdownButtonFormField<String>(
        value: selectedActivity,
        isExpanded: true,
        dropdownColor: fieldColor,
        style: TextStyle(
          color: textColor,
          fontSize: 14,
        ),
        iconEnabledColor: textColor,
        alignment:
        AlignmentDirectional.centerStart,
        validator: (value) {
          if (!isOtherActivity &&
              value == null) {
            return 'مطلوب';
          }

          return null;
        },
        decoration: inputDecoration(
          icon:
          Icons.directions_run_rounded,
          borderColor: borderColor,
          primaryColor: primaryColor,
          errorText: null,
          fieldColor: fieldColor,
        ),
        hint: _RightText(
          'نوع النشاط',
          isHint: true,
          textColor: textColor,
          hintColor: hintColor,
        ),
        items: [
          _dropdownItem(
            'المشي',
            textColor,
            hintColor,
          ),
          _dropdownItem(
            'الجري',
            textColor,
            hintColor,
          ),
          _dropdownItem(
            'السباحة',
            textColor,
            hintColor,
          ),
          _dropdownItem(
            'ركوب الدراجة',
            textColor,
            hintColor,
          ),
          _dropdownItem(
            'كرة القدم',
            textColor,
            hintColor,
          ),
          _dropdownItem(
            'نشاط آخر',
            textColor,
            hintColor,
          ),
        ],
        onChanged: isSaving
            ? null
            : (value) {
          if (value ==
              'نشاط آخر') {
            selectOtherActivity();
            return;
          }

          setState(() {
            selectedActivity =
                value;
          });
        },
      ),
    );
  }

  Widget _durationField({
    required Color primaryColor,
    required Color borderColor,
    required Color fieldColor,
    required Color textColor,
    required Color hintColor,
  }) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child:
      DropdownButtonFormField<String>(
        value: selectedDuration,
        isExpanded: true,
        dropdownColor: fieldColor,
        style: TextStyle(
          color: textColor,
          fontSize: 14,
        ),
        iconEnabledColor: textColor,
        alignment:
        AlignmentDirectional.centerStart,
        validator: (value) =>
        value == null ? 'مطلوب' : null,
        decoration: inputDecoration(
          icon: Icons.access_time_rounded,
          borderColor: borderColor,
          primaryColor: primaryColor,
          errorText: null,
          fieldColor: fieldColor,
        ),
        hint: _RightText(
          'مدة النشاط',
          isHint: true,
          textColor: textColor,
          hintColor: hintColor,
        ),
        items: [
          _dropdownItem(
            '15 دقيقة',
            textColor,
            hintColor,
          ),
          _dropdownItem(
            '30 دقيقة',
            textColor,
            hintColor,
          ),
          _dropdownItem(
            '45 دقيقة',
            textColor,
            hintColor,
          ),
          _dropdownItem(
            'ساعة',
            textColor,
            hintColor,
          ),
          _dropdownItem(
            'أكثر من ساعة',
            textColor,
            hintColor,
          ),
        ],
        onChanged: isSaving
            ? null
            : (value) {
          setState(() {
            selectedDuration =
                value;
          });
        },
      ),
    );
  }

  Widget _intensityField({
    required Color primaryColor,
    required Color borderColor,
    required Color fieldColor,
    required Color textColor,
    required Color hintColor,
  }) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child:
      DropdownButtonFormField<String>(
        value: selectedIntensity,
        isExpanded: true,
        dropdownColor: fieldColor,
        style: TextStyle(
          color: textColor,
          fontSize: 14,
        ),
        iconEnabledColor: textColor,
        alignment:
        AlignmentDirectional.centerStart,
        validator: (value) =>
        value == null ? 'مطلوب' : null,
        decoration: inputDecoration(
          icon: Icons.bar_chart_rounded,
          borderColor: borderColor,
          primaryColor: primaryColor,
          errorText: null,
          fieldColor: fieldColor,
        ),
        hint: _RightText(
          'شدة النشاط',
          isHint: true,
          textColor: textColor,
          hintColor: hintColor,
        ),
        items: [
          _dropdownItem(
            'خفيف',
            textColor,
            hintColor,
          ),
          _dropdownItem(
            'متوسط',
            textColor,
            hintColor,
          ),
          _dropdownItem(
            'شديد',
            textColor,
            hintColor,
          ),
        ],
        onChanged: isSaving
            ? null
            : (value) {
          setState(() {
            selectedIntensity =
                value;
          });
        },
      ),
    );
  }

  DropdownMenuItem<String> _dropdownItem(
      String value,
      Color textColor,
      Color hintColor,
      ) {
    return DropdownMenuItem<String>(
      value: value,
      child: _RightText(
        value,
        textColor: textColor,
        hintColor: hintColor,
      ),
    );
  }

  Widget _dateField({
    required Color primaryColor,
    required Color borderColor,
    required Color hintColor,
    required Color darkColor,
    required Color fieldColor,
  }) {
    return InkWell(
      onTap:
      isSaving ? null : selectActivityDate,
      borderRadius:
      BorderRadius.circular(14),
      child: InputDecorator(
        decoration: inputDecoration(
          icon:
          Icons.calendar_month_outlined,
          borderColor: borderColor,
          primaryColor: primaryColor,
          errorText: dateError,
          fieldColor: fieldColor,
        ),
        child: Text(
          activityDate == null
              ? 'تاريخ النشاط'
              : formatDate(activityDate),
          textAlign: TextAlign.right,
          style: TextStyle(
            color: activityDate == null
                ? hintColor
                : darkColor,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _timeField({
    required Color primaryColor,
    required Color borderColor,
    required Color hintColor,
    required Color darkColor,
    required Color fieldColor,
  }) {
    return InkWell(
      onTap:
      isSaving ? null : selectActivityTime,
      borderRadius:
      BorderRadius.circular(14),
      child: InputDecorator(
        decoration: inputDecoration(
          icon: Icons.access_time_rounded,
          borderColor: borderColor,
          primaryColor: primaryColor,
          errorText: timeError,
          fieldColor: fieldColor,
        ),
        child: Text(
          activityTime == null
              ? 'وقت النشاط'
              : formatTime(activityTime),
          textAlign: TextAlign.right,
          style: TextStyle(
            color: activityTime == null
                ? hintColor
                : darkColor,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  InputDecoration inputDecoration({
    required IconData icon,
    required Color borderColor,
    required Color primaryColor,
    required String? errorText,
    required Color fieldColor,
  }) {
    return InputDecoration(
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
        horizontal: 12,
        vertical: 17,
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

class _RightText extends StatelessWidget {
  final String text;
  final bool isHint;
  final Color textColor;
  final Color hintColor;

  const _RightText(
      this.text, {
        this.isHint = false,
        required this.textColor,
        required this.hintColor,
      });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Text(
        text,
        textAlign: TextAlign.right,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color:
          isHint ? hintColor : textColor,
          fontSize: 14,
        ),
      ),
    );
  }
}