import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../data/models/category_model.dart';
import '../../data/models/listing_model.dart';
import '../../data/repositories/home_repository.dart';
import '../widgets/category_grid_section.dart' show isImageUrl, resolveImageUrl, iconForCategory, colorForCategory;
import 'listing_card.dart';
import 'listing_detail_page.dart';
import 'category_results_page.dart';
import 'origin_results_page.dart';
import '../widgets/promo_banner_carousel.dart';
import '../../data/models/banner_model.dart';

/// صفحة فئة غنية (مطابقة لتصميم ForSale) — تفصل الفئات الفرعية إلى قسمين
/// "الشركات" و"أقسام"، وتعرض إعلانات مميزة وأحدث إعلانات.
/// حالياً مبنية خصيصاً لفئة "المركبات"، وقابلة للتوسعة لفئات ثانية لاحقاً.
class VehicleCategoryPage extends StatefulWidget {
  final CategoryModel category;
  final List<CategoryModel> allCategories;

  const VehicleCategoryPage({
    super.key,
    required this.category,
    required this.allCategories,
  });

  // ✏️ عدّل هذي القائمة لو غيّرت أسماء فئات "الشركات"
  static const List<String> companySubcategoryNames = [
    'مكاتب تأجير السيارات',
    'مكاتب السيارات',
    'كراج السيارات',
    'الوكالات',
    'معارض السيارات',
    'وكالات السيارات',
    'مراكز صيانة السيارات',
  ];

  @override
  State<VehicleCategoryPage> createState() => _VehicleCategoryPageState();
}

class _VehicleCategoryPageState extends State<VehicleCategoryPage> {
  final _repo = HomeRepository();
  List<ListingModel> _allListings = [];
  List<BannerModel> _banners = [];
  bool _loading = true;

  List<CategoryModel> get _subcategories =>
      widget.allCategories.where((c) => c.parentId == widget.category.id).toList();

  List<CategoryModel> get _companySubs => _subcategories
      .where((c) => VehicleCategoryPage.companySubcategoryNames.contains(c.nameAr))
      .toList();

  // ✏️ عدّل هذي القائمة لو تبي فئات ثانية تصير "مميزة" بصف خاص فوق
  static const List<String> _priorityNames = ['سيارات جديدة', 'سيارات مستعملة'];

  List<CategoryModel> get _priorityRegularSubs => _subcategories
      .where((c) =>
          !VehicleCategoryPage.companySubcategoryNames.contains(c.nameAr) &&
          _priorityNames.contains(c.nameAr))
      .toList()
    ..sort((a, b) => _priorityNames.indexOf(a.nameAr ?? '').compareTo(_priorityNames.indexOf(b.nameAr ?? '')));

  List<CategoryModel> get _regularSubs => _subcategories
      .where((c) =>
          !VehicleCategoryPage.companySubcategoryNames.contains(c.nameAr) &&
          !_priorityNames.contains(c.nameAr))
      .toList();

  List<int> get _relevantIds {
    final ids = <int>[if (widget.category.id != null) widget.category.id!];
    for (final c in _subcategories) {
      if (c.id != null) ids.add(c.id!);
    }
    return ids;
  }

  List<ListingModel> get _featuredListings =>
      _allListings.where((l) => l.isFeatured).toList();

  List<ListingModel> get _latestListings {
    final sorted = [..._allListings];
    sorted.sort((a, b) {
      if (a.createdAt == null || b.createdAt == null) return 0;
      return b.createdAt!.compareTo(a.createdAt!);
    });
    return sorted;
  }

  @override
  void initState() {
    super.initState();
    _loadListings();
  }

