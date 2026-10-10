enum SchoolStage { primary, prep, secondary }

extension SchoolStageX on SchoolStage {
  String get value => name;

  String get label {
    switch (this) {
      case SchoolStage.primary:
        return 'ابتدائي';
      case SchoolStage.prep:
        return 'إعدادي';
      case SchoolStage.secondary:
        return 'ثانوي';
    }
  }

  static SchoolStage fromValue(String v) =>
      SchoolStage.values.firstWhere((e) => e.value == v);
}

/// الصفوف المتاحة لكل مرحلة، تتحدد أوتوماتيك حسب مرحلة المدرسة المختارة
List<String> gradesForStage(SchoolStage stage) {
  switch (stage) {
    case SchoolStage.primary:
      return const [
        'الصف الأول الابتدائي',
        'الصف الثاني الابتدائي',
        'الصف الثالث الابتدائي',
        'الصف الرابع الابتدائي',
        'الصف الخامس الابتدائي',
        'الصف السادس الابتدائي',
      ];
    case SchoolStage.prep:
      return const [
        'الصف الأول الإعدادي',
        'الصف الثاني الإعدادي',
        'الصف الثالث الإعدادي',
      ];
    case SchoolStage.secondary:
      return const [
        'الصف الأول الثانوي',
        'الصف الثاني الثانوي',
        'الصف الثالث الثانوي',
      ];
  }
}

/// مواد مقترحة عند إضافة مدرسة جديدة، يقدر مين ما بيضيف المدرسة يزود عليها
List<String> subjectSuggestionsForStage(SchoolStage stage) {
  switch (stage) {
    case SchoolStage.primary:
      return const ['لغة عربية', 'رياضيات', 'لغة إنجليزية', 'علوم', 'دراسات اجتماعية', 'تربية دينية'];
    case SchoolStage.prep:
      return const ['لغة عربية', 'رياضيات', 'لغة إنجليزية', 'علوم', 'دراسات اجتماعية', 'تربية دينية', 'حاسب آلي'];
    case SchoolStage.secondary:
      return const [
        'لغة عربية', 'لغة إنجليزية', 'رياضيات', 'فيزياء', 'كيمياء', 'أحياء',
        'تاريخ', 'جغرافيا', 'فلسفة ومنطق',
      ];
  }
}

class School {
  final String id;
  final String name;
  final String city;
  final SchoolStage stage;
  final List<String> subjects;

  School({
    required this.id,
    required this.name,
    required this.city,
    required this.stage,
    required this.subjects,
  });

  factory School.fromMap(String id, Map<String, dynamic> map) => School(
    id: id,
    name: map['name'] as String,
    city: map['city'] as String,
    stage: SchoolStageX.fromValue(map['stage'] as String),
    subjects: List<String>.from(map['subjects'] as List),
  );
}