import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/services.dart' show rootBundle;

class MedicationReportScreen extends StatelessWidget {
  final String childName;
  final DateTime startDate;
  final DateTime endDate;

  const MedicationReportScreen({
    super.key,
    required this.childName,
    required this.startDate,
    required this.endDate,
  });

  String formatDate(DateTime date) {
    final String day = date.day.toString().padLeft(2, '0');
    final String month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, textAlign: TextAlign.center),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
  Future<void> _exportPdf(BuildContext context) async {
    try {
      final fontData = await rootBundle.load('assets/fonts/arial.ttf');
      final arabicFont = pw.Font.ttf(fontData);

      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          theme: pw.ThemeData.withFont(
            base: arabicFont,
            bold: arabicFont,
          ),
          build: (pw.Context pdfContext) {
            return pw.Directionality(
              textDirection: pw.TextDirection.rtl,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Center(
                    child: pw.Text(
                      'تقرير الأدوية',
                      style: pw.TextStyle(
                        font: arabicFont,
                        fontSize: 22,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                  pw.SizedBox(height: 24),
                  pw.Text('اسم الطفل: $childName'),
                  pw.SizedBox(height: 10),
                  pw.Text(
                    'فترة التقرير: ${formatDate(startDate)} - ${formatDate(endDate)}',
                  ),
                  pw.SizedBox(height: 24),
                  pw.Text(
                    'لا توجد بيانات أدوية متاحة للعرض حاليًا.',
                    style: pw.TextStyle(
                      font: arabicFont,
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 10),
                  pw.Text(
                    'ستظهر الأدوية والجرعات المسجلة بعد ربط البيانات.',
                  ),
                  pw.SizedBox(height: 24),
                  pw.Text(
                    'تنبيه: لا تغيّري الجرعة ولا تبدئي أو توقفي أي علاج دون الرجوع إلى الطبيب أو المختص.',
                  ),
                ],
              ),
            );
          },
        ),
      );

      await Printing.layoutPdf(
        name: 'TinyGuide_Medication_Report.pdf',
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
  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    final Color primaryColor = theme.primaryColor;
    final Color textColor =
    isDark ? Colors.white : const Color(0xff2C4A5A);
    final Color secondaryTextColor =
    isDark ? Colors.white.withOpacity(0.60) : const Color(0xff78909A);
    final Color cardColor =
    isDark ? const Color(0xff1D292D) : Colors.white;
    final Color borderColor =
    isDark ? Colors.white.withOpacity(0.12) : const Color(0xffE2EEEE);

    return Scaffold(
      body: SafeArea(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final bool isTablet = constraints.maxWidth >= 600;
              final double horizontalPadding =
              constraints.maxWidth < 390
                  ? 14
                  : isTablet
                  ? 36
                  : 20;

              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: 18,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 760),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        SizedBox(
                          height: 48,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Center(
                                child: Text(
                                  'تقرير الأدوية',
                                  style: TextStyle(
                                    fontSize: isTablet ? 31 : 27,
                                    fontWeight: FontWeight.bold,
                                    color: textColor,
                                  ),
                                ),
                              ),
                              Align(
                                alignment: AlignmentDirectional.centerStart,
                                child: IconButton(
                                  onPressed: () => Navigator.pop(context),
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
                          'متابعة الأدوية المسجلة لـ $childName',
                          style: TextStyle(
                            fontSize: 14,
                            color: secondaryTextColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Report period
                        _card(
                          cardColor,
                          borderColor,
                          Row(
                            children: [
                              _icon(Icons.date_range_rounded, primaryColor),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
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

                        Text(
                          'ملخص الأدوية',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),

                        const SizedBox(height: 14),

                        // Empty state
                        _card(
                          cardColor,
                          borderColor,
                          SizedBox(
                            width: double.infinity,
                            child: Column(
                              children: [
                                Icon(
                                  Icons.medication_outlined,
                                  size: 52,
                                  color: primaryColor,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'لا توجد بيانات أدوية للعرض',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: textColor,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'ستظهر الأدوية والجرعات المسجلة للطفل خلال الفترة المحددة بعد ربط البيانات.',
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

                        Text(
                          'تفاصيل الأدوية',
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
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _icon(
                                Icons.info_outline_rounded,
                                primaryColor,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'التفاصيل غير متاحة حاليًا',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: textColor,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'لا تتوفر حاليًا بيانات كافية لعرض تفاصيل الأدوية أو الجرعات. لن يتم عرض أسماء أو أرقام تجريبية على أنها بيانات حقيقية.',
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
                        ),

                        const SizedBox(height: 20),

                        // Medical safety note
                        _card(
                          cardColor,
                          borderColor,
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.health_and_safety_outlined,
                                color: primaryColor,
                                size: 23,
                              ),
                              const SizedBox(width: 9),
                              Expanded(
                                child: Text(
                                  'يعرض التقرير الأدوية والجرعات المسجلة فقط. لا تغيّري الجرعة ولا تبدئي أو توقفي أي علاج دون الرجوع إلى الطبيب أو المختص.',
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

                        // Save report
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              _showMessage(
                                context,
                                'حفظ التقرير في قاعدة البيانات سيتاح بعد ربط Laravel API.',
                              );
                            },
                            icon: const Icon(Icons.save_outlined),
                            label: const Text(
                              'حفظ التقرير',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Download PDF


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

  Widget _card(Color cardColor, Color borderColor, Widget child) {
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

  Widget _icon(IconData icon, Color primaryColor) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.10),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(icon, color: primaryColor, size: 25),
    );
  }
}