  Future<void> _loadListings() async {
    setState(() => _loading = true);
    try {
      final results = await Future.wait([
        Future.wait(_relevantIds.map((id) => _repo.getListings(categoryId: id))),
        _repo.getBanners(categoryId: widget.category.id),
      ]);
      final listingLists = results[0] as List<List<ListingModel>>;
      final banners = results[1] as List<BannerModel>;
      final merged = <int, ListingModel>{};
      for (final list in listingLists) {
        for (final listing in list) {
          merged[listing.id] = listing;
        }
      }
      if (mounted) {
        setState(() {
          _allListings = merged.values.toList();
          _banners = banners;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _openSubcategory(CategoryModel sub) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CategoryResultsPage(category: sub, allCategories: widget.allCategories),
      ),
    );
  }

  // ✏️ عدّل هذي القائمة لو تبي دول ثانية — كل عنصر (النص المعروض، رمز العلم)
  static const List<Map<String, String>> originOptions = [
    {'label': 'صيني', 'flag': '🇨🇳'},
    {'label': 'أمريكي', 'flag': '🇺🇸'},
    {'label': 'ياباني', 'flag': '🇯🇵'},
    {'label': 'ألماني', 'flag': '🇩🇪'},
    {'label': 'إنجليزي', 'flag': '🇬🇧'},
    {'label': 'كوري', 'flag': '🇰🇷'},
    {'label': 'إيطالي', 'flag': '🇮🇹'},
    {'label': 'فرنسي', 'flag': '🇫🇷'},
    {'label': 'سويدي', 'flag': '🇸🇪'},
    {'label': 'إسباني', 'flag': '🇪🇸'},
    {'label': 'ماليزي', 'flag': '🇲🇾'},
    {'label': 'أخرى', 'flag': '🌐'},
  ];

  void _openOrigin(String label) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => OriginResultsPage(
          category: widget.category,
          allCategories: widget.allCategories,
          origin: label,
          originLabel: label,
        ),
      ),
    );
  }

  void _openListing(ListingModel listing) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ListingDetailPage(listingId: listing.id)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF2E2B5C),
          elevation: 0,
          centerTitle: true,
          title: Text(widget.category.nameAr ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _loadListings,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 24),
                  children: [
                    // بانر ترويجي تديره من لوحة التحكم (بأول الصفحة)
                    if (_banners.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      PromoBannerCarousel(banners: _banners),
                      const SizedBox(height: 8),
                    ],

                    if (_companySubs.isNotEmpty)
                      _SubcategorySection(title: 'الشركات', items: _companySubs, onTap: _openSubcategory),
                    if (_regularSubs.isNotEmpty || _priorityRegularSubs.isNotEmpty)
                      _RegularSubsSection(
                        title: '${widget.category.nameAr} أقسام',
                        priorityItems: _priorityRegularSubs,
                        regularItems: _regularSubs,
                        onTap: _openSubcategory,
                      ),

                    // تصفح حسب المنشأ
                    _OriginSection(options: originOptions, onTap: _openOrigin),

                    if (_featuredListings.isNotEmpty)
                      _ListingsStrip(title: 'إعلانات مميزة', listings: _featuredListings, onTap: _openListing),
                    if (_latestListings.isNotEmpty)
                      _ListingsStrip(title: 'أحدث الإعلانات', listings: _latestListings, onTap: _openListing),
                    if (_allListings.isEmpty && _subcategories.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 80),
                        child: Center(
                          child: Text('لا يوجد محتوى حالياً', style: TextStyle(color: Colors.grey[600])),
                        ),
                      ),
                  ],
                ),
              ),
      ),
    );
  }
}

class _RegularSubsSection extends StatelessWidget {
  final String title;
  final List<CategoryModel> priorityItems; // تُعرض بصف خاص بعمودين فوق (مثل: سيارات جديدة/مستعملة)
  final List<CategoryModel> regularItems; // باقي الفئات، شبكة عادية 4 أعمدة
  final void Function(CategoryModel) onTap;

