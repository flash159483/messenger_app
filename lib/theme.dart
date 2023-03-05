import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'modal/theme_data.dart';
import 'route/custom_route.dart';

ThemeData lightThemeData(BuildContext context) {
  return ThemeData.light().copyWith(
      primaryColor: primaryColor,
      scaffoldBackgroundColor: Colors.white,
      iconTheme: const IconThemeData(color: contentColorlight),
      colorScheme: const ColorScheme.light(
          primary: primaryColor, secondary: secondaryColor, error: errorColor),
      textTheme: GoogleFonts.interTextTheme(Theme.of(context).textTheme)
          .apply(bodyColor: contentColorlight),
      pageTransitionsTheme: PageTransitionsTheme(
          builders: {TargetPlatform.android: Custom_Page_transition()}),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: contentColorlight.withOpacity(0.8),
          unselectedItemColor: contentColorlight.withOpacity(0.3),
          selectedIconTheme: const IconThemeData(color: primaryColor)));
}
