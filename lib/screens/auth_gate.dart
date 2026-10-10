import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/school.dart';
import '../models/user_role.dart';
import '../theme/app_theme.dart';
import 'placeholders/role_home_placeholders.dart';
import 'role_selection_screen.dart';
import 'school_select_screen.dart';
import 'welcome_screen.dart';

/// نقطة الدخول الرئيسية: تحدد أوتوماتيك فين يوصل المستخدم حسب حالة تسجيله،
/// حتى لو قفل التطبيق في نص التسجيل (بعد إنشاء حساب لكن قبل اختيار مدرسة مثلاً).
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnap) {
        if (authSnap.connectionState == ConnectionState.waiting) {
          return const _Loading();
        }
        final user = authSnap.data;
        if (user == null) return const WelcomeScreen();

        return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          future: FirebaseFirestore.instance.collection('users').doc(user.uid).get(),
          builder: (context, userSnap) {
            if (userSnap.connectionState == ConnectionState.waiting) {
              return const _Loading();
            }
            final data = userSnap.data?.data();
            if (data == null) return const WelcomeScreen();

            final schoolId = data['schoolId'] as String?;
            if (schoolId == null) return const SchoolSelectScreen();

            final roleValue = data['role'] as String?;
            if (roleValue == null) {
              return FutureBuilder<School?>(
                future: FirebaseFirestore.instance
                    .collection('schools')
                    .doc(schoolId)
                    .get()
                    .then((d) => d.exists ? School.fromMap(d.id, d.data()!) : null),
                builder: (context, schoolSnap) {
                  if (!schoolSnap.hasData) return const _Loading();
                  final school = schoolSnap.data;
                  if (school == null) return const SchoolSelectScreen();
                  return RoleSelectionScreen(school: school);
                },
              );
            }

            final role = UserRoleX.fromValue(roleValue);
            switch (role) {
              case UserRole.student:
                return const StudentHomeScreen();
              case UserRole.teacher:
                return const TeacherHomeScreen();
              case UserRole.parent:
                return const ParentHomeScreen();
            }
          },
        );
      },
    );
  }
}

class _Loading extends StatelessWidget {
  const _Loading();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: appBackground,
        child: const Center(child: CircularProgressIndicator(color: AppColors.primaryLight)),
      ),
    );
  }
}