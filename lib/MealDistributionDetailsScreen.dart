import 'package:flutter/material.dart';

class MealDistributionDetailsScreen extends StatefulWidget {
  final String childName;
  final DateTime startDate;
  final DateTime endDate;

  const MealDistributionDetailsScreen({
    super.key,
    required this.childName,
    required this.startDate,
    required this.endDate,
  });

  @override
  State<MealDistributionDetailsScreen> createState() =>
      _MealDistributionDetailsScreenState();
}

class _MealDistributionDetailsScreenState
    extends State<MealDistributionDetailsScreen> {
  bool breakfastExpanded = false;
  bool lunchExpanded = false;
  bool dinnerExpanded = false;

  String formatDate(DateTime date) {
    final String day = date.day.toString().padLeft(2, '0');
    final String month = date.month.toString().padLeft(2, '0');

    return '$day/$month/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color primaryColor = theme.primaryColor;
    final Color textColor = theme.colorScheme.onSurface;
    final Color secondaryTextColor = textColor.withOpacity(0.60);

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
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                                  'توزيع الوجبات',
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
                                child: Material(
                                  color: Colors.white,
                                  borderRadius:
                                  BorderRadius.circular(12),
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.pop(context);
                                    },
                                    borderRadius:
                                    BorderRadius.circular(12),
                                    child: Container(
                                      width: 44,
                                      height: 44,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                        BorderRadius.circular(12),
                                        border: Border.all(
                                          color:
                                          textColor.withOpacity(0.12),
                                        ),
                                      ),
                                      child: Icon(
                                        Icons.arrow_back_ios_new_rounded,
                                        size: 19,
                                        color: textColor,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 8),

                        Padding(
                          padding:
                          const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            'تفاصيل أوقات وجبات ${widget.childName}',
                            style: TextStyle(
                              fontSize: 14,
                              color: secondaryTextColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // =========================
                        // Period
                        // =========================
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: textColor.withOpacity(0.10),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color:
                                  primaryColor.withOpacity(0.10),
                                  borderRadius:
                                  BorderRadius.circular(14),
                                ),
                                child: Icon(
                                  Icons.date_range_rounded,
                                  color: primaryColor,
                                ),
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
                                      '${formatDate(widget.startDate)} - ${formatDate(widget.endDate)}',
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
                        // Summary
                        // =========================
                        Text(
                          'ملخص أوقات الوجبات',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),

                        const SizedBox(height: 14),

                        _mealSummaryCard(
                          context,
                          icon: Icons.free_breakfast_rounded,
                          title: 'الإفطار',
                          averageTime: '7:30 ص',
                          registeredDays: '4 أيام',
                        ),

                        const SizedBox(height: 12),

                        _mealSummaryCard(
                          context,
                          icon: Icons.lunch_dining_rounded,
                          title: 'الغداء',
                          averageTime: '1:30 م',
                          registeredDays: '5 أيام',
                        ),

                        const SizedBox(height: 12),

                        _mealSummaryCard(
                          context,
                          icon: Icons.dinner_dining_rounded,
                          title: 'العشاء',
                          averageTime: '7:00 م',
                          registeredDays: '4 أيام',
                        ),

                        const SizedBox(height: 28),

                        // =========================
                        // Daily Records
                        // =========================
                        Text(
                          'السجل اليومي',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),

                        const SizedBox(height: 14),

                        _dailyMealSection(
                          context,
                          title: 'الإفطار',
                          icon: Icons.free_breakfast_rounded,
                          isExpanded: breakfastExpanded,
                          onTap: () {
                            setState(() {
                              breakfastExpanded =
                              !breakfastExpanded;
                            });
                          },
                          records: const [
                            MealDailyRecord(
                              date: '26/08/2026',
                              time: '7:25 ص',
                              status: 'تم التسجيل',
                              statusType: MealStatus.normal,
                            ),
                            MealDailyRecord(
                              date: '25/08/2026',
                              time: '8:15 ص',
                              status: 'أبعد عن الوقت المعتاد',
                              statusType: MealStatus.late,
                            ),
                            MealDailyRecord(
                              date: '24/08/2026',
                              time: null,
                              status: 'لا توجد وجبة مسجلة',
                              statusType: MealStatus.missing,
                            ),
                            MealDailyRecord(
                              date: '23/08/2026',
                              time: '7:20 ص',
                              status: 'تم التسجيل',
                              statusType: MealStatus.normal,
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        _dailyMealSection(
                          context,
                          title: 'الغداء',
                          icon: Icons.lunch_dining_rounded,
                          isExpanded: lunchExpanded,
                          onTap: () {
                            setState(() {
                              lunchExpanded = !lunchExpanded;
                            });
                          },
                          records: const [
                            MealDailyRecord(
                              date: '26/08/2026',
                              time: '1:20 م',
                              status: 'تم التسجيل',
                              statusType: MealStatus.normal,
                            ),
                            MealDailyRecord(
                              date: '25/08/2026',
                              time: '2:10 م',
                              status: 'أبعد عن الوقت المعتاد',
                              statusType: MealStatus.late,
                            ),
                            MealDailyRecord(
                              date: '24/08/2026',
                              time: '1:35 م',
                              status: 'تم التسجيل',
                              statusType: MealStatus.normal,
                            ),
                            MealDailyRecord(
                              date: '23/08/2026',
                              time: '1:25 م',
                              status: 'تم التسجيل',
                              statusType: MealStatus.normal,
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        _dailyMealSection(
                          context,
                          title: 'العشاء',
                          icon: Icons.dinner_dining_rounded,
                          isExpanded: dinnerExpanded,
                          onTap: () {
                            setState(() {
                              dinnerExpanded = !dinnerExpanded;
                            });
                          },
                          records: const [
                            MealDailyRecord(
                              date: '26/08/2026',
                              time: '7:10 م',
                              status: 'تم التسجيل',
                              statusType: MealStatus.normal,
                            ),
                            MealDailyRecord(
                              date: '25/08/2026',
                              time: null,
                              status: 'لا توجد وجبة مسجلة',
                              statusType: MealStatus.missing,
                            ),
                            MealDailyRecord(
                              date: '24/08/2026',
                              time: '7:40 م',
                              status: 'أبعد عن الوقت المعتاد',
                              statusType: MealStatus.late,
                            ),
                            MealDailyRecord(
                              date: '23/08/2026',
                              time: '6:55 م',
                              status: 'تم التسجيل',
                              statusType: MealStatus.normal,
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // =========================
                        // Note
                        // =========================
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color:
                            primaryColor.withOpacity(0.08),
                            borderRadius:
                            BorderRadius.circular(15),
                          ),
                          child: Row(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.info_outline_rounded,
                                color: primaryColor,
                                size: 22,
                              ),

                              const SizedBox(width: 8),

                              Expanded(
                                child: Text(
                                  'الوقت المعتاد هنا يعني متوسط أوقات الوجبات المسجلة خلال الفترة، وليس وقتًا طبيًا إلزاميًا.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    height: 1.6,
                                    color: secondaryTextColor,
                                  ),
                                ),
                              ),
                            ],
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
  // Meal Summary Card
  // =========================
  Widget _mealSummaryCard(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String averageTime,
        required String registeredDays,
      }) {
    final ThemeData theme = Theme.of(context);
    final Color primaryColor = theme.primaryColor;
    final Color textColor = theme.colorScheme.onSurface;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: textColor.withOpacity(0.10),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.10),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              icon,
              color: primaryColor,
              size: 24,
            ),
          ),

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

                const SizedBox(height: 5),

                Text(
                  'متوسط الوقت: $averageTime',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: textColor.withOpacity(0.60),
                  ),
                ),
              ],
            ),
          ),

          Text(
            registeredDays,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: textColor.withOpacity(0.55),
            ),
          ),
        ],
      ),
    );
  }

  // =========================
  // Daily Meal Section
  // =========================
  Widget _dailyMealSection(
      BuildContext context, {
        required String title,
        required IconData icon,
        required bool isExpanded,
        required VoidCallback onTap,
        required List<MealDailyRecord> records,
      }) {
    final ThemeData theme = Theme.of(context);
    final Color primaryColor = theme.primaryColor;
    final Color textColor = theme.colorScheme.onSurface;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: textColor.withOpacity(0.10),
        ),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(18),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color:
                      primaryColor.withOpacity(0.10),
                      borderRadius:
                      BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon,
                      color: primaryColor,
                      size: 22,
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                  ),

                  AnimatedRotation(
                    duration:
                    const Duration(milliseconds: 250),
                    turns: isExpanded ? 0.5 : 0,
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 25,
                      color: textColor.withOpacity(0.55),
                    ),
                  ),
                ],
              ),
            ),
          ),

          AnimatedSize(
            duration:
            const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: isExpanded
                ? Padding(
              padding: const EdgeInsets.fromLTRB(
                16,
                0,
                16,
                16,
              ),
              child: Column(
                children: [
                  Divider(
                    height: 1,
                    color:
                    textColor.withOpacity(0.08),
                  ),

                  const SizedBox(height: 14),

                  ...records.asMap().entries.map(
                        (entry) {
                      final int index = entry.key;
                      final MealDailyRecord record =
                          entry.value;

                      return Column(
                        children: [
                          _dailyRecordRow(
                            context,
                            record,
                          ),

                          if (index !=
                              records.length - 1)
                            Padding(
                              padding:
                              const EdgeInsets.symmetric(
                                vertical: 10,
                              ),
                              child: Divider(
                                height: 1,
                                color: textColor
                                    .withOpacity(0.08),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            )
                : const SizedBox(
              width: double.infinity,
              height: 0,
            ),
          ),
        ],
      ),
    );
  }

  // =========================
  // Daily Record Row
  // =========================
  Widget _dailyRecordRow(
      BuildContext context,
      MealDailyRecord record,
      ) {
    final ThemeData theme = Theme.of(context);
    final Color textColor = theme.colorScheme.onSurface;

    final IconData statusIcon;
    final Color statusColor;

    switch (record.statusType) {
      case MealStatus.normal:
        statusIcon =
            Icons.check_circle_outline_rounded;
        statusColor = const Color(0xff469E55);
        break;

      case MealStatus.late:
        statusIcon = Icons.schedule_rounded;
        statusColor = const Color(0xffC87817);
        break;

      case MealStatus.missing:
        statusIcon =
            Icons.remove_circle_outline_rounded;
        statusColor = const Color(0xffC85C55);
        break;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 3,
          child: Text(
            record.date,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
          ),
        ),

        Expanded(
          flex: 2,
          child: Text(
            record.time ?? '—',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.5,
              color: textColor.withOpacity(0.65),
            ),
          ),
        ),

        Expanded(
          flex: 4,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Icon(
                statusIcon,
                size: 17,
                color: statusColor,
              ),

              const SizedBox(width: 5),

              Flexible(
                child: Text(
                  record.status,
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// =========================
// Meal Status
// =========================
enum MealStatus {
  normal,
  late,
  missing,
}

// =========================
// Daily Record Model
// =========================
class MealDailyRecord {
  final String date;
  final String? time;
  final String status;
  final MealStatus statusType;

  const MealDailyRecord({
    required this.date,
    required this.time,
    required this.status,
    required this.statusType,
  });
}