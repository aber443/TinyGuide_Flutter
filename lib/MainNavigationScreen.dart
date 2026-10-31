import 'package:flutter/material.dart';

import 'HomeScreen.dart';
import 'ReportsScreen.dart';
import 'RecordsScreen.dart';
import 'ProfileScreen.dart';
import 'ChildStore.dart';

class MainNavigationScreen extends StatefulWidget {
  final String childName;
  final DateTime birthDate;
  final String gender;
  final String? childImagePath;

  const MainNavigationScreen({
    super.key,
    required this.childName,
    required this.birthDate,
    required this.gender,
    this.childImagePath,
  });

  @override
  State<MainNavigationScreen> createState() =>
      _MainNavigationScreenState();
}

class _MainNavigationScreenState
    extends State<MainNavigationScreen> {
  int selectedTabIndex = 0;

  final ChildStore store = ChildStore.instance;

  @override
  void initState() {
    super.initState();
    _ensureInitialChild();
  }

  // التأكد من وجود الطفل الأول وتحديده دون تكراره.
  void _ensureInitialChild() {
    store.deduplicateChildren();

    ChildModel? existingChild;

    for (final child in store.children) {
      if (child.fullName.trim().toLowerCase() ==
          widget.childName.trim().toLowerCase() &&
          child.gender.trim() == widget.gender.trim() &&
          DateUtils.isSameDay(
            child.birthDate,
            widget.birthDate,
          )) {
        existingChild = child;
        break;
      }
    }

    if (existingChild != null) {
      store.selectChild(existingChild.localId);
    } else {
      store.addChild(
        ChildModel(
          localId:
          DateTime.now().microsecondsSinceEpoch.toString(),
          firstName: widget.childName,
          gender: widget.gender,
          birthDate: widget.birthDate,
          imagePath: widget.childImagePath,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        final child = store.selectedChild;

        // الاحتفاظ ببيانات البداية إذا لم يوجد طفل محدد.
        final String childName =
            child?.fullName ?? widget.childName;
        final DateTime birthDate =
            child?.birthDate ?? widget.birthDate;
        final String gender =
            child?.gender ?? widget.gender;
        final String? childImagePath =
            child?.imagePath ?? widget.childImagePath;

        final theme = Theme.of(context);
        final primaryColor = theme.primaryColor;
        final textColor = theme.colorScheme.onSurface;

        final bool isVerySmall =
            MediaQuery.of(context).size.width < 390;

        final String childKey =
            child?.localId ?? 'initial-child';

        final List<Widget> pages = [
          HomeScreen(
            key: ValueKey('home-$childKey'),
            childName: childName,
            birthDate: birthDate,
            gender: gender,
            childImagePath: childImagePath,
            showBottomNavigationBar: false,
          ),
          ReportsScreen(
            key: ValueKey('reports-$childKey'),
            childName: childName,
            birthDate: birthDate,
            gender: gender,
            childImagePath: childImagePath,
          ),
          RecordsScreen(
            key: ValueKey('records-$childKey'),
          ),
          ProfileScreen(
            key: ValueKey('profile-$childKey'),
            childName: childName,
            birthDate: birthDate,
            gender: gender,
            childImagePath: childImagePath,
          ),
        ];

        return Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            body: IndexedStack(
              index: selectedTabIndex,
              children: pages,
            ),
            bottomNavigationBar: Container(
              decoration: BoxDecoration(
                color: theme.cardColor,
                border: Border(
                  top: BorderSide(
                    color: textColor.withOpacity(0.12),
                  ),
                ),
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isVerySmall ? 4 : 12,
                    vertical: 9,
                  ),
                  child: Row(
                    children: [
                      _buildItem(
                        icon: Icons.home_rounded,
                        label: 'الرئيسية',
                        index: 0,
                        primaryColor: primaryColor,
                        textColor: textColor,
                        isVerySmall: isVerySmall,
                      ),
                      _buildItem(
                        icon: Icons.bar_chart_rounded,
                        label: 'التقارير',
                        index: 1,
                        primaryColor: primaryColor,
                        textColor: textColor,
                        isVerySmall: isVerySmall,
                      ),
                      _buildItem(
                        icon: Icons.menu_book_rounded,
                        label: 'السجلات',
                        index: 2,
                        primaryColor: primaryColor,
                        textColor: textColor,
                        isVerySmall: isVerySmall,
                      ),
                      _buildItem(
                        icon: Icons.person_outline_rounded,
                        label: 'الملف الشخصي',
                        index: 3,
                        primaryColor: primaryColor,
                        textColor: textColor,
                        isVerySmall: isVerySmall,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildItem({
    required IconData icon,
    required String label,
    required int index,
    required Color primaryColor,
    required Color textColor,
    required bool isVerySmall,
  }) {
    final bool selected = selectedTabIndex == index;

    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            selectedTabIndex = index;
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 2,
            vertical: 3,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: isVerySmall ? 22 : 25,
                color: selected
                    ? primaryColor
                    : textColor.withOpacity(0.55),
              ),
              const SizedBox(height: 3),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: isVerySmall ? 10 : 11,
                  color: selected
                      ? primaryColor
                      : textColor.withOpacity(0.55),
                  fontWeight: selected
                      ? FontWeight.bold
                      : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}