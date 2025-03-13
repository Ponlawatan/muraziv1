import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CreateAccountPage extends StatefulWidget {
  const CreateAccountPage({super.key});

  @override
  _CreateAccountPageState createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends State<CreateAccountPage> {
  final _nameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Future<void> _createAccount() async {
    if (_formKey.currentState!.validate()) {
      // สร้าง payload สำหรับส่งไปยัง API
      final payload = {
        "username": _nameController.text,
        "lastname": _surnameController.text,
        "email": _emailController.text,
        "password": _passwordController.text,
      };

      // ส่งคำขอไปยัง API
      try {
        final response = await http.post(
          Uri.parse('http://localhost:5000/api/auth/register'),
          headers: {
            "Content-Type": "application/json",
          },
          body: jsonEncode(payload),
        );

        if (response.statusCode == 201) {
          // สำเร็จ
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('บัญชีถูกสร้างแล้ว กรุณายืนยันอีเมล')),
          );
          Navigator.pop(context); // กลับหน้าที่แล้ว
        } else {
          // แสดงข้อผิดพลาดที่ส่งกลับจาก API
          final Map<String, dynamic> resData = jsonDecode(response.body);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(resData['msg'] ?? 'เกิดข้อผิดพลาด')),
          );
        }
      } catch (e) {
        // ข้อผิดพลาดจากการเชื่อมต่อ
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์ได้')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('สร้างบัญชีใหม่'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'ชื่อ'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'กรุณากรอกชื่อ';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _surnameController,
                decoration: const InputDecoration(labelText: 'นามสกุล'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'กรุณากรอกนามสกุล';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'อีเมล'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'กรุณากรอกอีเมล';
                  }
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'กรุณากรอกอีเมลที่ถูกต้อง';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'รหัสผ่าน'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'กรุณากรอกรหัสผ่าน';
                  }
                  if (value.length < 8) {
                    return 'รหัสผ่านต้องมีอย่างน้อย 8 ตัวอักษร';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: 140,
                height: 40,
                child: ElevatedButton(
                  onPressed: _createAccount,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 255, 0, 0),
                    foregroundColor: const Color.fromARGB(255, 255, 255, 255),
                  ),
                  child: const Text(
                    'สร้างบัญชี',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
