import 'package:flutter/material.dart';
import '../../data/models/banner_model.dart';
import '../../data/models/category_model.dart';
import '../../data/repositories/home_repository.dart';
import '../widgets/category_grid_section.dart';
import '../widgets/discover_oman_section.dart';
import '../widgets/most_viewed_section.dart';
import '../widgets/category_listings_section.dart';
import '../widgets/banner_ad_widget.dart';
import '../../data/models/listing_model.dart';
import 'listing_detail_page.dart';
import 'category_results_page.dart';
import 'vehicle_category_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _repo = HomeRepository();
  List<BannerModel> banners = [];
  List<CategoryModel> categories = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        _repo.getBanners(),
        _repo.getCategories(),
      ]);
      setState(() {
        banners = results[0] as List<BannerModel>;
        categories = results[1] as List<CategoryModel>;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'تعذّر تحميل البيانات. تأكد من اتصال السيرفر.';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? _buildErrorState()
                : RefreshIndicator(
                    onRefresh: _loadData,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        children: [
                          SearchAndBannersSection(
                            banners: banners,
                            categories: categories,
                            onCategoryTap: (cat) {
                              // نسجّل الضغطة بالخلفية (بدون انتظار — ما يأثر على سرعة التنقل)
                              _repo.trackCategoryView(cat.id ?? 0);
                              _openCategoryResults(context, cat);
                            },
                          ),

                          // 1. قسم اكتشف عُمان
                          DiscoverOmanSection(
                            onSeeAllTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('عرض كل فئات اكتشف عُمان')),
                              );
                            },
                            onItemTap: (item) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('فتح: ${item.label}')),
                              );
                            },
                          ),

                          // 2. الأقسام الأكثر مشاهدة
                          MostViewedSection(
                            categories: categories,
                            onCategoryTap: (cat) {
                              _repo.trackCategoryView(cat.id ?? 0);
                              _openCategoryResults(context, cat);
                            },
                          ),

                          // 3. إعلان AdMob (بعد قسم الأكثر مشاهدة مباشرة)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16.0),
                            child: Center(
                              child: BannerAdWidget(),
                            ),
                          ),

                          // 4. أقسام الإعلانات حسب الفئة (سيارات، عقارات، إلكترونيات، مقاولات)
                          CategoryListingsSection(
                            categories: categories,
                            categoryName: 'المركبات',
                            displayTitle: 'إعلانات المركبات',
                            onListingTap: (listing) => _onListingTap(context, listing),
                            onSeeAllTap: () => _openCategoryResultsByName(context, 'المركبات'),
                          ),
                          CategoryListingsSection(
                            categories: categories,
                            categoryName: 'عقارات',
                            displayTitle: 'إعلانات العقارات',
                            onListingTap: (listing) => _onListingTap(context, listing),
                            onSeeAllTap: () => _openCategoryResultsByName(context, 'عقارات'),
                          ),
                          CategoryListingsSection(
                            categories: categories,
                            categoryName: 'إلكترونيات',
                            displayTitle: 'إعلانات الإلكترونيات',
                            onListingTap: (listing) => _onListingTap(context, listing),
                            onSeeAllTap: () => _openCategoryResultsByName(context, 'إلكترونيات'),
                          ),
                          CategoryListingsSection(
                            categories: categories,
                            categoryName: 'مقاولات',
                            displayTitle: 'إعلانات المقاولات',
                            onListingTap: (listing) => _onListingTap(context, listing),
                            onSeeAllTap: () => _openCategoryResultsByName(context, 'مقاولات'),
                          ),

                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
      ),
    );
  }

  void _openCategoryResults(BuildContext context, CategoryModel cat) {
    // فئة "المركبات" لها صفحة غنية خاصة (أقسام مقسّمة + مميزة + أحدث)
    if (cat.nameAr == 'المركبات') {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => VehicleCategoryPage(category: cat, allCategories: categories),
        ),
      );
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CategoryResultsPage(category: cat, allCategories: categories),
      ),
    );
  }

  void _openCategoryResultsByName(BuildContext context, String nameAr) {
    final match = categories.where((c) => c.nameAr == nameAr).toList();
    if (match.isEmpty) return;
    _openCategoryResults(context, match.first);
  }

  void _onListingTap(BuildContext context, ListingModel listing) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ListingDetailPage(listingId: listing.id),
      ),
    );
  }

  Widget _buildErrorState() {
    return ListView(
      children: [
        const SizedBox(height: 120),
        Icon(Icons.wifi_off_rounded, size: 48, color: Colors.grey[400]),
        const SizedBox(height: 12),
        Center(child: Text(_error!, style: TextStyle(color: Colors.grey[600]))),
        const SizedBox(height: 12),
        Center(
          child: TextButton(onPressed: _loadData, child: const Text('إعادة المحاولة')),
        ),
      ],
    );
  }
}