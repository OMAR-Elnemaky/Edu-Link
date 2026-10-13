import 'package:flutter/material.dart';
import '../models/registration_data.dart';
import '../models/school.dart';
import '../models/user_role.dart';
import '../services/auth_service.dart';
import '../services/school_service.dart';
import '../theme/app_theme.dart';
import 'add_school_screen.dart';
import 'role_selection_screen.dart';

class SchoolSelectScreen extends StatefulWidget {
  final RegistrationData? registrationData;
  const SchoolSelectScreen({super.key, this.registrationData});

  @override
  State<SchoolSelectScreen> createState() => _SchoolSelectScreenState();
}

class _SchoolSelectScreenState extends State<SchoolSelectScreen> {
  late Future<List<School>> _future;
  bool _loading = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'الكل';

  static const List<String> _categories = [
    'الكل',
    'البرمجة والتكنولوجيا',
    'الكهرباء والإلكترونيات',
    'الميكانيكا والسيارات',
    'الصناعة والطاقة',
    'التجارة واللوجستيات',
    'التصميم والحرف',
    'المجالات المتخصصة',
  ];

  @override
  void initState() {
    super.initState();
    _future = SchoolService().fetchSchools();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _reload() {
    setState(() => _future = SchoolService().fetchSchools());
  }

  String _normalizeArabic(String text) {
    return text
        .replaceAll(RegExp(r'[أإآآ]'), 'ا')
        .replaceAll('ة', 'ه')
        .replaceAll('ى', 'ي')
        .replaceAll(RegExp(r'[\u064B-\u0652]'), '')
        .toLowerCase();
  }

  List<School> _filterSchools(List<School> all) {
    final queryNorm = _normalizeArabic(_searchQuery);

    return all.where((s) {
      // 1. Category Filter
      if (_selectedCategory != 'الكل') {
        final matchesCat = s.categories.contains(_selectedCategory) ||
            _matchesCategoryFallback(s, _selectedCategory);
        if (!matchesCat) return false;
      }

      // 2. Search Filter
      if (queryNorm.isEmpty) return true;

      final nameNorm = _normalizeArabic(s.name);
      final engNorm = _normalizeArabic(s.englishName ?? '');
      final partnerNorm = _normalizeArabic(s.partner ?? '');
      final descNorm = _normalizeArabic(s.description ?? '');
      final cityNorm = _normalizeArabic(s.city);
      final specialtiesNorm = s.specialties.map(_normalizeArabic).join(' ');
      final subjectsNorm = s.subjects.map(_normalizeArabic).join(' ');

      return nameNorm.contains(queryNorm) ||
          engNorm.contains(queryNorm) ||
          partnerNorm.contains(queryNorm) ||
          descNorm.contains(queryNorm) ||
          cityNorm.contains(queryNorm) ||
          specialtiesNorm.contains(queryNorm) ||
          subjectsNorm.contains(queryNorm);
    }).toList();
  }

  bool _matchesCategoryFallback(School s, String category) {
    switch (category) {
      case 'البرمجة والتكنولوجيا':
        return s.subjects.any((sub) => sub.contains('برمجيات') || sub.contains('ذكاء') || sub.contains('حاسب') || sub.contains('تقن')) ||
               s.specialties.any((sp) => sp.contains('برمجة') || sp.contains('ذكاء') || sp.contains('تطوير'));
      case 'الكهرباء والإلكترونيات':
        return s.subjects.any((sub) => sub.contains('كهرباء') || sub.contains('إلكترون') || sub.contains('كابلات')) ||
               s.specialties.any((sp) => sp.contains('كهرباء') || sp.contains('إلكترونيات'));
      case 'الميكانيكا والسيارات':
        return s.subjects.any((sub) => sub.contains('ميكانيك') || sub.contains('سيارات') || sub.contains('معدات')) ||
               s.specialties.any((sp) => sp.contains('ميكانيكا') || sp.contains('سيارات'));
      case 'الصناعة والطاقة':
        return s.subjects.any((sub) => sub.contains('طاقة') || sub.contains('نووي') || sub.contains('صناع')) ||
               s.specialties.any((sp) => sp.contains('طاقة') || sp.contains('صناعة'));
      case 'التجارة واللوجستيات':
        return s.subjects.any((sub) => sub.contains('تجارة') || sub.contains('تسويق') || sub.contains('لوجست')) ||
               s.specialties.any((sp) => sp.contains('تجارة') || sp.contains('لوجستيات'));
      case 'التصميم والحرف':
        return s.subjects.any((sub) => sub.contains('تصميم') || sub.contains('حلي') || sub.contains('مجوهرات')) ||
               s.specialties.any((sp) => sp.contains('تصميم') || sp.contains('صناعة الحلي'));
      case 'المجالات المتخصصة':
        return s.subjects.any((sub) => sub.contains('رخام') || sub.contains('بناء') || sub.contains('دوائي')) ||
               s.specialties.any((sp) => sp.contains('دوائية') || sp.contains('رخام'));
      default:
        return false;
    }
  }

  void _showSchoolDetails(School school) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (context) => _SchoolDetailsSheet(
        school: school,
        loading: _loading,
        onConfirmSelect: () {
          Navigator.pop(context);
          _choose(school);
        },
      ),
    );
  }

  Future<void> _choose(School school) async {
    setState(() => _loading = true);
    try {
      final reg = widget.registrationData;
      if (reg != null) {
        // flow إنشاء حساب جديد — التسجيل الفعلي هنا
        await AuthService().finalizeRegistration(
          name: reg.name,
          age: reg.age,
          email: reg.email,
          password: reg.password,
          schoolId: school.id,
          role: reg.role ?? UserRole.student,
        );
      } else {
        // flow تسجيل دخول — حفظ المدرسة فقط
        await AuthService().selectSchool(school.id);
      }
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => RoleSelectionScreen(school: school),
        ),
      );
    } on AuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _openAddSchool() async {
    final created = await Navigator.push<School>(
      context,
      MaterialPageRoute(builder: (_) => const AddSchoolScreen()),
    );
    if (created != null) {
      _reload();
      if (mounted) _choose(created);
    }
  }

  void _resetSearchAndFilters() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
      _selectedCategory = 'الكل';
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isDark ? AppColors.bgTop : const Color(0xFFF8FAFC);
    final cardColor = isDark ? AppColors.card : Colors.white;
    final borderColor = isDark ? AppColors.cardBorder : const Color(0xFFE2E8F0);
    final titleColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final mutedColor = isDark ? AppColors.textMuted : const Color(0xFF64748B);
    final primaryColor = isDark ? AppColors.primaryLight : AppColors.primary;

    return Scaffold(
      backgroundColor: bgColor,
      body: Container(
        decoration: isDark ? appBackground : null,
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth >= 640;
                    return Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1000),
                        child: CustomScrollView(
                          physics: const BouncingScrollPhysics(),
                          slivers: [
                            // 1. Header
                            SliverToBoxAdapter(
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (Navigator.canPop(context))
                                      appBackButton(context),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'اختر مدرستك',
                                          style: TextStyle(
                                            fontSize: 26,
                                            fontWeight: FontWeight.w800,
                                            color: titleColor,
                                            height: 1.2,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'اكتشف مدارس التكنولوجيا التطبيقية وتخصصاتها',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: mutedColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // 2. Search Bar
                            SliverToBoxAdapter(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: cardColor,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: borderColor, width: 1.2),
                                    boxShadow: isDark
                                        ? null
                                        : [
                                            BoxShadow(
                                              color: Colors.black.withValues(alpha: 0.04),
                                              blurRadius: 10,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                  ),
                                  child: TextField(
                                    controller: _searchController,
                                    style: TextStyle(color: titleColor, fontSize: 15),
                                    decoration: InputDecoration(
                                      hintText: 'ابحث عن مدرسة أو تخصص...',
                                      hintStyle: TextStyle(color: mutedColor, fontSize: 14),
                                      prefixIcon: Icon(Icons.search_rounded, color: primaryColor),
                                      suffixIcon: _searchQuery.isNotEmpty
                                          ? IconButton(
                                              icon: Icon(Icons.cancel_rounded, color: mutedColor, size: 20),
                                              onPressed: () => _searchController.clear(),
                                            )
                                          : null,
                                      border: InputBorder.none,
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            // 3. Category Filter Chips
                            SliverToBoxAdapter(
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                physics: const BouncingScrollPhysics(),
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                child: Row(
                                  children: _categories.map((cat) {
                                    final selected = _selectedCategory == cat;
                                    return Padding(
                                      padding: const EdgeInsets.only(left: 8),
                                      child: ChoiceChip(
                                        label: Text(cat),
                                        selected: selected,
                                        onSelected: (_) {
                                          setState(() => _selectedCategory = cat);
                                        },
                                        selectedColor: AppColors.primary,
                                        backgroundColor: cardColor,
                                        labelStyle: TextStyle(
                                          color: selected
                                              ? Colors.white
                                              : (isDark ? AppColors.textMuted : const Color(0xFF334155)),
                                          fontSize: 13,
                                          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                                        ),
                                        side: BorderSide(
                                          color: selected ? AppColors.primary : borderColor,
                                          width: selected ? 1.5 : 1,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),

                            const SliverToBoxAdapter(child: SizedBox(height: 8)),

                            // 4. Main Schools List / Grid
                            FutureBuilder<List<School>>(
                              future: _future,
                              builder: (context, snap) {
                                if (snap.connectionState != ConnectionState.done) {
                                  return SliverFillRemaining(
                                    hasScrollBody: false,
                                    child: Center(
                                      child: CircularProgressIndicator(color: primaryColor),
                                    ),
                                  );
                                }

                                final allSchools = snap.data ?? [];
                                final filtered = _filterSchools(allSchools);

                                if (filtered.isEmpty) {
                                  return SliverFillRemaining(
                                    hasScrollBody: false,
                                    child: _EmptyStateWidget(
                                      isDark: isDark,
                                      titleColor: titleColor,
                                      mutedColor: mutedColor,
                                      primaryColor: primaryColor,
                                      onReset: _resetSearchAndFilters,
                                    ),
                                  );
                                }

                                return SliverPadding(
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                  sliver: isWide
                                      ? SliverGrid(
                                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 2,
                                            mainAxisSpacing: 14,
                                            crossAxisSpacing: 14,
                                            mainAxisExtent: 260,
                                          ),
                                          delegate: SliverChildBuilderDelegate(
                                            (context, i) => _SchoolCard(
                                              school: filtered[i],
                                              loading: _loading,
                                              onSelect: () => _showSchoolDetails(filtered[i]),
                                              isDark: isDark,
                                            ),
                                            childCount: filtered.length,
                                          ),
                                        )
                                      : SliverList(
                                          delegate: SliverChildBuilderDelegate(
                                            (context, i) {
                                              return Padding(
                                                padding: const EdgeInsets.only(bottom: 14),
                                                child: _SchoolCard(
                                                  school: filtered[i],
                                                  loading: _loading,
                                                  onSelect: () => _showSchoolDetails(filtered[i]),
                                                  isDark: isDark,
                                                ),
                                              );
                                            },
                                            childCount: filtered.length,
                                          ),
                                        ),
                                );
                              },
                            ),

                            const SliverToBoxAdapter(child: SizedBox(height: 12)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Bottom pinned button
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1000),
                  child: outlinedButtonWidget(
                    label: 'إضافة مدرسة جديدة',
                    icon: Icons.add_circle_outline_rounded,
                    onPressed: _loading ? null : _openAddSchool,
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

class _EmptyStateWidget extends StatelessWidget {
  final bool isDark;
  final Color titleColor;
  final Color mutedColor;
  final Color primaryColor;
  final VoidCallback onReset;

  const _EmptyStateWidget({
    required this.isDark,
    required this.titleColor,
    required this.mutedColor,
    required this.primaryColor,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? AppColors.card : Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark ? AppColors.cardBorder : const Color(0xFFE2E8F0),
                ),
              ),
              child: Icon(Icons.search_off_rounded, size: 48, color: primaryColor),
            ),
            const SizedBox(height: 16),
            Text(
              'مفيش مدارس مطابقة للبحث',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: titleColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'جرّب اسم مدرسة تانية أو غيّر التخصص المحدد.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: mutedColor,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            TextButton.icon(
              onPressed: onReset,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('مسح البحث وإعادة الضبط'),
              style: TextButton.styleFrom(
                foregroundColor: primaryColor,
                textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SchoolCard extends StatelessWidget {
  final School school;
  final bool loading;
  final VoidCallback onSelect;
  final bool isDark;

  const _SchoolCard({
    required this.school,
    required this.loading,
    required this.onSelect,
    required this.isDark,
  });

  IconData _getIcon(School s) {
    if (s.id.contains('we') || s.id.contains('hst')) return Icons.developer_board_rounded;
    if (s.id.contains('ghabbour') || s.id.contains('volkswagen')) return Icons.directions_car_rounded;
    if (s.id.contains('elsewedy') || s.id.contains('elaraby')) return Icons.bolt_rounded;
    if (s.id.contains('military')) return Icons.precision_manufacturing_rounded;
    if (s.id.contains('gold')) return Icons.auto_awesome_rounded;
    if (s.id.contains('btech')) return Icons.shopping_bag_rounded;
    if (s.id.contains('eva')) return Icons.medication_liquid_rounded;
    if (s.id.contains('nuclear') || s.id.contains('dabaa')) return Icons.science_rounded;
    if (s.id.contains('banque') || s.id.contains('misr')) return Icons.account_balance_rounded;
    return Icons.school_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final cardColor = isDark ? AppColors.card : Colors.white;
    final borderColor = isDark ? AppColors.cardBorder : const Color(0xFFE2E8F0);
    final titleColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final mutedColor = isDark ? AppColors.textMuted : const Color(0xFF64748B);
    final secondaryTextColor = isDark ? AppColors.textSecondary : const Color(0xFF334155);
    final primaryColor = isDark ? AppColors.primaryLight : AppColors.primary;

    final displaySpecialties = school.specialties.isNotEmpty
        ? school.specialties
        : school.subjects;

    return Material(
      color: cardColor,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: loading ? null : onSelect,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: borderColor, width: 1.2),
            boxShadow: isDark
                ? null
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row: Avatar + Title & English Name
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Logo / Avatar Badge
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: primaryColor.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Center(
                      child: school.logoAssetPath != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.asset(
                                school.logoAssetPath!,
                                width: 32,
                                height: 32,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) => Icon(
                                  _getIcon(school),
                                  color: primaryColor,
                                  size: 26,
                                ),
                              ),
                            )
                          : Icon(
                              _getIcon(school),
                              color: primaryColor,
                              size: 26,
                            ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          school.name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: titleColor,
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (school.englishName != null && school.englishName!.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            school.englishName!,
                            style: TextStyle(
                              fontSize: 12,
                              color: mutedColor,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // Partner Row
              if (school.partner != null && school.partner!.isNotEmpty) ...[
                Row(
                  children: [
                    Icon(Icons.handshake_outlined, size: 15, color: primaryColor),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'الشريك: ${school.partner!}',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: secondaryTextColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],

              // Description or Specialties preview
              if (school.description != null && school.description!.isNotEmpty) ...[
                Text(
                  school.description!,
                  style: TextStyle(
                    fontSize: 12.5,
                    color: mutedColor,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10),
              ],

              // Specialties Chips / Tags
              if (displaySpecialties.isNotEmpty) ...[
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: displaySpecialties.take(3).map((spec) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.06)
                            : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.1)
                              : const Color(0xFFE2E8F0),
                        ),
                      ),
                      child: Text(
                        spec,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: secondaryTextColor,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
              ],

              Divider(height: 16, thickness: 1, color: borderColor.withValues(alpha: 0.6)),

              // Bottom Badges & Details Indicator
              Row(
                children: [
                  // Location pill
                  Icon(Icons.location_on_outlined, size: 14, color: mutedColor),
                  const SizedBox(width: 3),
                  Expanded(
                    child: Text(
                      school.city,
                      style: TextStyle(fontSize: 11.5, color: mutedColor),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  // Duration pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.schedule_rounded, size: 12, color: primaryColor),
                        const SizedBox(width: 4),
                        Text(
                          '${school.durationYears} سنوات',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Tap for Details Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'التفاصيل',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: primaryColor,
                          ),
                        ),
                        const SizedBox(width: 3),
                        Icon(
                          Icons.info_outline_rounded,
                          size: 13,
                          color: primaryColor,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SchoolDetailsSheet extends StatelessWidget {
  final School school;
  final bool loading;
  final VoidCallback onConfirmSelect;

  const _SchoolDetailsSheet({
    required this.school,
    required this.loading,
    required this.onConfirmSelect,
  });

  IconData _getIcon(School s) {
    if (s.id.contains('we') || s.id.contains('hst')) return Icons.developer_board_rounded;
    if (s.id.contains('ghabbour') || s.id.contains('volkswagen')) return Icons.directions_car_rounded;
    if (s.id.contains('elsewedy') || s.id.contains('elaraby')) return Icons.bolt_rounded;
    if (s.id.contains('military')) return Icons.precision_manufacturing_rounded;
    if (s.id.contains('gold')) return Icons.auto_awesome_rounded;
    if (s.id.contains('btech')) return Icons.shopping_bag_rounded;
    if (s.id.contains('eva')) return Icons.medication_liquid_rounded;
    if (s.id.contains('nuclear') || s.id.contains('dabaa')) return Icons.science_rounded;
    if (s.id.contains('banque') || s.id.contains('misr')) return Icons.account_balance_rounded;
    return Icons.school_rounded;
  }

  String _getCareerOutlook(School s) {
    if (s.careerOutlook != null && s.careerOutlook!.isNotEmpty) {
      return s.careerOutlook!;
    }
    if (s.id.contains('we')) return 'فني اتصالات وبنية تحتية، تقني شبكات وأمن معلومات، مطور برمجيات ومواقع.';
    if (s.id.contains('elaraby')) return 'فني صيانة تكييف وتبريد، فني تركيبات كهربائية، تقني ميكانيكا ولوجستيات.';
    if (s.id.contains('elsewedy')) return 'فني إلكترونيات صناعية، تقني كابلات ومحولات طاقة، صيانة معدات خطوط إنتاج.';
    if (s.id.contains('military')) return 'فني ميكاترونكس وإلكترونيات، تقني تشغيل معادن وبرمجة آلات CNC.';
    if (s.id.contains('ghabbour')) return 'فني صيانة مركبات ومعدات ثقيلة، تقني ميكاترونكس ودهان سيارات معتمد.';
    if (s.id.contains('volkswagen')) return 'فني تشخيص إلكتروني وصيانة سيارات حديثة، تقني كهرباء وميكانيكا مركبات.';
    if (s.id.contains('gold')) return 'مصمم حلي ومجوهرات معتمد، صائغ وتقني تشكيل معادن نفيسة.';
    if (s.id.contains('hst')) return 'تقني ذكاء اصطناعي وأنظمة مراقبة أمنية، مطور ألعاب رقمية وفنون تفاعلية.';
    if (s.id.contains('btech')) return 'إخصائي مبيعات وتجارة تجزئة، تقني إدارة لوجستيات وسلاسل إمداد.';
    if (s.id.contains('eva')) return 'فني تشغيل وصيانة خطوط إنتاج دوائية وغذائية، تقني تكنولوجيا معلومات.';
    if (s.id.contains('nuclear') || s.id.contains('dabaa')) return 'فني متخصص في الكهرباء والميكانيكا والإلكترونيات للمحطات النووية.';
    if (s.id.contains('banque') || s.id.contains('misr')) return 'فني في الصناعات الدوائية، وتصنيع مواد البناء والرخام والجرانيت.';
    return 'فرص عمل متخصصة في المجال التقني والتطبيقي المرتبط بالمدرسة.';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.card : Colors.white;
    final borderColor = isDark ? AppColors.cardBorder : const Color(0xFFE2E8F0);
    final titleColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final mutedColor = isDark ? AppColors.textMuted : const Color(0xFF64748B);
    final secondaryTextColor = isDark ? AppColors.textSecondary : const Color(0xFF334155);
    final primaryColor = isDark ? AppColors.primaryLight : AppColors.primary;

    final displaySpecialties = school.specialties.isNotEmpty
        ? school.specialties
        : school.subjects;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(color: borderColor, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.1),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4.5,
            decoration: BoxDecoration(
              color: mutedColor.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(height: 12),

          // Content Area
          Flexible(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Header: Avatar + Title + Close Button
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: primaryColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: primaryColor.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            _getIcon(school),
                            color: primaryColor,
                            size: 32,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              school.name,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: titleColor,
                                height: 1.3,
                              ),
                            ),
                            if (school.englishName != null && school.englishName!.isNotEmpty) ...[
                              const SizedBox(height: 3),
                              Text(
                                school.englishName!,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: mutedColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.close_rounded, color: mutedColor),
                        tooltip: 'إغلاق',
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Key Specs Grid / Badges
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      if (school.partner != null && school.partner!.isNotEmpty)
                        _specChip(
                          icon: Icons.handshake_outlined,
                          label: 'الشريك: ${school.partner}',
                          isDark: isDark,
                          primaryColor: primaryColor,
                          secondaryTextColor: secondaryTextColor,
                        ),
                      _specChip(
                        icon: Icons.schedule_rounded,
                        label: 'مدة الدراسة: ${school.durationYears} سنوات',
                        isDark: isDark,
                        primaryColor: primaryColor,
                        secondaryTextColor: secondaryTextColor,
                      ),
                      _specChip(
                        icon: Icons.location_on_outlined,
                        label: 'الموقع: ${school.city}',
                        isDark: isDark,
                        primaryColor: primaryColor,
                        secondaryTextColor: secondaryTextColor,
                      ),
                      if (school.studySystem != null && school.studySystem!.isNotEmpty)
                        _specChip(
                          icon: Icons.menu_book_outlined,
                          label: school.studySystem!,
                          isDark: isDark,
                          primaryColor: primaryColor,
                          secondaryTextColor: secondaryTextColor,
                        ),
                    ],
                  ),

                  const SizedBox(height: 20),
                  Divider(color: borderColor.withValues(alpha: 0.6)),
                  const SizedBox(height: 16),

                  // About Section
                  if (school.description != null && school.description!.isNotEmpty) ...[
                    Text(
                      'عن المدرسة والبرنامج',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: titleColor,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      school.description!,
                      style: TextStyle(
                        fontSize: 13.5,
                        color: secondaryTextColor,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Specialties Section
                  if (displaySpecialties.isNotEmpty) ...[
                    Text(
                      'التخصصات والمسارات الدراسية',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: titleColor,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: displaySpecialties.map((spec) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                          decoration: BoxDecoration(
                            color: primaryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: primaryColor.withValues(alpha: 0.25),
                            ),
                          ),
                          child: Text(
                            spec,
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: primaryColor,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Future Career Outlook Box
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.04)
                          : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.08)
                            : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.work_outline_rounded, size: 18, color: primaryColor),
                            const SizedBox(width: 8),
                            Text(
                              'مجالات العمل والفرص المستقبلية',
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                                color: titleColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _getCareerOutlook(school),
                          style: TextStyle(
                            fontSize: 12.5,
                            color: mutedColor,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // Bottom Fixed Select Button
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: primaryButton(
              label: 'اختيار هذه المدرسة والمتابعة',
              icon: Icons.check_circle_outline_rounded,
              onPressed: loading ? null : onConfirmSelect,
              loading: loading,
            ),
          ),
        ],
      ),
    );
  }

  Widget _specChip({
    required IconData icon,
    required String label,
    required bool isDark,
    required Color primaryColor,
    required Color secondaryTextColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: primaryColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: secondaryTextColor,
            ),
          ),
        ],
      ),
    );
  }
}
