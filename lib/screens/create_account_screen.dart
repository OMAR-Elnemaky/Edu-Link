import 'package:flutter/material.dart';
import '../models/registration_data.dart';
import '../models/user_role.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import 'school_select_screen.dart';

class CreateAccountScreen extends StatefulWidget {
  final UserRole? role;
  const CreateAccountScreen({super.key, this.role});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _age = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _hidePass = true;
  bool _loading = false;

  @override
  void dispose() {
    for (final c in [_name, _age, _email, _password, _confirm]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submitEmail() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await AuthService().createAccount(
        name: _name.text,
        age: int.parse(_age.text.trim()),
        email: _email.text,
        password: _password.text,
      );
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SchoolSelectScreen(
            registrationData: RegistrationData(
              name: _name.text.trim(),
              age: int.parse(_age.text.trim()),
              email: _email.text.trim(),
              password: _password.text,
              role: widget.role,
            ),
          ),
        ),
      );
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
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const SchoolSelectScreen()),
      );
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
              appBackButton(context),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text('إنشاء حساب جديد',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white)),
                        const SizedBox(height: 6),
                        const Text('ابدأ باستخدام EduLink الآن',
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

                        _field(
                          controller: _name,
                          label: 'الاسم الكامل',
                          icon: Icons.person_outline,
                          validator: (v) => (v == null || v.trim().length < 3) ? 'اكتب اسمك الكامل' : null,
                        ),
                        _field(
                          controller: _age,
                          label: 'العمر',
                          icon: Icons.cake_outlined,
                          keyboard: TextInputType.number,
                          validator: (v) {
                            final n = int.tryParse(v?.trim() ?? '');
                            if (n == null || n < 4 || n > 100) return 'أدخل عمرًا صحيحًا';
                            return null;
                          },
                        ),
                        _field(
                          controller: _email,
                          label: 'البريد الإلكتروني',
                          icon: Icons.email_outlined,
                          keyboard: TextInputType.emailAddress,
                          ltr: true,
                          validator: (v) {
                            final t = v?.trim() ?? '';
                            return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(t)
                                ? null
                                : 'اكتب بريد إلكتروني صحيح';
                          },
                        ),
                        _field(
                          controller: _password,
                          label: 'كلمة المرور',
                          icon: Icons.lock_outline,
                          obscure: _hidePass,
                          ltr: true,
                          suffix: IconButton(
                            icon: Icon(
                                _hidePass ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                color: AppColors.textSecondary),
                            onPressed: () => setState(() => _hidePass = !_hidePass),
                          ),
                          validator: (v) => (v == null || v.length < 6) ? 'كلمة المرور 6 أحرف على الأقل' : null,
                        ),
                        _field(
                          controller: _confirm,
                          label: 'تأكيد كلمة المرور',
                          icon: Icons.lock_reset_outlined,
                          obscure: _hidePass,
                          ltr: true,
                          validator: (v) => v != _password.text ? 'كلمتا المرور غير متطابقتين' : null,
                        ),
                        const SizedBox(height: 8),
                        primaryButton(
                          label: 'إنشاء الحساب',
                          onPressed: _submitEmail,
                          loading: _loading,
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboard,
    bool obscure = false,
    bool ltr = false,
    Widget? suffix,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboard,
        textDirection: ltr ? TextDirection.ltr : null,
        style: const TextStyle(color: Colors.white),
        decoration: appFieldDecoration(label, icon, suffix: suffix),
        validator: validator,
      ),
    );
  }
}