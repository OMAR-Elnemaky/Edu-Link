import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const bgTop = Color(0xFF071330);
  static const bgBottom = Color(0xFF0B2150);
  static const primary = Color(0xFF2F80FF);
  static const primaryLight = Color(0xFF5AA0FF);
  static const card = Color(0xFF0C1F4D);
  static const cardBorder = Color(0xFF1B3A80);
  static const textSecondary = Color(0xFF6E9BFF);
  static const textMuted = Color(0xFF9DB7F0);
}

const appBackground = BoxDecoration(
  gradient: LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [AppColors.bgTop, AppColors.bgBottom],
  ),
);

ThemeData buildAppTheme() {
  final base = ThemeData.dark(useMaterial3: true);
  return base.copyWith(
    scaffoldBackgroundColor: AppColors.bgTop,
    colorScheme: base.colorScheme.copyWith(
      primary: AppColors.primary,
      surface: AppColors.card,
    ),
    textTheme: GoogleFonts.cairoTextTheme(base.textTheme),
  );
}