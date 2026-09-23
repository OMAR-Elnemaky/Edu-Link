import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'role_selection_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: appBackground,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.vertical -
                    32,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 24),
                  // الشعار
                  ShaderMask(
                    shaderCallback: (r) => const LinearGradient(
                      colors: [AppColors.primaryLight, AppColors.primary],
                    ).createShader(r),
                    child: const Icon(Icons.school_rounded,
                        size: 110, color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: RichText(
                      text: const TextSpan(
                        style: TextStyle(
                            fontSize: 52,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -1),
                        children: [
                          TextSpan(
                              text: 'Edu',
                              style: TextStyle(color: Colors.white)),
                          TextSpan(
                              text: 'Link',
                              style: TextStyle(color: AppColors.primary)),
                        ],
                      ),
                    ),
                  ),
                  const Text(
                    'مدرستك .. في مكان واحد',
                    style: TextStyle(
                        fontSize: 17, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 48),
                  const Text(
                    'تطبيق يربط طلاب، معلمين،\nأولياء الأمور وإداره',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        height: 1.5,
                        color: Colors.white),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'متابعة، تواصل، تقييم، و مزيد من الفرص\nلمستقبل أفضل',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 15,
                        height: 1.6,
                        color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 36),
                  // إنشاء حساب
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(28),
                        gradient: const LinearGradient(
                            colors: [AppColors.primary, AppColors.primaryLight]),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.4),
                            blurRadius: 18,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const RoleSelectionScreen()),
                        ),
                        icon: const Icon(Icons.person_add_alt_1_rounded),
                        label: const Text('إنشاء حساب جديد',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w700)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  // تسجيل الدخول
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // شاشه تسجيل دخول
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('قريباً: تسجيل الدخول')),
                        );
                      },
                      icon: const Icon(Icons.login_rounded),
                      label: const Text('تسجيل الدخول',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w700)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textMuted,
                        side: const BorderSide(
                            color: AppColors.primary, width: 1.5),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}