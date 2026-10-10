import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/school.dart';

class SchoolService {
  final _db = FirebaseFirestore.instance;

  Future<List<School>> fetchSchools() async {
    final snap = await _db.collection('schools').orderBy('name').get();
    return snap.docs.map((d) => School.fromMap(d.id, d.data())).toList();
  }

  Future<School?> fetchSchool(String schoolId) async {
    final doc = await _db.collection('schools').doc(schoolId).get();
    if (!doc.exists) return null;
    return School.fromMap(doc.id, doc.data()!);
  }

  /// أي مستخدم مسجّل دخول يقدر يضيف مدرسة (مثلاً مدرس مدرسته لسه مش موجودة)
  Future<String> addSchool({
    required String name,
    required String city,
    required SchoolStage stage,
    required List<String> subjects,
    required String createdByUid,
  }) async {
    final ref = await _db.collection('schools').add({
      'name': name.trim(),
      'city': city.trim(),
      'stage': stage.value,
      'subjects': subjects,
      'createdBy': createdByUid,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return ref.id;
  }
}