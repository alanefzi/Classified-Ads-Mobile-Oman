import 'package:flutter/material.dart';
import '../../../../core/services/recently_viewed_service.dart';
import '../../data/repositories/home_repository.dart';
import '../../data/models/listing_model.dart';
import 'listing_card.dart';
import 'listing_detail_page.dart';

class RecentlyViewedPage extends StatefulWidget {
  const RecentlyViewedPage({super.key});

  @override
  State<RecentlyViewedPage> createState() => _RecentlyViewedPageState();
}

class _RecentlyViewedPageState extends State<RecentlyViewedPage> {
  final _repo = HomeRepository();
  List<ListingModel> _listings = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final ids = await RecentlyViewedService.instance.getIds();

    if (ids.isEmpty) {
      if (mounted) setState(() { _listings = []; _loading = false; });
      return;
    }

    // نجيب تفاصيل كل إعلان بالتوازي، ونتجاهل بصمت أي إعلان انحذف أو صار غير متاح
    final results = await Future.wait(
      ids.map((id) async {
        try {
          return await _repo.getListingDetail(id);
        } catch (_) {
          return null;
        }
      }),
    );

    final validListings = results.whereType<ListingModel>().toList();

    if (mounted) setState(() { _listings = validListings; _loading = false; });
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
          title: const Text('شاهدت مؤخراً', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
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
    );
  }

  Widget _buildEmptyState() {
    return ListView(
      children: [
        const SizedBox(height: 100),
        Icon(Icons.visibility_outlined, size: 48, color: Colors.grey[400]),
        const SizedBox(height: 12),
        Center(child: Text('ما فتحت أي إعلان بعد', style: TextStyle(color: Colors.grey[600]))),
      ],
    );
  }
}
