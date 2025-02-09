import 'dart:convert';

class Report {
  final int id;
  final int userId;
  final String category;
  final String photo1;
  final String photo2;
  final String photo3;
  final String description;
  final String latitude;
  final String longitude;
  final String address;
  final String status;
  final DateTime createdAt;

  Report({
    required this.id,
    required this.userId,
    required this.category,
    required this.photo1,
    required this.photo2,
    required this.photo3,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.status,
    required this.createdAt,
  });

  // Factory method untuk mengubah JSON menjadi object Report
  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      id: json['id'],
      userId: json['user_id'],
      category: json['category'],
      photo1: json['photo_1'],
      photo2: json['photo_2'],
      photo3: json['photo_3'],
      description: json['description'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      address: json['address'],
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  // Method untuk mengubah object Report menjadi JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'category': category,
      'photo_1': photo1,
      'photo_2': photo2,
      'photo_3': photo3,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // Untuk mengonversi list JSON menjadi list object Report
  static List<Report> fromJsonList(String str) {
    final List<dynamic> jsonData = json.decode(str);
    return jsonData.map((item) => Report.fromJson(item)).toList();
  }
}
