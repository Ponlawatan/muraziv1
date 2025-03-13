import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  Map<String, dynamic> userData = {};
  bool isLoading = true;
  bool isEditing = false;

  // เพิ่ม controllers สำหรับ text fields
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _lastnameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchUserProfile();
  }

  Future<void> fetchUserProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('กรุณาเข้าสู่ระบบ')),
        );
        return;
      }

      final response = await http.get(
        Uri.parse('http://localhost:5000/api/user/profile'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Response data: $data');

        if (data != null && data['data'] != null) {
          setState(() {
            userData = data['data'];
            _usernameController.text = userData['username'] ?? '';
            _lastnameController.text = userData['lastname'] ?? '';
            isLoading = false;
          });
        } else {
          throw Exception('ข้อมูลไม่ถูกต้อง');
        }
      } else {
        print('Error response: ${response.body}');
        throw Exception('Failed to load profile: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading profile: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เกิดข้อผิดพลาด: $e')),
      );
      setState(() => isLoading = false);
    }
  }

  Future<void> _updateProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.put(
        Uri.parse('http://localhost:5000/api/user/profile'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'username': _usernameController.text,
          'lastname': _lastnameController.text,
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          isEditing = false;
          fetchUserProfile();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('อัพเดทข้อมูลสำเร็จ')),
        );
      } else {
        throw Exception('Failed to update profile');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เกิดข้อผิดพลาด: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ข้อมูลผู้ใช้'),
        backgroundColor: const Color.fromARGB(255, 255, 0, 0),
        actions: [
          IconButton(
            icon: Icon(isEditing ? Icons.save : Icons.edit),
            onPressed: () {
              if (isEditing) {
                _updateProfile();
              } else {
                setState(() => isEditing = true);
              }
            },
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.all(16.0),
              child: Card(
                elevation: 4,
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      ListTile(
                        leading: Icon(Icons.person),
                        title: Text('ชื่อ'),
                        subtitle: isEditing
                            ? TextField(
                                controller: _usernameController,
                                decoration: InputDecoration(
                                  hintText: 'กรุณากรอกชื่อ',
                                ),
                              )
                            : Text(userData['username'] ?? 'ไม่พบข้อมูล'),
                      ),
                      ListTile(
                        leading: Icon(Icons.person_outline),
                        title: Text('นามสกุล'),
                        subtitle: isEditing
                            ? TextField(
                                controller: _lastnameController,
                                decoration: InputDecoration(
                                  hintText: 'กรุณากรอกนามสกุล',
                                ),
                              )
                            : Text(userData['lastname'] ?? 'ไม่พบข้อมูล'),
                      ),
                      ListTile(
                        leading: Icon(Icons.email),
                        title: Text('อีเมล'),
                        subtitle: Text(userData['email'] ?? 'ไม่พบข้อมูล'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
