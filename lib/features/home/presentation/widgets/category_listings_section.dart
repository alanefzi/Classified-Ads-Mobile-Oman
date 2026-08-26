import 'package:flutter/material.dart';
import '../../data/models/category_model.dart';
import '../../data/models/listing_model.dart';
import '../../data/repositories/home_repository.dart';
import '../pages/listing_card.dart';

/// قسم إعلانات فئة معينة — يعرض عنوان الفئة + تبويبين (مبوبة/تجارية) + شريط أفقي لبطاقات الإعلانات
/// حالياً تبويب "تجارية" فاضي لأن الباك اند ما يميّز نوع الإعلان بعد (مبوبة/تجاري)
/// لما تضيف حقل النوع بالباك اند، بس فعّل شرط الفلترة بدالة _loadListings
class CategoryListingsSection extends StatefulWidget {
  final List<CategoryModel> categories;
  final String categoryName; // اسم الفئة بالعربي بالضبط زي قاعدة البيانات (مثلاً 'سيارات')
  final String displayTitle; // العنوان المعروض (مثلاً 'إعلانات المحركات')
  final void Function(ListingModel listing) onListingTap;
  final VoidCallback? onSeeAllTap;

  const CategoryListingsSection({
    super.key,
    required this.categories,
    required this.categoryName,
    required this.displayTitle,
    required this.onListingTap,
    this.onSeeAllTap,
  });

  @override
  State<CategoryListingsSection> createState() => _CategoryListingsSectionState();
}

class _CategoryListingsSectionState extends State<CategoryListingsSection> {
  final _repo = HomeRepository();
  List<ListingModel> _listings = [];
  bool _loading = true;
  int _activeTab = 0; // 0 = مبوبة، 1 = تجارية

  /// يرجّع الفئة الرئيسية + كل فئاتها الفرعية (لأن الإعلانات مرتبطة بالفئات الفرعية غالباً)
  List<int> get _relevantCategoryIds {
    final parent = widget.categories.where((c) => c.nameAr == widget.categoryName).toList();
    if (parent.isEmpty) return [];

    final parentId = parent.first.id;
    final ids = <int>[if (parentId != null) parentId];

    for (final c in widget.categories) {
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
    final ids = _relevantCategoryIds;
    if (ids.isEmpty) {
      setState(() => _loading = false);
      return;
    }
    try {
      // نجيب إعلانات كل فئة (رئيسية + فرعية) بالتوازي وندمجهم
      final results = await Future.wait(ids.map((id) => _repo.getListings(categoryId: id)));
      final merged = <int, ListingModel>{};
      for (final list in results) {
        for (final listing in list) {
          merged[listing.id] = listing; // إزالة التكرار حسب رقم الإعلان
        }
      }
      final combined = merged.values.toList();
      if (mounted) {
        setState(() {
          _listings = combined;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // ما نعرض القسم إطلاقاً لو الفئة مو موجودة أو ما فيها إعلانات
    if (!_loading && (_relevantCategoryIds.isEmpty || _listings.isEmpty)) {
      return const SizedBox.shrink();
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.displayTitle,
                    style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: Color(0xFF2E2B5C)),
                  ),
                  if (widget.onSeeAllTap != null)
                    InkWell(
                      onTap: widget.onSeeAllTap,
                      child: Row(
                        children: const [
                          Text('عرض الكل', style: TextStyle(fontSize: 13, color: Color(0xFF5FBFA0), fontWeight: FontWeight.w600)),
                          SizedBox(width: 4),
                          Icon(Icons.arrow_back_ios_new_rounded, size: 12, color: Color(0xFF5FBFA0)),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _TabButton(
                    label: 'إعلانات مبوبة',
                    isActive: _activeTab == 0,
                    onTap: () => setState(() => _activeTab = 0),
                  ),
                  const SizedBox(width: 20),
                  _TabButton(
                    label: 'إعلانات تجارية',
                    isActive: _activeTab == 1,
                    onTap: () => setState(() => _activeTab = 1),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            const Divider(height: 1),
            const SizedBox(height: 12),
            if (_loading)
              const SizedBox(
                height: 220,
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              )
            else if (_activeTab == 1)
              // تبويب "تجارية" — لا يوجد تمييز بالباك اند بعد
              const SizedBox(
                height: 100,
                child: Center(
                  child: Text('لا توجد إعلانات تجارية حالياً', style: TextStyle(color: Colors.grey)),
                ),
              )
            else
              SizedBox(
                height: 260,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _listings.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final listing = _listings[index];
                    return ListingCard(
                      listing: listing,
                      onTap: () => widget.onListingTap(listing),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _TabButton({required this.label, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                color: isActive ? const Color(0xFF2E2B5C) : Colors.grey,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              height: 3,
              width: 70,
              decoration: BoxDecoration(
                color: isActive ? const Color(0xFF2E2B5C) : Colors.transparent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}