import 'package:flutter/material.dart';
import 'SplashScreen.dart';

final ValueNotifier<ThemeMode> themeNotifier =
ValueNotifier(ThemeMode.light);

void main() {
  runApp(const TinyGuideApp());
}

class TinyGuideApp extends StatelessWidget {
  const TinyGuideApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, currentThemeMode, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'TinyGuide',

          themeMode: currentThemeMode,

          // =========================
          // Light Theme
          // =========================
          theme: ThemeData(
            brightness: Brightness.light,

            primaryColor: const Color(0xff64C7C4),

            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xff64C7C4),
              brightness: Brightness.light,
            ).copyWith(
              surface: Colors.white,
              onSurface: const Color(0xff2C4A5A),
            ),

            // الخلفية الأصلية المعتمدة
            scaffoldBackgroundColor:
            const Color(0xffF1F8F8),

            // الكروت الأصلية المعتمدة
            cardColor: Colors.white,

            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xff64C7C4),
              foregroundColor: Colors.white,
            ),

            inputDecorationTheme:
            const InputDecorationTheme(
              filled: true,
              fillColor: Colors.white,

              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Color(0xff64C7C4),
                  width: 2,
                ),
                borderRadius: BorderRadius.all(
                  Radius.circular(14),
                ),
              ),
            ),

            elevatedButtonTheme:
            ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor:
                const Color(0xff64C7C4),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(14),
                ),
              ),
            ),

            dividerColor:
            const Color(0xffE2EEEE),

            iconTheme: const IconThemeData(
              color: Color(0xff2C4A5A),
            ),
          ),

          // =========================
          // Dark Theme
          // =========================
          darkTheme: ThemeData(
            brightness: Brightness.dark,

            primaryColor: const Color(0xff64C7C4),

            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xff64C7C4),
              brightness: Brightness.dark,
            ).copyWith(
              surface: const Color(0xff1D292D),
              onSurface: Colors.white,
            ),

            scaffoldBackgroundColor:
            const Color(0xff121A1D),

            cardColor:
            const Color(0xff1D292D),

            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xff1D292D),
              foregroundColor: Colors.white,
            ),

            inputDecorationTheme:
            const InputDecorationTheme(
              filled: true,
              fillColor: Color(0xff1D292D),

              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Color(0xff64C7C4),
                  width: 2,
                ),
                borderRadius: BorderRadius.all(
                  Radius.circular(14),
                ),
              ),
            ),

            elevatedButtonTheme:
            ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor:
                const Color(0xff64C7C4),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(14),
                ),
              ),
            ),

            dividerColor:
            Colors.white.withOpacity(0.12),

            iconTheme: const IconThemeData(
              color: Colors.white,
            ),
          ),

          home: const SplashScreen(),
        );
      },
    );
  }
}