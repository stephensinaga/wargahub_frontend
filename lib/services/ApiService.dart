import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/ReportHistory.dart';
import 'package:wargahub_frontend/config/constant.dart';


class ApiService {
  static Future<List<ReportHistory>> fetchReportHistory(int reportId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('auth_token');

    if (token == null) {
      return [];
    }

    try {
      final response = await http.get(
        Uri.parse("${ApiConstants.baseUrl}/reports/$reportId/history"),
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body)['data'];
        return data.map((json) => ReportHistory.fromJson(json)).toList();
      }
    } catch (e) {
      print("Error: $e");
    }

    return [];
  }
}
