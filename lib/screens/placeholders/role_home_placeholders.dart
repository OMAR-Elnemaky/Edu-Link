import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';

/// واجهات مبدئية فاضية لكل دور، هتتستبدل بشاشات حقيقية بعدين

class StudentHomeScreen extends StatelessWidget {
  const StudentHomeScreen({super.key});
  @override
  Widget build(BuildContext context) => _placeholder('واجهة الطالب');
}

class TeacherHomeScreen extends StatelessWidget {
  const TeacherHomeScreen({super.key});
  @override
  Widget build(BuildContext context) => _placeholder('واجهة المدرس');
}

class ParentHomeScreen extends StatelessWidget {
  const ParentHomeScreen({super.key});
  @override
  Widget build(BuildContext context) => _placeholder('واجهة ولي الأمر');
}

Widget _placeholder(String text) {
  return Scaffold(
    appBar: AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      actions: [
        IconButton(
          icon: const Icon(Icons.logout_rounded, color: Colors.white),
          onPressed: () async => AuthService().signOut(),
        ),
      ],
    ),
    body: Container(
      decoration: appBackground,
      child: Center(
        child: Text(text,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white)),
      ),
    ),
  );
}