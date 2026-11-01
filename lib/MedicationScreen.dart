import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MedicationScreen extends StatefulWidget {
  final String childName;
  final DateTime birthDate;
  final String gender;
  final String? childImagePath;

  const MedicationScreen({
    super.key,
    required this.childName,
    required this.birthDate,
    required this.gender,
    this.childImagePath,
  });

  @override
  State<MedicationScreen> createState() => _MedicationScreenState();
}

class _MedicationScreenState extends State<MedicationScreen> {
  final formKey = GlobalKey<FormState>();
  final doseController = TextEditingController();
  final otherMedicineController = TextEditingController();
  final otherMedicineFocusNode = FocusNode();

  // Temporary UI-only records until the Laravel API is connected.
  final List<SavedMedication> savedMedications = [];

  static const medicines = ['Insulin', 'Metformin', 'Empagliflozin', 'أخرى'];
  static const insulinTypes = ['Short', 'Long', 'Mixed'];
  static const repeats = ['مرة يوميًا', 'مرتان يوميًا', '3 مرات يوميًا'];

  String? selectedMedicine;
  String? selectedInsulinType;
  String? selectedDoseUnit;
  String? selectedRepeat;
  TimeOfDay? selectedTime;
  DateTime? startDate;
  int? editingMedicationIndex;
  bool reminderEnabled = true;
  bool isSaving = false;
  String? timeError;
  String? startDateError;

  List<String> get availableDoseUnits {
    if (selectedMedicine == 'Insulin') return ['U'];
    if (selectedMedicine == 'Metformin' ||
        selectedMedicine == 'Empagliflozin') return ['mg'];
    return ['U', 'mg', 'mL'];
  }

  DateTime dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  String formatDate(DateTime? date) {
    if (date == null) return '';
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }

  String formatApiDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  String formatTime(TimeOfDay? time) {
    if (time == null) return '';
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'ص' : 'م';
    return '$hour:$minute $period';
  }

