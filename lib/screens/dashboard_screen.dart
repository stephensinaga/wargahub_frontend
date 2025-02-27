import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wargahub_frontend/screens/LoginScreen.dart';
import 'package:wargahub_frontend/screens/detail_report_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:wargahub_frontend/config/constant.dart';
import 'detail_report_petugas_screen.dart';

class DashboardPetugasScreen extends StatefulWidget {
  @override
  _DashboardPetugasScreenState createState() => _DashboardPetugasScreenState();
}

class _DashboardPetugasScreenState extends State<DashboardPetugasScreen> {
  String userName = "Petugas";
  String userEmail = "petugas@example.com";
  String? authToken;
  int _currentIndex = 0;
  List<dynamic> reports = []; // Menyimpan daftar laporan petugas

  @override
  void initState() {
    super.initState();
    loadUserData();
    fetchReports(); // Ambil laporan dari API
  }

  void refreshReports() {
    fetchReports(); // Pastikan data API terbaru diambil

    setState(() {
      reports = reports
          .where(
              (r) => r['status'] == 'accepted' || r['status'] == 'in_progress')
          .toList();
    });

    print(
        "🔄 Data diperbarui, laporan in_progress: ${reports.where((r) => r['status'] == 'in_progress').length}");
    print(
        "🔄 Data diperbarui, laporan completed: ${reports.where((r) => r['status'] == 'completed').length}");
  }

  /// Mengambil data user dan token
  Future<void> loadUserData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('auth_token');

    if (token == null || token.isEmpty) {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      }
      return;
    }

    setState(() {
      authToken = token;
      userName = prefs.getString('user_name') ?? "Petugas";
      userEmail = prefs.getString('user_email') ?? "petugas@example.com";
    });
  }

  /// Fetch laporan dari API berdasarkan status
  Future<void> fetchReports() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('auth_token');

    if (token == null || token.isEmpty) {
      print("⚠️ Token tidak ditemukan");
      return;
    }

    try {
      final response = await http.get(
        Uri.parse("${ApiConstants.baseUrl}/officer/assignments"),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      print("📡 API Response Status: ${response.statusCode}");
      print("📡 API Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        setState(() {
          reports = data
              .map((item) => {
                    'assignment_id': item['assignment_id'],
                    ...item['report'],
                  })
              .where(
                  (r) => r['status'] != 'rejected') // Hanya ambil status valid
              .toList();

          print("✅ Total laporan berhasil diambil: ${reports.length} laporan");
        });
      } else {
        print("❌ Gagal mengambil data laporan, status: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ Error Fetch Reports: $e");
    }
  }

  /// Fungsi logout
  Future<void> logout() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(title: Text("Dashboard Petugas")),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              UserAccountsDrawerHeader(
                accountName: Text(userName),
                accountEmail: Text(userEmail),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 40, color: Colors.blue),
                ),
              ),
              ListTile(
                leading: Icon(Icons.logout, color: Colors.red),
                title: Text("Logout", style: TextStyle(color: Colors.red)),
                onTap: logout,
              ),
            ],
          ),
        ),
        body: _getSelectedScreen(_currentIndex),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
                icon: Icon(Icons.dashboard), label: 'Dashboard'),
            BottomNavigationBarItem(
                icon: Icon(Icons.work), label: 'Sedang Dikerjakan'),
            BottomNavigationBarItem(icon: Icon(Icons.check), label: 'Selesai'),
          ],
        ),
      ),
    );
  }

  /// Fungsi untuk menampilkan layar sesuai indeks navigasi
  Widget _getSelectedScreen(int index) {
    if (index == 0) {
      // **Menampilkan hanya laporan yang diterima**
      return ReportListScreen(
        reports: reports.where((r) => r['status'] == 'accepted').toList(),
        onStatusChange: refreshReports, // Panggil refresh jika status berubah
      );
    } else if (index == 1) {
      // **Menampilkan hanya laporan yang sedang dikerjakan**
      return ReportListScreen(
        reports: reports.where((r) => r['status'] == 'in_progress').toList(),
        onStatusChange: refreshReports,
      );
    } else if (index == 2) {
      // **Menampilkan hanya laporan yang sudah selesai**
      return ReportListScreen(
        reports: reports.where((r) => r['status'] == 'completed').toList(),
        onStatusChange: refreshReports,
      );
    }
    return ReportListScreen(reports: reports);
  }

  /// Refresh data setelah perubahan status
}

/// Widget untuk menampilkan daftar laporan
class ReportListScreen extends StatelessWidget {
  final List<dynamic> reports;
  final VoidCallback? onStatusChange; // Tambahkan parameter baru

  ReportListScreen({required this.reports, this.onStatusChange});

  @override
  Widget build(BuildContext context) {
    return reports.isEmpty
        ? Center(child: CircularProgressIndicator())
        : ListView.builder(
            itemCount: reports.length,
            itemBuilder: (context, index) {
              final report = reports[index];
              return Card(
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: ListTile(
                      leading: Image.network(
                        "${ApiConstants.urlReal}/storage/${report['photo_1']}",
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            Icon(Icons.image_not_supported, size: 50),
                      ),
                      title: Text(report['category'] ?? "Tanpa Kategori"),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Status: ${_getStatusText(report['status'])}"),
                          Text(report['description'] ?? "Tidak ada deskripsi",
                              maxLines: 2, overflow: TextOverflow.ellipsis),
                        ],
                      ),
                      trailing: Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        print("📜 Data Report: $report");

                        if (report.containsKey('assignment_id') &&
                            report['assignment_id'] != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ReportDetailPetugasScreen(
                                assignmentId: report['assignment_id'],
                              ),
                            ),
                          ).then((_) {
                            if (onStatusChange != null) {
                              onStatusChange!(); // Refresh data setelah kembali dari detail
                            }
                          });
                        } else {
                          print(
                              "❌ assignment_id tidak ditemukan dalam data report.");
                        }
                      }));
            },
          );
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
