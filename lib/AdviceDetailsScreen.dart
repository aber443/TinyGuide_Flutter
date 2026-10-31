import 'package:flutter/material.dart';

class AdviceDetailsScreen extends StatelessWidget {
final String title;
final String description;
final IconData icon;

const AdviceDetailsScreen({
super.key,
required this.title,
required this.description,
required this.icon,
});

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
constraints: const BoxConstraints(maxWidth: 700),
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
'تفاصيل النصيحة',
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

const SizedBox(height: 28),

// Advice icon
Center(
child: Container(
width: 105,
height: 105,
decoration: BoxDecoration(
color: primaryColor.withOpacity(0.12),
shape: BoxShape.circle,
),
child: Icon(
icon,
size: 55,
color: primaryColor,
),
),
),

const SizedBox(height: 22),

// Advice title
Center(
child: Text(
title,
textAlign: TextAlign.center,
style: TextStyle(
fontSize: 23,
fontWeight: FontWeight.bold,
color: textColor,
),
),
),

const SizedBox(height: 24),

// Advice details
_buildCard(
cardColor: cardColor,
borderColor: borderColor,
child: Text(
description,
style: TextStyle(
fontSize: 14,
height: 1.8,
color: secondaryTextColor,
),
),
),

const SizedBox(height: 18),

// Helpful note
Container(
width: double.infinity,
padding: const EdgeInsets.all(15),
decoration: BoxDecoration(
color: primaryColor.withOpacity(
isDark ? 0.12 : 0.08,
),
borderRadius: BorderRadius.circular(15),
),
child: Row(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Icon(
Icons.lightbulb_outline_rounded,
color: primaryColor,
size: 23,
),
const SizedBox(width: 9),
Expanded(
child: Text(
'يمكن استخدام هذه المعلومات للمساعدة في تنظيم المتابعة اليومية وتسجيل البيانات بشكل أوضح.',
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

const SizedBox(height: 14),

// Medical safety warning
_buildCard(
cardColor: cardColor,
borderColor: borderColor,
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
'هذه المعلومات تعليمية فقط ولا تعتبر تشخيصًا طبيًا أو بديلاً عن الطبيب، ولا يجب استخدامها لتغيير دواء أو جرعة أو خطة علاج.',
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
padding: const EdgeInsets.all(18),
decoration: BoxDecoration(
color: cardColor,
borderRadius: BorderRadius.circular(18),
border: Border.all(color: borderColor),
),
child: child,
);
}
}