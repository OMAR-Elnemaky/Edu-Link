import 'package:flutter/material.dart';
import '../models/school.dart';
import '../models/user_role.dart';
import '../theme/app_theme.dart';
import 'role_details_screen.dart';

class _RoleInfo {
  final UserRole role;
  final String title;
  final String description;
  final IconData icon;
  const _RoleInfo(this.role, this.title, this.description, this.icon);
}

const _roles = [
  _RoleInfo(UserRole.student, 'طالب',
      'يمكنك من مشاهدة محاضراتك، وواجباتك، الاختبارات وملفات المواد والمراجعات', Icons.backpack_rounded),
  _RoleInfo(UserRole.teacher, 'مدرس',
      'إدارة محاضراتك، تقييم الطلاب أسبوعيًا وشهريًا، ومتابعة تقدمهم', Icons.co_present_rounded),
  _RoleInfo(UserRole.parent, 'ولي أمر',
      'متابعة أداء ابنك/ابنتك، الاطلاع على التقييمات والواجبات والإشعارات', Icons.family_restroom_rounded),
];

class RoleSelectionScreen extends StatefulWidget {
  final School school;
  const RoleSelectionScreen({super.key, required this.school});

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
              const SizedBox(height: 8),
              Text(widget.school.name,
                  style: const TextStyle(fontSize: 15, color: AppColors.textMuted)),
              const SizedBox(height: 4),
              const Text('ما هو دورك؟',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Colors.white)),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      for (final r in _roles) ...[
                        _roleCard(r),
                        const SizedBox(height: 12),
                      ],
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: primaryButton(
                  label: 'متابعة',
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => RoleDetailsScreen(school: widget.school, role: _selected),
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

  Widget _roleCard(_RoleInfo info) {
    final selected = _selected == info.role;
    return GestureDetector(
      onTap: () => setState(() => _selected = info.role),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: selected ? AppColors.primaryLight : AppColors.cardBorder,
            width: selected ? 2.5 : 1.2,
          ),
        ),
        child: Row(
          children: [
            Icon(info.icon, size: 44, color: AppColors.primaryLight),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(info.title,
                      style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w700, color: Colors.white)),
                  const SizedBox(height: 4),
                  Text(info.description,
                      style: const TextStyle(fontSize: 12.5, height: 1.5, color: AppColors.textMuted)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: selected ? 1 : 0,
              child: const CircleAvatar(
                radius: 12,
                backgroundColor: AppColors.primaryLight,
                child: Icon(Icons.check, size: 16, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}