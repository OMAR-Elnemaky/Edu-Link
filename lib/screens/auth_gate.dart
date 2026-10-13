import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/school.dart';
import '../models/user_role.dart';
import '../services/school_service.dart';
import '../theme/app_theme.dart';
import 'placeholders/role_home_placeholders.dart';
import 'role_details_screen.dart';
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
          future: FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get()
              .timeout(const Duration(seconds: 3)),
          builder: (context, userSnap) {
            if (userSnap.connectionState == ConnectionState.waiting) {
              return const _Loading();
            }
            if (userSnap.hasError || !userSnap.hasData) {
              return const WelcomeScreen();
            }
            final data = userSnap.data?.data();
            if (data == null) return const WelcomeScreen();

            // Step 1: School Selection
            final schoolId = data['schoolId'] as String?;
            if (schoolId == null) {
              return const SchoolSelectScreen();
            }

            // Fetch school object for subsequent steps
            return FutureBuilder<School?>(
              future: SchoolService().fetchSchool(schoolId),
              builder: (context, schoolSnap) {
                if (schoolSnap.connectionState == ConnectionState.waiting) {
                  return const _Loading();
                }
                final school = schoolSnap.data;
                if (school == null) return const SchoolSelectScreen();

                // Step 2: Role Selection
                final roleValue = data['role'] as String?;
                if (roleValue == null) {
                  return RoleSelectionScreen(school: school);
                }
                final role = UserRoleX.fromValue(roleValue);

                // Step 3: Role Details (Active Status)
                final status = data['status'] as String?;
                if (status == null || status != 'active') {
                  return RoleDetailsScreen(school: school, role: role);
                }

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
