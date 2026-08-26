class AgentModel {
  final int id;
  final String name;
  final String phone;
  final String whatsapp;
  final String? city;

  AgentModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.whatsapp,
    this.city,
  });

  factory AgentModel.fromJson(Map<String, dynamic> json) {
    final phone = json['phone'] ?? '';
    return AgentModel(
      id: json['id'] as int,
      name: json['name'] ?? '',
      phone: phone,
      // لو الواتساب فاضي، نستخدم رقم الهاتف نفسه تلقائياً
      whatsapp: (json['whatsapp'] == null || json['whatsapp'].toString().isEmpty) ? phone : json['whatsapp'],
      city: json['city'],
    );
  }
}
