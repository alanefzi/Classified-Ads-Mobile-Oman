class CategoryModel {
  final int? id;
  final String? nameAr;
  final String? nameEn;
  final String? icon;
  final int? parentId;
  final int? sortOrder; // ← أضف هذا

  CategoryModel({
    this.id,
    this.nameAr,
    this.nameEn,
    this.icon,
    this.parentId,
    this.sortOrder, // ← أضف هذا
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'],
      nameAr: json['name_ar'] ?? json['nameAr'],
      nameEn: json['name_en'] ?? json['nameEn'],
      icon: json['icon'],
      parentId: json['parent_id'] ?? json['parentId'],
      sortOrder: json['sort_order'] ?? json['sortOrder'] ?? 0, // ← أضف هذا
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name_ar': nameAr,
      'name_en': nameEn,
      'icon': icon,
      'parent_id': parentId,
      'sort_order': sortOrder, // ← أضف هذا
    };
  }
}