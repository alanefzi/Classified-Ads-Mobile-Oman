class CountryModel {
  final int id;
  final String nameAr;

  CountryModel({required this.id, required this.nameAr});

  factory CountryModel.fromJson(Map<String, dynamic> json) {
    return CountryModel(
      id: json['id'] as int,
      nameAr: json['name_ar'] ?? '',
    );
  }
}
