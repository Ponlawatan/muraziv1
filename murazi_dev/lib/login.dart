import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:murazi_dev/homepage.dart';
import 'package:murazi_dev/create_account.dart';
import 'package:murazi_dev/password_reset.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _checkLoggedIn();
  }

  // ✅ เช็คว่าเคย login แล้วหรือไม่
  Future<void> _checkLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token != null) {
      // ถ้ามี token ให้ไปหน้า HomePage โดยตรง
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    }
  }

  // ✅ ฟังก์ชันเข้าสู่ระบบ
  Future<void> _loginWithEmail() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showSnackbar('กรุณากรอกข้อมูลให้ครบถ้วน');
      return;
    }

    final url = Uri.parse('http://localhost:5000/api/auth/login');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        final token = data['token'];

        // ✅ บันทึก Token ลงใน SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);

        // ✅ นำผู้ใช้ไปยังหน้า HomePage
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );

        _showSnackbar('เข้าสู่ระบบสำเร็จ');
      } else {
        _showSnackbar(data['message'] ?? 'ข้อมูลการเข้าสู่ระบบไม่ถูกต้อง');
      }
    } catch (e) {
      _showSnackbar('เกิดข้อผิดพลาดในการเชื่อมต่อ');
    }
  }

  void _createNewAccount() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CreateAccountPage()),
    );
  }

  void _ForgetPassword() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ChangePasswordPage()),
    );
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // ปิดปุ่ม back บน Android
      child: Scaffold(
        appBar: AppBar(automaticallyImplyLeading: false),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'อีเมล'),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'รหัสผ่าน'),
                  obscureText: true,
                ),
                const SizedBox(height: 10),
                _buildButton('เข้าสู่ระบบ', _loginWithEmail),
                const SizedBox(height: 10),
                _buildButton('สร้างบัญชีใหม่', _createNewAccount),
                const SizedBox(height: 5),
                TextButton(
                  onPressed: _ForgetPassword,
                  child: const Text(
                    'ลืมรหัสผ่าน',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color.fromARGB(255, 255, 0, 0),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildButton(String text, VoidCallback onPressed) {
    return SizedBox(
      width: 140,
      height: 40,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 255, 0, 0),
          foregroundColor: Colors.white,
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
