import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

class MedicalExamScreen extends StatefulWidget {
  final String childName;
  final DateTime birthDate;
  final String gender;
  final String? childImagePath;

  const MedicalExamScreen({
    super.key,
    required this.childName,
    required this.birthDate,
    required this.gender,
    this.childImagePath,
  });

  @override
  State<MedicalExamScreen> createState() => _MedicalExamScreenState();
}

class _MedicalExamScreenState extends State<MedicalExamScreen> {

  final TextEditingController examNameController =
  TextEditingController();

  final TextEditingController examResultController =
  TextEditingController();

  final TextEditingController measurementUnitController =
  TextEditingController();

  final TextEditingController notesController =
  TextEditingController();

  final ImagePicker imagePicker = ImagePicker();

  DateTime? examDate;
  String? examDateError;

  bool isSaving = false;
  bool isPickingAttachment = false;

  String? selectedAttachmentType;
  XFile? selectedImage;
  PlatformFile? selectedFile;

  DateTime dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
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

  String? validateExamName(String? value) {
    final String text = value?.trim() ?? '';

    if (text.isEmpty) return 'مطلوب';
    if (text.length < 2) return 'اسم الفحص قصير';
    if (text.length > 80) return 'اسم الفحص طويل';
    if (text.contains('  ')) return 'اسم الفحص غير صحيح';

    return null;
  }

  String? validateExamResult(String? value) {
    final String text = value?.trim() ?? '';

    if (text.isEmpty) return 'مطلوب';
    if (text.length > 100) return 'النتيجة طويلة';

    return null;
  }

  String? validateMeasurementUnit(String? value) {
    final String text = value?.trim() ?? '';

    if (text.isEmpty) return null;
    if (text.length > 30) return 'الوحدة طويلة';

    return null;
  }

  String? validateNotes(String? value) {
    final String text = value?.trim() ?? '';

    if (text.length > 200) {
      return 'الحد الأقصى 200 حرف';
    }

    return null;
  }

  Future<void> selectExamDate() async {
    final DateTime today = dateOnly(DateTime.now());
    final DateTime birthDate = dateOnly(widget.birthDate);

    if (birthDate.isAfter(today)) {
      showTemporaryMessage(
        'تاريخ ميلاد الطفل لا يمكن أن يكون في المستقبل',
      );
      return;
    }

    DateTime initialDate = examDate ?? today;

    if (initialDate.isBefore(birthDate)) {
      initialDate = birthDate;
    }

    if (initialDate.isAfter(today)) {
      initialDate = today;
    }

    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: birthDate,
      lastDate: today,
      helpText: 'اختيار تاريخ الفحص',
      cancelText: 'إلغاء',
      confirmText: 'اختيار',
    );

    if (selectedDate == null || !mounted) return;

