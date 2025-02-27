import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wargahub_frontend/config/constant.dart';

class ReportDetailPetugasScreen extends StatefulWidget {
  final int assignmentId;

  const ReportDetailPetugasScreen({super.key, required this.assignmentId});

  @override
  _ReportDetailPetugasScreen createState() => _ReportDetailPetugasScreen();
}

class _ReportDetailPetugasScreen extends State<ReportDetailPetugasScreen> {
  Map<String, dynamic>? report;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchReportDetail();
  }

  /// Fungsi untuk memperbarui status laporan 
  Future<void> _updateReportStatus(String newStatus) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    if (token == null) {
      print("⚠️ Token tidak ditemukan, logout pengguna!");
      if (mounted) {
        Navigator.pushReplacementNamed(context, "/login");
      }
      return;
    }

    try {
      final response = await http.post(
        Uri.parse("${ApiConstants.baseUrl}/officer/assignments/${widget.assignmentId}/update"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json"
        },
        body: jsonEncode({"status": newStatus}),
      );

      print("📩 Response Code: ${response.statusCode}");
      print("📩 Response Body: ${response.body}");

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Status berhasil diperbarui!"))
        );

        // Refresh tampilan setelah update berhasil
        _fetchReportDetail();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal memperbarui status: ${response.body}"))
        );
      }
    } catch (e) {
      print("❌ Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Terjadi kesalahan: $e"))
      );
    }
  }

/// Fungsi untuk menyelesaikan tugas (ubah status ke "completed")
Future<void> _completeReport() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('auth_token');

  if (token == null) {
    print("⚠️ Token tidak ditemukan, logout pengguna!");
    if (mounted) {
      Navigator.pushReplacementNamed(context, "/login");
    }
    return;
  }

  try {
    final response = await http.post(
      Uri.parse("${ApiConstants.baseUrl}/officer/assignments/${widget.assignmentId}/complete"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json"
      },
    );

    print("📩 Response Code: ${response.statusCode}");
    print("📩 Response Body: ${response.body}");

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Laporan berhasil diselesaikan!"))
      );

      // Refresh tampilan setelah update berhasil
      _fetchReportDetail();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal menyelesaikan laporan: ${response.body}"))
      );
    }
  } catch (e) {
    print("❌ Error: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Terjadi kesalahan: $e"))
    );
  }
}

  /// Mengambil detail laporan berdasarkan assignmentId
  Future<void> _fetchReportDetail() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    if (token == null) {
      print("⚠️ Token tidak ditemukan, logout pengguna!");
      if (mounted) {
        Navigator.pushReplacementNamed(context, "/login");
      }
      return;
    }

    try {
      final response = await http.get(
        Uri.parse("${ApiConstants.baseUrl}/officer/assignments/${widget.assignmentId}"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json"
        },
      );

      print("📩 Response Code: ${response.statusCode}");
      print("📩 Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        setState(() {
          report = responseData['report'];
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = "Gagal mengambil data laporan: ${response.body}";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "Terjadi kesalahan: $e";
        isLoading = false;
      });
      print("❌ Error: $e");
    }
  }

  /// Widget untuk menampilkan informasi laporan
  Widget _buildReportDetail() {
    if (report == null) {
      return const Center(child: Text("Data laporan tidak ditemukan."));
    }

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        _buildInfoTile("Kategori", report!['category']),
        _buildInfoTile("Deskripsi", report!['description']),
        _buildInfoTile("Alamat", "${report!['address']}, ${report!['kecamatan']}, ${report!['kota']}"),
        _buildInfoTile("Status", _getStatusText(report!['status'])),

        const SizedBox(height: 16),

        // Tombol update status
        _buildUpdateStatusButton(),

        // Menampilkan foto laporan
        _buildReportImage(report!['photo_1']),
        _buildReportImage(report!['photo_2']),
        _buildReportImage(report!['photo_3']),
      ],
    );
  }

  /// Widget untuk menampilkan informasi dengan desain lebih rapi
  Widget _buildInfoTile(String title, String? value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          value ?? "-",
          style: const TextStyle(fontSize: 14, color: Colors.black87),
        ),
        const Divider(),
      ],
    );
  }

  /// Menampilkan gambar laporan dengan placeholder jika gagal
  Widget _buildReportImage(String? imageUrl) {
    if (imageUrl == null) return Container();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Image.network(
        "${ApiConstants.urlReal}/storage/$imageUrl",
        height: 200,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          height: 200,
          color: Colors.grey[300],
          child: const Icon(Icons.image_not_supported, size: 50),
        ),
      ),
    );
  }

  /// Tombol untuk memperbarui status
Widget _buildUpdateStatusButton() {
  if (report == null) {
    return SizedBox();
  }

  if (report!['status'] == 'accepted') {
    return ElevatedButton(
      onPressed: () async {
        await _updateReportStatus('in_progress'); // Ubah status ke "Sedang Dikerjakan"
        _fetchReportDetail(); // Refresh data setelah update
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
      child: const Text("Mulai Kerjakan", style: TextStyle(color: Colors.white)),
    );
  } else if (report!['status'] == 'in_progress') {
    return ElevatedButton(
      onPressed: () async {
        await _completeReport(); // Ubah status ke "Selesai"
        _fetchReportDetail(); // Refresh data setelah update
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
      child: const Text("Selesaikan", style: TextStyle(color: Colors.white)),
    );
  }

  return SizedBox(); // Jika status tidak cocok, tombol tidak ditampilkan
}

  

  /// Mengubah status menjadi teks lebih jelas
  String _getStatusText(String? status) {
    switch (status) {
      case 'pending':
        return "Menunggu Verifikasi";
      case 'accepted':
        return "Diterima";
      case 'rejected':
        return "Ditolak";
      case 'assigned':
        return "Menunggu Dikerjakan";
      case 'in_progress':
        return "Sedang Dikerjakan";
      case 'completed':
        return "Selesai";
      default:
        return "Tidak diketahui";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Detail Laporan"),
        backgroundColor: const Color(0xff3a57e8),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : (errorMessage != null
              ? Center(child: Text(errorMessage!, style: const TextStyle(color: Colors.red)))
              : _buildReportDetail()),
    );
  }
}
