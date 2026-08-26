class ListingModel {
  final int id;
  final String title;
  final String? description;
  final String? price;
  final String currency;
  final String? categoryNameAr;
  final String? cityNameAr;
  final bool isFeatured;
  final List<String> images;

  // ✅ حقول إضافية لصفحة تفاصيل الإعلان
  final String? sellerName;
  final String? sellerAvatar;
  final String? sellerPhone;
  final bool isNegotiable;
  final String? condition; // 'new' أو 'used'
  final int? viewsCount;
  final DateTime? createdAt;
  final Map<String, dynamic>? attributes;

  ListingModel({
    required this.id,
    required this.title,
    this.description,
    this.price,
    required this.currency,
    this.categoryNameAr,
    this.cityNameAr,
    required this.isFeatured,
    required this.images,
    this.sellerName,
    this.sellerAvatar,
    this.sellerPhone,
    this.isNegotiable = false,
    this.condition,
    this.viewsCount,
    this.createdAt,
    this.attributes,
  });

  factory ListingModel.fromJson(Map<String, dynamic> json) {
    final imagesJson = json['images'] as List<dynamic>? ?? [];
    final user = json['user'] as Map<String, dynamic>?;

    return ListingModel(
      id: json['id'] as int,
      title: json['title'] ?? '',
      description: json['description'],
      price: json['price']?.toString(),
      currency: json['currency'] ?? '',
      categoryNameAr: json['category']?['name_ar'],
      cityNameAr: json['city']?['name_ar'],
      isFeatured: json['is_featured'] == true,
      images: imagesJson
          .map((img) => img['path']?.toString() ?? '')
          .where((p) => p.isNotEmpty)
          .toList(),
      sellerName: user?['name'],
      sellerAvatar: user?['avatar'],
      sellerPhone: user?['phone'],
      isNegotiable: json['is_negotiable'] == true,
      condition: json['condition'],
      viewsCount: json['views_count'] is int ? json['views_count'] as int : null,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
      attributes: json['attributes'] is Map<String, dynamic> ? json['attributes'] as Map<String, dynamic> : null,
    );
  }
}