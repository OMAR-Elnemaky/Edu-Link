import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/school.dart';
import '../services/school_service.dart';
import '../theme/app_theme.dart';

class AddSchoolScreen extends StatefulWidget {
  const AddSchoolScreen({super.key});

  @override
  State<AddSchoolScreen> createState() => _AddSchoolScreenState();
}

class _AddSchoolScreenState extends State<AddSchoolScreen> {
  final _name = TextEditingController();
  final _city = TextEditingController();
  final _customSubject = TextEditingController();
  SchoolStage _stage = SchoolStage.secondary;
  final Set<String> _subjects = {};
  bool _loading = false;

  @override
  void dispose() {
    _name.dispose();
    _city.dispose();
    _customSubject.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_name.text.trim().isEmpty || _city.text.trim().isEmpty) {
      _showError('أدخل اسم المدرسة والمدينة');
      return;
    }
    if (_subjects.isEmpty) {
      _showError('اختر مادة واحدة على الأقل');
      return;
    }
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      _showError('يجب تسجيل الدخول أولاً');
      return;
    }
    setState(() => _loading = true);
    try {
      final id = await SchoolService().addSchool(
        name: _name.text,
        city: _city.text,
        stage: _stage,
        subjects: _subjects.toList(),
        createdByUid: uid,
      );
      if (!mounted) return;
      Navigator.pop(
        context,
        School(id: id, name: _name.text.trim(), city: _city.text.trim(), stage: _stage, subjects: _subjects.toList()),
      );
    } catch (_) {
      _showError('تعذر إضافة المدرسة، حاول مرة أخرى');
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
                      const Text('إضافة مدرسة جديدة',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Colors.white)),
                      const SizedBox(height: 6),
                      const Text('هذه البيانات ستظهر لكل من يسجل من نفس مدرستك',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                      const SizedBox(height: 24),
                      TextField(
                        controller: _name,
                        style: const TextStyle(color: Colors.white),
                        decoration: appFieldDecoration('اسم المدرسة', Icons.school_outlined),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: _city,
                        style: const TextStyle(color: Colors.white),
                        decoration: appFieldDecoration('المدينة', Icons.location_on_outlined),
                      ),
                      const SizedBox(height: 18),
                      const Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: Text('المرحلة الدراسية',
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 15)),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 10,
                        children: SchoolStage.values.map((s) {
                          final selected = _stage == s;
                          return ChoiceChip(
                            label: Text(s.label),
                            selected: selected,
                            onSelected: (_) => setState(() {
                              _stage = s;
                              _subjects.clear();
                            }),
                            selectedColor: AppColors.primary,
                            backgroundColor: AppColors.card,
                            labelStyle: TextStyle(color: selected ? Colors.white : AppColors.textMuted),
                            side: BorderSide(color: selected ? AppColors.primaryLight : AppColors.cardBorder),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 18),
                      const Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: Text('المواد الدراسية',
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 15)),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: subjectSuggestionsForStage(_stage).map((subj) {
                          final selected = _subjects.contains(subj);
                          return FilterChip(
                            label: Text(subj),
                            selected: selected,
                            onSelected: (v) =>
                                setState(() => v ? _subjects.add(subj) : _subjects.remove(subj)),
                            selectedColor: AppColors.primary,
                            backgroundColor: AppColors.card,
                            labelStyle: TextStyle(
                                color: selected ? Colors.white : AppColors.textMuted, fontSize: 13),
                            side: BorderSide(color: selected ? AppColors.primaryLight : AppColors.cardBorder),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _customSubject,
                              style: const TextStyle(color: Colors.white, fontSize: 14),
                              decoration: appFieldDecoration('إضافة مادة أخرى', Icons.add),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton.filled(
                            style: IconButton.styleFrom(backgroundColor: AppColors.primary),
                            icon: const Icon(Icons.add),
                            onPressed: () {
                              final v = _customSubject.text.trim();
                              if (v.isNotEmpty) {
                                setState(() {
                                  _subjects.add(v);
                                  _customSubject.clear();
                                });
                              }
                            },
                          ),
                        ],
                      ),
                      if (_subjects.any((s) => !subjectSuggestionsForStage(_stage).contains(s)))
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Wrap(
                            spacing: 8,
                            children: _subjects
                                .where((s) => !subjectSuggestionsForStage(_stage).contains(s))
                                .map((s) => Chip(
                              label: Text(s),
                              backgroundColor: AppColors.primary,
                              labelStyle: const TextStyle(color: Colors.white),
                              onDeleted: () => setState(() => _subjects.remove(s)),
                            ))
                                .toList(),
                          ),
                        ),
                      const SizedBox(height: 24),
                      primaryButton(label: 'إضافة المدرسة', onPressed: _submit, loading: _loading),
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