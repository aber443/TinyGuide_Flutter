import 'package:flutter/material.dart';
import 'validators.dart';

class MealScreen extends StatefulWidget {
  final String childName;
  final DateTime birthDate;
  final String gender;
  final String? childImagePath;

  const MealScreen({
    super.key,
    required this.childName,
    required this.birthDate,
    required this.gender,
    this.childImagePath,
  });

  @override
  State<MealScreen> createState() => _MealScreenState();
}

class _MealScreenState extends State<MealScreen> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  String? selectedMealType;
  String? selectedMealName;
  String? selectedPortionSize;

  DateTime? mealDate;
  TimeOfDay? mealTime;

  final TextEditingController customMealNameController =
  TextEditingController();

  final TextEditingController notesController =
  TextEditingController();

  final TextEditingController ingredientsController =
  TextEditingController();

  final FocusNode customMealNameFocusNode = FocusNode();

  bool isOtherMealName = false;
  bool isSaving = false;

  String? mealDateError;
  String? mealTimeError;

  DateTime dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  bool isToday(DateTime date) {
    return dateOnly(date) == dateOnly(DateTime.now());
  }

  bool isFutureTimeToday() {
    if (mealDate == null ||
        mealTime == null ||
        !isToday(mealDate!)) {
      return false;
    }

    final DateTime now = DateTime.now();

    final DateTime selectedDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      mealTime!.hour,
      mealTime!.minute,
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

  Future<void> selectMealDate() async {
    final DateTime today = dateOnly(DateTime.now());

    final DateTime childBirthDate =
    dateOnly(widget.birthDate);

    DateTime initialDate = mealDate ?? today;

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
      helpText: 'اختيار تاريخ الوجبة',
      cancelText: 'إلغاء',
      confirmText: 'اختيار',
    );

    if (selectedDate == null) {
      return;
    }

    setState(() {
      mealDate = selectedDate;
      mealDateError = null;

      if (mealTime != null &&
          isFutureTimeToday()) {
        mealTime = null;
        mealTimeError = null;
      }
    });
  }

  Future<void> selectMealTime() async {
    final TimeOfDay? selectedTime =
    await showTimePicker(
      context: context,
      initialTime: mealTime ?? TimeOfDay.now(),
      helpText: 'اختيار وقت الوجبة',
      cancelText: 'إلغاء',
      confirmText: 'اختيار',
    );

    if (selectedTime == null) {
      return;
    }

    setState(() {
      mealTime = selectedTime;

      if (mealDate != null &&
          isFutureTimeToday()) {
        mealTimeError =
        'لا يمكن اختيار وقت مستقبلي';
      } else {
        mealTimeError = null;
      }
    });
  }

  void selectOtherMealName() {
    setState(() {
      selectedMealName = null;
      isOtherMealName = true;
      customMealNameController.clear();
    });

    WidgetsBinding.instance
        .addPostFrameCallback((_) {
      if (mounted) {
        customMealNameFocusNode.requestFocus();
      }
    });
  }

  void returnToMealOptions() {
    FocusScope.of(context).unfocus();

    setState(() {
      selectedMealName = null;
      isOtherMealName = false;
      customMealNameController.clear();
    });
  }

  String get finalMealName {
    if (isOtherMealName) {
      return customMealNameController.text.trim();
    }

    return selectedMealName ?? '';
  }

  bool validateDateAndTime() {
    setState(() {
      mealDateError =
      mealDate == null ? 'مطلوب' : null;

      if (mealTime == null) {
        mealTimeError = 'مطلوب';
      } else if (isFutureTimeToday()) {
        mealTimeError =
        'لا يمكن اختيار وقت مستقبلي';
      } else {
        mealTimeError = null;
      }
    });

    return mealDateError == null &&
        mealTimeError == null;
  }

  Future<void> saveMeal() async {
    if (isSaving) {
      return;
    }

    FocusScope.of(context).unfocus();

    final bool formIsValid =
        formKey.currentState?.validate() ?? false;

    final bool dateAndTimeValid =
    validateDateAndTime();

    if (!formIsValid || !dateAndTimeValid) {
      return;
    }

    setState(() {
      isSaving = true;
    });

    final String notes =
    notesController.text.trim();

    /*
      مستقبلًا عند ربط Laravel:

      POST /api/children/{childId}/meals

      Authorization: Bearer TOKEN

      {
        "meal_type": selectedMealType,
        "meal_name": finalMealName,
        "ingredients": ingredientsController.text.trim(),
        "portion_size": selectedPortionSize,
        "meal_date": formatApiDate(mealDate!),
        "meal_time": formatApiTime(mealTime!),
        "notes": notes.isEmpty ? null : notes
      }
    */

    debugPrint('Meal type: $selectedMealType');
    debugPrint('Meal name: $finalMealName');

    debugPrint(
      'Ingredients: ${ingredientsController.text.trim()}',
    );

    debugPrint('Portion: $selectedPortionSize');

    debugPrint(
      'Date: ${formatApiDate(mealDate!)}',
    );

    debugPrint(
      'Time: ${formatApiTime(mealTime!)}',
    );

    debugPrint(
      'Notes: ${notes.isEmpty ? 'none' : notes}',
    );

    await Future.delayed(
      const Duration(seconds: 2),
    );

    if (!mounted) {
      return;
    }

    ingredientsController.clear();
    notesController.clear();
    customMealNameController.clear();

    setState(() {
      isSaving = false;

      selectedMealType = null;
      selectedMealName = null;
      selectedPortionSize = null;

      isOtherMealName = false;

      mealDate = null;
      mealTime = null;

      mealDateError = null;
      mealTimeError = null;

      formKey = GlobalKey<FormState>();
    });

    ScaffoldMessenger.of(context)
        .hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'تم حفظ الوجبة بنجاح',
          textAlign: TextAlign.center,
        ),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  void dispose() {
    customMealNameController.dispose();
    ingredientsController.dispose();
    notesController.dispose();
    customMealNameFocusNode.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    final Color primaryColor = theme.primaryColor;

    final Color darkColor =
        theme.colorScheme.onSurface;

    final Color cardColor = theme.cardColor;

    final bool isDark =
        theme.brightness == Brightness.dark;

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
                          SizedBox(
                            height: 48,
                            child: Stack(
                              alignment:
                              Alignment.center,
                              children: [
                                Text(
                                  'تسجيل وجبة',
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
                                          : saveMeal,
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
                                    .restaurant_rounded,
                                color:
                                primaryColor,
                                size: 24,
                              ),

                              const SizedBox(
                                width: 7,
                              ),

                              Text(
                                'بيانات الوجبة',
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
                            first: _mealTypeField(
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
                            _mealNameField(
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
                            _ingredientsField(
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
                            second: _portionField(
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
                            first: _dateField(
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
                            second: _timeField(
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

                          TextFormField(
                            controller:
                            notesController,
                            enabled: !isSaving,
                            textAlign:
                            TextAlign.right,
                            keyboardType:
                            TextInputType
                                .multiline,
                            minLines: 3,
                            maxLines: 5,
                            maxLength: 200,
                            style: TextStyle(
                              color: darkColor,
                            ),
                            decoration:
                            inputDecoration(
                              icon: Icons
                                  .edit_note_rounded,
                              borderColor:
                              borderColor,
                              primaryColor:
                              primaryColor,
                              errorText: null,
                              fieldColor:
                              cardColor,
                            ).copyWith(
                              hintText:
                              'اكتب أي ملاحظات إضافية (اختياري)',
                              hintTextDirection:
                              TextDirection
                                  .rtl,
                              hintStyle:
                              TextStyle(
                                color:
                                hintColor,
                                fontSize: 14,
                              ),
                              alignLabelWithHint:
                              true,
                              counterStyle:
                              TextStyle(
                                color:
                                hintColor,
                              ),
                            ),
                          ),

                          const SizedBox(
                            height: 150,
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
                              color: isDark
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

  Widget _mealTypeField({
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
        value: selectedMealType,
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
          if (value == null) {
            return 'مطلوب';
          }

          return null;
        },
        decoration: inputDecoration(
          icon: Icons.list_rounded,
          borderColor: borderColor,
          primaryColor: primaryColor,
          errorText: null,
          fieldColor: fieldColor,
        ),
        hint: _RightText(
          'نوع الوجبة',
          isHint: true,
          textColor: textColor,
          hintColor: hintColor,
        ),
        items: [
          _dropdownItem(
            'الإفطار',
            textColor,
            hintColor,
          ),
          _dropdownItem(
            'الغداء',
            textColor,
            hintColor,
          ),
          _dropdownItem(
            'العشاء',
            textColor,
            hintColor,
          ),
          _dropdownItem(
            'وجبة خفيفة',
            textColor,
            hintColor,
          ),
        ],
        onChanged: isSaving
            ? null
            : (value) {
          setState(() {
            selectedMealType = value;
          });
        },
      ),
    );
  }

  Widget _mealNameField({
    required Color primaryColor,
    required Color borderColor,
    required Color fieldColor,
    required Color textColor,
    required Color hintColor,
  }) {
    if (isOtherMealName) {
      return TextFormField(
        controller:
        customMealNameController,
        focusNode:
        customMealNameFocusNode,
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
          Icons.restaurant_menu_rounded,
          borderColor: borderColor,
          primaryColor: primaryColor,
          errorText: null,
          fieldColor: fieldColor,
        ).copyWith(
          hintText: 'اكتب اسم الوجبة',
          hintTextDirection:
          TextDirection.rtl,
          hintStyle: TextStyle(
            color: hintColor,
            fontSize: 14,
          ),
          suffixIcon: IconButton(
            tooltip: 'الرجوع للخيارات',
            onPressed: isSaving
                ? null
                : returnToMealOptions,
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
        value: selectedMealName,
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
          if (!isOtherMealName &&
              value == null) {
            return 'مطلوب';
          }

          return null;
        },
        decoration: inputDecoration(
          icon:
          Icons.restaurant_menu_rounded,
          borderColor: borderColor,
          primaryColor: primaryColor,
          errorText: null,
          fieldColor: fieldColor,
        ),
        hint: _RightText(
          'اسم الوجبة',
          isHint: true,
          textColor: textColor,
          hintColor: hintColor,
        ),
        items: [
          _dropdownItem(
            'أرز',
            textColor,
            hintColor,
          ),
          _dropdownItem(
            'خبز',
            textColor,
            hintColor,
          ),
          _dropdownItem(
            'سلطة',
            textColor,
            hintColor,
          ),
          _dropdownItem(
            'فواكه',
            textColor,
            hintColor,
          ),
          _dropdownItem(
            'وجبة أخرى',
            textColor,
            hintColor,
          ),
        ],
        onChanged: isSaving
            ? null
            : (value) {
          if (value ==
              'وجبة أخرى') {
            selectOtherMealName();
            return;
          }

          setState(() {
            selectedMealName =
                value;
          });
        },
      ),
    );
  }

  Widget _ingredientsField({
    required Color primaryColor,
    required Color borderColor,
    required Color fieldColor,
    required Color textColor,
    required Color hintColor,
  }) {
    return TextFormField(
      controller: ingredientsController,
      enabled: !isSaving,
      textAlign: TextAlign.right,
      keyboardType: TextInputType.text,
      style: TextStyle(
        color: textColor,
      ),
      autovalidateMode:
      AutovalidateMode.onUserInteraction,
      validator: (value) {
        final String text =
            value?.trim() ?? '';

        if (text.isEmpty) {
          return 'مطلوب';
        }

        if (text.length < 2) {
          return 'النص قصير';
        }

        if (text.length > 100) {
          return 'النص طويل';
        }

        return null;
      },
      decoration: inputDecoration(
        icon:
        Icons.receipt_long_outlined,
        borderColor: borderColor,
        primaryColor: primaryColor,
        errorText: null,
        fieldColor: fieldColor,
      ).copyWith(
        hintText: 'اكتب مكونات الوجبة',
        hintTextDirection:
        TextDirection.rtl,
        hintStyle: TextStyle(
          color: hintColor,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _portionField({
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
        value: selectedPortionSize,
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
          if (value == null) {
            return 'مطلوب';
          }

          return null;
        },
        decoration: inputDecoration(
          icon: Icons.pie_chart_outline,
          borderColor: borderColor,
          primaryColor: primaryColor,
          errorText: null,
          fieldColor: fieldColor,
        ),
        hint: _RightText(
          'حجم الحصة',
          isHint: true,
          textColor: textColor,
          hintColor: hintColor,
        ),
        items: [
          _dropdownItem(
            'صغيرة',
            textColor,
            hintColor,
          ),
          _dropdownItem(
            'متوسطة',
            textColor,
            hintColor,
          ),
          _dropdownItem(
            'كبيرة',
            textColor,
            hintColor,
          ),
        ],
        onChanged: isSaving
            ? null
            : (value) {
          setState(() {
            selectedPortionSize =
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
      onTap: isSaving ? null : selectMealDate,
      borderRadius:
      BorderRadius.circular(14),
      child: InputDecorator(
        decoration: inputDecoration(
          icon:
          Icons.calendar_month_outlined,
          borderColor: borderColor,
          primaryColor: primaryColor,
          errorText: mealDateError,
          fieldColor: fieldColor,
        ),
        child: Text(
          mealDate == null
              ? 'تاريخ الوجبة'
              : formatDate(mealDate),
          textAlign: TextAlign.right,
          style: TextStyle(
            color: mealDate == null
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
      onTap: isSaving ? null : selectMealTime,
      borderRadius:
      BorderRadius.circular(14),
      child: InputDecorator(
        decoration: inputDecoration(
          icon: Icons.access_time_rounded,
          borderColor: borderColor,
          primaryColor: primaryColor,
          errorText: mealTimeError,
          fieldColor: fieldColor,
        ),
        child: Text(
          mealTime == null
              ? 'وقت الوجبة'
              : formatTime(mealTime),
          textAlign: TextAlign.right,
          style: TextStyle(
            color: mealTime == null
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