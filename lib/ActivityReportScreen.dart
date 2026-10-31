import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/services.dart' show rootBundle;

class ActivityReportScreen extends StatelessWidget {
  final String childName;
  final DateTime startDate;
  final DateTime endDate;

  const ActivityReportScreen({
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
        content: Text(
          message,
          textAlign: TextAlign.center,
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
  Future<void> _exportPdf(BuildContext context) async {
    try {
      _showMessage(context, 'جارٍ تجهيز ملف PDF...');

      final fontData =
      await rootBundle.load('assets/fonts/arial.ttf');

      final arabicFont = pw.Font.ttf(fontData);

      final pdf = pw.Document(
        theme: pw.ThemeData.withFont(
          base: arabicFont,
          bold: arabicFont,
        ),
      );

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(40),
          textDirection: pw.TextDirection.rtl,
          build: (pw.Context pdfContext) {
            return [
              pw.Center(
                child: pw.Text(
                  'TinyGuide',
                  style: pw.TextStyle(
                    fontSize: 25,
                    fontWeight: pw.FontWeight.bold,
                    color: const PdfColor(0.20, 0.66, 0.64),
                  ),
                ),
              ),

              pw.SizedBox(height: 12),

              pw.Center(
                child: pw.Text(
                  'تقرير النشاط',
                  style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),

              pw.SizedBox(height: 25),

              pw.Text(
                'اسم الطفل: $childName',
                style: const pw.TextStyle(fontSize: 13),
              ),

              pw.SizedBox(height: 12),

              pw.Text(
                'تاريخ البداية: ${formatDate(startDate)}',
                style: const pw.TextStyle(fontSize: 13),
              ),

              pw.SizedBox(height: 12),

              pw.Text(
                'تاريخ النهاية: ${formatDate(endDate)}',
                style: const pw.TextStyle(fontSize: 13),
              ),

              pw.SizedBox(height: 12),

              pw.Text(
                'تاريخ إنشاء التقرير: '
                    '${formatDate(DateTime.now())}',
                style: const pw.TextStyle(fontSize: 13),
              ),

              pw.SizedBox(height: 25),

              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(15),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(
                    color: const PdfColor(0.82, 0.88, 0.88),
                  ),
                  borderRadius: pw.BorderRadius.circular(10),
                ),
                child: pw.Column(
                  crossAxisAlignment:
                  pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'ملخص النشاط',
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                        color: const PdfColor(0.20, 0.66, 0.64),
                      ),
                    ),

                    pw.SizedBox(height: 12),

                    pw.Text(
                      'لا توجد بيانات نشاط فعلية متاحة للعرض حاليًا.',
                      style: const pw.TextStyle(
                        fontSize: 12,
                        lineSpacing: 4,
                      ),
                    ),

                    pw.SizedBox(height: 12),

                    pw.Text(
                      'ستظهر أنواع الأنشطة ومددها وأيام تسجيلها '
                          'بعد ربط التقرير بمصدر البيانات وتوفر '
                          'السجلات الفعلية للطفل خلال الفترة المحددة.',
                      style: const pw.TextStyle(
                        fontSize: 12,
                        lineSpacing: 4,
                      ),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 20),

              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(
                    color: const PdfColor(0.82, 0.88, 0.88),
                  ),
                  borderRadius: pw.BorderRadius.circular(10),
                ),
                child: pw.Text(
                  'تنبيه: هذا التقرير مخصص للمتابعة والتنظيم فقط، '
                      'ولا يُعد تقييمًا طبيًا لمستوى نشاط الطفل.',
                  style: const pw.TextStyle(
                    fontSize: 11,
                    lineSpacing: 4,
                  ),
                ),
              ),

              pw.SizedBox(height: 25),

              pw.Divider(
                color: const PdfColor(0.82, 0.88, 0.88),
              ),

              pw.SizedBox(height: 8),

              pw.Center(
                child: pw.Text(
                  'تم إنشاء هذا التقرير بواسطة TinyGuide',
                  style: const pw.TextStyle(
                    fontSize: 10,
                  ),
                ),
              ),
            ];
          },
        ),
      );

      await Printing.layoutPdf(
        name: 'TinyGuide_Activity_Report.pdf',
        format: PdfPageFormat.a4,
        onLayout: (PdfPageFormat format) async {
          return pdf.save();
        },
      );
    } catch (error) {
      if (!context.mounted) return;

      _showMessage(
        context,
        'تعذر إنشاء ملف PDF. حاولي مرة أخرى.',
      );

      debugPrint('Activity PDF export error: $error');
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
                                  'تقرير النشاط',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: isTablet ? 31 : 27,
                                    fontWeight: FontWeight.bold,
                                    color: textColor,
                                  ),
                                ),
                              ),
                              Align(
                                alignment:
                                AlignmentDirectional.centerStart,
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
                          'متابعة نشاط $childName خلال الفترة المحددة',
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

                        Text(
                          'ملخص النشاط',
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
                                  Icons.directions_run_rounded,
                                  size: 52,
                                  color: primaryColor,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'لا توجد بيانات نشاط للعرض',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: textColor,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'ستظهر أعداد الأنشطة ومددها وتفاصيلها بعد جلب السجلات الفعلية للطفل خلال الفترة المحددة.',
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
                          'تفاصيل النشاط',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),

                        const SizedBox(height: 14),

                        _detailCard(
                          icon: Icons.list_alt_rounded,
                          title: 'الأنشطة المسجلة',
                          description:
                          'ستظهر أنواع الأنشطة التي تم تسجيلها للطفل خلال الفترة المحددة.',
                          primaryColor: primaryColor,
                          cardColor: cardColor,
                          borderColor: borderColor,
                          textColor: textColor,
                          secondaryTextColor: secondaryTextColor,
                        ),

                        const SizedBox(height: 12),

                        _detailCard(
                          icon: Icons.timer_outlined,
                          title: 'مدة النشاط',
                          description:
                          'ستظهر مدد الأنشطة المسجلة عند توفر البيانات.',
                          primaryColor: primaryColor,
                          cardColor: cardColor,
                          borderColor: borderColor,
                          textColor: textColor,
                          secondaryTextColor: secondaryTextColor,
                        ),

                        const SizedBox(height: 12),

                        _detailCard(
                          icon: Icons.calendar_today_outlined,
                          title: 'أيام النشاط',
                          description:
                          'سيتم عرض الأيام التي تحتوي على سجلات نشاط فعلية.',
                          primaryColor: primaryColor,
                          cardColor: cardColor,
                          borderColor: borderColor,
                          textColor: textColor,
                          secondaryTextColor: secondaryTextColor,
                        ),

                        const SizedBox(height: 24),

                        // Educational note
                        _card(
                          cardColor,
                          borderColor,
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.info_outline_rounded,
                                color: primaryColor,
                                size: 22,
                              ),
                              const SizedBox(width: 9),
                              Expanded(
                                child: Text(
                                  'هذا التقرير مخصص للمتابعة والتنظيم فقط، ولا يُعد تقييمًا طبيًا لمستوى نشاط الطفل.',
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

                        // Save report - pending API integration
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              _showMessage(
                                context,
                                'حفظ التقرير سيتاح بعد ربط Laravel API.',
                              );
                            },
                            icon: const Icon(Icons.save_outlined),
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

                        // PDF export - not implemented yet


                        const SizedBox(height: 20),

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
              crossAxisAlignment: CrossAxisAlignment.start,
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