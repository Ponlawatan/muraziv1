import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // ใช้สำหรับการแปลง JSON
import 'package:murazi_dev/favorite.dart';
import 'package:murazi_dev/homepage.dart';
import 'package:murazi_dev/login.dart';
import 'package:murazi_dev/notification.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:murazi_dev/screens/user_profile_screen.dart';
import 'package:image_picker/image_picker.dart';

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  int _selectedIndex = 3;
  String? _selectedLanguage;
  bool _isDropdownVisible = false;
  final List<String> _languages = ['ภาษาไทย', 'English', 'Français', 'Español'];
  String? _profileImageUrl;
  String username = '';
  String lastname = '';
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      setState(() => isLoading = true);
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) return;

      final response = await http.get(
        Uri.parse('http://localhost:5000/api/user/profile'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          username = data['data']['username'] ?? '';
          lastname = data['data']['lastname'] ?? '';
          _profileImageUrl = data['data']['profileImage'];
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading profile: $e');
      setState(() => isLoading = false);
    }
  }

  Future<void> _updateProfileImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image == null) return;

      setState(() => isLoading = true);

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('กรุณาเข้าสู่ระบบ')),
        );
        setState(() => isLoading = false);
        return;
      }

      // อ่านข้อมูลรูปภาพเป็น bytes แล้วแปลงเป็น base64
      final bytes = await image.readAsBytes();
      final base64Image = base64Encode(bytes);

      // ส่ง request แบบปกติโดยใช้ base64 string
      final response = await http.post(
        Uri.parse('http://localhost:5000/api/user/profile/image'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'imageBase64': base64Image,
          'filename': image.name,
          'mimeType': image.mimeType ?? 'image/jpeg',
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('อัพโหลดรูปโปรไฟล์สำเร็จ')),
        );
        await _loadUserProfile();
      } else {
        throw Exception('ไม่สามารถอัพโหลดรูปภาพได้ (${response.statusCode})');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เกิดข้อผิดพลาด: $e')),
      );
      setState(() => isLoading = false);
    }
  }

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;
    setState(() {
      _selectedIndex = index;
    });

    Widget page;
    switch (index) {
      case 0:
        page = HomePage();
        break;
      case 1:
        page = FavoritePage();
        break;
      case 2:
        page = NotificationPage();
        break;
      case 3:
        page = UserPage();
        break;
      default:
        return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    final url = Uri.parse('http://localhost:5000/api/auth/logout');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // ใช้ token ที่บันทึกไว้
        },
      );

      if (response.statusCode == 200) {
        await prefs.remove('token'); // ลบ token ออกจาก SharedPreferences
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      } else {
        final data = jsonDecode(response.body);
        _showErrorDialog(data['message'] ?? 'Logout failed.');
      }
    } catch (e) {
      _showErrorDialog('An error occurred. Please check your connection.');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Error',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          content: Text(
            message,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.red,
              ),
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        flexibleSpace: Center(
          child: Text(
            'MURAZI',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 255, 0, 0),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _UserProfileImageShow(),
                SizedBox(height: 5),
                _UserProfilePhotoChangeButton(),
                SizedBox(height: 3),
                _UserProfileNameShow(),
                SizedBox(height: 20),
                _ChangeUserDataButton(),
                SizedBox(height: 10),
                _ChangeLanguageButton(),
                _languageDropdown(),
                SizedBox(height: 10),
                _ReportButton(),
                SizedBox(height: 10),
                _logoutButton(),
              ],
            ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _UserProfileImageShow() {
    return Center(
      child: Container(
        margin: EdgeInsets.only(top: 20, bottom: 10),
        child: CircleAvatar(
          radius: 60,
          backgroundImage:
              _profileImageUrl != null ? NetworkImage(_profileImageUrl!) : null,
          backgroundColor: Colors.grey[200],
          child: _profileImageUrl == null
              ? const Icon(Icons.person, size: 60)
              : null,
        ),
      ),
    );
  }

  Widget _UserProfilePhotoChangeButton() {
    return Center(
      child: SizedBox(
        width: 120,
        height: 30,
        child: TextButton(
          onPressed: _updateProfileImage,
          style: TextButton.styleFrom(
            foregroundColor: const Color.fromARGB(255, 255, 0, 0),
            padding: EdgeInsets.zero,
          ),
          child: Text(
            'เปลี่ยนรูปภาพ',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _UserProfileNameShow() {
    return Center(
      child: Text(
        '$username $lastname',
        style: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: const Color.fromARGB(255, 255, 0, 0),
        ),
      ),
    );
  }

  Widget _ChangeUserDataButton() {
    return Center(
      child: SizedBox(
        width: 280,
        height: 50,
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => UserProfileScreen()),
            );
          },
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: const Color.fromARGB(255, 255, 0, 0),
            padding: EdgeInsets.zero,
          ),
          child: Text(
            'เปลี่ยนข้อมูลผู้ใช้งาน',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _ChangeLanguageButton() {
    return Center(
      child: SizedBox(
        width: 280,
        height: 50,
        child: ElevatedButton(
          onPressed: () {
            setState(() {
              _isDropdownVisible = !_isDropdownVisible;
            });
          },
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: const Color.fromARGB(255, 255, 0, 0),
            padding: EdgeInsets.zero,
          ),
          child: Text(
            'เปลี่ยนภาษา',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _languageDropdown() {
    return Visibility(
      visible: _isDropdownVisible,
      child: SizedBox(
        width: 150,
        child: DropdownButton<String>(
          value: _selectedLanguage,
          hint: Text('เลือกภาษา'),
          isExpanded: true,
          items: _languages.map((String language) {
            return DropdownMenuItem<String>(
              value: language,
              child: SizedBox(
                height: 40,
                child: Text(
                  language,
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
              ),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              _selectedLanguage = newValue;
              _isDropdownVisible = false;
            });
          },
        ),
      ),
    );
  }

  Widget _ReportButton() {
    return Center(
      child: SizedBox(
        width: 280,
        height: 50,
        child: ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: const Color.fromARGB(255, 255, 0, 0),
            padding: EdgeInsets.zero,
          ),
          child: Text(
            'แจ้งปัญหา',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _logoutButton() {
    return Center(
      child: SizedBox(
        width: 280,
        height: 50,
        child: ElevatedButton(
          onPressed: () {
            _showLogoutConfirmationDialog();
          },
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: const Color.fromARGB(255, 255, 0, 0),
            padding: EdgeInsets.zero,
          ),
          child: Text(
            'ออกจากระบบ',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  void _showLogoutConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async {
            return false;
          },
          child: AlertDialog(
            title: Text(
              'ยืนยันการออกจากระบบ',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            content: Text(
              'คุณต้องการออกจากระบบหรือไม่?',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: const Color.fromARGB(255, 255, 0, 0),
              ),
            ),
            actions: <Widget>[
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: const Color.fromARGB(255, 255, 255, 255),
                  backgroundColor: const Color.fromARGB(255, 255, 17, 0),
                ),
                child: Text('ไม่'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: const Color.fromARGB(255, 255, 255, 255),
                  backgroundColor: const Color.fromARGB(255, 255, 17, 0),
                ),
                child: Text('ใช่'),
                onPressed: () {
                  Navigator.of(context).pop();
                  _logout(); // เรียกใช้งาน logout
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'หน้าหลัก',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.favorite),
          label: 'สถานที่ถูกใจ',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.notifications),
          label: 'การแจ้งเตือน',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'ข้อมูลผู้ใช้',
        ),
      ],
      currentIndex: _selectedIndex,
      selectedItemColor: const Color.fromARGB(255, 255, 0, 0),
      unselectedItemColor: const Color.fromARGB(255, 255, 0, 0),
      onTap: _onItemTapped,
    );
  }
}