  const _RegularSubsSection({
    required this.title,
    required this.priorityItems,
    required this.regularItems,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(title, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: Color(0xFF2E2B5C))),
          ),
          const SizedBox(height: 12),
          if (priorityItems.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: priorityItems.map((cat) {
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: _SubcategoryCircleItem(category: cat, size: 78, onTap: () => onTap(cat)),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 18),
          ],
          if (regularItems.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: regularItems.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 4,
                  childAspectRatio: 0.78,
                ),
                itemBuilder: (context, index) {
                  final cat = regularItems[index];
                  return _SubcategoryCircleItem(category: cat, size: 62, onTap: () => onTap(cat));
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _SubcategoryCircleItem extends StatelessWidget {
  final CategoryModel category;
  final double size;
  final VoidCallback onTap;

  const _SubcategoryCircleItem({required this.category, required this.size, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final resolvedUrl = resolveImageUrl(category.icon);
    final hasImage = resolvedUrl != null && resolvedUrl.isNotEmpty && isImageUrl(resolvedUrl);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: hasImage
                ? CachedNetworkImage(
                    imageUrl: resolvedUrl,
                    width: size,
                    height: size,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(width: size, height: size, color: Colors.grey.shade100),
                    errorWidget: (_, __, ___) => _fallback(),
                  )
                : _fallback(),
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

  Widget _fallback() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: colorForCategory(category.icon).withOpacity(0.12), borderRadius: BorderRadius.circular(16)),
      child: Center(child: Icon(iconForCategory(category.icon), color: colorForCategory(category.icon), size: size * 0.4)),
    );
  }
}

class _OriginSection extends StatelessWidget {
  final List<Map<String, String>> options;
  final void Function(String label) onTap;

  const _OriginSection({required this.options, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text('تصفح حسب المنشأ', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: Color(0xFF2E2B5C))),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 92,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: options.length,
              separatorBuilder: (_, __) => const SizedBox(width: 14),
              itemBuilder: (context, index) {
                final label = options[index]['label']!;
                final flag = options[index]['flag']!;
                return InkWell(
                  onTap: () => onTap(label),
                  borderRadius: BorderRadius.circular(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F1FA),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        alignment: Alignment.center,
                        child: Text(flag, style: const TextStyle(fontSize: 26)),
                      ),
                      const SizedBox(height: 6),
                      Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF2E2B5C), fontWeight: FontWeight.w500)),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SubcategorySection extends StatelessWidget {
  final String title;
  final List<CategoryModel> items;
  final void Function(CategoryModel) onTap;

  const _SubcategorySection({required this.title, required this.items, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(title, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: Color(0xFF2E2B5C))),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 16,
                crossAxisSpacing: 4,
                childAspectRatio: 0.78,
              ),
              itemBuilder: (context, index) {
                final cat = items[index];
                final resolvedUrl = resolveImageUrl(cat.icon);
                final hasImage = resolvedUrl != null && resolvedUrl.isNotEmpty && isImageUrl(resolvedUrl);
                return InkWell(
                  onTap: () => onTap(cat),
                  borderRadius: BorderRadius.circular(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: hasImage
                            ? CachedNetworkImage(
                                imageUrl: resolvedUrl,
                                width: 62,
                                height: 62,
                                fit: BoxFit.cover,
                                placeholder: (_, __) => Container(width: 62, height: 62, color: Colors.grey.shade100),
                                errorWidget: (_, __, ___) => _fallback(cat),
                              )
                            : _fallback(cat),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        cat.nameAr ?? '',
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 11, color: Color(0xFF2E2B5C), fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _fallback(CategoryModel cat) {
    return Container(
      width: 62,
      height: 62,
      decoration: BoxDecoration(color: colorForCategory(cat.icon).withOpacity(0.12), borderRadius: BorderRadius.circular(16)),
      child: Center(child: Icon(iconForCategory(cat.icon), color: colorForCategory(cat.icon), size: 24)),
    );
  }
}

class _ListingsStrip extends StatelessWidget {
  final String title;
  final List<ListingModel> listings;
  final void Function(ListingModel) onTap;

  const _ListingsStrip({required this.title, required this.listings, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(title, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: Color(0xFF2E2B5C))),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 260,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: listings.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final listing = listings[index];
                return ListingCard(listing: listing, onTap: () => onTap(listing));
              },
            ),
          ),
        ],
      ),
    );
  }
}