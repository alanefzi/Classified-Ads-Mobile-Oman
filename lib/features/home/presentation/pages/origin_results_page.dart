import 'package:flutter/material.dart';
import '../../data/models/category_model.dart';
import '../../data/models/listing_model.dart';
import '../../data/repositories/home_repository.dart';
import 'listing_card.dart';
import 'listing_detail_page.dart';

/// صفحة نتائج مفلترة حسب بلد المنشأ (ضمن فئة معينة + فئاتها الفرعية)
class OriginResultsPage extends StatefulWidget {
  final CategoryModel category;
  final List<CategoryModel> allCategories;
  final String origin; // القيمة المخزّنة بحقل attributes.origin (مثلاً "ياباني")
  final String originLabel; // النص المعروض بالعنوان

  const OriginResultsPage({
    super.key,
    required this.category,
    required this.allCategories,
    required this.origin,
    required this.originLabel,
  });

  @override
  State<OriginResultsPage> createState() => _OriginResultsPageState();
}

class _OriginResultsPageState extends State<OriginResultsPage> {
  final _repo = HomeRepository();
  List<ListingModel> _listings = [];
  bool _loading = true;
  bool _error = false;

  List<int> get _relevantIds {
    final parentId = widget.category.id;
    final ids = <int>[if (parentId != null) parentId];
    for (final c in widget.allCategories) {
      if (c.parentId == parentId && c.id != null) ids.add(c.id!);
    }
    return ids;
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = false; });
    try {
      final results = await Future.wait(
        _relevantIds.map((id) => _repo.getListings(categoryId: id, origin: widget.origin)),
      );
      final merged = <int, ListingModel>{};
      for (final list in results) {
        for (final listing in list) {
          merged[listing.id] = listing;
        }
      }
      if (mounted) setState(() { _listings = merged.values.toList(); _loading = false; });
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
          title: Text('${widget.category.nameAr} ${widget.originLabel}', style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
        body: SafeArea(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _error
                  ? _buildErrorState()
                  : _listings.isEmpty
                      ? _buildEmptyState()
                      : RefreshIndicator(
                          onRefresh: _load,
                          child: GridView.builder(
                            padding: const EdgeInsets.all(16),
                            physics: const AlwaysScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 14,
                              crossAxisSpacing: 14,
                              childAspectRatio: 0.68,
                            ),
                            itemCount: _listings.length,
                            itemBuilder: (context, index) {
                              final listing = _listings[index];
                              return ListingCard(listing: listing, onTap: () => _openListing(listing), width: double.infinity);
                            },
                          ),
                        ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return ListView(
      children: [
        const SizedBox(height: 100),
        Icon(Icons.search_off_rounded, size: 48, color: Colors.grey[400]),
        const SizedBox(height: 12),
        Center(child: Text('لا توجد إعلانات بهذا المنشأ حالياً', style: TextStyle(color: Colors.grey[600]))),
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
        Center(child: TextButton(onPressed: _load, child: const Text('إعادة المحاولة'))),
      ],
    );
  }
}
