class PageModel {
  final String slug;
  final String titleAr;
  final String contentAr;
  final bool isActive;

  PageModel({
    required this.slug,
    required this.titleAr,
    required this.contentAr,
    required this.isActive,
  });

  factory PageModel.fromJson(Map<String, dynamic> json) {
    return PageModel(
      slug: json['slug'] ?? '',
      titleAr: json['title_ar'] ?? '',
      contentAr: json['content_ar'] ?? '',
      isActive: json['is_active'] == true,
    );
  }
}
