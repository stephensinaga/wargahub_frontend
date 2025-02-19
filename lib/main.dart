import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wargahub_frontend/screens/LoginScreen.dart';
import 'package:wargahub_frontend/screens/RegisterScreen.dart';
import 'package:wargahub_frontend/screens/home_screen.dart';
import 'package:wargahub_frontend/screens/welcome_screen.dart'; // Import Welcome Screen

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/welcome', // Menampilkan Welcome Screen terlebih dahulu
      routes: {
        '/welcome': (context) => WelcomeScreen(),
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/dashboard': (context) => HomeScreen(),
        '/splash': (context) => SplashScreen(), // Tambahkan SplashScreen untuk cek login
      },
    );
  }
}

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

    await Future.delayed(const Duration(seconds: 2)); // Efek loading sebentar

    if (token != null && token.isNotEmpty) {
      Navigator.pushReplacementNamed(context, '/dashboard'); // Jika login, masuk ke dashboard
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
