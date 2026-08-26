import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/network/dio_client.dart';
import '../../data/models/banner_model.dart';
import '../../data/models/category_model.dart';
IconData iconForCategory(String? iconKey) {
  switch (iconKey) {
    case 'heroicon-o-truck':
    case 'car':
      return Icons.directions_car_rounded;
    case 'heroicon-o-home':
    case 'home':
      return Icons.home_rounded;
    case 'heroicon-o-device-phone-mobile':
    case 'device':
      return Icons.devices_rounded;
    case 'phone':
      return Icons.smartphone_rounded;
    case 'heroicon-o-cube':
    case 'chair':
      return Icons.chair_rounded;
    case 'heroicon-o-briefcase':
    case 'work':
      return Icons.work_rounded;
    case 'heroicon-o-wrench-screwdriver':
    case 'build':
      return Icons.build_rounded;
    case 'heroicon-o-sparkles':
    case 'checkroom':
      return Icons.checkroom_rounded;
    case 'heroicon-o-heart':
    case 'pets':
      return Icons.pets_rounded;
    case 'heroicon-o-trophy':
    case 'sport':
      return Icons.sports_soccer_rounded;
    case 'heroicon-o-building-office':
      return Icons.business_center_rounded;
    case 'garden':
      return Icons.yard_rounded;
    case 'game':
      return Icons.sports_esports_rounded;
    case 'food':
      return Icons.restaurant_rounded;
    case 'book':
      return Icons.menu_book_rounded;
    case 'motorcycle':
      return Icons.two_wheeler_rounded;
    case 'baby':
      return Icons.child_friendly_rounded;
    case 'camera':
      return Icons.camera_alt_rounded;
    case 'music':
      return Icons.music_note_rounded;
    default:
      return Icons.category_rounded;
  }
}
Color colorForCategory(String? iconKey) {
  switch (iconKey) {
    case 'heroicon-o-truck':
    case 'car':
      return const Color(0xFFE53935);
    case 'heroicon-o-home':
    case 'home':
      return const Color(0xFF1E88E5);
    case 'heroicon-o-device-phone-mobile':
    case 'device':
      return const Color(0xFFFB8C00);
    case 'phone':
      return const Color(0xFF039BE5);
    case 'heroicon-o-cube':
    case 'chair':
      return const Color(0xFF6D4C41);
    case 'heroicon-o-briefcase':
    case 'work':
      return const Color(0xFF43A047);
    case 'heroicon-o-wrench-screwdriver':
    case 'build':
      return const Color(0xFF8E24AA);
    case 'heroicon-o-sparkles':
    case 'checkroom':
      return const Color(0xFFD81B60);
    case 'heroicon-o-heart':
    case 'pets':
      return const Color(0xFF00897B);
    case 'heroicon-o-trophy':
    case 'sport':
      return const Color(0xFFF9A825);
    case 'heroicon-o-building-office':
      return const Color(0xFF3949AB);
    case 'garden':
      return const Color(0xFF7CB342);
    case 'game':
      return const Color(0xFF5E35B1);
    case 'food':
      return const Color(0xFFEF6C00);
    case 'book':
      return const Color(0xFF00ACC1);
    case 'motorcycle':
      return const Color(0xFFC62828);
    case 'baby':
      return const Color(0xFFEC407A);
    case 'camera':
      return const Color(0xFF546E7A);
    case 'music':
      return const Color(0xFF6A1B9A);
    default:
      return const Color(0xFF2E2B5C);
  }
}
bool isImageUrl(String icon) {
  return icon.startsWith('http://') ||
      icon.startsWith('https://') ||
      icon.startsWith('//');
}
/// يحول رابط Imgur العادي إلى رابط مباشر
String? resolveImageUrl(String? rawUrl) {
  if (rawUrl == null || rawUrl.isEmpty) return null;
  if (rawUrl.contains('imgur.com') && !rawUrl.contains('i.imgur.com')) {
    final id = rawUrl.split('/').last;
    return 'https://i.imgur.com/$id.png';
  }
  return rawUrl;
}
class SearchAndBannersSection extends StatefulWidget {
  final List<BannerModel> banners;
  final List<CategoryModel> categories;
  final void Function(CategoryModel) onCategoryTap;
  const SearchAndBannersSection({
    super.key,
    required this.banners,
    required this.categories,
    required this.onCategoryTap,
  });
  @override
  State<SearchAndBannersSection> createState() =>
      _SearchAndBannersSectionState();
}
class _SearchAndBannersSectionState extends State<SearchAndBannersSection> {
  int _currentBanner = 0;
  late final PageController _pageController;
  Timer? _autoPlayTimer;
  static const int _maxMainCategories = 14;
  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _startAutoPlay();
  }
  void _startAutoPlay() {
    if (widget.banners.length <= 1) return;
    _autoPlayTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (!_pageController.hasClients) return;
      final nextPage = (_currentBanner + 1) % widget.banners.length;
      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }
  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }
  List<CategoryModel> get _mainCategories =>
      widget.categories.where((c) => c.parentId == null).toList();
  List<CategoryModel> get _sortedCategories {
    final cats = _mainCategories;
    final sorted = List<CategoryModel>.from(cats);
    sorted.sort((a, b) {
      final orderA = a.sortOrder ?? 9999;
      final orderB = b.sortOrder ?? 9999;
      if (orderA == orderB) {
        return (a.id ?? 0).compareTo(b.id ?? 0);
      }
      return orderA.compareTo(orderB);
    });
    return sorted;
  }
  List<CategoryModel> get _visibleCategories {
    final sorted = _sortedCategories;
    if (sorted.length <= _maxMainCategories) return sorted;
    return sorted.sublist(0, _maxMainCategories);
  }
  bool get _hasMore => _sortedCategories.length > _maxMainCategories;
  /// يدور على فئة "سيارات" من نفس قائمة الفئات المتوفرة عندنا أصلاً
  CategoryModel? get _carsCategory {
    for (final c in widget.categories) {
      if (c.parentId == null &&
          (c.nameAr == 'المركبات' || c.icon == 'car' || c.icon == 'heroicon-o-truck')) {
        return c;
      }
    }
    return null;
  }
  void _showAllCategoriesSheet() {
    final allCats = _sortedCategories;
    if (allCats.isEmpty) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: DraggableScrollableSheet(
            initialChildSize: 0.65,
            minChildSize: 0.3,
            maxChildSize: 0.92,
            expand: false,
            builder: (context, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: CustomScrollView(
                  controller: scrollController,
                  slivers: [
                    SliverToBoxAdapter(
                      child: Column(
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 12, bottom: 8),
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'جميع الفئات',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2E2B5C),
                                  ),
                                ),
                                IconButton(
                                  onPressed: () => Navigator.pop(context),
                                  icon: const Icon(Icons.close, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                          const Divider(height: 1),
                        ],
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.all(16),
                      sliver: SliverGrid(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final cat = allCats[index];
                            return _CategoryItem(
                              category: cat,
                              onTap: () {
                                Navigator.pop(context);
                                widget.onCategoryTap(cat);
                              },
                            );
                          },
                          childCount: allCats.length,
                        ),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 8,
                          childAspectRatio: 0.8,
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 24)),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    final visibleCats = _visibleCategories;
    final hasMore = _hasMore;
    final gridItemCount = visibleCats.length + (hasMore ? 1 : 0);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF4F4F5),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const TextField(
              textAlign: TextAlign.right,
              decoration: InputDecoration(
                hintText: 'ابحث عن أي شيء',
                suffixIcon: Icon(Icons.search),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
        ),
        if (widget.banners.isNotEmpty) ...[
          SizedBox(
            height: 150,
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (i) => setState(() => _currentBanner = i),
              itemCount: widget.banners.length,
              itemBuilder: (context, index) {
                final banner = widget.banners[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: CachedNetworkImage(
                      imageUrl: fullImageUrl(banner.image),
                      fit: BoxFit.cover,
                      width: double.infinity,
                      placeholder: (_, __) => Container(
                        color: const Color(0xFFEDEBF5),
                        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                      ),
                      errorWidget: (_, __, ___) => Container(
                        color: const Color(0xFFEDEBF5),
                        child: const Center(child: Icon(Icons.image_not_supported_outlined)),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          if (widget.banners.length > 1)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(widget.banners.length, (i) {
                return Container(
                  width: i == _currentBanner ? 18 : 6,
                  height: 6,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: i == _currentBanner
                        ? const Color(0xFF2E2B5C)
                        : const Color(0xFFE4E4E7),
                    borderRadius: BorderRadius.circular(3),
                  ),
                );
              }),
            ),
        ],
        const SizedBox(height: 20),
        if (visibleCats.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: gridItemCount,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 16,
                crossAxisSpacing: 8,
                childAspectRatio: 0.8,
              ),
              itemBuilder: (context, index) {
                if (hasMore && index == visibleCats.length) {
                  return _MoreButton(onTap: _showAllCategoriesSheet);
                }
                final cat = visibleCats[index];
                return _CategoryItem(
                  category: cat,
                  onTap: () => widget.onCategoryTap(cat),
                );
              },
            ),
          ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Builder(builder: (context) {
            final carsCat = _carsCategory;
            final carIconRaw = carsCat?.icon;
            final carResolvedUrl = carIconRaw == null ? null : resolveImageUrl(carIconRaw);
            final carIsImage = carResolvedUrl != null && isImageUrl(carResolvedUrl);
            return InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                if (carsCat != null) widget.onCategoryTap(carsCat);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF5FBFA0).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF5FBFA0)),
                ),
                child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: Row(
                    children: [
                      // صورة/أيقونة السيارة يمين الزر
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: carIsImage
                            ? CachedNetworkImage(
                                imageUrl: carResolvedUrl,
                                width: 48,
                                height: 48,
                                fit: BoxFit.cover,
                                placeholder: (_, __) => Container(
                                  width: 48,
                                  height: 48,
                                  color: const Color(0xFF2E2B5C).withOpacity(0.08),
                                ),
                                errorWidget: (_, __, ___) => Container(
                                  width: 48,
                                  height: 48,
                                  color: const Color(0xFF2E2B5C).withOpacity(0.08),
                                  child: const Icon(Icons.directions_car_rounded, color: Color(0xFF2E2B5C)),
                                ),
                              )
                            : Container(
                                width: 48,
                                height: 48,
                                color: const Color(0xFF2E2B5C).withOpacity(0.08),
                                child: const Icon(Icons.directions_car_rounded, color: Color(0xFF2E2B5C)),
                              ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'أكمل تصفح السيارات وقطع الغيار والإكسسوارات',
                          textAlign: TextAlign.right,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2E2B5C), fontSize: 14),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: Color(0xFF2E2B5C)),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}
