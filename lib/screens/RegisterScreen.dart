import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool isLoading = false;

  Future<void> register(BuildContext context) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => isLoading = true);

    final url = Uri.parse('http://192.168.50.223:4500/api/register');
    final body = {
      "name": nameController.text,
      "email": emailController.text,
      "password": passwordController.text,
      "password_confirmation": confirmPasswordController.text,
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      setState(() => isLoading = false);

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration successful. Please login.')),
        );

        Navigator.of(context).pushReplacementNamed('/login');
      } else {
        final data = jsonDecode(response.body);
        final errorMessage = data['message'] ?? 'Registration failed';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Network error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.network(
                  "https://cdn1.iconfinder.com/data/icons/borrow-book-flat/340/device_tablet_register_login_member_user-256.png",
                  height: 100,
                ),
                SizedBox(height: 16),
                Text(
                  "Let's Get Started!",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: Color(0xff3a57e8),
                  ),
                ),
                SizedBox(height: 40),
                CustomTextField(
                  hintText: "Name",
                  prefixIcon: Icons.person,
                  controller: nameController,
                  validator: (value) => value!.isEmpty ? "Name is required" : null,
                ),
                SizedBox(height: 16),
                CustomTextField(
                  hintText: "Email Address",
                  prefixIcon: Icons.mail,
                  controller: emailController,
                  validator: (value) {
                    if (value!.isEmpty) return "Email is required";
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                      return "Enter a valid email";
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                CustomTextField(
                  hintText: "Password",
                  prefixIcon: Icons.lock,
                  controller: passwordController,
                  isPassword: true,
                  validator: (value) {
                    if (value!.isEmpty) return "Password is required";
                    if (value.length < 6) return "Password must be at least 6 characters";
                    return null;
                  },
                ),
                SizedBox(height: 16),
                CustomTextField(
                  hintText: "Confirm Password",
                  prefixIcon: Icons.lock,
                  controller: confirmPasswordController,
                  isPassword: true,
                  validator: (value) {
                    if (value!.isEmpty) return "Confirm your password";
                    if (value != passwordController.text) return "Passwords do not match";
                    return null;
                  },
                ),
                SizedBox(height: 24),
                isLoading
                    ? CircularProgressIndicator()
                    : MaterialButton(
                        onPressed: () => register(context),
                        color: Color(0xff3a57e8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        padding: EdgeInsets.all(16),
                        child: Text("Sign Up", style: TextStyle(color: Colors.white)),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CustomTextField extends StatelessWidget {
  final String hintText;
  final IconData prefixIcon;
  final TextEditingController controller;
  final bool isPassword;
  final String? Function(String?)? validator;

  const CustomTextField({
    required this.hintText,
    required this.prefixIcon,
    required this.controller,
    this.isPassword = false,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      validator: validator,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: Icon(prefixIcon, color: Color(0xff212435)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: Color(0xff3a57e8)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: Color(0xff3a57e8)),
        ),
      ),
    );
  }
}
