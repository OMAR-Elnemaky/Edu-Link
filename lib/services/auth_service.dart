import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_role.dart';

class AuthException implements Exception {
  final String message;
  AuthException(this.message);
  @override
  String toString() => message;
}

class AuthService {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<void> signOut() async {
    await _auth.signOut();
    try {
      await GoogleSignIn().signOut();
    } catch (_) {}
  }

  // ---------------------------------------------------------------
  // 1) التحقق من البيانات محلياً بدون إنشاء حساب في Firebase
  // ---------------------------------------------------------------
  Future<void> createAccount({
    required String name,
    required int age,
    required String email,
    required String password,
  }) async {
    // لا يوجد تحقق مسبق — سيظهر الخطأ عند finalizeRegistration إن كان الإيميل مستخدم
  }

  // ---------------------------------------------------------------
  // 1b) إنشاء الحساب الفعلي في Firebase بعد اختيار المدرسة
  // ---------------------------------------------------------------
  Future<void> finalizeRegistration({
    required String name,
    required int age,
    required String email,
    required String password,
    required String schoolId,
    required UserRole role,
  }) async {
    User user;
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      user = cred.user!;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_authMessage(e.code));
    }

    try {
      await _db.collection('users').doc(user.uid).set({
        'name': name.trim(),
        'age': age,
        'email': user.email,
        'role': role.value,
        'schoolId': schoolId,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      try { await user.delete(); } catch (_) {}
      throw AuthException('تعذر إنشاء الحساب، حاول مرة أخرى');
    }
  }

  // ---------------------------------------------------------------
  // تسجيل الدخول / التسجيل بحساب Google (نفس الدالة تخدم الحالتين)
  // ---------------------------------------------------------------
  Future<void> signInWithGoogle() async {
    try {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        throw AuthException('تم إلغاء تسجيل الدخول');
      }
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final userCred = await _auth.signInWithCredential(credential);
      final user = userCred.user!;

      final doc = await _db.collection('users').doc(user.uid).get();
      if (!doc.exists) {
        await _db.collection('users').doc(user.uid).set({
          'name': user.displayName ?? '',
          'age': null,
          'email': user.email,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    } on FirebaseAuthException catch (e) {
      throw AuthException(_authMessage(e.code));
    }
  }

  // ---------------------------------------------------------------
  // تسجيل الدخول العادي
  // ---------------------------------------------------------------
  Future<void> signIn({required String email, required String password}) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email.trim(), password: password);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_authMessage(e.code));
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.code == 'user-not-found'
          ? 'لا يوجد حساب بهذا البريد'
          : 'تأكد من صحة البريد الإلكتروني');
    }
  }

  // ---------------------------------------------------------------
  // 2) حفظ الدور واختيار المدرسة
  // ---------------------------------------------------------------
  Future<void> saveRole(UserRole role) async {
    final uid = _requireUid();
    await _db.collection('users').doc(uid).set({
      'role': role.value,
    }, SetOptions(merge: true));
  }

  Future<void> selectSchool(String schoolId) async {
    final uid = _requireUid();
    await _db.collection('users').doc(uid).set({'schoolId': schoolId}, SetOptions(merge: true));
  }

  // ---------------------------------------------------------------
  // 3) استكمال البيانات حسب الدور
  // ---------------------------------------------------------------
  Future<void> completeAsStudent({
    required String schoolId,
    required String grade,
  }) async {
    final uid = _requireUid();
    final code = await _uniqueStudentCode();
    final batch = _db.batch();
    batch.update(_db.collection('users').doc(uid), {
      'role': UserRole.student.value,
      'status': 'active',
      'schoolId': schoolId,
      'grade': grade,
      'linkCode': code,
    });
    batch.set(_db.collection('studentCodes').doc(code), {
      'studentUid': uid,
      'schoolId': schoolId,
    });
    await batch.commit();
  }

  Future<void> completeAsTeacher({
    required String schoolId,
    required String subject,
  }) async {
    final uid = _requireUid();
    await _db.collection('users').doc(uid).update({
      'role': UserRole.teacher.value,
      'status': 'active',
      'schoolId': schoolId,
      'subject': subject,
    });
  }

  Future<void> completeAsParent({
    required String schoolId,
    required String studentCode,
  }) async {
    final uid = _requireUid();
    final code = studentCode.trim().toUpperCase();
    final codeDoc = await _db.collection('studentCodes').doc(code).get();
    if (!codeDoc.exists) {
      throw AuthException('كود الطالب غير صحيح');
    }
    if (codeDoc.data()!['schoolId'] != schoolId) {
      throw AuthException('هذا الكود لا يخص المدرسة المختارة');
    }
    await _db.collection('users').doc(uid).update({
      'role': UserRole.parent.value,
      'status': 'active',
      'schoolId': schoolId,
      'studentCode': code,
      'linkedStudents': [codeDoc.data()!['studentUid']],
    });
  }

  // ---------------------------------------------------------------
  // أدوات مساعدة
  // ---------------------------------------------------------------
  String _requireUid() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw AuthException('يجب تسجيل الدخول أولاً');
    return uid;
  }

  Future<String> _uniqueStudentCode() async {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final rnd = Random.secure();
    for (var i = 0; i < 5; i++) {
      final code = List.generate(6, (_) => chars[rnd.nextInt(chars.length)]).join();
      final exists = (await _db.collection('studentCodes').doc(code).get()).exists;
      if (!exists) return code;
    }
    throw AuthException('تعذر إنشاء كود الطالب، حاول مرة أخرى');
  }

  String _authMessage(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'هذا البريد مسجل بالفعل';
      case 'invalid-email':
        return 'البريد الإلكتروني غير صحيح';
      case 'weak-password':
        return 'كلمة المرور ضعيفة (6 أحرف على الأقل)';
      case 'network-request-failed':
        return 'تأكد من اتصالك بالإنترنت';
      case 'account-exists-with-different-credential':
        return 'هذا البريد مسجل بطريقة تسجيل دخول مختلفة';
      default:
        return 'حدث خطأ ($code)';
    }
  }
}