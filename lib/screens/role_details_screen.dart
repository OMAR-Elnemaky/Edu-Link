import 'package:flutter/material.dart';
import '../models/school.dart';
import '../models/user_role.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import 'auth_gate.dart';

/// شاشة استكمال البيانات، محتواها يتغيّر حسب الدور المختار
class RoleDetailsScreen extends StatefulWidget {
  final School school;
  final UserRole role;
  const RoleDetailsScreen({super.key, required this.school, required this.role});

  @override
  State<RoleDetailsScreen> createState() => _RoleDetailsScreenState();
}

class _RoleDetailsScreenState extends State<RoleDetailsScreen> {
  String? _grade;
  String? _subject;
  final _studentCode = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _studentCode.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final auth = AuthService();
    setState(() => _loading = true);
    try {
      switch (widget.role) {
        case UserRole.student:
          if (_grade == null) throw AuthException('اختر الصف الدراسي');
          await auth.completeAsStudent(schoolId: widget.school.id, grade: _grade!);
          break;
        case UserRole.teacher:
          if (_subject == null) throw AuthException('اختر المادة');
          await auth.completeAsTeacher(schoolId: widget.school.id, subject: _subject!);
          break;
        case UserRole.parent:
          if (_studentCode.text.trim().length != 6) throw AuthException('الكود من 6 أحرف/أرقام');
          await auth.completeAsParent(schoolId: widget.school.id, studentCode: _studentCode.text);
          break;
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('تم إنشاء حسابك بنجاح ✅')));
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const AuthGate()),
            (route) => false,
      );
    } on AuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
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
                      Text('خطوة أخيرة (${widget.role.label})',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white)),
                      const SizedBox(height: 6),
                      Text(widget.school.name,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 15, color: AppColors.textSecondary)),
                      const SizedBox(height: 24),
                      ..._fieldsForRole(),
                      const SizedBox(height: 8),
                      primaryButton(label: 'إنهاء التسجيل', onPressed: _submit, loading: _loading),
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

  List<Widget> _fieldsForRole() {
    switch (widget.role) {
      case UserRole.student:
        final grades = gradesForStage(widget.school.stage);
        return [
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: DropdownButtonFormField<String>(
              initialValue: _grade,
              isExpanded: true,
              dropdownColor: AppColors.card,
              decoration: appFieldDecoration('الصف الدراسي', Icons.class_outlined),
              items: grades.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
              onChanged: (v) => setState(() => _grade = v),
            ),
          ),
          _note('سيتم إنشاء كود خاص بك بعد التسجيل، تعطيه لولي أمرك ليربط حسابه بحسابك.'),
        ];
      case UserRole.teacher:
        return [
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: DropdownButtonFormField<String>(
              initialValue: _subject,
              isExpanded: true,
              dropdownColor: AppColors.card,
              decoration: appFieldDecoration('المادة التي تدرسها', Icons.menu_book_outlined),
              items: widget.school.subjects.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
              onChanged: (v) => setState(() => _subject = v),
            ),
          ),
        ];
      case UserRole.parent:
        return [
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: TextField(
              controller: _studentCode,
              textDirection: TextDirection.ltr,
              style: const TextStyle(color: Colors.white),
              decoration: appFieldDecoration('كود الطالب', Icons.link_rounded),
            ),
          ),
          _note('اطلب الكود من ابنك/ابنتك، يظهر في حسابه بعد التسجيل.'),
        ];
    }
  }

  Widget _note(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, size: 18, color: AppColors.primaryLight),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text,
                style: const TextStyle(fontSize: 13, height: 1.5, color: AppColors.textMuted)),
          ),
        ],
      ),
    );
  }
}