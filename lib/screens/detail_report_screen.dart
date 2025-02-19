import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wargahub_frontend/config/constant.dart';

class DetailReportScreen extends StatefulWidget {
  final String reportId;

  DetailReportScreen({required this.reportId});

  @override
  _DetailReportScreenState createState() => _DetailReportScreenState();
}

class _DetailReportScreenState extends State<DetailReportScreen> {
  Map<String, dynamic>? report;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchReportDetail();
  }

  Future<void> fetchReportDetail() async {
    setState(() {
      isLoading = true;
    });

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('auth_token');

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Anda harus login terlebih dahulu!")),
      );
      setState(() {
        isLoading = false;
      });
      return;
    }

    try {
      final response = await http.get(
        Uri.parse("${ApiConstants.baseUrl}/reports/${widget.reportId}"),
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        setState(() {
          report = jsonDecode(response.body);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal mengambil detail laporan")),
        );
      }
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Terjadi kesalahan saat mengambil data")),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Detail Laporan")),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : report == null
              ? Center(child: Text("Data tidak ditemukan"))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Image.network(
                          report!['image_url'] ?? "https://via.placeholder.com/150",
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                      ),
                      SizedBox(height: 16),
                      Text("Kategori:", style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(report!['category'] ?? "Tidak ada kategori"),
                      SizedBox(height: 10),
                      Text("Deskripsi:", style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(report!['description'] ?? "Tidak ada deskripsi"),
                      SizedBox(height: 10),
                      Text("Lokasi:", style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(report!['location'] ?? "Tidak ada lokasi"),
                      SizedBox(height: 10),
                      Text("Status:", style: TextStyle(fontWeight: FontWeight.bold)),
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                        decoration: BoxDecoration(
                          color: _getStatusColor(report!['status']),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          _getStatusText(report!['status']),
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      SizedBox(height: 20),
                      Center(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text("Kembali"),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

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
}
