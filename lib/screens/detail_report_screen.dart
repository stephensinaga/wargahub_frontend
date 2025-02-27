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
  List<dynamic> reportHistory = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchReportDetail();
    fetchReportHistory(); // Ambil timeline riwayat status laporan
  }

  Future<void> fetchReportDetail() async {
    setState(() => isLoading = true);

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('auth_token');

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Anda harus login terlebih dahulu!")),
      );
      setState(() => isLoading = false);
      return;
    }

    try {
      final response = await http.get(
        Uri.parse("${ApiConstants.baseUrl}/reports/${widget.reportId}"),
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        setState(() => report = jsonDecode(response.body)['data']);
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
      setState(() => isLoading = false);
    }
  }

  Future<void> fetchReportHistory() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('auth_token');

    if (token == null) return;

    try {
      final response = await http.get(
        Uri.parse("${ApiConstants.baseUrl}/reports/${widget.reportId}/history"),
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        setState(() => reportHistory = jsonDecode(response.body)['data']);
      }
    } catch (e) {
      print("Error: $e");
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
                  child: ListView(
                    children: [
                      // Gambar dalam bentuk carousel
                      _buildImageCarousel(),

                      SizedBox(height: 16),
                      _buildDetailItem("Kategori", report!['category']),
                      _buildDetailItem("Deskripsi", report!['description']),
                      
                      Divider(),
                      _buildDetailItem("Alamat", report!['address']),
                      _buildDetailItem("Kota", report!['kota']),
                      _buildDetailItem("Kecamatan", report!['kecamatan']),

                      SizedBox(height: 10),
                      _buildStatusBadge(report!['status']),

                      Divider(),
                      Text("Riwayat Perubahan Status", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      SizedBox(height: 10),
                      _buildTimeline(),

                      SizedBox(height: 20),
                      Center(
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text("Kembali"),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildImageCarousel() {
    List<String> images = [
      if (report!['photo_1'] != null && report!['photo_1'].toString().isNotEmpty)
        report!['photo_1'].toString(),
      if (report!['photo_2'] != null && report!['photo_2'].toString().isNotEmpty)
        report!['photo_2'].toString(),
      if (report!['photo_3'] != null && report!['photo_3'].toString().isNotEmpty)
        report!['photo_3'].toString(),
    ];

    if (images.isEmpty) {
      return Center(child: Text("Tidak ada gambar tersedia"));
    }

    return SizedBox(
      height: 180,
      child: PageView.builder(
        itemCount: images.length,
        itemBuilder: (context, index) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              "${ApiConstants.urlReal}/storage/${images[index]}",
              fit: BoxFit.cover,
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailItem(String title, String? value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        Text(value ?? "Tidak ada data", style: TextStyle(fontSize: 14)),
        SizedBox(height: 10),
      ],
    );
  }

  Widget _buildStatusBadge(String? status) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: _getStatusColor(status),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        _getStatusText(status), 
        style: TextStyle(color: Colors.white, fontSize: 14),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildTimeline() {
    if (reportHistory.isEmpty) {
      return Center(child: Text("Belum ada riwayat status."));
    }

    return Column(
      children: reportHistory.map((history) {
        return ListTile(
          leading: _buildStatusIcon(history['status']),
          title: Text(_getStatusText(history['status']), style: TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text("Diubah oleh: ${history['user']['name']} \n${_formatDate(history['created_at'])}"),
        );
      }).toList(),
    );
  }

  Widget _buildStatusIcon(String status) {
    IconData icon;
    Color color;

    switch (status) {
      case 'pending':
        icon = Icons.hourglass_empty;
        color = Colors.orange;
        break;
      case 'accepted':
        icon = Icons.check_circle;
        color = Colors.green;
        break;
      case 'rejected':
        icon = Icons.cancel;
        color = Colors.red;
        break;
      case 'in_progress':
        icon = Icons.sync;
        color = Colors.blue;
        break;
      case 'completed':
        icon = Icons.done_all;
        color = Colors.purple;
        break;
      default:
        icon = Icons.info;
        color = Colors.grey;
    }

    return Icon(icon, color: color, size: 30);
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


  String _formatDate(String dateString) {
    DateTime date = DateTime.parse(dateString);
    return "${date.day}/${date.month}/${date.year} - ${date.hour}:${date.minute}";
  }
}