    setState(() {
      examDate = selectedDate;
      examDateError = null;
    });
  }

  bool validateExamDate() {
    setState(() {
      examDateError = examDate == null ? 'مطلوب' : null;
    });

    return examDateError == null;
  }

  Future<void> showAttachmentOptions(
      TapDownDetails details,
      ) async {
    if (isSaving || isPickingAttachment) return;

    final ThemeData theme = Theme.of(context);

    final RenderObject? renderObject =
    Overlay.of(context).context.findRenderObject();

    if (renderObject is! RenderBox) {
      showTemporaryMessage('تعذر فتح قائمة المرفقات');
      return;
    }

    final RenderBox overlay = renderObject;
    final Offset position = details.globalPosition;

    final String? option = await showMenu<String>(
      context: context,
      color: theme.cardColor,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy,
        overlay.size.width - position.dx,
        overlay.size.height - position.dy,
      ),
      items: [
        PopupMenuItem<String>(
          value: 'gallery',
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Row(
              children: [
                const Icon(
                  Icons.photo_library_outlined,
                  color: Color(0xff64C7C4),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'اختيار صورة من المعرض',
                    style: TextStyle(
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        PopupMenuItem<String>(
          value: 'camera',
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Row(
              children: [
                const Icon(
                  Icons.camera_alt_outlined,
                  color: Color(0xff64C7C4),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'التقاط صورة بالكاميرا',
                    style: TextStyle(
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        PopupMenuItem<String>(
          value: 'file',
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Row(
              children: [
                const Icon(
                  Icons.insert_drive_file_outlined,
                  color: Color(0xff64C7C4),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'اختيار ملف',
                    style: TextStyle(
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );

    if (!mounted || option == null) return;

    switch (option) {
      case 'gallery':
        await pickImageFromGallery();
        break;
      case 'camera':
        await takePicture();
        break;
      case 'file':
        await pickFile();
        break;
    }
  }

  Future<void> pickImageFromGallery() async {
    if (isPickingAttachment || isSaving) return;

    setState(() {
      isPickingAttachment = true;
    });

    try {
      final XFile? image = await imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (!mounted || image == null) return;

      setState(() {
        selectedImage = image;
        selectedFile = null;
        selectedAttachmentType = 'gallery';
      });

      showTemporaryMessage('تم اختيار الصورة بنجاح');
    } catch (e) {
      debugPrint('Gallery error: $e');

      if (mounted) {
        showTemporaryMessage(
          'تعذر فتح المعرض. حاولي مرة أخرى.',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isPickingAttachment = false;
        });
      }
    }
  }

  Future<void> takePicture() async {
    if (isPickingAttachment || isSaving) return;

    setState(() {
      isPickingAttachment = true;
    });

    try {
      final XFile? image = await imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );

      if (!mounted || image == null) return;

      setState(() {
        selectedImage = image;
        selectedFile = null;
        selectedAttachmentType = 'camera';
      });

      showTemporaryMessage('تم التقاط الصورة بنجاح');
    } catch (e) {
      debugPrint('Camera error: $e');

      if (mounted) {
        showTemporaryMessage(
          'تعذر تشغيل الكاميرا. حاولي مرة أخرى.',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isPickingAttachment = false;
        });
      }
    }
  }

  Future<void> pickFile() async {
    if (isPickingAttachment || isSaving) return;

    setState(() {
      isPickingAttachment = true;
    });

    try {
      final FilePickerResult? result =
      await FilePicker.pickFiles(
        type: FileType.any,
        allowMultiple: false,
      );

      if (!mounted) return;

      if (result == null || result.files.isEmpty) {
        return;
      }

      final PlatformFile file = result.files.first;

      setState(() {
        selectedFile = file;
        selectedImage = null;
        selectedAttachmentType = 'file';
      });

      showTemporaryMessage('تم اختيار الملف بنجاح');
    } catch (e) {
      if (mounted) {
        showTemporaryMessage(
          'تعذر فتح الملفات. حاولي مرة أخرى.',
        );

        debugPrint('File picker error: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          isPickingAttachment = false;
        });
      }
    }
  }

  void removeAttachment() {
    if (isSaving || isPickingAttachment) return;

    setState(() {
      selectedAttachmentType = null;
      selectedImage = null;
      selectedFile = null;
    });

    showTemporaryMessage('تم إلغاء المرفق');
  }

  String attachmentText() {
    if (selectedImage != null) {
      return selectedImage!.name;
    }

    if (selectedFile != null) {
      return selectedFile!.name;
    }

    return 'اضغط لإرفاق صورة أو ملف (اختياري)';
  }

  void showTemporaryMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          textAlign: TextAlign.center,
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> saveMedicalExam() async {
    if (isSaving || isPickingAttachment) return;

    FocusScope.of(context).unfocus();



    final String examName = examNameController.text.trim();
    final String examResult = examResultController.text.trim();
    final String measurementUnit =
    measurementUnitController.text.trim();
    final String notes = notesController.text.trim();

    /*
      مستقبلًا عند ربط Laravel:

      POST /api/children/{childId}/medical-exams

      Authorization: Bearer TOKEN

      {
        "exam_name": examName,
        "exam_result": examResult,
        "measurement_unit": measurementUnit,
        "exam_date": formatApiDate(examDate!),
        "notes": notes
      }

      رفع المرفقات يحتاج إرسالها إلى API
      وحفظ مسار الملف في قاعدة البيانات.
    */

    debugPrint('Exam name: $examName');
    debugPrint('Exam result: $examResult');
    debugPrint('Unit: $measurementUnit');
    debugPrint('Date: ${formatApiDate(examDate!)}');
    debugPrint('Notes: $notes');
    debugPrint('Attachment type: $selectedAttachmentType');

    debugPrint(
      'Attachment path: '
          '${selectedImage?.path ?? selectedFile?.path ?? "لا يوجد"}',
    );

    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    examNameController.clear();
    examResultController.clear();
    measurementUnitController.clear();
    notesController.clear();

    setState(() {
      isSaving = false;
      examDate = null;
      examDateError = null;
      selectedAttachmentType = null;
      selectedImage = null;
      selectedFile = null;
    });

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'تم حفظ بيانات الفحص الطبي بنجاح',
          textAlign: TextAlign.center,
        ),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  void dispose() {
    examNameController.dispose();
    examResultController.dispose();
    measurementUnitController.dispose();
    notesController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    final Color primaryColor = theme.primaryColor;
    final Color darkColor = theme.colorScheme.onSurface;
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
                      child: Column(
                        children: [
                          // Header
                          SizedBox(
                            height: 48,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Text(
                                  'تسجيل فحص طبي',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize:
                                    isVerySmall ? 18 : 22,
                                    fontWeight: FontWeight.bold,
                                    color: darkColor,
                                  ),
                                ),

                                Align(
                                  alignment: AlignmentDirectional
                                      .centerStart,
                                  child: IconButton(
                                    onPressed: isSaving
                                        ? null
                                        : () {
                                      Navigator.pop(context);
                                    },
                                    padding: EdgeInsets.zero,
                                    constraints:
                                    const BoxConstraints(
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
                                  alignment: AlignmentDirectional
                                      .centerEnd,
                                  child: SizedBox(
                                    height: 44,
                                    child: ElevatedButton(
                                      onPressed: isSaving
                                          ? null
                                          : saveMedicalExam,
                                      style:
                                      ElevatedButton.styleFrom(
                                        backgroundColor:
                                        primaryColor,
                                        foregroundColor:
                                        Colors.white,
                                        elevation: 0,
                                        padding:
                                        EdgeInsets.symmetric(
                                          horizontal:
                                          isVerySmall ? 14 : 18,
                                        ),
                                        shape:
                                        RoundedRectangleBorder(
                                          borderRadius:
                                          BorderRadius.circular(
                                            12,
                                          ),
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
                            height: isSmallScreen ? 35 : 45
                            ,
                          ),

                          // عنوان بيانات الفحص
                          Row(
                            children: [
                              Icon(
                                Icons.assignment_turned_in_outlined,
                                color: primaryColor,
                                size: 25,
                              ),
                              const SizedBox(width: 7),
                              Text(
                                'بيانات الفحص الطبي',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: darkColor,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 18),

                          // اسم الفحص ونتيجته
                          _responsivePair(
                            isVerySmall: isVerySmall,
                            first: TextFormField(
                              controller: examNameController,
                              enabled: !isSaving,
                              style: TextStyle(
                                color: darkColor,
                              ),
                              textAlign: TextAlign.right,
                              autovalidateMode:
                              AutovalidateMode
                                  .onUserInteraction,
                              validator: validateExamName,
                              decoration: examInputDecoration(
                                label: 'اسم الفحص',
                                hint: 'مثال: HbA1c',
                                icon: Icons.science_outlined,
                                errorText: null,
                                primaryColor: primaryColor,
                                borderColor: borderColor,
                                hintColor: hintColor,
                              ),
                            ),
                            second: TextFormField(
                              controller: examResultController,
                              enabled: !isSaving,
                              style: TextStyle(
                                color: darkColor,
                              ),
                              textAlign: TextAlign.right,
                              autovalidateMode:
                              AutovalidateMode
                                  .onUserInteraction,
                              validator: validateExamResult,
                              decoration: examInputDecoration(
                                label: 'نتيجة الفحص',
                                hint: 'أدخل النتيجة',
                                icon: Icons.fact_check_outlined,
                                errorText: null,
                                primaryColor: primaryColor,
                                borderColor: borderColor,
                                hintColor: hintColor,
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // وحدة القياس وتاريخ الفحص
                          _responsivePair(
                            isVerySmall: isVerySmall,
                            first: TextFormField(
                              controller:
                              measurementUnitController,
                              enabled: !isSaving,
                              style: TextStyle(
                                color: darkColor,
                              ),
                              textAlign: TextAlign.right,
                              autovalidateMode:
                              AutovalidateMode
                                  .onUserInteraction,
                              validator:
                              validateMeasurementUnit,
                              decoration: examInputDecoration(
                                label: 'وحدة القياس (اختياري)',
                                hint: 'مثال: mg/dL أو %',
                                icon:
                                Icons.straighten_outlined,
                                errorText: null,
                                primaryColor: primaryColor,
                                borderColor: borderColor,
                                hintColor: hintColor,
                              ),
                            ),
                            second: _buildDateField(
                              primaryColor: primaryColor,
                              borderColor: borderColor,
                              hintColor: hintColor,
                              darkColor: darkColor,
                            ),
                          ),

                          const SizedBox(height: 16),

                          // المرفق
                          GestureDetector(
                            onTapDown:
                            isSaving || isPickingAttachment
                                ? null
                                : showAttachmentOptions,
                            child: Container(
                              width: double.infinity,
                              padding:
                              const EdgeInsets.symmetric(
                                horizontal: 15,
                                vertical: 15,
                              ),
                              decoration: BoxDecoration(
                                color: cardColor,
                                borderRadius:
                                BorderRadius.circular(14),
                                border: Border.all(
                                  color:
                                  selectedAttachmentType ==
                                      null
                                      ? borderColor
                                      : primaryColor,
                                  width: 1.3,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    selectedImage != null
                                        ? Icons.image_outlined
                                        : selectedFile != null
                                        ? Icons
                                        .insert_drive_file_outlined
                                        : Icons
                                        .cloud_upload_outlined,
                                    size: 27,
                                    color: primaryColor,
                                  ),

                                  const SizedBox(width: 10),

                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment
                                          .start,
                                      children: [
                                        Text(
                                          'المرفق',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight:
                                            FontWeight.bold,
                                            color: darkColor,
                                          ),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          isPickingAttachment
                                              ? 'جارٍ فتح المرفقات...'
                                              : attachmentText(),
                                          maxLines: 2,
                                          overflow:
                                          TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: hintColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  if (isPickingAttachment)
                                    SizedBox(
                                      width: 22,
                                      height: 22,
                                      child:
                                      CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: primaryColor,
                                      ),
                                    )
                                  else if (
                                  selectedAttachmentType !=
                                      null)
                                    IconButton(
                                      onPressed: isSaving
                                          ? null
                                          : removeAttachment,
                                      icon: const Icon(
                                        Icons.close_rounded,
                                        color: Color(0xffC85C55),
                                      ),
                                    )
                                  else
                                    Icon(
                                      Icons
                                          .keyboard_arrow_down_rounded,
                                      color: darkColor,
                                    ),
                                ],
                              ),
                            ),
                          ),

                          // معاينة الصورة
                          if (selectedImage != null) ...[
                            const SizedBox(height: 12),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: cardColor,
                                borderRadius:
                                BorderRadius.circular(14),
                                border: Border.all(
                                  color: borderColor,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius:
                                BorderRadius.circular(10),
                                child: Image.file(
                                  File(selectedImage!.path),
                                  height: 180,
                                  fit: BoxFit.contain,
                                  errorBuilder:
                                      (context, error, stackTrace) {
                                    return const SizedBox(
                                      height: 100,
                                      child: Center(
                                        child: Text(
                                          'تعذر عرض معاينة الصورة',
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],

                          // تفاصيل الملف
                          if (selectedFile != null) ...[
                            const SizedBox(height: 12),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: cardColor,
                                borderRadius:
                                BorderRadius.circular(14),
                                border: Border.all(
                                  color: borderColor,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.description_outlined,
                                    color: primaryColor,
                                    size: 30,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment
                                          .start,
                                      children: [
                                        Text(
                                          selectedFile!.name,
                                          maxLines: 2,
                                          overflow:
                                          TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: darkColor,
                                            fontWeight:
                                            FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${(selectedFile!.size / 1024).toStringAsFixed(1)} KB',
                                          style: TextStyle(
                                            color: hintColor,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          const SizedBox(height: 16),

                          // الملاحظات
                          TextFormField(
                            controller: notesController,
                            enabled: !isSaving,
                            style: TextStyle(
                              color: darkColor,
                            ),
                            textAlign: TextAlign.right,
                            keyboardType:
                            TextInputType.multiline,
                            minLines: 2,
                            maxLines: 4,
                            maxLength: 200,
                            validator: validateNotes,
                            decoration: examInputDecoration(
                              label: 'ملاحظات (اختياري)',
                              hint:
                              'مثال: الفحص كان صائمًا أو تعليق الطبيب',
                              icon: Icons.edit_note_rounded,
                              errorText: null,
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

                          const SizedBox(height: 39),

                          // التنبيه
                          Container(
                            width: double.infinity,
                            padding:
                            const EdgeInsets.symmetric(
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
                                    'أدخل نتيجة الفحص كما تظهر في التقرير الطبي دون تفسيرها',
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

  Widget _buildDateField({
    required Color primaryColor,
    required Color borderColor,
    required Color hintColor,
    required Color darkColor,
  }) {
    return InkWell(
      onTap: isSaving ? null : selectExamDate,
      borderRadius: BorderRadius.circular(14),
      child: InputDecorator(
        decoration: examInputDecoration(
          label: 'تاريخ الفحص',
          hint: '',
          icon: Icons.calendar_month_outlined,
          errorText: examDateError,
          primaryColor: primaryColor,
          borderColor: borderColor,
          hintColor: hintColor,
        ),
        child: Text(
          examDate == null
              ? 'اختر تاريخ الفحص'
              : formatDate(examDate),
          textAlign: TextAlign.right,
          style: TextStyle(
            fontSize: 13,
            color: examDate == null
                ? hintColor
                : darkColor,
          ),
        ),
      ),
    );
  }

  InputDecoration examInputDecoration({
    required String label,
    required String hint,
    required IconData icon,
    required String? errorText,
    required Color primaryColor,
    required Color borderColor,
    required Color hintColor,
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
        size: 21,
      ),
      filled: true,
      fillColor: theme.cardColor,
      contentPadding: const EdgeInsets.symmetric(
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