import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import 'auth_gate.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _hidePass = true;
  bool _loading = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _goHome() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const AuthGate()),
          (route) => false,
    );
  }

  Future<void> _submit() async {
    setState(() => _loading = true);
    try {
      await AuthService().signIn(email: _email.text, password: _password.text);
      if (!mounted) return;
      _goHome();
    } on AuthException catch (e) {
      _showError(e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _submitGoogle() async {
    setState(() => _loading = true);
    try {
      await AuthService().signInWithGoogle();
      if (!mounted) return;
      _goHome();
    } on AuthException catch (e) {
      _showError(e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: appBackground,
        child: SafeArea(
          child: Column(
            children: [
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_rounded, color: AppColors.primaryLight),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text('تسجيل الدخول',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white)),
                      const SizedBox(height: 6),
                      const Text('أهلاً بعودتك 👋',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16, color: AppColors.textSecondary)),
                      const SizedBox(height: 24),
                      outlinedButtonWidget(
                        label: 'المتابعة بحساب Google',
                        icon: Icons.g_mobiledata_rounded,
                        onPressed: _loading ? null : _submitGoogle,
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: const [
                          Expanded(child: Divider(color: AppColors.cardBorder)),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: Text('أو', style: TextStyle(color: AppColors.textMuted)),
                          ),
                          Expanded(child: Divider(color: AppColors.cardBorder)),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: TextField(
                          controller: _email,
                          keyboardType: TextInputType.emailAddress,
                          textDirection: TextDirection.ltr,
                          style: const TextStyle(color: Colors.white),
                          decoration: appFieldDecoration('البريد الإلكتروني', Icons.email_outlined),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: TextField(
                          controller: _password,
                          obscureText: _hidePass,
                          textDirection: TextDirection.ltr,
                          style: const TextStyle(color: Colors.white),
                          decoration: appFieldDecoration(
                            'كلمة المرور',
                            Icons.lock_outline,
                            suffix: IconButton(
                              icon: Icon(
                                  _hidePass ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                  color: AppColors.textSecondary),
                              onPressed: () => setState(() => _hidePass = !_hidePass),
                            ),
                          ),
                        ),
                      ),
                      Align(
                        alignment: AlignmentDirectional.centerEnd,
                        child: TextButton(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
                          ),
                          child: const Text('نسيت كلمة المرور؟',
                              style: TextStyle(color: AppColors.textMuted)),
                        ),
                      ),
                      const SizedBox(height: 12),
                      primaryButton(label: 'تسجيل الدخول', onPressed: _submit, loading: _loading),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}