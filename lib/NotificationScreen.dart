import 'package:flutter/material.dart';

enum NotificationType { appointment, medication, general }

class AppNotification {
  final int id;
  final NotificationType type;
  final String title;
  final String message;
  final DateTime createdAt;
  bool isRead;

  AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.createdAt,
    required this.isRead,
  });
}

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  bool showUnreadOnly = false;

  // بيانات مؤقتة لتجربة التصميم.
  // عند ربط Laravel سيتم جلب الإشعارات من الـ API.
  final List<AppNotification> notifications = [
    AppNotification(
      id: 1,
      type: NotificationType.appointment,
      title: 'تذكير بموعد طبي',
      message: 'لديك موعد مراجعة السكري غدًا الساعة 10:30 ص.',
      createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
      isRead: false,
    ),
    AppNotification(
      id: 2,
      type: NotificationType.medication,
      title: 'تذكير بالدواء',
      message: 'حان وقت الدواء المسجل للطفل.',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      isRead: false,
    ),
    AppNotification(
      id: 3,
      type: NotificationType.appointment,
      title: 'موعد طبي قادم',
      message: 'موعد غدد الأطفال بعد 3 أيام.',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      isRead: true,
    ),
  ];

  int get unreadCount {
    return notifications.where((notification) => !notification.isRead).length;
  }

  List<AppNotification> get visibleNotifications {
    if (!showUnreadOnly) {
      return notifications;
    }

    return notifications
        .where((notification) => !notification.isRead)
        .toList();
  }

  void markAsRead(AppNotification notification) {
    if (notification.isRead) {
      return;
    }

    setState(() {
      notification.isRead = true;
    });

    /*
      مستقبلًا:
      PATCH /api/notifications/{notificationId}/read
    */
  }

  void markAllAsRead() {
    if (unreadCount == 0) {
      return;
    }

    setState(() {
      for (final notification in notifications) {
        notification.isRead = true;
      }
    });

    /*
      مستقبلًا:
      PATCH /api/notifications/read-all
    */

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'تم تحديد جميع الإشعارات كمقروءة',
          textAlign: TextAlign.center,
        ),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void deleteNotification(AppNotification notification) {
    final int originalIndex = notifications.indexOf(notification);

    if (originalIndex == -1) {
      return;
    }

    setState(() {
      notifications.remove(notification);
    });

    /*
      مستقبلًا:
      DELETE /api/notifications/{notificationId}
    */

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'تم حذف الإشعار',
          textAlign: TextAlign.center,
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'تراجع',
          onPressed: () {
            setState(() {
              final int safeIndex = originalIndex > notifications.length
                  ? notifications.length
                  : originalIndex;

              notifications.insert(safeIndex, notification);
            });
          },
        ),
      ),
    );
  }

  IconData notificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.appointment:
        return Icons.event_available_outlined;

      case NotificationType.medication:
        return Icons.medication_outlined;

      case NotificationType.general:
        return Icons.notifications_none_rounded;
    }
  }

  Color notificationIconColor(NotificationType type) {
    switch (type) {
      case NotificationType.appointment:
        return const Color(0xff4B9EB8);

      case NotificationType.medication:
        return const Color(0xffC87817);

      case NotificationType.general:
        return const Color(0xff64C7C4);
    }
  }

  Color notificationIconBackground(NotificationType type) {
    switch (type) {
      case NotificationType.appointment:
        return const Color(0xffEAF5F8);

      case NotificationType.medication:
        return const Color(0xffFFF4E0);

      case NotificationType.general:
        return const Color(0xffE8F7F6);
    }
  }

  String formatNotificationTime(DateTime date) {
    final DateTime now = DateTime.now();

    final DateTime today = DateTime(
      now.year,
      now.month,
      now.day,
    );

    final DateTime notificationDay = DateTime(
      date.year,
      date.month,
      date.day,
    );

    final int difference = today.difference(notificationDay).inDays;

    final int hour = date.hour > 12
        ? date.hour - 12
        : date.hour == 0
        ? 12
        : date.hour;

    final String minute = date.minute.toString().padLeft(2, '0');

    final String period = date.hour < 12 ? 'ص' : 'م';

    final String time = '$hour:$minute $period';

    if (difference == 0) {
      return 'اليوم • $time';
    }

    if (difference == 1) {
      return 'أمس • $time';
    }

    final String day = date.day.toString().padLeft(2, '0');

    final String month = date.month.toString().padLeft(2, '0');

    return '$day/$month/${date.year} • $time';
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).primaryColor;

    const Color darkColor = Color(0xff2C4A5A);
    const Color borderColor = Color(0xffD7E7E7);
    const Color hintColor = Color(0xff8A989D);

    final List<AppNotification> displayedNotifications =
        visibleNotifications;

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
                    constraints: const BoxConstraints(maxWidth: 720),
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
                                'الإشعارات',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: isVerySmall ? 19 : 22,
                                  fontWeight: FontWeight.bold,
                                  color: darkColor,
                                ),
                              ),

                              // زر الرجوع
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
                                        borderRadius:
                                        BorderRadius.circular(12),
                                        border: Border.all(
                                          color: borderColor,
                                          width: 1.2,
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons
                                            .arrow_back_ios_new_rounded,
                                        color: darkColor,
                                        size: 19,
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              // تحديد الكل كمقروء
                              Align(
                                alignment:
                                AlignmentDirectional.centerEnd,
                                child: TextButton(
                                  onPressed: unreadCount == 0
                                      ? null
                                      : markAllAsRead,
                                  child: Text(
                                    isVerySmall
                                        ? 'قراءة الكل'
                                        : 'تحديد الكل كمقروء',
                                    style: TextStyle(
                                      fontSize:
                                      isVerySmall ? 11 : 12,
                                      fontWeight:
                                      FontWeight.w600,
                                      color: unreadCount == 0
                                          ? hintColor
                                          : primaryColor,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(
                          height: isSmallScreen ? 22 : 30,
                        ),

                        // =====================
                        // Filters
                        // =====================
                        Row(
                          children: [
                            _filterButton(
                              text: 'الكل',
                              selected: !showUnreadOnly,
                              primaryColor: primaryColor,
                              onTap: () {
                                setState(() {
                                  showUnreadOnly = false;
                                });
                              },
                            ),

                            const SizedBox(width: 8),

                            _unreadFilterButton(
                              selected: showUnreadOnly,
                              primaryColor: primaryColor,
                              unreadCount: unreadCount,
                              onTap: () {
                                setState(() {
                                  showUnreadOnly = true;
                                });
                              },
                            ),
                          ],
                        ),

                        const SizedBox(height: 18),

                        // =====================
                        // Notifications
                        // =====================
                        if (displayedNotifications.isEmpty)
                          _emptyState(
                            primaryColor: primaryColor,
                            darkColor: darkColor,
                            hintColor: hintColor,
                          )
                        else
                          ListView.separated(
                            shrinkWrap: true,
                            physics:
                            const NeverScrollableScrollPhysics(),
                            itemCount:
                            displayedNotifications.length,
                            separatorBuilder: (context, index) =>
                            const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final AppNotification notification =
                              displayedNotifications[index];

                              return _notificationCard(
                                notification: notification,
                                primaryColor: primaryColor,
                                darkColor: darkColor,
                                hintColor: hintColor,
                                borderColor: borderColor,
                              );
                            },
                          ),

                        const SizedBox(height: 25),
                      ],
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

  Widget _filterButton({
    required String text,
    required bool selected,
    required Color primaryColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 9,
        ),
        decoration: BoxDecoration(
          color: selected ? primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? primaryColor
                : const Color(0xffD7E7E7),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected
                ? Colors.white
                : const Color(0xff5C6E75),
          ),
        ),
      ),
    );
  }

  // زر غير المقروء + العدد بجانبه
  Widget _unreadFilterButton({
    required bool selected,
    required Color primaryColor,
    required int unreadCount,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: selected ? primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? primaryColor
                : const Color(0xffD7E7E7),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'غير المقروء',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: selected
                    ? Colors.white
                    : const Color(0xff5C6E75),
              ),
            ),

            if (unreadCount > 0) ...[
              const SizedBox(width: 7),

              Container(
                constraints: const BoxConstraints(
                  minWidth: 22,
                  minHeight: 22,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 6),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected
                      ? Colors.white
                      : primaryColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$unreadCount',
                  style: TextStyle(
                    color: selected
                        ? primaryColor
                        : Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _notificationCard({
    required AppNotification notification,
    required Color primaryColor,
    required Color darkColor,
    required Color hintColor,
    required Color borderColor,
  }) {
    return Material(
      color: notification.isRead
          ? Colors.white
          : const Color(0xffF4FBFA),
      borderRadius: BorderRadius.circular(17),
      child: InkWell(
        onTap: () {
          markAsRead(notification);
        },
        borderRadius: BorderRadius.circular(17),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(17),
            border: Border.all(
              color: notification.isRead
                  ? borderColor
                  : const Color(0xffBDE5E2),
              width: notification.isRead ? 1.1 : 1.4,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color:
                  notificationIconBackground(notification.type),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  notificationIcon(notification.type),
                  color:
                  notificationIconColor(notification.type),
                  size: 25,
                ),
              ),

              const SizedBox(width: 11),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: notification.isRead
                                  ? FontWeight.w600
                                  : FontWeight.bold,
                              color: darkColor,
                            ),
                          ),
                        ),

                        if (!notification.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            margin:
                            const EdgeInsets.only(right: 6),
                            decoration: BoxDecoration(
                              color: primaryColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 6),

                    Text(
                      notification.message,
                      style: const TextStyle(
                        fontSize: 13,
                        height: 1.45,
                        color: Color(0xff5C6E75),
                      ),
                    ),

                    const SizedBox(height: 9),

                    Text(
                      formatNotificationTime(
                        notification.createdAt,
                      ),
                      style: TextStyle(
                        fontSize: 11,
                        color: hintColor,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 4),

              IconButton(
                tooltip: 'حذف الإشعار',
                onPressed: () {
                  deleteNotification(notification);
                },
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  color: Color(0xffC85C55),
                  size: 21,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _emptyState({
    required Color primaryColor,
    required Color darkColor,
    required Color hintColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 38,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xffE9F0F0),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              color: Color(0xffE8F7F6),
              shape: BoxShape.circle,
            ),
            child: Icon(
              showUnreadOnly
                  ? Icons.mark_email_read_outlined
                  : Icons.notifications_none_rounded,
              color: primaryColor,
              size: 34,
            ),
          ),

          const SizedBox(height: 15),

          Text(
            showUnreadOnly
                ? 'لا توجد إشعارات غير مقروءة'
                : 'لا توجد إشعارات',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: darkColor,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            showUnreadOnly
                ? 'تمت قراءة جميع الإشعارات'
                : 'ستظهر هنا تذكيرات الأدوية والمواعيد الطبية',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: hintColor,
            ),
          ),
        ],
      ),
    );
  }
}