  String formatApiTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute:00';
  }

  String? validateMedicineName(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'مطلوب';
    if (text.length < 2) return 'اسم الدواء قصير';
    if (text.length > 60) return 'اسم الدواء طويل';
    final regex = RegExp(r'^[A-Za-z\u0621-\u064A0-9 .\-]+$');
    if (!regex.hasMatch(text) || text.contains('  ')) {
      return 'اسم الدواء غير صحيح';
    }
    return null;
  }

  String? validateDose(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'مطلوب';
    final dose = double.tryParse(text);
    if (dose == null) return 'رقم غير صحيح';
    if (dose <= 0) return 'الجرعة غير صحيحة';
    if (dose > 9999) return 'تحقق من الجرعة';
    return null;
  }

  Future<void> selectMedicineTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? TimeOfDay.now(),
      helpText: 'اختيار وقت الدواء',
      cancelText: 'إلغاء',
      confirmText: 'اختيار',
    );
    if (time == null || !mounted) return;
    setState(() {
      selectedTime = time;
      timeError = null;
    });
  }

  Future<void> selectStartDate() async {
    final today = dateOnly(DateTime.now());
    final birthDate = dateOnly(widget.birthDate);
    DateTime initialDate = startDate ?? today;
    if (initialDate.isBefore(birthDate)) initialDate = birthDate;
    if (initialDate.isAfter(today)) initialDate = today;
    final date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: birthDate,
      lastDate: today,
      helpText: 'اختيار تاريخ بدء الدواء',
      cancelText: 'إلغاء',
      confirmText: 'اختيار',
    );
    if (date == null || !mounted) return;
    setState(() {
      startDate = date;
      startDateError = null;
    });
  }

  void onMedicineChanged(String? value) {
    setState(() {
      selectedMedicine = value;
      selectedInsulinType = null;
      selectedDoseUnit = null;
      otherMedicineController.clear();
      if (value == 'Insulin') selectedDoseUnit = 'U';
      if (value == 'Metformin' || value == 'Empagliflozin') {
        selectedDoseUnit = 'mg';
      }
    });
    if (value == 'أخرى') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) otherMedicineFocusNode.requestFocus();
      });
    }
  }

  bool validateDateAndTime() {
    setState(() {
      timeError = selectedTime == null ? 'مطلوب' : null;
      startDateError = startDate == null ? 'مطلوب' : null;
    });
    return timeError == null && startDateError == null;
  }

  void editMedication(int index) {
    final medication = savedMedications[index];
    FocusScope.of(context).unfocus();
    setState(() {
      editingMedicationIndex = index;
      selectedMedicine = medication.medicineSelection;
      selectedInsulinType = medication.insulinType;
      otherMedicineController.text = medication.medicineSelection == 'أخرى'
          ? medication.name
          : '';
      doseController.text = medication.dose;
      selectedDoseUnit = medication.doseUnit;
      selectedRepeat = medication.repeat;
      selectedTime = medication.medicineTime;
      startDate = medication.startDateValue;
      reminderEnabled = medication.reminderEnabled;
      timeError = null;
      startDateError = null;
    });
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('يمكنك الآن تعديل بيانات الدواء', textAlign: TextAlign.center),
      behavior: SnackBarBehavior.floating,
      duration: Duration(seconds: 2),
    ));
  }

  Future<void> saveMedication() async {
    if (isSaving) return;
    FocusScope.of(context).unfocus();
    final formIsValid = formKey.currentState?.validate() ?? false;
    final dateAndTimeValid = validateDateAndTime();
    if (!formIsValid || !dateAndTimeValid) return;
    setState(() => isSaving = true);

    final medicineName = selectedMedicine == 'أخرى'
        ? otherMedicineController.text.trim()
        : selectedMedicine!;
    final dose = doseController.text.trim();
    final medication = SavedMedication(
      medicineSelection: selectedMedicine!,
      name: medicineName,
      insulinType: selectedMedicine == 'Insulin' ? selectedInsulinType : null,
      dose: dose,
      doseUnit: selectedDoseUnit!,
      repeat: selectedRepeat!,
      time: formatTime(selectedTime),
      startDate: formatDate(startDate),
      reminderEnabled: reminderEnabled,
      medicineTime: selectedTime!,
      startDateValue: startDate!,
    );

    // Future Laravel integration:
    // POST /api/children/{childId}/medications
    // PUT /api/children/{childId}/medications/{medicationId}
    // DELETE /api/children/{childId}/medications/{medicationId}
    debugPrint('Medicine: $medicineName');
    debugPrint('Insulin type: $selectedInsulinType');
    debugPrint('Dose: $dose $selectedDoseUnit');
    debugPrint('Repeat: $selectedRepeat');
    debugPrint('Time: ${formatApiTime(selectedTime!)}');
    debugPrint('Start date: ${formatApiDate(startDate!)}');
    debugPrint('Reminder: $reminderEnabled');

    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    final isEditing = editingMedicationIndex != null;
    setState(() {
      if (editingMedicationIndex != null) {
        savedMedications[editingMedicationIndex!] = medication;
      } else {
        savedMedications.insert(0, medication);
      }
      isSaving = false;
      clearForm();
    });
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        isEditing ? 'تم تحديث بيانات الدواء بنجاح' : 'تم حفظ الدواء مؤقتًا',
        textAlign: TextAlign.center,
      ),
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 2),
    ));
  }

  void clearForm() {
    doseController.clear();
    otherMedicineController.clear();
    selectedMedicine = null;
    selectedInsulinType = null;
    selectedDoseUnit = null;
    selectedRepeat = null;
    selectedTime = null;
    startDate = null;
    editingMedicationIndex = null;
    reminderEnabled = true;
    timeError = null;
    startDateError = null;
    formKey.currentState?.reset();
    FocusScope.of(context).unfocus();
  }

  void cancelEditing() {
    setState(clearForm);
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('تم إلغاء التعديل', textAlign: TextAlign.center),
      behavior: SnackBarBehavior.floating,
      duration: Duration(seconds: 2),
    ));
  }

  void deleteMedication(int index) {
    final medication = savedMedications[index];
    setState(() {
      savedMedications.removeAt(index);
      if (editingMedicationIndex != null) {
        if (editingMedicationIndex == index) {
          clearForm();
        } else if (editingMedicationIndex! > index) {
          editingMedicationIndex = editingMedicationIndex! - 1;
        }
      }
    });
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('تم حذف ${medication.name}', textAlign: TextAlign.center),
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 2),
    ));
  }

  @override
  void dispose() {
    doseController.dispose();
    otherMedicineController.dispose();
    otherMedicineFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;
    final darkColor = theme.colorScheme.onSurface;
    final cardColor = theme.cardColor;
    final isDark = theme.brightness == Brightness.dark;
    final borderColor = isDark
        ? darkColor.withOpacity(0.14)
        : const Color(0xffD7E7E7);
    final hintColor = isDark
        ? darkColor.withOpacity(0.52)
        : const Color(0xff8A989D);

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final screenWidth = constraints.maxWidth;
            final screenHeight = constraints.maxHeight;
            final isVerySmall = screenWidth < 390;
            final isSmallScreen = screenWidth < 430 || screenHeight < 650;
            final isTablet = screenWidth >= 600;
            final horizontalPadding = isVerySmall ? 14.0 : (isTablet ? 36.0 : 20.0);
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
                          SizedBox(
                            height: 48,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Text(
                                  'تسجيل دواء',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: isVerySmall ? 18 : 22,
                                    fontWeight: FontWeight.bold,
                                    color: darkColor,
                                  ),
                                ),
                                Align(
                                  alignment: AlignmentDirectional.centerStart,
                                  child: IconButton(
                                    onPressed: isSaving ? null : () => Navigator.pop(context),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
                                    icon: Icon(Icons.arrow_back_ios_new_rounded, color: darkColor, size: 22),
                                  ),
                                ),
                                Align(
                                  alignment: AlignmentDirectional.centerEnd,
                                  child: SizedBox(
                                    height: 44,
                                    child: ElevatedButton(
                                      onPressed: isSaving ? null : saveMedication,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: primaryColor,
                                        foregroundColor: Colors.white,
                                        padding: EdgeInsets.symmetric(horizontal: isVerySmall ? 12 : 18),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        elevation: 0,
                                      ),
                                      child: isSaving
                                          ? const SizedBox(
                                        width: 21,
                                        height: 21,
                                        child: CircularProgressIndicator(strokeWidth: 2.3, color: Colors.white),
                                      )
                                          : Text(
                                        editingMedicationIndex != null ? 'تحديث' : 'حفظ',
                                        style: TextStyle(
                                          fontSize: isVerySmall ? 14 : 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: isSmallScreen ? 30 : 40),
                          Row(
                            children: [
                              Icon(Icons.medication_liquid_rounded, color: primaryColor, size: 24),
                              const SizedBox(width: 7),
                              Text('الأدوية المسجلة', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: darkColor)),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: borderColor, width: 1.2),
                            ),
                            child: savedMedications.isEmpty
                                ? Padding(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              child: Column(
                                children: [
                                  Icon(Icons.medication_outlined, size: 36, color: hintColor),
                                  const SizedBox(height: 9),
                                  Text('لا توجد أدوية مسجلة', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: darkColor)),
                                  const SizedBox(height: 5),
                                  Text('سيظهر الدواء هنا بعد حفظه', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: hintColor)),
                                ],
                              ),
                            )
                                : ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: savedMedications.length,
                              separatorBuilder: (context, index) => const SizedBox(height: 12),
                              itemBuilder: (context, index) => medicationRecordCard(
                                medication: savedMedications[index],
                                index: index,
                                primaryColor: primaryColor,
                                darkColor: darkColor,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: primaryColor.withOpacity(0.40), width: 1.4),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      editingMedicationIndex != null ? Icons.edit_outlined : Icons.add_circle_outline_rounded,
                                      color: primaryColor,
                                      size: 25,
                                    ),
                                    const SizedBox(width: 7),
                                    Expanded(
                                      child: Text(
                                        editingMedicationIndex != null ? 'تعديل بيانات الدواء' : 'إضافة دواء',
                                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: darkColor),
                                      ),
                                    ),
                                    if (editingMedicationIndex != null)
                                      TextButton(
                                        onPressed: isSaving ? null : cancelEditing,
                                        child: const Text('إلغاء التعديل'),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 18),
                                _buildDropdown(
                                  value: selectedMedicine,
                                  values: medicines,
                                  hint: 'اسم الدواء',
                                  icon: Icons.medication_outlined,
                                  primaryColor: primaryColor,
                                  borderColor: borderColor,
                                  cardColor: cardColor,
                                  onChanged: onMedicineChanged,
                                ),
                                if (selectedMedicine == 'Insulin') ...[
                                  const SizedBox(height: 16),
                                  _buildDropdown(
                                    value: selectedInsulinType,
                                    values: insulinTypes,
                                    hint: 'نوع الأنسولين',
                                    icon: Icons.medication_liquid_outlined,
                                    primaryColor: primaryColor,
                                    borderColor: borderColor,
                                    cardColor: cardColor,
                                    onChanged: (value) => setState(() => selectedInsulinType = value),
                                  ),
                                ],
                                if (selectedMedicine == 'أخرى') ...[
                                  const SizedBox(height: 16),
                                  TextFormField(
                                    controller: otherMedicineController,
                                    focusNode: otherMedicineFocusNode,
                                    enabled: !isSaving,
                                    style: TextStyle(color: darkColor),
                                    textAlign: TextAlign.right,
                                    textInputAction: TextInputAction.next,
                                    autovalidateMode: AutovalidateMode.onUserInteraction,
                                    validator: validateMedicineName,
                                    decoration: medicationDecoration(
                                      icon: Icons.edit_note_rounded,
                                      hint: 'اكتب اسم الدواء',
                                      primaryColor: primaryColor,
                                      borderColor: borderColor,
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 16),
                                _responsivePair(
                                  isVerySmall: isVerySmall,
                                  first: TextFormField(
                                    controller: doseController,
                                    enabled: !isSaving,
                                    style: TextStyle(color: darkColor),
                                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                    textAlign: TextAlign.right,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(RegExp(r'^\d{0,4}(\.\d{0,2})?')),
                                    ],
                                    validator: validateDose,
                                    autovalidateMode: AutovalidateMode.onUserInteraction,
                                    decoration: medicationDecoration(
                                      icon: Icons.vaccines_outlined,
                                      hint: 'الجرعة',
                                      primaryColor: primaryColor,
                                      borderColor: borderColor,
                                    ),
                                  ),
                                  second: _buildDropdown(
                                    value: selectedDoseUnit,
                                    values: availableDoseUnits,
                                    hint: 'وحدة الجرعة',
                                    icon: Icons.scale_outlined,
                                    primaryColor: primaryColor,
                                    borderColor: borderColor,
                                    cardColor: cardColor,
                                    onChanged: (value) => setState(() => selectedDoseUnit = value),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                _buildDropdown(
                                  value: selectedRepeat,
                                  values: repeats,
                                  hint: 'التكرار',
                                  icon: Icons.repeat_rounded,
                                  primaryColor: primaryColor,
                                  borderColor: borderColor,
                                  cardColor: cardColor,
                                  onChanged: (value) => setState(() => selectedRepeat = value),
                                ),
                                const SizedBox(height: 16),
                                _responsivePair(
                                  isVerySmall: isVerySmall,
                                  first: _buildTimeField(
                                    primaryColor: primaryColor,
                                    borderColor: borderColor,
                                    hintColor: hintColor,
                                    darkColor: darkColor,
                                  ),
                                  second: _buildStartDateField(
                                    primaryColor: primaryColor,
                                    borderColor: borderColor,
                                    hintColor: hintColor,
                                    darkColor: darkColor,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Container(
                                  width: double.infinity,
                                  constraints: const BoxConstraints(minHeight: 58),
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                                  decoration: BoxDecoration(
                                    color: cardColor,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(color: borderColor, width: 1.3),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.notifications_none_rounded, color: primaryColor, size: 22),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text('تفعيل التذكير', style: TextStyle(color: darkColor, fontSize: 14, fontWeight: FontWeight.bold)),
                                            const SizedBox(height: 2),
                                            Text('للتذكير بوقت الدواء', style: TextStyle(color: hintColor, fontSize: 11)),
                                          ],
                                        ),
                                      ),
                                      Switch(
                                        value: reminderEnabled,
                                        activeColor: primaryColor,
                                        onChanged: isSaving ? null : (value) => setState(() => reminderEnabled = value),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 17),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                                  decoration: BoxDecoration(
                                    color: isDark ? const Color(0xff18272A) : const Color(0xffEEF7FA),
                                    borderRadius: BorderRadius.circular(13),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.info_outline_rounded, color: primaryColor, size: 20),
                                      const SizedBox(width: 7),
                                      Flexible(
                                        child: Text(
                                          'سجّل بيانات الدواء حسب وصفة الطبيب المعتمدة للطفل',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(fontSize: 13, color: darkColor),
                                        ),
                                      ),
                                    ],
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

  Widget _buildDropdown({
    required String? value,
    required List<String> values,
    required String hint,
    required IconData icon,
    required Color primaryColor,
    required Color borderColor,
    required Color cardColor,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      key: ValueKey('$hint-${values.join('|')}'),
      value: values.contains(value) ? value : null,
      isExpanded: true,
      dropdownColor: cardColor,
      alignment: AlignmentDirectional.centerStart,
      validator: (value) => value == null ? 'مطلوب' : null,
      decoration: medicationDecoration(
        icon: icon,
        hint: '',
        primaryColor: primaryColor,
        borderColor: borderColor,
      ),
      hint: _RightText(hint, isHint: true),
      items: values.map((item) => DropdownMenuItem<String>(
        value: item,
        child: _RightText(item),
      )).toList(),
      onChanged: isSaving ? null : onChanged,
    );
  }

  Widget _responsivePair({
    required bool isVerySmall,
    required Widget first,
    required Widget second,
  }) {
    if (isVerySmall) {
      return Column(children: [first, const SizedBox(height: 16), second]);
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

  Widget _buildTimeField({
    required Color primaryColor,
    required Color borderColor,
    required Color hintColor,
    required Color darkColor,
  }) {
    return InkWell(
      onTap: isSaving ? null : selectMedicineTime,
      borderRadius: BorderRadius.circular(14),
      child: InputDecorator(
        decoration: medicationDecoration(
          icon: Icons.access_time_rounded,
          hint: '',
          primaryColor: primaryColor,
          borderColor: borderColor,
        ).copyWith(errorText: timeError),
        child: Text(
          selectedTime == null ? 'وقت الدواء' : formatTime(selectedTime),
          textAlign: TextAlign.right,
          style: TextStyle(color: selectedTime == null ? hintColor : darkColor, fontSize: 14),
        ),
      ),
    );
  }

  Widget _buildStartDateField({
    required Color primaryColor,
    required Color borderColor,
    required Color hintColor,
    required Color darkColor,
  }) {
    return InkWell(
      onTap: isSaving ? null : selectStartDate,
      borderRadius: BorderRadius.circular(14),
      child: InputDecorator(
        decoration: medicationDecoration(
          icon: Icons.calendar_month_outlined,
          hint: '',
          primaryColor: primaryColor,
          borderColor: borderColor,
        ).copyWith(errorText: startDateError),
        child: Text(
          startDate == null ? 'تاريخ بدء الدواء' : formatDate(startDate),
          textAlign: TextAlign.right,
          style: TextStyle(color: startDate == null ? hintColor : darkColor, fontSize: 14),
        ),
      ),
    );
  }

  Widget medicationRecordCard({
    required SavedMedication medication,
    required int index,
    required Color primaryColor,
    required Color darkColor,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final secondaryTextColor = isDark
        ? darkColor.withOpacity(0.65)
        : const Color(0xff6D7A80);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xff182326) : const Color(0xffFAFDFD),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? darkColor.withOpacity(0.10) : const Color(0xffE3EEEE),
          width: 1.1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xff3B3020) : const Color(0xffFFF4E0),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.medication_rounded, color: Color(0xffC87817), size: 26),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      medication.name,
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: darkColor),
                    ),
                    if (medication.insulinType != null) ...[
                      const SizedBox(height: 4),
                      Text('نوع الأنسولين: ${medication.insulinType}', style: TextStyle(fontSize: 12, color: secondaryTextColor)),
                    ],
                    const SizedBox(height: 4),
                    Text('الجرعة: ${medication.dose} ${medication.doseUnit}', style: TextStyle(fontSize: 12, color: secondaryTextColor)),
                  ],
                ),
              ),
              IconButton(
                onPressed: isSaving ? null : () => editMedication(index),
                tooltip: 'تعديل بيانات الدواء',
                icon: const Icon(Icons.edit_outlined, color: Color(0xff419F98)),
              ),
              IconButton(
                onPressed: isSaving ? null : () => deleteMedication(index),
                tooltip: 'حذف الدواء',
                icon: const Icon(Icons.delete_outline_rounded, color: Color(0xffC85C55)),
              ),
            ],
          ),
          const SizedBox(height: 11),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              medicationDetail(icon: Icons.repeat_rounded, text: medication.repeat, primaryColor: primaryColor),
              medicationDetail(icon: Icons.access_time_rounded, text: medication.time, primaryColor: primaryColor),
              medicationDetail(icon: Icons.calendar_month_outlined, text: 'من ${medication.startDate}', primaryColor: primaryColor),
              medicationDetail(
                icon: medication.reminderEnabled
                    ? Icons.notifications_active_outlined
                    : Icons.notifications_off_outlined,
                text: medication.reminderEnabled ? 'التذكير مفعّل' : 'التذكير متوقف',
                primaryColor: primaryColor,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget medicationDetail({
    required IconData icon,
    required String text,
    required Color primaryColor,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark
        ? theme.colorScheme.onSurface.withOpacity(0.70)
        : const Color(0xff5C6E75);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xff202E31) : const Color(0xffF2F8F8),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: primaryColor),
          const SizedBox(width: 5),
          Text(text, style: TextStyle(fontSize: 11, color: textColor, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  InputDecoration medicationDecoration({
    required IconData icon,
    required String hint,
    required Color primaryColor,
    required Color borderColor,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final hintColor = isDark
        ? theme.colorScheme.onSurface.withOpacity(0.52)
        : const Color(0xff8A989D);
    return InputDecoration(
      hintText: hint,
      hintTextDirection: TextDirection.rtl,
      hintStyle: TextStyle(color: hintColor, fontSize: 13),
      errorStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
      prefixIcon: Icon(icon, color: primaryColor, size: 22),
      filled: true,
      fillColor: theme.cardColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 11, vertical: 17),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: borderColor, width: 1.3),
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
}

class SavedMedication {
  final String medicineSelection;
  final String name;
  final String? insulinType;
  final String dose;
  final String doseUnit;
  final String repeat;
  final String time;
  final String startDate;
  final bool reminderEnabled;
  final TimeOfDay medicineTime;
  final DateTime startDateValue;

  const SavedMedication({
    required this.medicineSelection,
    required this.name,
    required this.insulinType,
    required this.dose,
    required this.doseUnit,
    required this.repeat,
    required this.time,
    required this.startDate,
    required this.reminderEnabled,
    required this.medicineTime,
    required this.startDateValue,
  });
}

class _RightText extends StatelessWidget {
  final String text;
  final bool isHint;

  const _RightText(this.text, {this.isHint = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isHint
        ? (isDark ? theme.colorScheme.onSurface.withOpacity(0.52) : const Color(0xff8A989D))
        : (isDark ? theme.colorScheme.onSurface : const Color(0xff2C4A5A));
    return SizedBox(
      width: double.infinity,
      child: Text(
        text,
        textAlign: TextAlign.right,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: textColor, fontSize: 14),
      ),
    );
  }
}