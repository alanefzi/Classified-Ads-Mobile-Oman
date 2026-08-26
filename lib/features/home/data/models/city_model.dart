class CityModel {
  final int id;
  final String nameAr;

  CityModel({required this.id, required this.nameAr});

  factory CityModel.fromJson(Map<String, dynamic> json) {
    return CityModel(
      id: json['id'] as int,
      nameAr: json['name_ar'] ?? '',
    );
  }
}
