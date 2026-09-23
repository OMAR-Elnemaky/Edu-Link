enum UserRole { student, teacher, parent, admin }

extension UserRoleX on UserRole {
  /// القيمة اللي هتتحفظ في Firestore
  String get value => name;

  String get label {
    switch (this) {
      case UserRole.student:
        return 'طالب';
      case UserRole.teacher:
        return 'مدرس';
      case UserRole.parent:
        return 'ولي أمر';
      case UserRole.admin:
        return 'إدارة';
    }
  }
}