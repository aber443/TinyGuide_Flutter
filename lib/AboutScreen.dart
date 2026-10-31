import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).primaryColor;
    final Color textColor = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      body: SafeArea(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 18,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 700),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // =========================
                    // Header
                    // =========================
                    Row(
                      children: [
                        IconButton(
                          tooltip: 'رجوع',
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            'حول التطبيق',
                            style: TextStyle(
                              fontSize: 27,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // =========================
                    // App Icon
                    // =========================
                    Center(
                      child: Container(
                        width: 115,
                        height: 115,
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.health_and_safety_rounded,
                          size: 62,
                          color: primaryColor,
                        ),
                      ),
                    ),

                    const SizedBox(height: 22),

                    Center(
                      child: Text(
                        'TinyGuide',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                    ),

                    const SizedBox(height: 7),

                    Center(
                      child: Text(
                        'الإصدار 1.0.0',
                        style: TextStyle(
                          fontSize: 13,
                          color: textColor.withOpacity(0.55),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // =========================
                    // About
                    // =========================
                    _buildInfoCard(
                      context,
                      icon: Icons.info_outline_rounded,
                      title: 'عن TinyGuide',
                      description:
                      'تطبيق يساعد ولي الأمر على متابعة معلومات الطفل '
                          'وسجلاته الصحية بطريقة منظمة وسهلة.',
                    ),

                    const SizedBox(height: 14),

                    _buildInfoCard(
                      context,
                      icon: Icons.favorite_outline_rounded,
                      title: 'هدف التطبيق',
                      description:
                      'تسهيل متابعة صحة الطفل ومواعيده وبياناته المهمة، '
                          'وتوفير تجربة بسيطة تساعد ولي الأمر في الوصول '
                          'إلى المعلومات بسرعة.',
                    ),

                    const SizedBox(height: 14),

                    _buildInfoCard(
                      context,
                      icon: Icons.health_and_safety_outlined,
                      title: 'متابعة صحة الطفل',
                      description:
                      'يوفر التطبيق مكانًا منظمًا لمتابعة المعلومات '
                          'والسجلات الصحية والتنبيهات المرتبطة بالطفل.',
                    ),

                    const SizedBox(height: 30),

                    Center(
                      child: Text(
                        'TinyGuide © 2026',
                        style: TextStyle(
                          fontSize: 12,
                          color: textColor.withOpacity(0.50),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String description,
      }) {
    final Color primaryColor = Theme.of(context).primaryColor;
    final Color textColor = Theme.of(context).colorScheme.onSurface;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: textColor.withOpacity(0.12),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
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
              size: 25,
              color: primaryColor,
            ),
          ),

          const SizedBox(width: 13),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.7,
                    color: textColor.withOpacity(0.60),
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