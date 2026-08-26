import 'package:flutter/material.dart';
import 'category_grid_section.dart' show isImageUrl, resolveImageUrl;

class DiscoverOmanItem {
  final String label;
  final String? imageUrl; // رابط صورة (اختياري) — لو فاضي يستخدم الأيقونة والبديل
  final IconData fallbackIcon;
  final Color color;

  const DiscoverOmanItem({
    required this.label,
    this.imageUrl,
    required this.fallbackIcon,
    required this.color,
  });
}

class DiscoverOmanSection extends StatelessWidget {
  final VoidCallback onSeeAllTap;
  final void Function(DiscoverOmanItem item) onItemTap;

  const DiscoverOmanSection({
    super.key,
    required this.onSeeAllTap,
    required this.onItemTap,
  });

  static const List<DiscoverOmanItem> _items = [
    DiscoverOmanItem(label: 'المطاعم والمقاهي', fallbackIcon: Icons.restaurant_rounded, color: Color(0xFFEF9F27)),
    DiscoverOmanItem(label: 'اللياقة والرياضة', fallbackIcon: Icons.fitness_center_rounded, color: Color(0xFFE24B4A)),
    DiscoverOmanItem(label: 'الرعاية الصحية', fallbackIcon: Icons.favorite_rounded, color: Color(0xFFE24B4A)),
    DiscoverOmanItem(label: 'الترفيه', fallbackIcon: Icons.local_movies_rounded, color: Color(0xFFD85A30)),
    DiscoverOmanItem(label: 'التسوق', fallbackIcon: Icons.shopping_bag_rounded, color: Color(0xFF7F77DD)),
    DiscoverOmanItem(label: 'البقالة والسوبر ماركت', fallbackIcon: Icons.shopping_basket_rounded, color: Color(0xFF639922)),
    DiscoverOmanItem(label: 'الأزياء', fallbackIcon: Icons.checkroom_rounded, color: Color(0xFFD4537E)),
    DiscoverOmanItem(label: 'التعليم', fallbackIcon: Icons.menu_book_rounded, color: Color(0xFF378ADD)),
    DiscoverOmanItem(label: 'السفر والسياحة', fallbackIcon: Icons.flight_rounded, color: Color(0xFF1D9E75)),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFCEFDA), // خلفية كريمية دافئة
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ===== رأس القسم: العنوان + الشارة يمين، عرض الكل يسار =====
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFF534AB7),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'جديد',
                              style: TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'اكتشف عُمان',
                            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF2E2B5C)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'ستجد كل ما تبحث عنه في عُمان',
                        style: TextStyle(fontSize: 12, color: Color(0xFF6B6880)),
                      ),
                    ],
                  ),
                  InkWell(
                    onTap: onSeeAllTap,
                    borderRadius: BorderRadius.circular(20),
                    child: Row(
                      children: const [
                        Icon(Icons.arrow_back_rounded, size: 18, color: Color(0xFF2E2B5C)),
                        SizedBox(width: 6),
                        Text(
                          'عرض الكل',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF2E2B5C)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // ===== شبكة الفئات (4 بكل صف) =====
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _items.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 4,
                  childAspectRatio: 0.75,
                ),
                itemBuilder: (context, index) {
                  final item = _items[index];
                  return _DiscoverCircleItem(item: item, onTap: () => onItemTap(item));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DiscoverCircleItem extends StatelessWidget {
  final DiscoverOmanItem item;
  final VoidCallback onTap;

  const _DiscoverCircleItem({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final resolvedUrl = resolveImageUrl(item.imageUrl);
    final hasImage = resolvedUrl != null && resolvedUrl.isNotEmpty && isImageUrl(resolvedUrl);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipOval(
            child: hasImage
                ? Image.network(
                    resolvedUrl,
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _fallbackCircle(),
                  )
                : _fallbackCircle(),
          ),
          const SizedBox(height: 6),
          Text(
            item.label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 11, color: Color(0xFF2E2B5C), fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _fallbackCircle() {
    return Container(
      width: 56,
      height: 56,
      color: Colors.white,
      child: Icon(item.fallbackIcon, color: item.color, size: 24),
    );
  }
}