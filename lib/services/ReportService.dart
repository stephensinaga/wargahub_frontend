import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class ReportService {
  static const String baseUrl = "http://192.168.50.51:4500/api"; // Ganti sesuai IP Laravel

  // 🟢 Fungsi untuk mengirim laporan
  static Future<bool> sendReport({
    required String category,
    required File photo1,
    required File photo2,
    required File photo3,
    required String description,
    required String latitude,
    required String longitude,
    required String address,
    required String token, // Token autentikasi
  }) async {
    var uri = Uri.parse('$baseUrl/report');

    var request = http.MultipartRequest("POST", uri);
    request.headers['Authorization'] = 'Bearer $token';

    request.fields['category'] = category;
    request.fields['description'] = description;
    request.fields['latitude'] = latitude;
    request.fields['longitude'] = longitude;
    request.fields['address'] = address;

    request.files.add(await http.MultipartFile.fromPath('photo_1', photo1.path));
    request.files.add(await http.MultipartFile.fromPath('photo_2', photo2.path));
    request.files.add(await http.MultipartFile.fromPath('photo_3', photo3.path));

    var response = await request.send();

    if (response.statusCode == 201) {
      return true;
    } else {
      return false;
    }
  }

  // 🟢 Fungsi untuk mengambil semua laporan
  static Future<List<dynamic>> getReports(String token) async {
    var response = await http.get(
      Uri.parse('$baseUrl/report'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Gagal mengambil laporan');
    }
  }
}
