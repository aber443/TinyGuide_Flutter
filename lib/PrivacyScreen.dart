import 'package:flutter/material.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).primaryColor;
    final Color textColor = Theme.of(context).colorScheme.onSurface;
    final Color secondaryTextColor =
    Theme.of(context).colorScheme.onSurface.withOpacity(0.65);

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
                    // العنوان وزر الرجوع
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: textColor,
                          ),
                        ),

                        const SizedBox(width: 5),

                        Expanded(
                          child: Text(
                            'الخصوصية',
                            style: TextStyle(
                              fontSize: 27,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    // أيقونة الخصوصية
                    Center(
                      child: Container(
                        width: 105,
                        height: 105,
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.privacy_tip_outlined,
                          size: 55,
                          color: primaryColor,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // العنوان الرئيسي
                    Center(
                      child: Text(
                        'خصوصيتك تهمنا',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    Center(
                      child: Text(
                        'نحرص على حماية بيانات ولي الأمر والبيانات الصحية للطفل.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.7,
                          color: secondaryTextColor,
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    _privacyCard(
                      context,
                      icon: Icons.lock_outline_rounded,
                      title: 'حماية البيانات',
                      description:
                      'يتم التعامل مع بيانات الحساب والطفل بشكل آمن، '
                          'ولا يتم عرضها إلا للمستخدم المصرح له.',
                    ),

                    const SizedBox(height: 14),

                    _privacyCard(
                      context,
                      icon: Icons.health_and_safety_outlined,
                      title: 'البيانات الصحية',
                      description:
                      'تُستخدم بيانات الطفل الصحية لتقديم وظائف المتابعة '
                          'داخل التطبيق، مثل القراءات والمواعيد والسجلات.',
                    ),

                    const SizedBox(height: 14),

                    _privacyCard(
                      context,
                      icon: Icons.notifications_none_rounded,
                      title: 'الإشعارات',
                      description:
                      'قد يستخدم التطبيق الإشعارات لتذكير ولي الأمر '
                          'بالمواعيد والتنبيهات المهمة للطفل.',
                    ),

                    const SizedBox(height: 14),

                    _privacyCard(
                      context,
                      icon: Icons.cloud_outlined,
                      title: 'تخزين البيانات',
                      description:
                      'عند ربط التطبيق بالخادم سيتم حفظ البيانات وفق '
                          'إجراءات الحماية والصلاحيات المعتمدة في النظام.',
                    ),

                    const SizedBox(height: 30),

                    Center(
                      child: Text(
                        'سيتم تحديث سياسة الخصوصية عند ربط النظام بالخادم.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: textColor.withOpacity(0.55),
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

  Widget _privacyCard(
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
        // يتغير تلقائيًا مع الوضع الداكن
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
              color: primaryColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              icon,
              color: primaryColor,
              size: 25,
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
                    color: textColor.withOpacity(0.65),
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