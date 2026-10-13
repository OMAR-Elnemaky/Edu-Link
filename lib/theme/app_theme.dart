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

InputDecoration appFieldDecoration(String label, IconData icon, {Widget? suffix}) {
  OutlineInputBorder border(Color c, [double w = 1.2]) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(16),
    borderSide: BorderSide(color: c, width: w),
  );
  return InputDecoration(
    labelText: label,
    labelStyle: const TextStyle(color: AppColors.textSecondary),
    prefixIcon: Icon(icon, color: AppColors.primaryLight),
    suffixIcon: suffix,
    filled: true,
    fillColor: AppColors.card,
    enabledBorder: border(AppColors.cardBorder),
    focusedBorder: border(AppColors.primaryLight, 2),
    errorBorder: border(Colors.redAccent),
    focusedErrorBorder: border(Colors.redAccent, 2),
  );
}

Widget appBackButton(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.only(top: 8, right: 8, left: 8),
    child: Align(
      alignment: AlignmentDirectional.centerStart,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Navigator.pop(context),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.cardBorder, width: 1.2),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.primaryLight, size: 18),
                SizedBox(width: 6),
                Text('رجوع', style: TextStyle(color: AppColors.primaryLight, fontSize: 15, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

Widget primaryButton({
  required String label,
  required VoidCallback? onPressed,
  bool loading = false,
  IconData? icon,
}) {
  return SizedBox(
    height: 54,
    width: double.infinity,
    child: ElevatedButton(
      onPressed: loading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(27)),
      ),
      child: loading
          ? const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
          : Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[Icon(icon), const SizedBox(width: 8)],
          Text(label, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        ],
      ),
    ),
  );
}

Widget outlinedButtonWidget({
  required String label,
  required VoidCallback? onPressed,
  IconData? icon,
}) {
  return SizedBox(
    height: 54,
    width: double.infinity,
    child: OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon ?? Icons.arrow_forward),
      label: Text(label, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        side: const BorderSide(color: AppColors.primary, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(27)),
      ),
    ),
  );
}