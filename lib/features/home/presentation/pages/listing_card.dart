import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/network/dio_client.dart';
import '../../data/models/listing_model.dart';

/// كارد إعلان قابل لإعادة الاستخدام — يُستخدم بالشريط الأفقي بالصفحة الرئيسية
/// وبصفحة نتائج الفئة (شبكة كاملة)
class ListingCard extends StatelessWidget {
  final ListingModel listing;
  final VoidCallback onTap;
  final double width;

  const ListingCard({
    super.key,
    required this.listing,
    required this.onTap,
    this.width = 165,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = listing.images.isNotEmpty ? fullImageUrl(listing.images.first) : null;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: width,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFEDEBF5)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 1.15,
                  child: imageUrl != null
                      ? CachedNetworkImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          placeholder: (_, __) => Container(color: const Color(0xFFF3F1FA)),
                          errorWidget: (_, __, ___) => Container(
                            color: const Color(0xFFF3F1FA),
                            child: const Icon(Icons.image_not_supported_outlined, color: Colors.grey),
                          ),
                        )
                      : Container(
                          color: const Color(0xFFF3F1FA),
                          child: const Icon(Icons.image_not_supported_outlined, color: Colors.grey),
                        ),
                ),
                if (listing.isFeatured)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2E2B5C),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'VIP',
                        style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (listing.categoryNameAr != null || listing.cityNameAr != null)
                    Text(
                      [listing.categoryNameAr, listing.cityNameAr].where((e) => e != null && e.isNotEmpty).join(' , '),
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 4),
                  Text(
                    listing.title,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF2E2B5C)),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  if (listing.price != null)
                    Text(
                      '${listing.price} ${listing.currency}',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF5FBFA0)),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
