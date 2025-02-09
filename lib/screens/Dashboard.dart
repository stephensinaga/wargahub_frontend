import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final String apiUrl = "https://jsonplaceholder.typicode.com/photos";
  String? token; // Simpan token dari login
  bool isLoading = true;
  String errorMessage = "";
  List<dynamic> data = [];

  @override
  void initState() {
    super.initState();
    getTokenAndFetchData();
  }

  /// Ambil token dari SharedPreferences dan fetch data API
  Future<void> getTokenAndFetchData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString('auth_token');

    print("Token yang digunakan: $token"); // Debugging token

    await fetchData();
  }

  /// Fetch data dari API
  Future<void> fetchData() async {
    setState(() => isLoading = true);
    
    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: token != null ? {"Authorization": "Bearer $token"} : {},
      );

      print("Response Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        setState(() {
          data = json.decode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception("Failed to load data");
      }
    } catch (e) {
      setState(() {
        errorMessage = "Error: $e";
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('auth_token'); // Hapus token saat logout
              if (mounted) {
                Navigator.pushReplacementNamed(context, "/login"); // Kembali ke Login
              }
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(child: Text(errorMessage))
              : _buildDashboardContent(),
    );
  }

  /// **Widget untuk menampilkan isi Dashboard**
  Widget _buildDashboardContent() {
    if (data.isEmpty) {
      return const Center(child: Text("No data available"));
    }

    final List<String> imageUrls =
        data.take(5).map<String>((item) => item['url']).toList();

    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 10),
          _buildImageCarousel(imageUrls),
          const SizedBox(height: 20),
          _buildNewsGrid(),
          const SizedBox(height: 20),
          _buildQuickActions(),
        ],
      ),
    );
  }

  /// **Banner Carousel**
  Widget _buildImageCarousel(List<String> imageUrls) {
    return SizedBox(
      height: 200,
      child: PageView.builder(
        itemCount: imageUrls.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                imageUrls[index],
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            ),
          );
        },
      ),
    );
  }

  /// **Grid Berita Unggulan**
  Widget _buildNewsGrid() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: data.length < 8 ? data.length : 8,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 0.9,
        ),
        itemBuilder: (BuildContext context, int index) {
          final item = data[index];
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                  child: Image.network(
                    item['url'],
                    height: 100,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    item['title'],
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// **Tombol Navigasi Cepat**
  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GridView.count(
        shrinkWrap: true,
        crossAxisCount: 4,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          ActionTile(
            icon: Icons.report,
            label: 'Laporan',
            onPressed: () {},
          ),
          ActionTile(
            icon: Icons.notifications,
            label: 'Notifikasi',
            onPressed: () {},
          ),
          ActionTile(
            icon: Icons.account_circle,
            label: 'Profil',
            onPressed: () {},
          ),
          ActionTile(
            icon: Icons.settings,
            label: 'Pengaturan',
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}

/// **Action Tile untuk Navigasi Cepat**
class ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const ActionTile({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.blueAccent,
            child: Icon(icon, color: Colors.white, size: 30),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
