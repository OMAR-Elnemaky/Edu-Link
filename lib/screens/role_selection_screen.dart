import 'package:flutter/material.dart';
import '../models/user_role.dart';
import '../theme/app_theme.dart';
import 'sign_up_screen.dart';

class _RoleInfo {
  final UserRole role;
  final String title;
  final String description;
  final IconData icon;
  const _RoleInfo(this.role, this.title, this.description, this.icon);
}

const _roles = [
  _RoleInfo(
    UserRole.student,
    'طالب',
    'يمكنك من مشاهدة محاضراتك، وواجباتك، الاختبارات وملفات المواد والمراجعات',
    Icons.backpack_rounded,
  ),
  _RoleInfo(
    UserRole.teacher,
    'مدرس',
    'إدارة محاضراتك، تقييم الطلاب أسبوعيًا وشهريًا، ومتابعة تقدمهم',
    Icons.co_present_rounded,
  ),
  _RoleInfo(
    UserRole.parent,
    'ولي أمر',
    'متابعة أداء ابنك/ابنتك، الاطلاع على التقييمات والواجبات والإشعارات',
    Icons.family_restroom_rounded,
  ),
  _RoleInfo(
    UserRole.admin,
    'إدارة',
    'اطلاع عام على كل ما يحدث في المدرسة، من طلاب، أولياء أمور، ومدرسين',
    Icons.admin_panel_settings_rounded,
  ),
];

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  UserRole _selected = UserRole.student;

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
                  icon: const Icon(Icons.arrow_back_rounded,
                      color: AppColors.primaryLight),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      RichText(
                        text: const TextSpan(
                          style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w800,
                              fontFamily: 'Cairo'),
                          children: [
                            TextSpan(
                                text: 'إنشاء حساب ',
                                style: TextStyle(color: Colors.white)),
                            TextSpan(
                                text: 'جديد',
                                style: TextStyle(color: AppColors.primary)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text('اختر نوع الحساب الذي تريد إنشاؤه',
                          style: TextStyle(
                              fontSize: 17, color: AppColors.textSecondary)),
                      const SizedBox(height: 24),
                      _row(_roles[0], _roles[1]),
                      const SizedBox(height: 12),
                      _row(_roles[2], _roles[3]),
                      const SizedBox(height: 16),
                      _securityNote(),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => SignUpScreen(role: _selected)),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(27)),
                    ),
                    child: const Text('متابعة',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w700)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(_RoleInfo a, _RoleInfo b) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: _roleCard(a)),
          const SizedBox(width: 12),
          Expanded(child: _roleCard(b)),
        ],
      ),
    );
  }

  Widget _roleCard(_RoleInfo info) {
    final selected = _selected == info.role;
    return GestureDetector(
      onTap: () => setState(() => _selected = info.role),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: selected ? AppColors.primaryLight : AppColors.cardBorder,
            width: selected ? 2.5 : 1.2,
          ),
        ),
        child: Column(
          children: [
            Align(
              alignment: AlignmentDirectional.topEnd,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: selected ? 1 : 0,
                child: const CircleAvatar(
                  radius: 12,
                  backgroundColor: AppColors.primaryLight,
                  child: Icon(Icons.check, size: 16, color: Colors.white),
                ),
              ),
            ),
            Icon(info.icon, size: 56, color: AppColors.primaryLight),
            const SizedBox(height: 8),
            Text(info.title,
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white)),
            const SizedBox(height: 6),
            Text(info.description,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 12.5, height: 1.5, color: AppColors.textMuted)),
          ],
        ),
      ),
    );
  }

  Widget _securityNote() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: const Row(
        children: [
          Icon(Icons.shield_outlined, size: 44, color: AppColors.primaryLight),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('بياناتك آمنة',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
                SizedBox(height: 4),
                Text(
                  'جميع المعلومات محمية وتستخدم فقط لأغراض المدرسة والتواصل بين الأطراف.',
                  style: TextStyle(
                      fontSize: 12.5, height: 1.5, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}