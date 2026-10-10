/// أدوار المستخدمين المتاحة للتسجيل (لا يوجد دور "إدارة" في هذه النسخة)
enum UserRole { student, teacher, parent }

extension UserRoleX on UserRole {
  String get value => name; // يُحفظ في Firestore

  String get label {
    switch (this) {
      case UserRole.student:
        return 'طالب';
      case UserRole.teacher:
        return 'مدرس';
      case UserRole.parent:
        return 'ولي أمر';
    }
  }

  static UserRole fromValue(String v) =>
      UserRole.values.firstWhere((e) => e.value == v);
}