import 'package:flutter/material.dart';
import 'package:murazi_dev/favorite.dart';
import 'package:murazi_dev/homepage.dart';
import 'package:murazi_dev/userpage.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  int _selectedIndex = 2;

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return; // Avoid redundant navigation

    setState(() {
      _selectedIndex = index; // Update the selected index
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
        return; // Should not reach here
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 10),
            _HeadText(),
            SizedBox(height: 5),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _HeadText() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          'การแจ้งเตือน',
          style: TextStyle(
            color: const Color.fromARGB(255, 255, 0, 0),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
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
