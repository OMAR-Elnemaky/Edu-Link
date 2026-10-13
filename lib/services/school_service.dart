import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/school.dart';

final List<School> defaultAppliedSchools = [
  School(
    id: 'we_tech',
    name: 'مدرسة WE للتكنولوجيا التطبيقية',
    englishName: 'WE Applied Technology School',
    city: 'القاهرة والجيزة وفروع المحافظات',
    stage: SchoolStage.secondary,
    subjects: ['اتصالات', 'شبكات', 'برمجيات', 'ذكاء اصطناعي'],
    partner: 'الشركة المصرية للاتصالات',
    description: 'تخصصات في الاتصالات والشبكات والبرمجيات والذكاء الاصطناعي.',
    specialties: ['الاتصالات', 'شبكات وأمن المعلومات', 'تطوير المواقع والبرمجيات', 'تحليل البيانات والذكاء الاصطناعي'],
    durationYears: 3,
    studySystem: 'الدراسة باللغة الإنجليزية',
    categories: ['البرمجة والتكنولوجيا'],
  ),
  School(
    id: 'elaraby_tech',
    name: 'مدرسة العربي للتكنولوجيا التطبيقية',
    englishName: 'ELARABY Applied Technology School',
    city: 'المنوفية',
    stage: SchoolStage.secondary,
    subjects: ['تبريد وتكييف', 'تركيبات كهربائية', 'ميكانيكا', 'لوجستيات'],
    partner: 'مجموعة شركات العربي',
    description: 'تخصصات صناعية تجمع بين الميكانيكا والكهرباء والتبريد واللوجستيات.',
    specialties: ['التبريد والتكييف', 'التركيبات الكهربائية', 'الميكانيكا', 'اللوجستيات'],
    durationYears: 3,
    studySystem: 'تدريب عملي مرتبط بالمجالات الصناعية',
    categories: ['الصناعة والطاقة', 'الكهرباء والإلكترونيات', 'الميكانيكا والسيارات', 'التجارة واللوجستيات'],
  ),
  School(
    id: 'elsewedy_tech',
    name: 'مدرسة السويدي للتكنولوجيا التطبيقية',
    englishName: 'STA - Elsewedy Technical Academy',
    city: 'الشرقية',
    stage: SchoolStage.secondary,
    subjects: ['إلكترونيات صناعية', 'كابلات ومحولات', 'ميكانيكا', 'تركيبات'],
    partner: 'السويدي إلكتريك',
    description: 'مسارات في الكهرباء والطاقة والتصنيع الكهربائي.',
    specialties: ['الإلكترونيات الصناعية', 'الكابلات والمحولات ومكونات الطاقة', 'الميكانيكا', 'التركيبات'],
    durationYears: 3,
    studySystem: 'تدريب عملي مرتبط بالصناعة',
    categories: ['الكهرباء والإلكترونيات', 'الصناعة والطاقة', 'الميكانيكا والسيارات'],
  ),
  School(
    id: 'military_prod_tech',
    name: 'مدرسة الإنتاج الحربي للتكنولوجيا التطبيقية',
    englishName: 'Military Production School',
    city: 'حلوان والسلام',
    stage: SchoolStage.secondary,
    subjects: ['ميكاترونكس', 'إلكترونيات', 'برمجيات', 'تشغيل معادن'],
    partner: 'وزارة الإنتاج الحربي',
    description: 'تخصصات تجمع بين التكنولوجيا والتصنيع والإلكترونيات.',
    specialties: ['الميكاترونكس', 'الإلكترونيات', 'البرمجيات', 'تشغيل المعادن', 'تكنولوجيا الحاسب'],
    durationYears: 3,
    studySystem: 'تعليم وتدريب مزدوج وتطبيقي',
    categories: ['الصناعة والطاقة', 'الكهرباء والإلكترونيات', 'البرمجة والتكنولوجيا'],
  ),
  School(
    id: 'ghabbour_tech',
    name: 'مدرسة غبور للتكنولوجيا التطبيقية',
    englishName: 'Ghabbour Applied Technology School',
    city: 'القليوبية والفيوم',
    stage: SchoolStage.secondary,
    subjects: ['صيانة سيارات الركوب', 'دهان وهياكل', 'معدات ثقيلة', 'ميكاترونكس سيارات'],
    partner: 'مؤسسة غبور للتنمية',
    description: 'تدريب تقني في صيانة المركبات والمعدات الثقيلة.',
    specialties: ['صيانة سيارات الركوب', 'دهان وهياكل السيارات', 'صيانة المعدات الثقيلة', 'ميكاترونكس السيارات'],
    durationYears: 3,
    studySystem: 'تدريب تقني ومعايير دولية',
    categories: ['الميكانيكا والسيارات'],
  ),
  School(
    id: 'volkswagen_tech',
    name: 'مدرسة فولكس فاجن للتكنولوجيا التطبيقية',
    englishName: 'Volkswagen Applied Technology School',
    city: 'حي الأسمرات - القاهرة',
    stage: SchoolStage.secondary,
    subjects: ['صيانة سيارات حديثة', 'ميكانيكا سيارات', 'كهرباء سيارات', 'تشخيص إلكتروني'],
    partner: 'مجموعة فولكس فاجن للسيارات',
    description: 'تخصصات تقنية مرتبطة بصيانة السيارات الحديثة وتشخيص أعطالها.',
    specialties: ['إصلاح وصيانة السيارات الحديثة', 'ميكانيكا السيارات', 'كهرباء السيارات', 'التشخيص الإلكتروني'],
    durationYears: 3,
    studySystem: 'تأهيل على أحدث تكنولوجيا السيارات',
    categories: ['الميكانيكا والسيارات', 'الكهرباء والإلكترونيات'],
  ),
  School(
    id: 'egypt_gold_tech',
    name: 'مدرسة إيجيبت جولد للتكنولوجيا التطبيقية',
    englishName: 'Egypt Gold Applied Technology School',
    city: 'مدينة العبور - القليوبية',
    stage: SchoolStage.secondary,
    subjects: ['صناعة الحلي والمجوهرات', 'تصميم', 'صياغة', 'تشكيل معادن'],
    partner: 'مجموعة إيجيبت جولد للمجوهرات',
    description: 'مسار متخصص في تصميم وصناعة الحلي والمجوهرات.',
    specialties: ['صناعة الحلي والمجوهرات', 'التصميم', 'الصياغة', 'تشكيل المعادن النفيسة'],
    durationYears: 3,
    studySystem: 'تدريب عملي في ورش ومصانع المجوهرات',
    categories: ['التصميم والحرف'],
  ),
  School(
    id: 'hst_tech',
    name: 'مدرسة HST للتكنولوجيا التطبيقية',
    englishName: 'HST Applied Technology School',
    city: 'مصر الجديدة - القاهرة',
    stage: SchoolStage.secondary,
    subjects: ['ذكاء اصطناعي', 'أنظمة مراقبة وأنذار', 'ألعاب رقمية', 'فنون رقمية'],
    partner: 'شركة HST للأنظمة الأمنية والتقنيات الذكية',
    description: 'تخصصات في الذكاء الاصطناعي والتقنيات الذكية والمجالات الرقمية.',
    specialties: ['الذكاء الاصطناعي', 'أنظمة المراقبة والإنذار', 'الألعاب الرقمية', 'الفنون الرقمية'],
    durationYears: 3,
    studySystem: 'تخصصات تكنولوجية ورقمية حديثة',
    categories: ['البرمجة والتكنولوجيا', 'التصميم والحرف'],
  ),
  School(
    id: 'btech_tech',
    name: 'مدرسة بي تك (B.TECH) للتكنولوجيا التطبيقية',
    englishName: 'B.TECH Applied Technology School',
    city: 'المقطم - القاهرة',
    stage: SchoolStage.secondary,
    subjects: ['تجارة التجزئة', 'إدارة اللوجستيات', 'سلاسل الإمداد', 'تسويق ومبيعات'],
    partner: 'شركة بي تك للأجهزة الإلكترونية',
    description: 'تعليم تطبيقي في التجارة والمبيعات وإدارة العمليات وسلاسل الإمداد.',
    specialties: ['تجارة التجزئة', 'إدارة اللوجستيات', 'سلاسل الإمداد', 'التسويق والمبيعات'],
    durationYears: 3,
    studySystem: 'تعليم تطبيقي في قطاع التجزئة والمبيعات',
    categories: ['التجارة واللوجستيات'],
  ),
  School(
    id: 'eva_tech',
    name: 'مدرسة إيفا الدولية للتكنولوجيا التطبيقية',
    englishName: 'EVA International Applied Technology School',
    city: '6 أكتوبر - الجيزة',
    stage: SchoolStage.secondary,
    subjects: ['صناعات دوائية وغذائية', 'تطوير برمجيات', 'تكنولوجيا المعلومات'],
    partner: 'إيفا فارما (EVA Pharma)',
    description: 'تخصصات تقنية مرتبطة بالإنتاج والصيانة وتكنولوجيا المعلومات.',
    specialties: ['تشغيل وصيانة معدات الصناعات الدوائية والغذائية', 'تطوير البرمجيات', 'تكنولوجيا المعلومات'],
    durationYears: 3,
    studySystem: 'تأهيل للعمل في الصناعات الدوائية والتكنولوجية',
    categories: ['الصناعة والطاقة', 'البرمجة والتكنولوجيا'],
  ),
  School(
    id: 'dabaa_nuclear_tech',
    name: 'مدرسة الضبعة الفنية المتقدمة لتكنولوجيا الطاقة النووية',
    englishName: 'Dabaa Nuclear Technology School',
    city: 'الضبعة - مطروح',
    stage: SchoolStage.secondary,
    subjects: ['ميكانيكا نووية', 'كهرباء نووية', 'إلكترونيات نووية'],
    partner: 'وزارة التربية والتعليم وهيئة المحطات النووية لتوليد الكهرباء',
    description: 'تعليم فني متخصص في تكنولوجيا الطاقة النووية السلمية.',
    specialties: ['الميكانيكا النووية', 'الكهرباء النووية', 'الإلكترونيات النووية'],
    durationYears: 5,
    studySystem: 'إقامة داخلية بمطروح وتخصص متقدم',
    categories: ['الصناعة والطاقة', 'الكهرباء والإلكترونيات', 'المجالات المتخصصة'],
  ),
  School(
    id: 'banque_misr_tech',
    name: 'مدرسة بنك مصر للتكنولوجيا التطبيقية',
    englishName: 'Banque Misr Applied Technology School',
    city: 'القاهرة والجيزة',
    stage: SchoolStage.secondary,
    subjects: ['صناعات دوائية', 'مواد البناء', 'رخام وجرانيت'],
    partner: 'بنك مصر بالتعاون مع اتحاد الصناعات المصرية',
    description: 'مسارات فنية مرتبطة باحتياجات بعض القطاعات الصناعية.',
    specialties: ['الصناعات الدوائية', 'مواد البناء', 'الرخام والجرانيت'],
    durationYears: 3,
    studySystem: 'تدريب فني مرتبط بقطاعات صناعية حيوية',
    categories: ['الصناعة والطاقة', 'المجالات المتخصصة'],
  ),
];

class SchoolService {
  final _db = FirebaseFirestore.instance;

  Future<List<School>> fetchSchools() async {
    List<School> firestoreSchools = [];
    try {
      final snap = await _db
          .collection('schools')
          .orderBy('name')
          .get()
          .timeout(const Duration(seconds: 3));
      firestoreSchools = snap.docs.map((d) => School.fromMap(d.id, d.data())).toList();
    } catch (_) {
      // Gracefully handle timeout or offline mode
    }

    final Map<String, School> merged = {};
    for (final school in defaultAppliedSchools) {
      merged[school.id] = school;
    }
    for (final school in firestoreSchools) {
      merged[school.id] = school;
    }

    return merged.values.toList();
  }

  Future<School?> fetchSchool(String schoolId) async {
    try {
      final doc = await _db
          .collection('schools')
          .doc(schoolId)
          .get()
          .timeout(const Duration(seconds: 3));
      if (doc.exists) {
        return School.fromMap(doc.id, doc.data()!);
      }
    } catch (_) {}

    try {
      return defaultAppliedSchools.firstWhere((s) => s.id == schoolId);
    } catch (_) {
      return null;
    }
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