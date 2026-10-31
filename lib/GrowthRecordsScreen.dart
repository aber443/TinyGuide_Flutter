import 'package:flutter/material.dart';

class GrowthRecordsScreen extends StatefulWidget {
  const GrowthRecordsScreen({super.key});

  @override
  State<GrowthRecordsScreen> createState() =>
      _GrowthRecordsScreenState();
}

class _GrowthRecordsScreenState
    extends State<GrowthRecordsScreen> {
  bool filterExpanded = false;

  DateTime? startDate;
  DateTime? endDate;

  final List<GrowthRecord> allRecords = [
    GrowthRecord(
      height: '122 سم',
      weight: '24 كجم',
      date: DateTime(2026, 9, 1),
      time: '09:00 ص',
    ),
    GrowthRecord(
      height: '121 سم',
      weight: '23.6 كجم',
      date: DateTime(2026, 8, 15),
      time: '10:20 ص',
    ),
    GrowthRecord(
      height: '120 سم',
      weight: '23 كجم',
      date: DateTime(2026, 8, 1),
      time: '08:45 ص',
    ),
  ];

  List<GrowthRecord> filteredRecords = [];

  @override
  void initState() {
    super.initState();
    filteredRecords = List.from(allRecords);
  }

  String formatDate(DateTime date) {
    final String day =
    date.day.toString().padLeft(2, '0');
    final String month =
    date.month.toString().padLeft(2, '0');

    return '$day/$month/${date.year}';
  }

  Future<void> pickStartDate() async {
    final DateTime? pickedDate =
    await showDatePicker(
      context: context,
      initialDate: startDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        startDate = pickedDate;

        if (endDate != null &&
            endDate!.isBefore(startDate!)) {
          endDate = null;
        }
      });
    }
  }

  Future<void> pickEndDate() async {
    if (startDate == null) {
      ScaffoldMessenger.of(context)
          .hideCurrentSnackBar();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'اختاري تاريخ البداية أولًا',
            textAlign: TextAlign.center,
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );

      return;
    }

    final DateTime? pickedDate =
    await showDatePicker(
      context: context,
      initialDate: endDate ?? startDate!,
      firstDate: startDate!,
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        endDate = pickedDate;
      });
    }
  }

  void applyFilter() {
    if (startDate == null || endDate == null) {
      ScaffoldMessenger.of(context)
          .hideCurrentSnackBar();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'اختاري تاريخ البداية والنهاية',
            textAlign: TextAlign.center,
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );

      return;
    }

    final DateTime normalizedStart = DateTime(
      startDate!.year,
      startDate!.month,
      startDate!.day,
    );

    final DateTime normalizedEnd = DateTime(
      endDate!.year,
      endDate!.month,
      endDate!.day,
      23,
      59,
      59,
    );

    setState(() {
      filteredRecords =
          allRecords.where((record) {
            return !record.date
                .isBefore(normalizedStart) &&
                !record.date.isAfter(normalizedEnd);
          }).toList();
    });
  }

  void resetFilter() {
    setState(() {
      startDate = null;
      endDate = null;
      filteredRecords = List.from(allRecords);
    });
  }

  Future<void> confirmDelete(
      GrowthRecord record,
      ) async {
    final bool? shouldDelete =
    await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final ThemeData theme =
        Theme.of(dialogContext);

        final bool isDark =
            theme.brightness == Brightness.dark;

        final Color textColor = isDark
            ? Colors.white
            : const Color(0xff2C4A5A);

        final Color cardColor = isDark
            ? const Color(0xff1D292D)
            : Colors.white;

        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            backgroundColor: cardColor,
            shape: RoundedRectangleBorder(
              borderRadius:
              BorderRadius.circular(20),
            ),
            title: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color:
                    Colors.red.withOpacity(0.08),
                    borderRadius:
                    BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.delete_outline_rounded,
                    color: Colors.red,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'حذف السجل',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight:
                      FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                ),
              ],
            ),
            content: Text(
              'هل أنت متأكد من حذف سجل النمو هذا؟',
              style: TextStyle(
                fontSize: 14,
                height: 1.6,
                color:
                textColor.withOpacity(0.70),
              ),
            ),
            actionsPadding:
            const EdgeInsets.fromLTRB(
              16,
              0,
              16,
              16,
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(
                    dialogContext,
                    false,
                  );
                },
                child: Text(
                  'إلغاء',
                  style: TextStyle(
                    color:
                    textColor.withOpacity(0.65),
                    fontWeight:
                    FontWeight.w600,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(
                    dialogContext,
                    true,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'نعم، حذف',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );

    if (shouldDelete == true) {
      deleteRecord(record);
    }
  }

  void deleteRecord(GrowthRecord record) {
    setState(() {
      allRecords.remove(record);
      filteredRecords.remove(record);
    });

    ScaffoldMessenger.of(context)
        .hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'تم حذف السجل بنجاح',
          textAlign: TextAlign.center,
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor:
        Theme.of(context).primaryColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme =
    Theme.of(context);

    final bool isDark =
        theme.brightness == Brightness.dark;

    final Color primaryColor =
        theme.primaryColor;

    final Color textColor = isDark
        ? Colors.white
        : const Color(0xff2C4A5A);

    final Color secondaryTextColor = isDark
        ? Colors.white.withOpacity(0.60)
        : const Color(0xff78909A);

    return Scaffold(
      body: SafeArea(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final double width =
                  constraints.maxWidth;

              final bool isVerySmall =
                  width < 390;

              final bool isTablet =
                  width >= 600;

              final double horizontalPadding =
              isVerySmall
                  ? 14
                  : isTablet
                  ? 36
                  : 20;

              return SingleChildScrollView(
                physics:
                const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(
                  horizontal:
                  horizontalPadding,
                  vertical: 18,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints:
                    const BoxConstraints(
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
                            alignment:
                            Alignment.center,
                            children: [
                              Center(
                                child: Text(
                                  'سجلات النمو',
                                  textAlign:
                                  TextAlign.center,
                                  style: TextStyle(
                                    fontSize:
                                    isTablet
                                        ? 31
                                        : 27,
                                    fontWeight:
                                    FontWeight
                                        .bold,
                                    color:
                                    textColor,
                                  ),
                                ),
                              ),

                              // السهم بدون خلفية أو بوردر
                              Align(
                                alignment:
                                AlignmentDirectional
                                    .centerStart,
                                child: IconButton(
                                  onPressed: () {
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
                                  splashRadius: 22,
                                  icon: Icon(
                                    Icons
                                        .arrow_back_ios_new_rounded,
                                    size: 22,
                                    color:
                                    textColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 12),

                        Padding(
                          padding:
                          const EdgeInsets
                              .symmetric(
                            horizontal: 6,
                          ),
                          child: Text(
                            'عرض قياسات النمو التي تم تسجيلها سابقًا',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight:
                              FontWeight.w500,
                              color:
                              secondaryTextColor,
                            ),
                          ),
                        ),

                        const SizedBox(height: 22),

                        _filterSection(
                          context,
                          primaryColor:
                          primaryColor,
                          textColor: textColor,
                        ),

                        const SizedBox(height: 22),

                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'السجلات',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight:
                                  FontWeight
                                      .bold,
                                  color:
                                  textColor,
                                ),
                              ),
                            ),
                            Text(
                              '${filteredRecords.length} سجل',
                              style: TextStyle(
                                fontSize: 12.5,
                                color:
                                secondaryTextColor,
                                fontWeight:
                                FontWeight
                                    .w500,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        if (filteredRecords.isEmpty)
                          _emptyState(context)
                        else
                          ...filteredRecords
                              .asMap()
                              .entries
                              .map(
                                (entry) {
                              final int index =
                                  entry.key;

                              final GrowthRecord
                              record =
                                  entry.value;

                              return Column(
                                children: [
                                  _growthRecordCard(
                                    context,
                                    record: record,
                                  ),
                                  if (index !=
                                      filteredRecords
                                          .length -
                                          1)
                                    const SizedBox(
                                      height: 12,
                                    ),
                                ],
                              );
                            },
                          ),

                        const SizedBox(height: 24),
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
  // Filter Section
  // =========================
  Widget _filterSection(
      BuildContext context, {
        required Color primaryColor,
        required Color textColor,
      }) {
    final ThemeData theme =
    Theme.of(context);

    final bool isDark =
        theme.brightness == Brightness.dark;

    final Color cardColor = isDark
        ? const Color(0xff1D292D)
        : Colors.white;

    final Color borderColor = isDark
        ? Colors.white.withOpacity(0.12)
        : const Color(0xffE2EEEE);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius:
        BorderRadius.circular(18),
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                filterExpanded =
                !filterExpanded;
              });
            },
            borderRadius:
            BorderRadius.circular(18),
            child: Padding(
              padding:
              const EdgeInsets.all(15),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color:
                      primaryColor.withOpacity(
                        isDark ? 0.14 : 0.10,
                      ),
                      borderRadius:
                      BorderRadius.circular(
                        13,
                      ),
                    ),
                    child: Icon(
                      Icons.filter_alt_outlined,
                      color: primaryColor,
                      size: 23,
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Text(
                      'فلترة قياسات النمو حسب التاريخ',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight:
                        FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                  ),

                  AnimatedRotation(
                    duration:
                    const Duration(
                      milliseconds: 250,
                    ),
                    turns:
                    filterExpanded ? 0.5 : 0,
                    child: Icon(
                      Icons
                          .keyboard_arrow_down_rounded,
                      color: textColor
                          .withOpacity(0.45),
                    ),
                  ),
                ],
              ),
            ),
          ),

          AnimatedSize(
            duration:
            const Duration(
              milliseconds: 250,
            ),
            alignment:
            Alignment.topCenter,
            child: filterExpanded
                ? Padding(
              padding:
              const EdgeInsets
                  .fromLTRB(
                15,
                0,
                15,
                15,
              ),
              child: Column(
                children: [
                  Divider(
                    color: textColor
                        .withOpacity(
                      0.08,
                    ),
                  ),

                  const SizedBox(
                    height: 12,
                  ),

                  Row(
                    children: [
                      Expanded(
                        child:
                        _dateField(
                          context,
                          label:
                          'من تاريخ',
                          value: startDate ==
                              null
                              ? 'اختاري التاريخ'
                              : formatDate(
                            startDate!,
                          ),
                          onTap:
                          pickStartDate,
                        ),
                      ),

                      const SizedBox(
                        width: 10,
                      ),

                      Expanded(
                        child:
                        _dateField(
                          context,
                          label:
                          'إلى تاريخ',
                          value: endDate ==
                              null
                              ? 'اختاري التاريخ'
                              : formatDate(
                            endDate!,
                          ),
                          onTap:
                          pickEndDate,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 15,
                  ),

                  SizedBox(
                    width:
                    double.infinity,
                    height: 48,
                    child:
                    ElevatedButton
                        .icon(
                      onPressed:
                      applyFilter,
                      icon: const Icon(
                        Icons
                            .filter_alt_rounded,
                      ),
                      label:
                      const Text(
                        'تطبيق الفلترة',
                        style:
                        TextStyle(
                          fontWeight:
                          FontWeight
                              .bold,
                        ),
                      ),
                      style:
                      ElevatedButton
                          .styleFrom(
                        backgroundColor:
                        primaryColor,
                        foregroundColor:
                        Colors.white,
                        elevation: 0,
                        shape:
                        RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius
                              .circular(
                            14,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 8,
                  ),

                  TextButton(
                    onPressed:
                    resetFilter,
                    child: Text(
                      'إعادة تعيين',
                      style:
                      TextStyle(
                        color:
                        primaryColor,
                        fontWeight:
                        FontWeight
                            .w600,
                      ),
                    ),
                  ),
                ],
              ),
            )
                : const SizedBox(
              height: 0,
            ),
          ),
        ],
      ),
    );
  }

  // =========================
  // Date Field
  // =========================
  Widget _dateField(
      BuildContext context, {
        required String label,
        required String value,
        required VoidCallback onTap,
      }) {
    final ThemeData theme =
    Theme.of(context);

    final bool isDark =
        theme.brightness == Brightness.dark;

    final Color primaryColor =
        theme.primaryColor;

    final Color textColor = isDark
        ? Colors.white
        : const Color(0xff2C4A5A);

    final Color fieldColor = isDark
        ? const Color(0xff243236)
        : primaryColor.withOpacity(0.04);

    final Color borderColor = isDark
        ? Colors.white.withOpacity(0.12)
        : const Color(0xffE2EEEE);

    return InkWell(
      onTap: onTap,
      borderRadius:
      BorderRadius.circular(14),
      child: Container(
        padding:
        const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: fieldColor,
          borderRadius:
          BorderRadius.circular(14),
          border: Border.all(
            color: borderColor,
          ),
        ),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11.5,
                color:
                textColor.withOpacity(0.55),
              ),
            ),

            const SizedBox(height: 7),

            Row(
              children: [
                Icon(
                  Icons
                      .calendar_today_outlined,
                  size: 18,
                  color: primaryColor,
                ),

                const SizedBox(width: 6),

                Expanded(
                  child: Text(
                    value,
                    maxLines: 1,
                    overflow:
                    TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight:
                      FontWeight.w500,
                      color: textColor,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // =========================
  // Growth Record Card
  // =========================
  Widget _growthRecordCard(
      BuildContext context, {
        required GrowthRecord record,
      }) {
    final ThemeData theme =
    Theme.of(context);

    final bool isDark =
        theme.brightness == Brightness.dark;

    final Color primaryColor =
        theme.primaryColor;

    final Color textColor = isDark
        ? Colors.white
        : const Color(0xff2C4A5A);

    final Color cardColor = isDark
        ? const Color(0xff1D292D)
        : Colors.white;

    final Color borderColor = isDark
        ? Colors.white.withOpacity(0.12)
        : const Color(0xffE2EEEE);

    return Container(
      width: double.infinity,
      padding:
      const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius:
        BorderRadius.circular(18),
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xff4F829E)
                  .withOpacity(0.18)
                  : const Color(0xffEAF4FA),
              borderRadius:
              BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.height_rounded,
              color: Color(0xff4F829E),
              size: 27,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 14,
                  runSpacing: 7,
                  children: [
                    Row(
                      mainAxisSize:
                      MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.height_rounded,
                          size: 16,
                          color:
                          primaryColor,
                        ),
                        const SizedBox(
                          width: 4,
                        ),
                        Text(
                          record.height,
                          style:
                          TextStyle(
                            fontSize: 15,
                            fontWeight:
                            FontWeight
                                .bold,
                            color: textColor,
                          ),
                        ),
                      ],
                    ),

                    Row(
                      mainAxisSize:
                      MainAxisSize.min,
                      children: [
                        Icon(
                          Icons
                              .monitor_weight_outlined,
                          size: 16,
                          color:
                          primaryColor,
                        ),
                        const SizedBox(
                          width: 4,
                        ),
                        Text(
                          record.weight,
                          style:
                          TextStyle(
                            fontSize: 15,
                            fontWeight:
                            FontWeight
                                .bold,
                            color: textColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                Wrap(
                  spacing: 12,
                  runSpacing: 5,
                  children: [
                    Row(
                      mainAxisSize:
                      MainAxisSize.min,
                      children: [
                        Icon(
                          Icons
                              .calendar_today_outlined,
                          size: 14,
                          color:
                          primaryColor,
                        ),

                        const SizedBox(
                          width: 4,
                        ),

                        Text(
                          formatDate(
                            record.date,
                          ),
                          style:
                          TextStyle(
                            fontSize: 11.5,
                            color: textColor
                                .withOpacity(
                              0.55,
                            ),
                          ),
                        ),
                      ],
                    ),

                    Row(
                      mainAxisSize:
                      MainAxisSize.min,
                      children: [
                        Icon(
                          Icons
                              .access_time_rounded,
                          size: 14,
                          color:
                          primaryColor,
                        ),

                        const SizedBox(
                          width: 4,
                        ),

                        Text(
                          record.time,
                          style:
                          TextStyle(
                            fontSize: 11.5,
                            color: textColor
                                .withOpacity(
                              0.55,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          Material(
            color: Colors.red.withOpacity(
              isDark ? 0.12 : 0.08,
            ),
            borderRadius:
            BorderRadius.circular(12),
            child: InkWell(
              onTap: () =>
                  confirmDelete(record),
              borderRadius:
              BorderRadius.circular(12),
              child: const SizedBox(
                width: 42,
                height: 42,
                child: Icon(
                  Icons
                      .delete_outline_rounded,
                  color: Colors.red,
                  size: 22,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =========================
  // Empty State
  // =========================
  Widget _emptyState(
      BuildContext context,
      ) {
    final ThemeData theme =
    Theme.of(context);

    final bool isDark =
        theme.brightness == Brightness.dark;

    final Color primaryColor =
        theme.primaryColor;

    final Color textColor = isDark
        ? Colors.white
        : const Color(0xff2C4A5A);

    final Color cardColor = isDark
        ? const Color(0xff1D292D)
        : Colors.white;

    final Color borderColor = isDark
        ? Colors.white.withOpacity(0.12)
        : const Color(0xffE2EEEE);

    return Container(
      width: double.infinity,
      padding:
      const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 32,
      ),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius:
        BorderRadius.circular(18),
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.height_rounded,
            size: 38,
            color: primaryColor,
          ),

          const SizedBox(height: 12),

          Text(
            startDate != null &&
                endDate != null
                ? 'لا توجد قياسات نمو ضمن الفترة المحددة'
                : 'لا توجد قياسات نمو',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight:
              FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}

class GrowthRecord {
  final String height;
  final String weight;
  final DateTime date;
  final String time;

  GrowthRecord({
    required this.height,
    required this.weight,
    required this.date,
    required this.time,
  });
}