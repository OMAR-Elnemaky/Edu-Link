import 'package:flutter/material.dart';
import '../models/user_role.dart';
import '../theme/app_theme.dart';

const _grades = [
  'الصف الأول الابتدائي',
  'الصف الثاني الابتدائي',
  'الصف الثالث الابتدائي',
  'الصف الرابع الابتدائي',
  'الصف الخامس الابتدائي',
  'الصف السادس الابتدائي',
  'الصف الأول الإعدادي',
  'الصف الثاني الإعدادي',
  'الصف الثالث الإعدادي',
  'الصف الأول الثانوي',
  'الصف الثاني الثانوي',
  'الصف الثالث الثانوي',
];

class SignUpScreen extends StatefulWidget {
  final UserRole role;
  const SignUpScreen({super.key, required this.role});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  final _subject = TextEditingController(); // مدرس
  final _studentCode = TextEditingController(); // ولي أمر
  final _inviteCode = TextEditingController(); // إدارة

  String? _grade; // طالب
  bool _hidePass = true;

  @override
  void dispose() {
    for (final c in [
      _name, _email, _password, _confirm, _subject, _studentCode, _inviteCode
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(
              'البيانات صحيحة (${widget.role.label}) - الربط بـ Firebase في الخطوة الجاية')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final role = widget.role;
    return Scaffold(
      body: Container(
        decoration: appBackground,
        child: SafeArea(
          child: Column(
            children: [
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_rounded,
                      color: AppColors.primaryLight),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text('حساب ${role.label}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                color: Colors.white)),
                        const SizedBox(height: 6),
                        const Text('أدخل بياناتك لإنشاء الحساب',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 16, color: AppColors.textSecondary)),
                        const SizedBox(height: 24),

                        // ---- الحقول المشتركة ----
                        _field(
                          controller: _name,
                          label: 'الاسم الكامل',
                          icon: Icons.person_outline,
                          validator: (v) => (v == null || v.trim().length < 3)
                              ? 'اكتب اسمك الكامل'
                              : null,
                        ),
                        _field(
                          controller: _email,
                          label: 'البريد الإلكتروني',
                          icon: Icons.email_outlined,
                          keyboard: TextInputType.emailAddress,
                          ltr: true,
                          validator: (v) {
                            final t = v?.trim() ?? '';
                            final ok =
                            RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(t);
                            return ok ? null : 'اكتب بريد إلكتروني صحيح';
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
                                _hidePass
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: AppColors.textSecondary),
                            onPressed: () =>
                                setState(() => _hidePass = !_hidePass),
                          ),
                          validator: (v) => (v == null || v.length < 6)
                              ? 'كلمة المرور 6 أحرف على الأقل'
                              : null,
                        ),
                        _field(
                          controller: _confirm,
                          label: 'تأكيد كلمة المرور',
                          icon: Icons.lock_reset_outlined,
                          obscure: _hidePass,
                          ltr: true,
                          validator: (v) => v != _password.text
                              ? 'كلمتا المرور غير متطابقتين'
                              : null,
                        ),

                        // ---- حقول خاصة بكل دور ----
                        ..._roleFields(role),

                        const SizedBox(height: 8),
                        SizedBox(
                          height: 54,
                          child: ElevatedButton(
                            onPressed: _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(27)),
                            ),
                            child: const Text('إنشاء الحساب',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700)),
                          ),
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

  List<Widget> _roleFields(UserRole role) {
    switch (role) {
      case UserRole.student:
        return [
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: DropdownButtonFormField<String>(
              initialValue: _grade,
              isExpanded: true,
              dropdownColor: AppColors.card,
              decoration: _decoration('الصف الدراسي', Icons.class_outlined),
              items: _grades
                  .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                  .toList(),
              onChanged: (v) => setState(() => _grade = v),
              validator: (v) => v == null ? 'اختر الصف الدراسي' : null,
            ),
          ),
          _note('سيتم إنشاء كود خاص بك بعد التسجيل، تعطيه لولي أمرك ليربط حسابه بحسابك.'),
        ];
      case UserRole.teacher:
        return [
          _field(
            controller: _subject,
            label: 'المادة التي تدرسها',
            icon: Icons.menu_book_outlined,
            validator: (v) =>
            (v == null || v.trim().isEmpty) ? 'اكتب المادة' : null,
          ),
          _note('حسابك سيتم مراجعته من الإدارة قبل التفعيل.'),
        ];
      case UserRole.parent:
        return [
          _field(
            controller: _studentCode,
            label: 'كود الطالب',
            icon: Icons.link_rounded,
            ltr: true,
            validator: (v) => (v == null || v.trim().length != 6)
                ? 'الكود من 6 أحرف/أرقام'
                : null,
          ),
          _note('اطلب الكود من ابنك/ابنتك، يظهر في حسابه بعد التسجيل.'),
        ];
      case UserRole.admin:
        return [
          _field(
            controller: _inviteCode,
            label: 'كود دعوة الإدارة',
            icon: Icons.vpn_key_outlined,
            ltr: true,
            validator: (v) =>
            (v == null || v.trim().isEmpty) ? 'اكتب كود الدعوة' : null,
          ),
          _note('حساب الإدارة يحتاج كود دعوة من إدارة المدرسة.'),
        ];
    }
  }

  InputDecoration _decoration(String label, IconData icon, {Widget? suffix}) {
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
        decoration: _decoration(label, icon, suffix: suffix),
        validator: validator,
      ),
    );
  }

  Widget _note(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline,
              size: 18, color: AppColors.primaryLight),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text,
                style: const TextStyle(
                    fontSize: 13, height: 1.5, color: AppColors.textMuted)),
          ),
        ],
      ),
    );
  }
}