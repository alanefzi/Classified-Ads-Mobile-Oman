import 'package:flutter/material.dart';
import '../../data/models/category_model.dart';
import '../../data/models/listing_model.dart';
import '../../data/models/banner_model.dart';
import '../../data/repositories/home_repository.dart';
import 'listing_card.dart';
import 'listing_detail_page.dart';
import '../widgets/promo_banner_carousel.dart';

/// صفحة نتائج فئة معينة — تجمع الفئة الرئيسية + كل فئاتها الفرعية
/// وتعرض كل إعلاناتها بشبكة كاملة قابلة للتمرير وسحب للتحديث
class CategoryResultsPage extends StatefulWidget {
  final CategoryModel category;
  final List<CategoryModel> allCategories; // كل الفئات (لإيجاد الفئات الفرعية)

  const CategoryResultsPage({
    super.key,
    required this.category,
    required this.allCategories,
  });

  @override
  State<CategoryResultsPage> createState() => _CategoryResultsPageState();
}

class _CategoryResultsPageState extends State<CategoryResultsPage> {
  final _repo = HomeRepository();
  List<ListingModel> _listings = [];
  List<BannerModel> _banners = [];
  bool _loading = true;
  bool _error = false;

  /// الفئة الرئيسية + كل فئاتها الفرعية
  List<int> get _relevantCategoryIds {
    final parentId = widget.category.id;
    final ids = <int>[if (parentId != null) parentId];
    for (final c in widget.allCategories) {
      if (c.parentId == parentId && c.id != null) {
        ids.add(c.id!);
      }
    }
    return ids;
  }

  @override
  void initState() {
    super.initState();
    _loadListings();
  }

  Future<void> _loadListings() async {
    setState(() {
      _loading = true;
      _error = false;
    });
    final ids = _relevantCategoryIds;
    if (ids.isEmpty) {
      setState(() { _loading = false; });
      return;
    }
    try {
      final results = await Future.wait([
        Future.wait(ids.map((id) => _repo.getListings(categoryId: id))),
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
          _listings = merged.values.toList();
          _banners = banners;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() { _error = true; _loading = false; });
    }
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
          title: Text(
            widget.category.nameAr ?? '',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        body: SafeArea(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _error
                  ? _buildErrorState()
                  : _listings.isEmpty
                      ? _buildEmptyState()
                      : RefreshIndicator(
                          onRefresh: _loadListings,
                          child: CustomScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            slivers: [
                              // بانر ترويجي تديره من لوحة التحكم (بأول الصفحة)
                              if (_banners.isNotEmpty)
                                SliverToBoxAdapter(
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 12, bottom: 4),
                                    child: PromoBannerCarousel(banners: _banners),
                                  ),
                                ),
                              SliverPadding(
                                padding: const EdgeInsets.all(16),
                                sliver: SliverGrid(
                                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    mainAxisSpacing: 14,
                                    crossAxisSpacing: 14,
                                    childAspectRatio: 0.68,
                                  ),
                                  delegate: SliverChildBuilderDelegate(
                                    (context, index) {
                                      final listing = _listings[index];
                                      return ListingCard(
                                        listing: listing,
                                        onTap: () => _openListing(listing),
                                        width: double.infinity,
                                      );
                                    },
                                    childCount: _listings.length,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return ListView(
      children: [
        if (_banners.isNotEmpty) ...[
          const SizedBox(height: 12),
          PromoBannerCarousel(banners: _banners),
        ],
        const SizedBox(height: 60),
        Icon(Icons.search_off_rounded, size: 48, color: Colors.grey[400]),
        const SizedBox(height: 12),
        Center(
          child: Text(
            'لا توجد إعلانات بهذه الفئة حالياً',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState() {
    return ListView(
      children: [
        const SizedBox(height: 100),
        Icon(Icons.wifi_off_rounded, size: 48, color: Colors.grey[400]),
        const SizedBox(height: 12),
        Center(child: Text('تعذّر تحميل الإعلانات', style: TextStyle(color: Colors.grey[600]))),
        const SizedBox(height: 12),
        Center(
          child: TextButton(onPressed: _loadListings, child: const Text('إعادة المحاولة')),
        ),
      ],
    );
  }
}