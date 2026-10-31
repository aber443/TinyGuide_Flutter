import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/services.dart' show rootBundle;

class MealsAnalysisScreen extends StatelessWidget {
  final String childName;
  final DateTime startDate;
  final DateTime endDate;

  // تحديد هل التقرير مفتوح من التقارير المحفوظة
  final bool isSavedReport;

  const MealsAnalysisScreen({
    super.key,
    required this.childName,
    required this.startDate,
    required this.endDate,
    this.isSavedReport = false,
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
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // =========================
  // Generate and Export PDF
  // =========================

  Future<void> _exportPdf(BuildContext context) async {
    try {
      _showMessage(context, 'جارٍ تجهيز ملف PDF...');

      // Arabic fonts
      final fontData = await rootBundle.load(
        'assets/fonts/arial.ttf',
      );

      final pw.Font arabicFont = pw.Font.ttf(fontData);
      final pw.Font arabicBoldFont = pw.Font.ttf(fontData);

      final pw.Document pdf = pw.Document(
        theme: pw.ThemeData.withFont(
          base: arabicFont,
          bold: arabicBoldFont,
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
                  'تقرير تحليل الوجبات',
                  style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),

              pw.SizedBox(height: 25),

              _pdfSection(
                title: 'بيانات التقرير',
                children: [
                  _pdfText('اسم الطفل: $childName'),
                  _pdfText(
                    'تاريخ البداية: ${formatDate(startDate)}',
                  ),
                  _pdfText(
                    'تاريخ النهاية: ${formatDate(endDate)}',
                  ),
                  _pdfText(
                    'تاريخ إنشاء التقرير: '
                        '${formatDate(DateTime.now())}',
                  ),
                ],
              ),

              pw.SizedBox(height: 18),

              _pdfSection(
                title: 'ملخص الوجبات',
                children: [
                  _pdfText(
                    'لا توجد بيانات وجبات متاحة للعرض حاليًا.',
                  ),
                  pw.SizedBox(height: 8),
                  _pdfText(
                    'ستظهر إحصائيات الوجبات وتفاصيلها '
                        'بعد ربط التطبيق بمصدر البيانات '
                        'وتوفر الوجبات المسجلة للطفل خلال '
                        'الفترة المحددة.',
                  ),
                ],
              ),

              pw.SizedBox(height: 18),

              _pdfSection(
                title: 'ملاحظات التحليل',
                children: [
                  _pdfText(
                    'لا يمكن إصدار ملاحظات تحليلية '
                        'قبل توفر بيانات الوجبات الفعلية '
                        'خلال الفترة المحددة.',
                  ),
                ],
              ),

              pw.SizedBox(height: 18),

              _pdfSection(
                title: 'تنبيه صحي',
                children: [
                  _pdfText(
                    'هذا التقرير مخصص للمتابعة والتنظيم، '
                        'ولا يقدم تشخيصًا طبيًا أو تعديلات '
                        'على العلاج.',
                  ),
                  pw.SizedBox(height: 6),
                  _pdfText(
                    'لا تستخدمي هذا التقرير لتغيير '
                        'أي دواء أو جرعة أو خطة علاج دون '
                        'استشارة الطبيب المختص.',
                  ),
                ],
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
                    color: PdfColor(0.47, 0.57, 0.60),
                  ),
                ),
              ),
            ];
          },
        ),
      );

      await Printing.layoutPdf(
        name: 'TinyGuide_Meals_Report.pdf',
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

      debugPrint('PDF export error: $error');
    }
  }

  // =========================
  // PDF Section
  // =========================

  pw.Widget _pdfSection({
    required String title,
    required List<pw.Widget> children,
  }) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(
          color: const PdfColor(0.82, 0.88, 0.88),
        ),
        borderRadius: pw.BorderRadius.circular(10),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(
              fontSize: 15,
              fontWeight: pw.FontWeight.bold,
              color: const PdfColor(0.20, 0.66, 0.64),
            ),
          ),

          pw.SizedBox(height: 10),

          ...children,
        ],
      ),
    );
  }

  // =========================
  // PDF Text
  // =========================

  pw.Widget _pdfText(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 7),
      child: pw.Text(
        text,
        style: const pw.TextStyle(
          fontSize: 11,
          lineSpacing: 4,
        ),
      ),
    );
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
              final double width = constraints.maxWidth;

              final bool isVerySmall = width < 390;
              final bool isTablet = width >= 600;

              final double horizontalPadding = isVerySmall
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
                    constraints: const BoxConstraints(
                      maxWidth: 760,
                    ),
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
                                  'تحليل الوجبات',
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
                                  onPressed: () =>
                                      Navigator.pop(context),
                                  padding: EdgeInsets.zero,
                                  constraints:
                                  const BoxConstraints(
                                    minWidth: 44,
                                    minHeight: 44,
                                  ),
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

                        const SizedBox(height: 8),

                        Text(
                          'تقرير وجبات $childName',
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

                        _buildCard(
                          cardColor: cardColor,
                          borderColor: borderColor,
                          child: Row(
                            children: [
                              _buildIcon(
                                icon: Icons.date_range_rounded,
                                primaryColor: primaryColor,
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
                                      '${formatDate(startDate)} - '
                                          '${formatDate(endDate)}',
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
                        // Meals Summary
                        // =========================

                        Text(
                          'ملخص الوجبات',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),

                        const SizedBox(height: 14),

                        // Empty state until API integration
                        _buildCard(
                          cardColor: cardColor,
                          borderColor: borderColor,
                          child: SizedBox(
                            width: double.infinity,
                            child: Column(
                              children: [
                                Icon(
                                  Icons.restaurant_outlined,
                                  size: 54,
                                  color: primaryColor,
                                ),

                                const SizedBox(height: 12),

                                Text(
                                  'لا توجد بيانات وجبات للعرض',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: textColor,
                                  ),
                                ),

                                const SizedBox(height: 8),

                                Text(
                                  'ستظهر إحصائيات الوجبات وتفاصيلها '
                                      'بعد جلب البيانات المسجلة للطفل '
                                      'خلال الفترة المحددة.',
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
                        // Analysis Notes
                        // =========================

                        Text(
                          'ملاحظات التحليل',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),

                        const SizedBox(height: 14),

                        _buildInformationCard(
                          icon: Icons.info_outline_rounded,
                          title: 'البيانات غير متاحة حاليًا',
                          description:
                          'لا يمكن إصدار ملاحظات تحليلية قبل '
                              'توفر بيانات الوجبات المسجلة خلال '
                              'الفترة المحددة.',
                          primaryColor: primaryColor,
                          cardColor: cardColor,
                          borderColor: borderColor,
                          textColor: textColor,
                          secondaryTextColor: secondaryTextColor,
                        ),

                        const SizedBox(height: 12),

                        _buildInformationCard(
                          icon: Icons.health_and_safety_outlined,
                          title: 'تنبيه صحي',
                          description:
                          'هذا التقرير مخصص للمتابعة والتنظيم، '
                              'ولا يقدم تشخيصًا طبيًا أو تعديلات '
                              'على العلاج.',
                          primaryColor: primaryColor,
                          cardColor: cardColor,
                          borderColor: borderColor,
                          textColor: textColor,
                          secondaryTextColor: secondaryTextColor,
                        ),

                        const SizedBox(height: 24),

                        // =========================
                        // Report Actions
                        // =========================
                        // عند فتح تقرير محفوظ تختفي الأزرار

                        if (!isSavedReport) ...[
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
                                  'حفظ التقرير غير متاح حاليًا. '
                                      'سيتفعّل بعد ربط Laravel API.',
                                );
                              },
                              icon: const Icon(
                                Icons.save_outlined,
                              ),
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

                          // =========================
                          // Download PDF
                          // =========================


                        ],

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

  Widget _buildCard({
    required Color cardColor,
    required Color borderColor,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: child,
    );
  }

  // =========================
  // Icon
  // =========================

  Widget _buildIcon({
    required IconData icon,
    required Color primaryColor,
  }) {
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
  // Information Card
  // =========================

  Widget _buildInformationCard({
    required IconData icon,
    required String title,
    required String description,
    required Color primaryColor,
    required Color cardColor,
    required Color borderColor,
    required Color textColor,
    required Color secondaryTextColor,
  }) {
    return _buildCard(
      cardColor: cardColor,
      borderColor: borderColor,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildIcon(
            icon: icon,
            primaryColor: primaryColor,
          ),

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