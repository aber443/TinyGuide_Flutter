import 'dart:async';
import 'package:flutter/material.dart';
import 'LoginScreen.dart';
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}
class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;
  @override
  void initState() {
    super.initState();
    _timer = Timer(
      const Duration(seconds: 3),
      _goToNextScreen,
    );
  }
  void _goToNextScreen() {
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      ),
    );
  }
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).primaryColor;
    const Color darkColor = Color(0xff2C4A5A);
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double screenWidth = constraints.maxWidth;
            final double screenHeight = constraints.maxHeight;
            final bool isSmallScreen =
                screenWidth < 360 || screenHeight < 600;
            final bool isTablet = screenWidth >= 600;
            final double logoSize = isSmallScreen
                ? 100
                : isTablet
                ? 145
                : 120;
            final double englishTitleSize = isSmallScreen
                ? 30
                : isTablet
                ? 44
                : 36;
            final double arabicTitleSize = isSmallScreen
                ? 17
                : isTablet
                ? 22
                : 19;
            final double descriptionSize = isSmallScreen
                ? 13
                : isTablet
                ? 17
                : 15;
            return Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 40 : 24,
                  vertical: 16,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 460,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo
                      Image.asset(
                        'images/LogoProj.webp',
                        width: logoSize,
                        height: logoSize,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 12),
                      // English app name
                      Text(
                        'TinyGuide',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: englishTitleSize,
                          fontWeight: FontWeight.bold,
                          color: darkColor,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 5),
                      // Arabic app name

                      const SizedBox(height: 22),
                      // Description
                      RichText(
                        textAlign: TextAlign.center,
                        textDirection: TextDirection.rtl,
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: descriptionSize,
                            height: 1.8,
                            color: const Color(0xff6D7A80),
                            fontWeight: FontWeight.w500,
                          ),
                          children: [
                            const TextSpan(
                              text:
                              'تابع صحة طفلك بسهولة،\n'
                                  'وسجل بياناته في مكان واحد بأمان ',
                            ),
                            WidgetSpan(
                              alignment: PlaceholderAlignment.middle,
                              child: Icon(
                                Icons.favorite,
                                color: primaryColor,
                                size: isSmallScreen ? 15 : 17,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 48),
                      // Loading indicator
                      SizedBox(
                        width: 23,
                        height: 23,
                        child: CircularProgressIndicator(
                          color: primaryColor,
                          strokeWidth: 2.5,
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
    );
  }
}