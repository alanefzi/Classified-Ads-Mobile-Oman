import 'dart:io';
import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../models/listing_model.dart';

class ListingRepository {
  final Dio _dio = DioClient.instance.dio;

  Future<List<ListingModel>> fetchListings() async {
    try {
      final response = await _dio.get('/listings');
      final List<dynamic> data = response.data['data']['data'];
      return data.map((e) => ListingModel.fromJson(e)).toList();
    } catch (e) {
      throw Exception('فشل في جلب الإعلانات: $e');
    }
  }

  Future<List<ListingModel>> fetchFeaturedListings() async {
    final all = await fetchListings();
    return all.where((l) => l.isFeatured).toList();
  }

  /// ينشر إعلان جديد ويرجّع رقمه (id) — الحساب يحتاج تسجيل دخول (Bearer token)
  Future<int> createListing({
    required int categoryId,
    required int cityId,
    required String title,
    String? description,
    double? price,
    required String currency,
    bool isNegotiable = false,
    String? condition, // 'new' أو 'used'
    Map<String, dynamic>? attributes,
  }) async {
    final response = await _dio.post('/listings', data: {
      'category_id': categoryId,
      'city_id': cityId,
      'title': title,
      'description': description,
      'price': price,
      'currency': currency,
      'is_negotiable': isNegotiable,
      if (condition != null) 'condition': condition,
      'attributes': attributes ?? {},
    });

    if (response.data['success'] != true) {
      throw Exception(response.data['message'] ?? 'فشل نشر الإعلان');
    }

    return response.data['data']['id'] as int;
  }

  /// يرفع صور الإعلان بعد إنشائه (يقبل أكثر من صورة دفعة وحدة)
  Future<void> uploadImages(int listingId, List<File> images) async {
    if (images.isEmpty) return;

    final formData = FormData();
    for (final file in images) {
      formData.files.add(MapEntry(
        'images[]',
        await MultipartFile.fromFile(file.path, filename: file.path.split(Platform.pathSeparator).last),
      ));
    }

    final response = await _dio.post('/listings/$listingId/images', data: formData);

    if (response.data['success'] != true) {
      throw Exception(response.data['message'] ?? 'فشل رفع الصور');
    }
  }
}