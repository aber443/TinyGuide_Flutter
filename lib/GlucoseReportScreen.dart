import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class GlucoseReportScreen extends StatelessWidget {
  final String childName;
  final DateTime startDate;
  final DateTime endDate;

  const GlucoseReportScreen({
    super.key,
    required this.childName,
    required this.startDate,
    required this.endDate,
  });

  // =========================
  // Date Formatter
  // =========================

  String formatDate(DateTime date) {
    final String day = date.day.toString().padLeft(2, '0');
    final String month = date.month.toString().padLeft(2, '0');

    return '$day/$month/${date.year}';
  }

  // =========================
  // Message
  // =========================

  void _showMessage(BuildContext context, String message) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          textAlign: TextAlign.center,
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // =========================
  // PDF Detail
  // =========================

  pw.Widget _pdfDetail({
    required String title,
    required String description,
    required pw.Font font,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 16),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(
              font: font,
              fontSize: 15,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 6),
          pw.Text(
            description,
            style: pw.TextStyle(
              font: font,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // =========================
  // Export PDF
  // =========================

  Future<void> _exportPdf(BuildContext context) async {
    try {
      final fontData =
      await rootBundle.load('assets/fonts/arial.ttf');

      final arabicFont = pw.Font.ttf(fontData);

      final pdf = pw.Document();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          textDirection: pw.TextDirection.rtl,
          theme: pw.ThemeData.withFont(
            base: arabicFont,
            bold: arabicFont,
          ),
          build: (pw.Context pdfContext) => [
            pw.Center(
              child: pw.Text(
                'تقرير قراءات السكر',
                style: pw.TextStyle(
                  font: arabicFont,
                  fontSize: 22,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),

            pw.SizedBox(height: 24),

            pw.Text(
              'اسم الطفل: $childName',
              style: pw.TextStyle(
                font: arabicFont,
                fontSize: 13,
              ),
            ),

            pw.SizedBox(height: 10),

            pw.Text(
              'فترة التقرير: ${formatDate(startDate)} - ${formatDate(endDate)}',
              style: pw.TextStyle(
                font: arabicFont,
                fontSize: 13,
              ),
            ),

            pw.SizedBox(height: 24),

            pw.Text(
              'ملخص قراءات السكر',
              style: pw.TextStyle(
                font: arabicFont,
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
              ),
            ),

            pw.SizedBox(height: 12),

            pw.Text(
              'لا توجد بيانات قراءات سكر متاحة للعرض حاليًا.',
              style: pw.TextStyle(
                font: arabicFont,
                fontSize: 12,
              ),
            ),

            pw.SizedBox(height: 24),

            pw.Text(
              'تفاصيل قراءات السكر',
              style: pw.TextStyle(
                font: arabicFont,
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
              ),
            ),

            pw.SizedBox(height: 14),

            _pdfDetail(
              title: 'مستوى السكر',
              description:
              'ستظهر مستويات السكر المسجلة للطفل خلال الفترة المحددة.',
              font: arabicFont,
            ),

            _pdfDetail(
              title: 'تاريخ ووقت القياس',
              description:
              'ستظهر تواريخ وأوقات قياسات السكر المسجلة.',
              font: arabicFont,
            ),

            _pdfDetail(
              title: 'نوع القياس',
              description:
              'سيظهر نوع القياس المسجل، مثل قبل الوجبة أو بعدها.',
              font: arabicFont,
            ),

            _pdfDetail(
              title: 'متوسط قراءات السكر',
              description:
              'سيتم حساب المتوسط من القراءات الفعلية بعد ربط البيانات.',
              font: arabicFont,
            ),

            _pdfDetail(
              title: 'ملاحظات القراءات',
              description:
              'ستظهر الملاحظات المرتبطة بكل قراءة عند توفرها.',
              font: arabicFont,
            ),

            pw.SizedBox(height: 12),

            pw.Text(
              'ملاحظة طبية',
              style: pw.TextStyle(
                font: arabicFont,
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
              ),
            ),

            pw.SizedBox(height: 8),

            pw.Text(
              'هذا التقرير مخصص لتنظيم قراءات السكر المسجلة ومشاركتها مع الطبيب. لا يُعد تشخيصًا طبيًا، ولا يُستخدم لاتخاذ قرارات علاجية أو تعديل جرعات الإنسولين دون الرجوع للطبيب المختص.',
              style: pw.TextStyle(
                font: arabicFont,
                fontSize: 12,
              ),
            ),
          ],
        ),
      );

      await Printing.layoutPdf(
        name: 'TinyGuide_Glucose_Report.pdf',
        format: PdfPageFormat.a4,
        onLayout: (format) async => pdf.save(),
      );
    } catch (e) {
      if (!context.mounted) return;

      _showMessage(
        context,
        'تعذر إنشاء ملف PDF. تأكدي من وجود الخط وإعداداته.',
      );
    }
  }

  // =========================
  // Build Screen
  // =========================

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    final bool isDark =
        theme.brightness == Brightness.dark;

    final Color primaryColor = theme.primaryColor;

    final Color textColor = isDark
        ? Colors.white
        : const Color(0xff2C4A5A);

    final Color secondaryTextColor = isDark
        ? Colors.white.withOpacity(0.60)
        : const Color(0xff78909A);

    final Color cardColor = isDark
        ? const Color(0xff1D292D)
        : Colors.white;

    final Color borderColor = isDark
        ? Colors.white.withOpacity(0.12)
        : const Color(0xffE2EEEE);

    return Scaffold(
      body: SafeArea(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final bool isTablet =
                  constraints.maxWidth >= 600;

              final double horizontalPadding =
              constraints.maxWidth < 390
                  ? 14.0
                  : isTablet
                  ? 36.0
                  : 20.0;

              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: 18,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints:
                    const BoxConstraints(maxWidth: 760),
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        // =========================
                        // Header
                        // =========================

                        SizedBox(
                          height: 48,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Center(
                                child: Text(
                                  'تقرير قراءات السكر',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize:
                                    isTablet ? 31 : 27,
                                    fontWeight: FontWeight.bold,
                                    color: textColor,
                                  ),
                                ),
                              ),
                              Align(
                                alignment:
                                AlignmentDirectional.centerStart,
                                child: IconButton(
                                  onPressed: () =>
                                      Navigator.pop(context),
                                  icon: Icon(
                                    Icons.arrow_back_ios_new_rounded,
                                    color: textColor,
                                    size: 22,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 10),

                        Text(
                          'متابعة قراءات السكر للطفل $childName خلال الفترة المحددة',
                          style: TextStyle(
                            fontSize: 14,
                            color: secondaryTextColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),

                        const SizedBox(height: 24),

                        // =========================
                        // Report Period
                        // =========================

                        _card(
                          cardColor,
                          borderColor,
                          Row(
                            children: [
                              _icon(
                                Icons.date_range_rounded,
                                primaryColor,
                              ),

                              const SizedBox(width: 12),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'فترة التقرير',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: textColor,
                                      ),
                                    ),

                                    const SizedBox(height: 5),

                                    Text(
                                      '${formatDate(startDate)} - ${formatDate(endDate)}',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: secondaryTextColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // =========================
                        // Glucose Summary
                        // =========================

                        Text(
                          'ملخص قراءات السكر',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),

                        const SizedBox(height: 14),

                        _card(
                          cardColor,
                          borderColor,
                          SizedBox(
                            width: double.infinity,
                            child: Column(
                              children: [
                                Icon(
                                  Icons.bloodtype_outlined,
                                  size: 52,
                                  color: primaryColor,
                                ),

                                const SizedBox(height: 12),

                                Text(
                                  'لا توجد قراءات سكر للعرض',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: textColor,
                                  ),
                                ),

                                const SizedBox(height: 8),

                                Text(
                                  'ستظهر قراءات السكر المسجلة للطفل خلال الفترة المحددة بعد ربط البيانات الفعلية.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 13,
                                    height: 1.7,
                                    color: secondaryTextColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // =========================
                        // Glucose Details
                        // =========================

                        Text(
                          'تفاصيل قراءات السكر',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),

                        const SizedBox(height: 14),

                        _detailCard(
                          icon: Icons.water_drop_outlined,
                          title: 'مستوى السكر',
                          description:
                          'ستظهر مستويات السكر المسجلة للطفل خلال الفترة المحددة.',
                          primaryColor: primaryColor,
                          cardColor: cardColor,
                          borderColor: borderColor,
                          textColor: textColor,
                          secondaryTextColor:
                          secondaryTextColor,
                        ),

                        const SizedBox(height: 12),

                        _detailCard(
                          icon: Icons.access_time_rounded,
                          title: 'تاريخ ووقت القياس',
                          description:
                          'ستظهر تواريخ وأوقات قياسات السكر المسجلة.',
                          primaryColor: primaryColor,
                          cardColor: cardColor,
                          borderColor: borderColor,
                          textColor: textColor,
                          secondaryTextColor:
                          secondaryTextColor,
                        ),

                        const SizedBox(height: 12),

                        _detailCard(
                          icon: Icons.restaurant_outlined,
                          title: 'نوع القياس',
                          description:
                          'سيظهر نوع القياس المسجل، مثل قبل الوجبة أو بعدها.',
                          primaryColor: primaryColor,
                          cardColor: cardColor,
                          borderColor: borderColor,
                          textColor: textColor,
                          secondaryTextColor:
                          secondaryTextColor,
                        ),

                        const SizedBox(height: 12),

                        _detailCard(
                          icon: Icons.calculate_outlined,
                          title: 'متوسط قراءات السكر',
                          description:
                          'سيتم حساب المتوسط من القراءات الفعلية بعد ربط البيانات.',
                          primaryColor: primaryColor,
                          cardColor: cardColor,
                          borderColor: borderColor,
                          textColor: textColor,
                          secondaryTextColor:
                          secondaryTextColor,
                        ),

                        const SizedBox(height: 12),

                        _detailCard(
                          icon: Icons.notes_outlined,
                          title: 'ملاحظات القراءات',
                          description:
                          'ستظهر الملاحظات المرتبطة بكل قراءة عند توفرها.',
                          primaryColor: primaryColor,
                          cardColor: cardColor,
                          borderColor: borderColor,
                          textColor: textColor,
                          secondaryTextColor:
                          secondaryTextColor,
                        ),

                        const SizedBox(height: 24),

                        // =========================
                        // Medical Disclaimer
                        // =========================

                        _card(
                          cardColor,
                          borderColor,
                          Row(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.info_outline_rounded,
                                color: primaryColor,
                                size: 22,
                              ),

                              const SizedBox(width: 9),

                              Expanded(
                                child: Text(
                                  'هذا التقرير مخصص لتنظيم قراءات السكر المسجلة ومشاركتها مع الطبيب. لا يُعد تشخيصًا طبيًا، ولا يُستخدم لاتخاذ قرارات علاجية أو تعديل جرعات الإنسولين دون الرجوع للطبيب المختص.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    height: 1.7,
                                    color: secondaryTextColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // =========================
                        // Save Report
                        // =========================

                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              _showMessage(
                                context,
                                'حفظ التقرير غير متاح حاليًا. سيتفعّل بعد ربط Laravel API.',
                              );
                            },
                            icon: const Icon(
                              Icons.save_outlined,
                            ),
                            label: const Text(
                              'حفظ التقرير',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // =========================
                        // Download PDF
                        // =========================

                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: OutlinedButton.icon(
                            onPressed: () => _exportPdf(context),
                            icon: const Icon(
                              Icons.picture_as_pdf_outlined,
                            ),
                            label: const Text(
                              'تنزيل PDF',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // =========================
  // Card
  // =========================

  Widget _card(
      Color cardColor,
      Color borderColor,
      Widget child,
      ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
      ),
      child: child,
    );
  }

  // =========================
  // Icon
  // =========================

  Widget _icon(
      IconData icon,
      Color primaryColor,
      ) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.10),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(
        icon,
        color: primaryColor,
        size: 25,
      ),
    );
  }

  // =========================
  // Detail Card
  // =========================

  Widget _detailCard({
    required IconData icon,
    required String title,
    required String description,
    required Color primaryColor,
    required Color cardColor,
    required Color borderColor,
    required Color textColor,
    required Color secondaryTextColor,
  }) {
    return _card(
      cardColor,
      borderColor,
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _icon(icon, primaryColor),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12.5,
                    height: 1.7,
                    color: secondaryTextColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}