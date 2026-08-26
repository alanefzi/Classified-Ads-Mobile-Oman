import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../data/models/category_model.dart';
import 'category_grid_section.dart' show isImageUrl, resolveImageUrl, iconForCategory, colorForCategory;

/// قسم "الأقسام الأكثر مشاهدة" — يعرض فئات مختارة من نفس قائمة الفئات الحقيقية
/// حالياً القائمة ثابتة يدوياً (لعدم وجود بيانات زوار كافية بعد).
/// لاحقاً لما يصير عندك عدد زوار حقيقي، تقدر تستبدل _pinnedCategoryNames
/// بجلب البيانات من /api/categories/most-searched مباشرة.
class MostViewedSection extends StatelessWidget {
  final List<CategoryModel> categories;
  final void Function(CategoryModel category) onCategoryTap;

  const MostViewedSection({
    super.key,
    required this.categories,
    required this.onCategoryTap,
  });

  // ✏️ عدّل هذي القائمة وقت ما تبي تغيّر الفئات المعروضة
  static const List<String> _pinnedCategoryNames = [
    'المركبات',
    'عقارات',
    'إلكترونيات',
    'موبايل وتابلت',
    'خدمات',
  ];

  List<CategoryModel> get _items {
    final result = <CategoryModel>[];
    for (final name in _pinnedCategoryNames) {
      final match = categories.where((c) => c.nameAr == name).toList();
      if (match.isNotEmpty) result.add(match.first);
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final items = _items;
    if (items.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Container(
          width: double.infinity, // ← يجبر البطاقة تاخذ العرض الكامل بدل ما تنكمش على المحتوى
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFE1F1F7), // خلفية زرقاء فاتحة
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'الأقسام الأكثر مشاهدة',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF2E2B5C)),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 16,
                children: items.map((category) {
                  return SizedBox(
                    width: 76,
                    child: _MostViewedItem(
                      category: category,
                      onTap: () => onCategoryTap(category),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MostViewedItem extends StatelessWidget {
  final CategoryModel category;
  final VoidCallback onTap;

  const _MostViewedItem({required this.category, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final rawIcon = category.icon;
    final resolvedUrl = resolveImageUrl(rawIcon);
    final hasImage = resolvedUrl != null && resolvedUrl.isNotEmpty && isImageUrl(resolvedUrl);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipOval(
            child: hasImage
                ? CachedNetworkImage(
                    imageUrl: resolvedUrl!,
                    width: 64,
                    height: 64,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(width: 64, height: 64, color: Colors.white),
                    errorWidget: (_, __, ___) => _fallbackCircle(rawIcon),
                  )
                : _fallbackCircle(rawIcon),
          ),
          const SizedBox(height: 6),
          Text(
            category.nameAr ?? '',
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 11, color: Color(0xFF2E2B5C), fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _fallbackCircle(String? rawIcon) {
    return Container(
      width: 64,
      height: 64,
      color: Colors.white,
      child: Icon(iconForCategory(rawIcon), color: colorForCategory(rawIcon), size: 26),
    );
  }
}