import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wargahub_frontend/screens/LoginScreen.dart';
import 'package:wargahub_frontend/screens/report_screen.dart';
import 'package:wargahub_frontend/screens/view_report_screen.dart';
import 'package:wargahub_frontend/screens/detail_report_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:wargahub_frontend/config/constant.dart';


class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String userName = "User";
  String userEmail = "user@example.com";
  String? authToken;
  int _currentIndex = 0;
  List<dynamic> reports = []; // Menyimpan daftar laporan

  @override
  void initState() {
    super.initState();
    loadUserData();
    fetchReports(); // Ambil data laporan
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
      userName = prefs.getString('user_name') ?? "User";
      userEmail = prefs.getString('user_email') ?? "user@example.com";
    });
  }

  /// Fetch semua laporan dari API
  Future<void> fetchReports() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('auth_token');

    if (token == null) return;

    final response = await http.get(
      Uri.parse("${ApiConstants.baseUrl}/reports"), // Ganti dengan URL API
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        reports = data['data']; // Ambil data laporan dari JSON
      });
    } else {
      print("Gagal mengambil data laporan");
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
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        appBar: AppBar(title: Text("WargaHub")),
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
        onTap: (index) async {
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ViewReportScreen()),
            );
          } else if (index == 2) {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ReportScreen()),
            );

            // **Cek apakah ada hasil true dari ReportScreen**
            if (result == true) {
              fetchReports(); // Refresh laporan di HomeScreen
            }
          } else {
            setState(() {
              _currentIndex = index;
            });
          }
        },
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Dashboard'),
            BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Laporan Saya'),
            BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Buat Laporan'),
          ],
        ),
      ),
    );
  }

  /// Fungsi untuk menampilkan layar sesuai indeks navigasi
  Widget _getSelectedScreen(int index) {
    if (index == 0) {
      return DashboardScreen(reports: reports); // Kirim data laporan ke Dashboard
    }
    return DashboardScreen(reports: reports); // Default ke dashboard
  }
}

/// Widget untuk halaman Dashboard
class DashboardScreen extends StatelessWidget {
  final List<dynamic> reports;

  DashboardScreen({required this.reports});

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
                  title: Text(report['category']),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Pelapor: ${report['user']['name']}"),
                      Text("Status: ${_getStatusText(report['status'])}"),
                      Text(report['description'], maxLines: 2, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                  trailing: Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailReportScreen(reportId: report['id'].toString()),
                      ),
                    );
                  },
                ),
              );
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