// ============================================
// عنصر الفئة — يدعم صورة URL أو أيقونة Flutter
// ============================================
class _CategoryItem extends StatelessWidget {
  final CategoryModel category;
  final VoidCallback onTap;
  const _CategoryItem({
    required this.category,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    final rawIcon = category.icon;
    final resolvedUrl = resolveImageUrl(rawIcon);
    final isImage = resolvedUrl != null && isImageUrl(resolvedUrl);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        children: [
          // ========================================
          // صورة حقيقية بدون حواف ولا خلفية بيضاء ولا ظل
          // تملأ المربع بالكامل (BoxFit.cover) بزوايا دائرية فقط
          // ========================================
          isImage
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: CachedNetworkImage(
                    imageUrl: resolvedUrl,
                    width: 62,
                    height: 62,
                    fit: BoxFit.cover, // ← تملأ المربع بدون أي فراغ أبيض
                    placeholder: (context, url) => Container(
                      width: 62,
                      height: 62,
                      color: Colors.grey.shade100,
                      child: const Center(
                        child: SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    ),
                    errorWidget: (_, __, ___) => Container(
                      width: 62,
                      height: 62,
                      decoration: BoxDecoration(
                        color: colorForCategory(rawIcon).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Center(
                        child: Icon(
                          iconForCategory(rawIcon),
                          color: colorForCategory(rawIcon),
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                )
              : Container(
                  width: 62,
                  height: 62,
                  decoration: BoxDecoration(
                    color: colorForCategory(rawIcon).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Center(
                    child: Icon(
                      iconForCategory(rawIcon),
                      color: colorForCategory(rawIcon),
                      size: 26,
                    ),
                  ),
                ),
          const SizedBox(height: 6),
          Text(
            category.nameAr ?? '',
            style: const TextStyle(fontSize: 10.5),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
// ============================================
// زر المزيد
// ============================================
class _MoreButton extends StatelessWidget {
  final VoidCallback onTap;
  const _MoreButton({required this.onTap});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFFF4F4F5),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFD4D4D8),
                width: 1,
              ),
            ),
            child: const Center(
              child: Icon(
                Icons.arrow_forward_ios_rounded,
                color: Color(0xFF2E2B5C),
                size: 22,
              ),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'المزيد',
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w500,
              color: Color(0xFF2E2B5C),
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}