import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'create_account_screen.dart';
import 'login_screen.dart';

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
                  ShaderMask(
                    shaderCallback: (r) => const LinearGradient(
                      colors: [AppColors.primaryLight, AppColors.primary],
                    ).createShader(r),
                    child: const Icon(Icons.school_rounded, size: 110, color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: RichText(
                      text: const TextSpan(
                        style: TextStyle(fontSize: 52, fontWeight: FontWeight.w800, letterSpacing: -1),
                        children: [
                          TextSpan(text: 'Edu', style: TextStyle(color: Colors.white)),
                          TextSpan(text: 'Link', style: TextStyle(color: AppColors.primary)),
                        ],
                      ),
                    ),
                  ),
                  const Text('مدرستك .. في مكان واحد',
                      style: TextStyle(fontSize: 17, color: AppColors.textSecondary)),
                  const SizedBox(height: 48),
                  const Text(
                    'منصة تربط طلابك، معلميك،\nأولياء الأمور',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, height: 1.5, color: Colors.white),
                  ),
                  const SizedBox(height: 36),
                  primaryButton(
                    label: 'إنشاء حساب جديد',
                    icon: Icons.person_add_alt_1_rounded,
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CreateAccountScreen()),
                    ),
                  ),
                  const SizedBox(height: 14),
                  outlinedButtonWidget(
                    label: 'تسجيل الدخول',
                    icon: Icons.login_rounded,
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
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