import 'package:flutter/material.dart';

import 'ChildStore.dart';
import 'ChildInfoScreen.dart';
import 'MainNavigationScreen.dart';

class ChildSelectionScreen extends StatefulWidget {
  const ChildSelectionScreen({super.key});

  @override
  State<ChildSelectionScreen> createState() =>
      _ChildSelectionScreenState();
}

class _ChildSelectionScreenState
    extends State<ChildSelectionScreen> {
  bool openingChild = false;
  bool isAddingChild = false;

  void openChild(ChildModel child) {
    if (openingChild || !mounted) return;

    openingChild = true;
    ChildStore.instance.selectChild(child.localId);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => MainNavigationScreen(
          childName: child.fullName,
          birthDate: child.birthDate,
          gender: child.gender,
          childImagePath: child.imagePath,
        ),
      ),
    );
  }

  Future<void> addChild() async {
    if (isAddingChild) return;

    setState(() {
      isAddingChild = true;
    });

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ChildInfoScreen(
          showBackButton: true,
          returnToProfileAfterSave: true,
        ),
      ),
    );

    if (!mounted) return;

    setState(() {
      isAddingChild = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;
    final textColor = theme.colorScheme.onSurface;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('اختيار الطفل'),
          automaticallyImplyLeading: false,
        ),
        body: AnimatedBuilder(
          animation: ChildStore.instance,
          builder: (context, _) {
            final children = ChildStore.instance.children;

            if (children.length == 1 && !openingChild) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!mounted || openingChild) return;
                openChild(children.first);
              });

              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (children.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.child_care_rounded,
                        size: 70,
                        color: primaryColor,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'أضيفي بيانات طفلك للبدء',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed:
                        isAddingChild ? null : addChild,
                        icon: const Icon(Icons.person_add),
                        label: const Text('إضافة طفل'),
                      ),
                    ],
                  ),
                ),
              );
            }

            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text(
                  'أطفالي',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'اختاري الطفل لعرض بياناته الصحية',
                  style: TextStyle(
                    color: textColor.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 20),

                ...children.map((child) {
                  return Card(
                    color: theme.cardColor,
                    margin: const EdgeInsets.only(bottom: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ListTile(
                      contentPadding:
                      const EdgeInsets.all(12),
                      leading: CircleAvatar(
                        radius: 28,
                        backgroundColor:
                        primaryColor.withOpacity(0.15),
                        child: Icon(
                          Icons.child_care_rounded,
                          color: primaryColor,
                          size: 32,
                        ),
                      ),
                      title: Text(
                        child.fullName,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      subtitle: Text(
                        '${child.gender} • '
                            '${child.birthDate.year}',
                      ),
                      trailing: Icon(
                        Icons.chevron_left_rounded,
                        color: primaryColor,
                      ),
                      onTap: openingChild
                          ? null
                          : () => openChild(child),
                    ),
                  );
                }),

                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed:
                  isAddingChild ? null : addChild,
                  icon: const Icon(
                    Icons.person_add_alt_1,
                  ),
                  label: const Text('إضافة طفل'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}