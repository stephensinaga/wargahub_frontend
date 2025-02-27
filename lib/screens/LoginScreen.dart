import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';
import 'RegisterScreen.dart';
import 'package:wargahub_frontend/screens/dashboard_screen.dart';
import 'package:wargahub_frontend/config/constant.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    checkLoginStatus();
  }

  /// Mengecek apakah pengguna sudah login sebelumnya
  Future<void> checkLoginStatus() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    final String? token = prefs.getString('auth_token');
    final String? role = prefs.getString('user_role');
print("🔍 Role yang ditemukan saat login: $role");


    print("🔎 Token di SharedPreferences: ${token ?? 'Token tidak ditemukan!'}");

    if (token != null && token.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
          (route) => false,
        );
      });
    }
  }

  /// Menyimpan token ke SharedPreferences
  /// Menyimpan token dan role ke SharedPreferences
  Future<void> saveUserData(String token, String role) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    print("🟢 Menerima token dari API: $token");
    print("🟢 Menerima role dari API: $role");

    bool isTokenSaved = await prefs.setString('auth_token', token);
    bool isRoleSaved = await prefs.setString('user_role', role);

print("🔹 Role yang disimpan: ${prefs.getString('user_role')}");

    await prefs.reload();
    await Future.delayed(Duration(milliseconds: 500));

    if (isTokenSaved && isRoleSaved) {
      print("✅ Data berhasil disimpan di SharedPreferences!");
      print("✅ Token: ${prefs.getString('auth_token')}");
      print("✅ Role: ${prefs.getString('user_role')}");
    } else {
      print("❌ Gagal menyimpan data!");
    }
  }

  /// Fungsi login
   /// Fungsi login
Future<void> loginUser(BuildContext context) async {
  if (emailController.text.isEmpty || passwordController.text.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Email dan password harus diisi!')),
    );
    return;
  }

  setState(() => isLoading = true);
  final url = Uri.parse("${ApiConstants.baseUrl}/login");

  try {
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": emailController.text.trim(),
        "password": passwordController.text,
      }),
    );

    print("📩 Response Code: ${response.statusCode}");
    print("📩 Response Body: ${response.body}");

    final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['token'] != null && data['user']['role'] != null) {
        await saveUserData(data['token'], data['user']['role']);

      if (!mounted) return;
      print("🔹 Navigasi ke: ${data['role'] == "petugas" ? "DashboardPetugasScreen" : "HomeScreen"}");
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => 
          data['user']['role'] == "petugas" ? DashboardPetugasScreen() : HomeScreen()),
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(data['message'] ?? 'Login gagal, coba lagi.')),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Terjadi kesalahan, periksa koneksi Anda.')),
    );
    print("❌ Error: $e");
  } finally {
    if (mounted) setState(() => isLoading = false);
  }
}


  /// Tombol untuk logout (Hapus token dan kembali ke login)
  Future<void> logoutUser() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    print('🛑 Token dihapus, kembali ke login!');
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffe6e6e6),
      body: Stack(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height * 0.35,
            decoration: const BoxDecoration(color: Color(0xff3a57e8)),
          ),
          Container(
            margin: const EdgeInsets.fromLTRB(20, 100, 20, 20),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Icon(Icons.lock, size: 80, color: Colors.blue),
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    "Login",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      labelText: "Email",
                      border: UnderlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: "Password",
                      border: UnderlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : () => loginUser(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff3a57e8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              "Login",
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Don't have an account?"),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => RegisterScreen()),
                          );
                        },
                        child: const Text("Sign Up", style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
