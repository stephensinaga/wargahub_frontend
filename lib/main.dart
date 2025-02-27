import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wargahub_frontend/screens/LoginScreen.dart';
import 'package:wargahub_frontend/screens/RegisterScreen.dart';
import 'package:wargahub_frontend/screens/home_screen.dart';
import 'package:wargahub_frontend/screens/welcome_screen.dart';
import 'package:wargahub_frontend/screens/dashboard_screen.dart';
import 'package:wargahub_frontend/screens/detail_report_petugas_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/splash', // Mulai dari SplashScreen
      routes: {
        '/splash': (context) => SplashScreen(), // Cek login user dulu
        '/welcome': (context) => WelcomeScreen(),
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/dashboard': (context) => HomeScreen(),
        '/dashboard-petugas': (context) => DashboardPetugasScreen(),
        '/report-detail': (context) => ReportDetailWrapper(), // Wrapper untuk menerima argumen
      },
    );
  }
}

/// Splash Screen untuk cek status login
class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    checkLogin();
  }

  Future<void> checkLogin() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('auth_token');
    final String? role = prefs.getString('user_role'); // Cek peran user (misal: "petugas" atau "warga")

    await Future.delayed(const Duration(seconds: 2)); // Efek loading

    if (token != null && token.isNotEmpty) {
      if (role == "petugas") {
        Navigator.pushReplacementNamed(context, '/dashboard-petugas'); // Petugas ke dashboard petugas
      } else {
        Navigator.pushReplacementNamed(context, '/dashboard'); // Warga ke dashboard biasa
      }
    } else {
      Navigator.pushReplacementNamed(context, '/login'); // Jika tidak login, masuk ke login
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueAccent,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: Colors.white),
            const SizedBox(height: 20),
            const Text(
              "Memeriksa sesi login...",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

/// Wrapper untuk menangkap argumen yang dikirim ke halaman detail laporan petugas
class ReportDetailWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Object? args = ModalRoute.of(context)!.settings.arguments;

    if (args == null || args is! int) {
      return Scaffold(
        appBar: AppBar(title: const Text("Error")),
        body: const Center(child: Text("Data tidak ditemukan")),
      );
    }

    return ReportDetailPetugasScreen(assignmentId: args);
  }
}
