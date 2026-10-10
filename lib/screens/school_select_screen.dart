import 'package:flutter/material.dart';
import '../models/school.dart';
import '../services/auth_service.dart';
import '../services/school_service.dart';
import '../theme/app_theme.dart';
import 'add_school_screen.dart';
import 'role_selection_screen.dart';

class SchoolSelectScreen extends StatefulWidget {
  const SchoolSelectScreen({super.key});

  @override
  State<SchoolSelectScreen> createState() => _SchoolSelectScreenState();
}

class _SchoolSelectScreenState extends State<SchoolSelectScreen> {
  late Future<List<School>> _future;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _future = SchoolService().fetchSchools();
  }

  void _reload() {
    setState(() => _future = SchoolService().fetchSchools());
  }

  Future<void> _choose(School school) async {
    setState(() => _loading = true);
    try {
      await AuthService().selectSchool(school.id);
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => RoleSelectionScreen(school: school)),
      );
    } on AuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _openAddSchool() async {
    final created = await Navigator.push<School>(
      context,
      MaterialPageRoute(builder: (_) => const AddSchoolScreen()),
    );
    if (created != null) {
      _reload();
      if (mounted) _choose(created);
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
              const SizedBox(height: 8),
              const Text('اختر مدرستك',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Colors.white)),
              const SizedBox(height: 6),
              const Text('من القائمة، أو أضِف مدرستك إذا لم تكن موجودة',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
              const SizedBox(height: 16),
              Expanded(
                child: FutureBuilder<List<School>>(
                  future: _future,
                  builder: (context, snap) {
                    if (snap.connectionState != ConnectionState.done) {
                      return const Center(
                          child: CircularProgressIndicator(color: AppColors.primaryLight));
                    }
                    final schools = snap.data ?? [];
                    if (schools.isEmpty) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: Text('لا توجد مدارس مسجّلة بعد، كن أول من يضيف مدرسته!',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: AppColors.textMuted)),
                        ),
                      );
                    }
                    return ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: schools.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, i) {
                        final s = schools[i];
                        return Material(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(18),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(18),
                            onTap: _loading ? null : () => _choose(s),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(color: AppColors.cardBorder),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.school_rounded, color: AppColors.primaryLight, size: 34),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(s.name,
                                            style: const TextStyle(
                                                fontSize: 17, fontWeight: FontWeight.w700, color: Colors.white)),
                                        const SizedBox(height: 2),
                                        Text('${s.city} - ${s.stage.label}',
                                            style: const TextStyle(fontSize: 13, color: AppColors.textMuted)),
                                      ],
                                    ),
                                  ),
                                  const Icon(Icons.arrow_forward_ios_rounded,
                                      size: 16, color: AppColors.textMuted),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: outlinedButtonWidget(
                  label: 'إضافة مدرسة جديدة',
                  icon: Icons.add_circle_outline_rounded,
                  onPressed: _loading ? null : _openAddSchool,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}