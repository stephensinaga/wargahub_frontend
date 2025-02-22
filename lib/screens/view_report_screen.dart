import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:wargahub_frontend/config/constant.dart';
import 'detail_report_screen.dart';

class ViewReportScreen extends StatefulWidget {
  @override
  _ViewReportScreenState createState() => _ViewReportScreenState();
}

class _ViewReportScreenState extends State<ViewReportScreen> {
  late Future<List<dynamic>> futureReports;

  @override
  void initState() {
    super.initState();
    futureReports = fetchUserReports();
  }

  Future<List<dynamic>> fetchUserReports() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('auth_token');

    if (token == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Anda harus login terlebih dahulu!")),
        );
      }
      return [];
    }

    try {
      final response = await http.get(
        Uri.parse("${ApiConstants.baseUrl}/reports/user"),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json"
        },
      );

      print("Token yang dikirim: $token");
      print("Response Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final List<dynamic> responseData = jsonDecode(response.body);
        return responseData;
      } else if (response.statusCode == 401) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Sesi habis, silakan login kembali")),
          );
        }
        await prefs.remove('auth_token');
        return [];
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Gagal mengambil data laporan")),
          );
        }
      }
    } catch (e) {
      print("Error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Terjadi kesalahan saat mengambil data")),
        );
      }
    }
    return [];
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Laporan Saya")),
      body: FutureBuilder<List<dynamic>>(
        future: futureReports,
        builder: (context, snapshot) {
          print("Snapshot Data: ${snapshot.data}");
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Terjadi kesalahan, coba lagi"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("Belum ada laporan"));
          }

          final reports = snapshot.data!;

          return ListView.builder(
            itemCount: reports.length,
            itemBuilder: (context, index) {
              final report = reports[index];

            print("Laporan ke-${index + 1}: ${report['category']}");

              return Card(
                margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: ListTile(
                  leading: report['photo_1'] != null && report['photo_1'].isNotEmpty
                      ? Image.network(
                          "${ApiConstants.urlReal}/storage/${report['photo_1']}",
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Icon(Icons.image_not_supported),
                        )
                      : Icon(Icons.image_not_supported, size: 50),
                  title: Text(
                    report['category'] ?? "Tanpa Kategori",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(report['description'] ?? "Tanpa Deskripsi"),
                      SizedBox(height: 5),
                      Text(
                        _getStatusText(report['status']),
                        style: TextStyle(color: _getStatusColor(report['status']), fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 5),
                      Text(
                        "Dibuat pada: ${_formatDate(report['created_at'])}",
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                  trailing: Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailReportScreen(
                          reportId: report['id'].toString(),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  /// 🔹 **Fungsi untuk mengubah status menjadi teks yang lebih informatif**
  String _getStatusText(String? status) {
    switch (status) {
      case 'pending':
        return "Menunggu Verifikasi";
      case 'accepted':
        return "Diterima";
      case 'rejected':
        return "Ditolak";
      case 'in_progress':
        return "Sedang Dikerjakan";
      case 'completed':
        return "Selesai";
      default:
        return "Tidak diketahui";
    }
  }

  /// 🔹 **Fungsi untuk memberi warna pada status laporan**
  Color _getStatusColor(String? status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'accepted':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'in_progress':
        return Colors.blue;
      case 'completed':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  /// 🔹 **Fungsi untuk memformat tanggal dengan lebih rapi**
  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return "Tidak diketahui";
    DateTime date = DateTime.parse(dateStr);
    return "${date.day}-${date.month}-${date.year} ${date.hour}:${date.minute}";
  }
}
