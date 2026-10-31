import 'package:flutter/material.dart';

class MedicalAppointmentScreen extends StatefulWidget {
  // نحتفظ بهذه المعاملات للتوافق مع الشاشات التي تستدعي الواجهة.
  // لن تظهر بيانات الطفل في هذه الشاشة.
  final String? childName;
  final DateTime? birthDate;
  final String? gender;
  final String? childImagePath;

  const MedicalAppointmentScreen({
    super.key,
    this.childName,
    this.birthDate,
    this.gender,
    this.childImagePath,
  });

  @override
  State<MedicalAppointmentScreen> createState() =>
      _MedicalAppointmentScreenState();
}

class _MedicalAppointmentScreenState
    extends State<MedicalAppointmentScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController appointmentPurposeController =
  TextEditingController();

  final TextEditingController clinicNameController =
  TextEditingController();

  final TextEditingController doctorNameController =
  TextEditingController();

  final TextEditingController notesController =
  TextEditingController();

  DateTime? appointmentDate;
  TimeOfDay? appointmentTime;

  TimeOfDay reminderTime = const TimeOfDay(
    hour: 20,
    minute: 0,
  );

  String? appointmentDateError;
  String? appointmentTimeError;
  String? reminderError;

  bool reminderEnabled = true;
  bool isSaving = false;

  // =========================
  // Date and time helpers
  // =========================

  DateTime dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  bool isSameDay(DateTime first, DateTime second) {
    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
  }

  String formatDate(DateTime? date) {
    if (date == null) return '';

    final String day = date.day.toString().padLeft(2, '0');
    final String month = date.month.toString().padLeft(2, '0');

    return '$day/$month/${date.year}';
  }

  String formatApiDate(DateTime date) {
    final String month = date.month.toString().padLeft(2, '0');
    final String day = date.day.toString().padLeft(2, '0');

    return '${date.year}-$month-$day';
  }

  String formatTime(TimeOfDay? time) {
    if (time == null) return '';

    final int hour = time.hourOfPeriod == 0
        ? 12
        : time.hourOfPeriod;

    final String minute = time.minute.toString().padLeft(2, '0');

    final String period = time.period == DayPeriod.am ? 'ص' : 'م';

    return '$hour:$minute $period';
  }

  String formatApiTime(TimeOfDay time) {
    final String hour = time.hour.toString().padLeft(2, '0');
    final String minute = time.minute.toString().padLeft(2, '0');

    return '$hour:$minute:00';
  }

  DateTime buildAppointmentDateTime() {
    return DateTime(
      appointmentDate!.year,
      appointmentDate!.month,
      appointmentDate!.day,
      appointmentTime!.hour,
      appointmentTime!.minute,
    );
  }

  // التذكير في اليوم السابق للموعد.
  DateTime buildReminderDateTime() {
    final DateTime previousDay =
    appointmentDate!.subtract(const Duration(days: 1));

    return DateTime(
      previousDay.year,
      previousDay.month,
      previousDay.day,
      reminderTime.hour,
      reminderTime.minute,
    );
  }

  // =========================
  // Validation
  // =========================

  String? validateAppointmentPurpose(String? value) {
    final String text = value?.trim() ?? '';

    if (text.isEmpty) {
      return 'مطلوب';
    }

    if (text.length < 2) {
      return 'السبب قصير';
    }

    if (text.length > 80) {
      return 'السبب طويل';
    }

    if (text.contains('  ')) {
      return 'النص غير صحيح';
    }

    return null;
  }

  String? validateClinicName(String? value) {
    final String text = value?.trim() ?? '';

    // اسم العيادة اختياري.
    if (text.isEmpty) {
      return null;
    }

    if (text.length < 2) {
      return 'اسم العيادة قصير';
    }

    if (text.length > 80) {
      return 'اسم العيادة طويل';
    }

    return null;
  }

  String? validateDoctorName(String? value) {
    final String text = value?.trim() ?? '';

    // اسم الطبيب اختياري.
    if (text.isEmpty) {
      return null;
    }

    if (text.length < 2) {
      return 'الاسم قصير';
    }

    if (text.length > 60) {
      return 'الاسم طويل';
    }

    return null;
  }

  String? validateNotes(String? value) {
    final String text = value?.trim() ?? '';

    if (text.length > 200) {
      return 'الحد الأقصى 200 حرف';
    }

    return null;
  }

  bool validateDateAndTime() {
    appointmentDateError =
    appointmentDate == null ? 'مطلوب' : null;

    appointmentTimeError =
    appointmentTime == null ? 'مطلوب' : null;

    reminderError = null;

    if (appointmentDate != null && appointmentTime != null) {
      final DateTime appointment = buildAppointmentDateTime();

      if (!appointment.isAfter(DateTime.now())) {
        appointmentTimeError = 'اختر وقتًا لاحقًا';
      }

      if (reminderEnabled &&
          appointment.isAfter(DateTime.now())) {
        final DateTime reminderDateTime =
        buildReminderDateTime();

        if (!reminderDateTime.isAfter(DateTime.now())) {
          reminderError =
          'وقت التذكير المحدد انتهى، اختر موعدًا أو وقتًا آخر';
        }

        if (!reminderDateTime.isBefore(appointment)) {
          reminderError = 'يجب أن يكون التذكير قبل الموعد';
        }
      }
    }

    setState(() {});

    return appointmentDateError == null &&
        appointmentTimeError == null &&
        reminderError == null;
  }

  // =========================
  // Select appointment date
  // =========================

  Future<void> selectAppointmentDate() async {
    if (isSaving) return;

    final DateTime today = dateOnly(DateTime.now());

    DateTime initialDate = appointmentDate ?? today;

    if (initialDate.isBefore(today)) {
      initialDate = today;
    }

    final DateTime lastDate = DateTime(
      today.year + 5,
      today.month,
      today.day,
    );

    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: today,
      lastDate: lastDate,
      helpText: 'اختيار تاريخ الموعد',
      cancelText: 'إلغاء',
      confirmText: 'اختيار',
    );

    if (selectedDate == null || !mounted) return;

    setState(() {
      appointmentDate = selectedDate;
      appointmentDateError = null;
      reminderError = null;

      // إذا كان الموعد اليوم، يجب اختيار وقت لم يمر بعد.
      if (appointmentTime != null &&
          isSameDay(selectedDate, DateTime.now())) {
        final DateTime selectedDateTime = DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
          appointmentTime!.hour,
          appointmentTime!.minute,
        );

        if (!selectedDateTime.isAfter(DateTime.now())) {
          appointmentTime = null;
          appointmentTimeError = 'اختر وقتًا لاحقًا';
        }
      }
    });
  }

  // =========================
  // Select appointment time
  // =========================

  Future<void> selectAppointmentTime() async {
    if (isSaving) return;

    final TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: appointmentTime ?? TimeOfDay.now(),
      helpText: 'اختيار وقت الموعد',
      cancelText: 'إلغاء',
      confirmText: 'اختيار',
    );

    if (selectedTime == null || !mounted) return;

    if (appointmentDate != null &&
        isSameDay(appointmentDate!, DateTime.now())) {
      final DateTime selectedDateTime = DateTime(
        appointmentDate!.year,
        appointmentDate!.month,
        appointmentDate!.day,
        selectedTime.hour,
        selectedTime.minute,
      );

      if (!selectedDateTime.isAfter(DateTime.now())) {
        setState(() {
          appointmentTime = null;
          appointmentTimeError = 'اختر وقتًا لاحقًا';
        });

        return;
      }
    }

    setState(() {
      appointmentTime = selectedTime;
      appointmentTimeError = null;
      reminderError = null;
    });
  }

  // =========================
  // Select reminder time
  // =========================

  Future<void> selectReminderTime() async {
    if (isSaving || !reminderEnabled) return;

    final TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: reminderTime,
      helpText: 'اختيار وقت التذكير',
      cancelText: 'إلغاء',
      confirmText: 'اختيار',
    );

    if (selectedTime == null || !mounted) return;

    setState(() {
      reminderTime = selectedTime;
      reminderError = null;
    });
  }

  // =========================
  // Save appointment
  // =========================

  Future<void> saveAppointment() async {
    if (isSaving) return;

    FocusScope.of(context).unfocus();

    final bool formIsValid =
        formKey.currentState?.validate() ?? false;

    final bool dateAndTimeValid = validateDateAndTime();

    if (!formIsValid || !dateAndTimeValid) {
      return;
    }

    setState(() {
      isSaving = true;
    });

    final String appointmentPurpose =
    appointmentPurposeController.text.trim();

    final String clinicName =
    clinicNameController.text.trim();

    final String doctorName =
    doctorNameController.text.trim();

    final String notes = notesController.text.trim();

    /*
      مستقبلًا عند ربط Laravel:

      POST /api/children/{childId}/appointments

      {
        "appointment_purpose": appointmentPurpose,
        "clinic_name": clinicName.isEmpty ? null : clinicName,
        "doctor_name": doctorName.isEmpty ? null : doctorName,
        "appointment_date": formatApiDate(appointmentDate!),
        "appointment_time": formatApiTime(appointmentTime!),
        "notes": notes.isEmpty ? null : notes,
        "reminder_enabled": reminderEnabled,
        "reminder_time": reminderEnabled
            ? formatApiTime(reminderTime)
            : null,
        "reminder_at": reminderEnabled
            ? buildReminderDateTime().toIso8601String()
            : null
      }

      هذه البيانات توضح شكل الطلب المستقبلي فقط.
      الحفظ الدائم يحتاج تنفيذ طلب API وربطه بقاعدة البيانات.
    */

    debugPrint('Purpose: $appointmentPurpose');

    debugPrint(
      'Clinic: ${clinicName.isEmpty ? 'غير محددة' : clinicName}',
    );

    debugPrint(
      'Doctor: ${doctorName.isEmpty ? 'غير محدد' : doctorName}',
    );

    debugPrint(
      'Date: ${formatApiDate(appointmentDate!)}',
    );

    debugPrint(
      'Time: ${formatApiTime(appointmentTime!)}',
    );

    debugPrint('Notes: $notes');
    debugPrint('Reminder enabled: $reminderEnabled');

    if (reminderEnabled) {
      debugPrint(
        'Reminder time: ${formatApiTime(reminderTime)}',
      );

      debugPrint(
        'Reminder date/time: ${buildReminderDateTime()}',
      );
    }

    // محاكاة الحفظ الحالي إلى أن يتم ربط Laravel.
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    appointmentPurposeController.clear();
    clinicNameController.clear();
    doctorNameController.clear();
    notesController.clear();

    formKey.currentState?.reset();

    setState(() {
      isSaving = false;

      appointmentDate = null;
      appointmentTime = null;

      appointmentDateError = null;
      appointmentTimeError = null;
      reminderError = null;

      reminderEnabled = true;

      reminderTime = const TimeOfDay(
        hour: 20,
        minute: 0,
      );
    });

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'تم حفظ بيانات الموعد بنجاح',
          textAlign: TextAlign.center,
        ),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }

  // =========================
  // Reset form
  // =========================

  void clearAppointmentForm() {
    appointmentPurposeController.clear();
    clinicNameController.clear();
    doctorNameController.clear();
    notesController.clear();

    formKey.currentState?.reset();

    setState(() {
      appointmentDate = null;
      appointmentTime = null;

      appointmentDateError = null;
      appointmentTimeError = null;
      reminderError = null;

      reminderEnabled = true;

      reminderTime = const TimeOfDay(
        hour: 20,
        minute: 0,
      );
    });
  }

  @override
  void dispose() {
    appointmentPurposeController.dispose();
    clinicNameController.dispose();
    doctorNameController.dispose();
    notesController.dispose();

    super.dispose();
  }

  // =========================
  // Main interface
  // =========================

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    final bool isDark =
        theme.brightness == Brightness.dark;

    final Color primaryColor = theme.primaryColor;
    final Color darkColor = theme.colorScheme.onSurface;
    final Color cardColor = theme.cardColor;

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
                    constraints: const BoxConstraints(
                      maxWidth: 720,
                    ),
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
                                  'إضافة موعد طبي',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: isVerySmall ? 18 : 22,
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
                                        : () => Navigator.pop(context),
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
                                          : saveAppointment,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: primaryColor,
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        padding: EdgeInsets.symmetric(
                                          horizontal:
                                          isVerySmall ? 14 : 18,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                          BorderRadius.circular(12),
                                        ),
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
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(
                            height: isSmallScreen ? 26 : 34,
                          ),

                          // =====================
                          // Appointment title
                          // =====================

                          Row(
                            children: [
                              Icon(
                                Icons.event_available_outlined,
                                color: primaryColor,
                                size: 25,
                              ),
                              const SizedBox(width: 7),
                              Text(
                                'بيانات الموعد',
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
                          // Appointment purpose
                          // =====================

                          TextFormField(
                            controller: appointmentPurposeController,
                            enabled: !isSaving,
                            style: TextStyle(color: darkColor),
                            textAlign: TextAlign.right,
                            keyboardType: TextInputType.text,
                            textInputAction: TextInputAction.next,
                            autovalidateMode:
                            AutovalidateMode.onUserInteraction,
                            validator: validateAppointmentPurpose,
                            decoration: appointmentInputDecoration(
                              label: 'نوع أو سبب الموعد',
                              hint: 'مثال: مراجعة السكري أو غدد أطفال',
                              icon: Icons.medical_information_outlined,
                              primaryColor: primaryColor,
                              borderColor: borderColor,
                              hintColor: hintColor,
                            ),
                          ),

                          const SizedBox(height: 16),

                          // =====================
                          // Clinic name
                          // =====================

                          TextFormField(
                            controller: clinicNameController,
                            enabled: !isSaving,
                            style: TextStyle(color: darkColor),
                            textAlign: TextAlign.right,
                            keyboardType: TextInputType.text,
                            textInputAction: TextInputAction.next,
                            autovalidateMode:
                            AutovalidateMode.onUserInteraction,
                            validator: validateClinicName,
                            decoration: appointmentInputDecoration(
                              label: 'اسم العيادة (اختياري)',
                              hint: 'اسم المستشفى أو العيادة',
                              icon: Icons.local_hospital_outlined,
                              primaryColor: primaryColor,
                              borderColor: borderColor,
                              hintColor: hintColor,
                            ),
                          ),

                          const SizedBox(height: 16),

                          // =====================
                          // Doctor name
                          // =====================

                          TextFormField(
                            controller: doctorNameController,
                            enabled: !isSaving,
                            style: TextStyle(color: darkColor),
                            textAlign: TextAlign.right,
                            keyboardType: TextInputType.text,
                            textInputAction: TextInputAction.next,
                            autovalidateMode:
                            AutovalidateMode.onUserInteraction,
                            validator: validateDoctorName,
                            decoration: appointmentInputDecoration(
                              label: 'اسم الطبيب (اختياري)',
                              hint: 'مثال: د. أحمد',
                              icon: Icons.person_outline_rounded,
                              primaryColor: primaryColor,
                              borderColor: borderColor,
                              hintColor: hintColor,
                            ),
                          ),

                          const SizedBox(height: 16),

                          // =====================
                          // Date and time side by side
                          // =====================

                          _responsivePair(
                            isVerySmall: isVerySmall,
                            first: _buildAppointmentDateField(
                              primaryColor: primaryColor,
                              borderColor: borderColor,
                              hintColor: hintColor,
                              darkColor: darkColor,
                            ),
                            second: _buildAppointmentTimeField(
                              primaryColor: primaryColor,
                              borderColor: borderColor,
                              hintColor: hintColor,
                              darkColor: darkColor,
                            ),
                          ),

                          const SizedBox(height: 16),

                          // =====================
                          // Notes
                          // =====================

                          TextFormField(
                            controller: notesController,
                            enabled: !isSaving,
                            style: TextStyle(color: darkColor),
                            textAlign: TextAlign.right,
                            keyboardType: TextInputType.multiline,
                            textInputAction: TextInputAction.newline,
                            minLines: 2,
                            maxLines: 4,
                            maxLength: 200,
                            autovalidateMode:
                            AutovalidateMode.onUserInteraction,
                            validator: validateNotes,
                            decoration: appointmentInputDecoration(
                              label: 'ملاحظات (اختياري)',
                              hint: 'أي تفاصيل أو تعليمات متعلقة بالموعد',
                              icon: Icons.edit_note_rounded,
                              primaryColor: primaryColor,
                              borderColor: borderColor,
                              hintColor: hintColor,
                            ).copyWith(
                              alignLabelWithHint: true,
                              counterStyle: TextStyle(
                                color: hintColor,
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // =====================
                          // Reminder
                          // =====================

                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: reminderError != null
                                    ? Colors.red
                                    : borderColor,
                                width: 1.3,
                              ),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.notifications_none_rounded,
                                      color: primaryColor,
                                      size: 23,
                                    ),

                                    const SizedBox(width: 8),

                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'تفعيل تذكير الموعد',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: darkColor,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            reminderEnabled
                                                ? 'قبل الموعد بيوم'
                                                : 'التذكير غير مفعّل',
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: hintColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    if (reminderEnabled) ...[
                                      InkWell(
                                        onTap: isSaving
                                            ? null
                                            : selectReminderTime,
                                        borderRadius:
                                        BorderRadius.circular(10),
                                        child: Container(
                                          padding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 8,
                                          ),
                                          decoration: BoxDecoration(
                                            color: isDark
                                                ? primaryColor
                                                .withOpacity(0.12)
                                                : primaryColor
                                                .withOpacity(0.08),
                                            borderRadius:
                                            BorderRadius.circular(10),
                                            border: Border.all(
                                              color: primaryColor
                                                  .withOpacity(0.30),
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.schedule_rounded,
                                                size: 17,
                                                color: primaryColor,
                                              ),
                                              const SizedBox(width: 5),
                                              Text(
                                                formatTime(reminderTime),
                                                style: TextStyle(
                                                  fontSize: 12.5,
                                                  fontWeight:
                                                  FontWeight.bold,
                                                  color: darkColor,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 5),
                                    ],

                                    Switch(
                                      value: reminderEnabled,
                                      activeColor: primaryColor,
                                      onChanged: isSaving
                                          ? null
                                          : (value) {
                                        setState(() {
                                          reminderEnabled = value;
                                          reminderError = null;
                                        });
                                      },
                                    ),
                                  ],
                                ),

                                if (reminderError != null) ...[
                                  const SizedBox(height: 5),
                                  Align(
                                    alignment:
                                    AlignmentDirectional.centerStart,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                      ),
                                      child: Text(
                                        reminderError!,
                                        style: const TextStyle(
                                          color: Colors.red,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),

                          const SizedBox(height: 18),

                          // =====================
                          // Reminder information
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
                              borderRadius: BorderRadius.circular(13),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.info_outline_rounded,
                                  color: primaryColor,
                                  size: 20,
                                ),
                                const SizedBox(width: 7),
                                Flexible(
                                  child: Text(
                                    reminderEnabled
                                        ? 'سيتم تذكير ولي الأمر قبل الموعد بيوم في الساعة ${formatTime(reminderTime)}'
                                        : 'يمكن تفعيل التذكير لتنبيه ولي الأمر قبل الموعد',
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

  // =========================
  // Responsive date/time fields
  // =========================

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

  // =========================
  // Appointment date field
  // =========================

  Widget _buildAppointmentDateField({
    required Color primaryColor,
    required Color borderColor,
    required Color hintColor,
    required Color darkColor,
  }) {
    return InkWell(
      onTap: isSaving ? null : selectAppointmentDate,
      borderRadius: BorderRadius.circular(14),
      child: InputDecorator(
        decoration: appointmentInputDecoration(
          label: 'تاريخ الموعد',
          hint: '',
          icon: Icons.calendar_month_outlined,
          errorText: appointmentDateError,
          primaryColor: primaryColor,
          borderColor: borderColor,
          hintColor: hintColor,
        ),
        child: Text(
          appointmentDate == null
              ? 'اختر تاريخ الموعد'
              : formatDate(appointmentDate),
          textAlign: TextAlign.right,
          style: TextStyle(
            fontSize: 13,
            color: appointmentDate == null
                ? hintColor
                : darkColor,
          ),
        ),
      ),
    );
  }

  // =========================
  // Appointment time field
  // =========================

  Widget _buildAppointmentTimeField({
    required Color primaryColor,
    required Color borderColor,
    required Color hintColor,
    required Color darkColor,
  }) {
    return InkWell(
      onTap: isSaving ? null : selectAppointmentTime,
      borderRadius: BorderRadius.circular(14),
      child: InputDecorator(
        decoration: appointmentInputDecoration(
          label: 'وقت الموعد',
          hint: '',
          icon: Icons.access_time_rounded,
          errorText: appointmentTimeError,
          primaryColor: primaryColor,
          borderColor: borderColor,
          hintColor: hintColor,
        ),
        child: Text(
          appointmentTime == null
              ? 'اختر وقت الموعد'
              : formatTime(appointmentTime),
          textAlign: TextAlign.right,
          style: TextStyle(
            fontSize: 13,
            color: appointmentTime == null
                ? hintColor
                : darkColor,
          ),
        ),
      ),
    );
  }

  // =========================
  // Input decoration
  // =========================

  InputDecoration appointmentInputDecoration({
    required String label,
    required String hint,
    required IconData icon,
    required Color primaryColor,
    required Color borderColor,
    required Color hintColor,
    String? errorText,
  }) {
    final ThemeData theme = Theme.of(context);

    final bool isDark =
        theme.brightness == Brightness.dark;

    final Color textColor =
        theme.colorScheme.onSurface;

    final Color labelColor = isDark
        ? textColor.withOpacity(0.70)
        : const Color(0xff6F8086);

    return InputDecoration(
      labelText: label,
      hintText: hint,
      hintTextDirection: TextDirection.rtl,
      floatingLabelBehavior: FloatingLabelBehavior.auto,

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

      errorText: errorText,

      errorStyle: const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w500,
      ),

      prefixIcon: Icon(
        icon,
        color: primaryColor,
        size: 22,
      ),

      filled: true,
      fillColor: theme.cardColor,

      contentPadding: const EdgeInsets.symmetric(
        horizontal: 12,
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