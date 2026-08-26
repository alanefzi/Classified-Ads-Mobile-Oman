import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/network/dio_client.dart';
import '../../data/models/listing_model.dart';
import '../../data/repositories/home_repository.dart';
import '../../../../core/services/recently_viewed_service.dart';

class ListingDetailPage extends StatefulWidget {
  final int listingId;
  const ListingDetailPage({super.key, required this.listingId});

  @override
  State<ListingDetailPage> createState() => _ListingDetailPageState();
}

class _ListingDetailPageState extends State<ListingDetailPage> {
  final _repo = HomeRepository();
  ListingModel? _listing;
  bool _loading = true;
  bool _error = false;
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadListing();
  }

  Future<void> _loadListing() async {
    setState(() {
      _loading = true;
      _error = false;
    });
    try {
      final result = await _repo.getListingDetail(widget.listingId);
      if (mounted) setState(() { _listing = result; _loading = false; });
      // نسجّل المشاهدة محلياً (بدون انتظار — ما يأثر على سرعة عرض الصفحة)
      RecentlyViewedService.instance.addListing(widget.listingId);
    } catch (_) {
      if (mounted) setState(() { _error = true; _loading = false; });
    }
  }

  /// وقت نسبي بسيط بدون أي حزمة خارجية (منذ ٣ أيام، منذ ساعتين...)
  String _relativeTime(DateTime? date) {
    if (date == null) return '';
    final diff = DateTime.now().difference(date);
    if (diff.inDays >= 30) return 'منذ ${(diff.inDays / 30).floor()} شهر';
    if (diff.inDays >= 1) return 'منذ ${diff.inDays} يوم';
    if (diff.inHours >= 1) return 'منذ ${diff.inHours} ساعة';
    if (diff.inMinutes >= 1) return 'منذ ${diff.inMinutes} دقيقة';
    return 'الآن';
  }

  Future<void> _callSeller(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _whatsappSeller(String phone) async {
    // يشيل أي رموز غير رقمية من الرقم قبل بناء رابط واتساب
    final cleaned = phone.replaceAll(RegExp(r'[^0-9]'), '');
    final uri = Uri.parse('https://wa.me/$cleaned');
    if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error || _listing == null
                ? _buildErrorState()
                : _buildContent(_listing!),
        bottomNavigationBar: (!_loading && _listing != null)
            ? ListingContactBar(
                phone: _listing!.sellerPhone,
                onCall: () => _callSeller(_listing!.sellerPhone!),
                onWhatsapp: () => _whatsappSeller(_listing!.sellerPhone!),
              )
            : null,
      ),
    );
  }

  Widget _buildErrorState() {
    return SafeArea(
      child: Column(
        children: [
          Align(
            alignment: Alignment.topRight,
            child: IconButton(
              icon: const Icon(Icons.arrow_forward_ios_rounded),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          const Expanded(
            child: Center(
              child: Text('تعذّر تحميل تفاصيل الإعلان', style: TextStyle(color: Colors.grey)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(ListingModel listing) {
    return CustomScrollView(
      slivers: [
        // ===== معرض الصور =====
        SliverToBoxAdapter(
          child: Stack(
            children: [
              AspectRatio(
                aspectRatio: 1.1,
                child: listing.images.isEmpty
                    ? Container(
                        color: const Color(0xFFF3F1FA),
                        child: const Icon(Icons.image_not_supported_outlined, size: 48, color: Colors.grey),
                      )
                    : PageView.builder(
                        itemCount: listing.images.length,
                        onPageChanged: (i) => setState(() => _currentImageIndex = i),
                        itemBuilder: (context, index) => CachedNetworkImage(
                          imageUrl: fullImageUrl(listing.images[index]),
                          fit: BoxFit.cover,
                          width: double.infinity,
                          placeholder: (_, __) => Container(color: const Color(0xFFF3F1FA)),
                          errorWidget: (_, __, ___) => Container(
                            color: const Color(0xFFF3F1FA),
                            child: const Icon(Icons.image_not_supported_outlined, color: Colors.grey),
                          ),
                        ),
                      ),
              ),
              // زر الرجوع
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: _CircleIconButton(
                    icon: Icons.arrow_forward_ios_rounded,
                    onTap: () => Navigator.of(context).pop(),
                  ),
                ),
              ),
              // شارة VIP
              if (listing.isFeatured)
                Positioned(
                  top: 60,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E2B5C),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text('VIP', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              // مؤشر عدد الصور
              if (listing.images.length > 1)
                Positioned(
                  bottom: 12,
                  right: 0,
                  left: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(listing.images.length, (i) {
                      return Container(
                        width: 6,
                        height: 6,
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: i == _currentImageIndex ? Colors.white : Colors.white.withOpacity(0.5),
                        ),
                      );
                    }),
                  ),
                ),
            ],
          ),
        ),

        // ===== التفاصيل =====
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // السعر
                if (listing.price != null)
                  Text(
                    '${listing.price} ${listing.currency}',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF5FBFA0)),
                  ),
                const SizedBox(height: 6),
                // العنوان
                Text(
                  listing.title,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2E2B5C)),
                ),
                const SizedBox(height: 10),
                // شارات: قابل للتفاوض / الحالة
                Wrap(
                  spacing: 8,
                  children: [
                    if (listing.isNegotiable) _Chip(label: 'قابل للتفاوض', color: const Color(0xFF5FBFA0)),
                    if (listing.condition == 'new') _Chip(label: 'جديد', color: const Color(0xFF378ADD)),
                    if (listing.condition == 'used') _Chip(label: 'مستعمل', color: Colors.orange),
                  ],
                ),
                const SizedBox(height: 12),
                // بيانات ثانوية: الفئة، المدينة، المشاهدات، الوقت
                Wrap(
                  spacing: 12,
                  runSpacing: 4,
                  children: [
                    if (listing.categoryNameAr != null) _MetaItem(icon: Icons.category_outlined, text: listing.categoryNameAr!),
                    if (listing.cityNameAr != null) _MetaItem(icon: Icons.location_on_outlined, text: listing.cityNameAr!),
                    if (listing.viewsCount != null) _MetaItem(icon: Icons.visibility_outlined, text: '${listing.viewsCount} مشاهدة'),
                    if (listing.createdAt != null) _MetaItem(icon: Icons.access_time_rounded, text: _relativeTime(listing.createdAt)),
                  ],
                ),
                const Divider(height: 32),
                // الوصف
                if (listing.description != null && listing.description!.isNotEmpty) ...[
                  const Text('الوصف', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF2E2B5C))),
                  const SizedBox(height: 8),
                  Text(listing.description!, style: const TextStyle(fontSize: 14, color: Color(0xFF4A4760), height: 1.6)),
                  const Divider(height: 32),
                ],
                // بطاقة البائع
                if (listing.sellerName != null) ...[
                  const Text('البائع', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF2E2B5C))),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: const Color(0xFFEDEBF5),
                        backgroundImage: listing.sellerAvatar != null && listing.sellerAvatar!.isNotEmpty
                            ? CachedNetworkImageProvider(fullImageUrl(listing.sellerAvatar!))
                            : null,
                        child: listing.sellerAvatar == null || listing.sellerAvatar!.isEmpty
                            ? const Icon(Icons.person, color: Color(0xFF2E2B5C))
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          listing.sellerName!,
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF2E2B5C)),
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 90), // مساحة لشريط الاتصال الثابت بالأسفل
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// شريط ثابت بالأسفل لصفحة التفاصيل: اتصال + واتساب
/// استخدمه كـ bottomNavigationBar عند بناء الصفحة داخل Scaffold يحتوي البيانات
class ListingContactBar extends StatelessWidget {
  final String? phone;
  final VoidCallback onCall;
  final VoidCallback onWhatsapp;

  const ListingContactBar({super.key, required this.phone, required this.onCall, required this.onWhatsapp});

  @override
  Widget build(BuildContext context) {
    if (phone == null || phone!.isEmpty) return const SizedBox.shrink();
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, -2))],
        ),
        child: SafeArea(
          top: false,
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onCall,
                  icon: const Icon(Icons.call_rounded, size: 18),
                  label: const Text('اتصال'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF2E2B5C),
                    side: const BorderSide(color: Color(0xFF2E2B5C)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onWhatsapp,
                  icon: const Icon(Icons.chat_bubble_rounded, size: 18),
                  label: const Text('واتساب'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF25D366),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
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

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CircleIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
        child: Icon(icon, size: 18, color: const Color(0xFF2E2B5C)),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;
  const _Chip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
    );
  }
}

class _MetaItem extends StatelessWidget {
  final IconData icon;
  final String text;
  const _MetaItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: Colors.grey),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}