import 'package:flutter/material.dart';
import 'AdviceDetailsScreen.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/services.dart' show rootBundle;

class HealthAdviceReportScreen extends StatelessWidget {
  final String childName;
  final DateTime startDate;
  final DateTime endDate;

  // تبقى false حتى تصل النصائح الحقيقية من Laravel.
  // لا نعرض نصائح تجريبية على أنها نتائج فعلية.
  static const bool showDemoData = false;

  const HealthAdviceReportScreen({
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
          build: (pw.Context context) {
            return pw.Directionality(
              textDirection: pw.TextDirection.rtl,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Center(
                    child: pw.Text(
                      'تقرير النصائح الصحية',
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
                    'لا توجد نصائح صحية متاحة حاليًا.',
                    style: pw.TextStyle(
                      font: arabicFont,
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 10),
                  pw.Text(
                    'ستظهر النصائح بعد ربط النظام بـ Laravel وتوفر البيانات اللازمة للطفل خلال الفترة المحددة.',
                  ),
                  pw.SizedBox(height: 24),
                  pw.Text(
                    'تنبيه: المعلومات الصحية إرشادية ولا تغني عن استشارة الطبيب أو المختص. لا تستخدميها لتغيير دواء أو جرعة أو خطة علاج.',
                  ),
                ],
              ),
            );
          },
        ),
      );

      await Printing.layoutPdf(
        name: 'TinyGuide_Health_Advice_Report.pdf',
        format: PdfPageFormat.a4,
        onLayout: (format) async => pdf.save(),
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'تعذر إنشاء ملف PDF. تأكدي من وجود الخط وإعداداته.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;

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
                                  'النصائح الصحية',
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
                                    size: 22,
                                    color: textColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 8),

                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                          ),
                          child: Text(
                            'متابعة النصائح الصحية الخاصة بـ $childName',
                            style: TextStyle(
                              fontSize: 14,
                              color: secondaryTextColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Report period only
                        _buildCard(
                          cardColor: cardColor,
                          borderColor: borderColor,
                          child: Row(
                            children: [
                              _buildIcon(
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

                        Text(
                          'نصائح المتابعة',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),

                        const SizedBox(height: 14),

                        if (showDemoData)
                          _buildEmptyState(
                            primaryColor: primaryColor,
                            cardColor: cardColor,
                            borderColor: borderColor,
                            textColor: textColor,
                            secondaryTextColor: secondaryTextColor,
                            icon: Icons.science_outlined,
                            title: 'وضع عرض تجريبي',
                            description:
                            'المحتوى المعروض تجريبي، وليس نصائح مستنتجة من بيانات الطفل.',
                          )
                        else
                          _buildEmptyState(
                            primaryColor: primaryColor,
                            cardColor: cardColor,
                            borderColor: borderColor,
                            textColor: textColor,
                            secondaryTextColor: secondaryTextColor,
                            icon: Icons.lightbulb_outline_rounded,
                            title: 'لا توجد نصائح متاحة حاليًا',
                            description:
                            'ستظهر النصائح هنا بعد ربط الشاشة بـ Laravel وتوفر البيانات اللازمة للطفل خلال الفترة المحددة. لا يمكن إنشاء نصائح مخصصة قبل توفر البيانات.',
                          ),

                        const SizedBox(height: 24),

                        // Future API integration information
                        _buildInformationCard(
                          primaryColor: primaryColor,
                          cardColor: cardColor,
                          borderColor: borderColor,
                          textColor: textColor,
                          secondaryTextColor: secondaryTextColor,
                          icon: Icons.sync_outlined,
                          title: 'مصدر النصائح',
                          description:
                          'هذه الواجهة مجهزة لاستقبال النصائح المرتبطة بالطفل المحدد من Laravel. لم يتم تنفيذ الاتصال بالخادم في هذه المرحلة.',
                        ),

                        const SizedBox(height: 16),

                        // Medical safety warning
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(
                              isDark ? 0.12 : 0.08,
                            ),
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: primaryColor.withOpacity(0.15),
                            ),
                          ),
                          child: Row(
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
                                  'النصائح الصحية إرشادية ولا تغني عن استشارة الطبيب أو المختص. لا تستخدميها لتغيير دواء أو جرعة أو خطة علاج.',
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

                        const SizedBox(height: 20),



                        const SizedBox(height: 12),

                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'حفظ التقرير سيتاح بعد ربط Laravel API.',
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.save_outlined),
                            label: const Text('حفظ التقرير'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                        ),
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
        border: Border.all(color: borderColor),
      ),
      child: child,
    );
  }

  Widget _buildIcon(IconData icon, Color primaryColor) {
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

  Widget _buildEmptyState({
    required Color primaryColor,
    required Color cardColor,
    required Color borderColor,
    required Color textColor,
    required Color secondaryTextColor,
    required IconData icon,
    required String title,
    required String description,
  }) {
    return _buildCard(
      cardColor: cardColor,
      borderColor: borderColor,
      child: SizedBox(
        width: double.infinity,
        child: Column(
          children: [
            Icon(
              icon,
              size: 52,
              color: primaryColor,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
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
    );
  }

  Widget _buildInformationCard({
    required Color primaryColor,
    required Color cardColor,
    required Color borderColor,
    required Color textColor,
    required Color secondaryTextColor,
    required IconData icon,
    required String title,
    required String description,
  }) {
    return _buildCard(
      cardColor: cardColor,
      borderColor: borderColor,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildIcon(icon, primaryColor),
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