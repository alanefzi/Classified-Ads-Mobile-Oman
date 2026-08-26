class BannerModel {
  final int id;
  final String title;
  final String image;
  final String? link;

  BannerModel({
    required this.id,
    required this.title,
    required this.image,
    this.link,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: json['id'] as int,
      title: json['title'] ?? '',
      image: json['image'] ?? '',
      link: json['link'],
    );
  }
}