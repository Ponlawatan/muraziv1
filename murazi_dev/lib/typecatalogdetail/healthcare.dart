import 'package:flutter/material.dart';
import 'package:murazi_dev/favorite.dart';
import 'package:murazi_dev/homepage.dart';
import 'package:murazi_dev/notification.dart';
import 'package:murazi_dev/userpage.dart';

class HealthCareCatalogPage extends StatefulWidget {
  const HealthCareCatalogPage({super.key});

  @override
  _HealthCareCatalogPageState createState() => _HealthCareCatalogPageState();
}

class _HealthCareCatalogPageState extends State<HealthCareCatalogPage> {
  int _selectedIndex = 0;
  String? _selectedProvince;

  final List<String> _provinces = [
    'กรุงเทพมหานคร',
    'กระบี่',
    'กาญจนบุรี',
    'กาฬสินธุ์',
    'กำแพงเพชร',
    'ขอนแก่น',
    'จันทบุรี',
    'ฉะเชิงเทรา',
    'ชลบุรี',
    'ชัยนาท',
    'ชัยภูมิ',
    'ชุมพร',
    'เชียงราย',
    'เชียงใหม่',
    'ตรัง',
    'ตราด',
    'ตาก',
    'นครนายก',
    'นครปฐม',
    'นครพนม',
    'นครราชสีมา',
    'นครศรีธรรมราช',
    'นครสวรรค์',
    'นนทบุรี',
    'นราธิวาส',
    'น่าน',
    'ปทุมธานี',
    'ประจวบคีรีขันธ์',
    'ปราจีนบุรี',
    'ปัตตานี',
    'พะเยา',
    'พระนครศรีอยุธยา',
    'พังงา',
    'พัทลุง',
    'พิจิตร',
    'พิษณุโลก',
    'เพชรบุรี',
    'เพชรบูรณ์',
    'แพร่',
    'ภูเก็ต',
    'มหาสารคาม',
    'มุกดาหาร',
    'ยะลา',
    'ยโสธร',
    'ร้อยเอ็ด',
    'ระนอง',
    'ระยอง',
    'ราชบุรี',
    'ลพบุรี',
    'ลำปาง',
    'ลำพูน',
    'เลย',
    'ศรีสะเกษ',
    'สกลนคร',
    'สงขลา',
    'สตูล',
    'สมุทรปราการ',
    'สมุทรสงคราม',
    'สมุทรสาคร',
    'สระบุรี',
    'สระแก้ว',
    'สิงห์บุรี',
    'สุโขทัย',
    'สุพรรณบุรี',
    'สุราษฎร์ธานี',
    'สุรินทร์',
    'อ่างทอง',
    'อุดรธานี',
    'อุตรดิตถ์',
    'อุทัยธานี',
    'อุบลราชธานี',
  ];

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
            size: 26,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
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
            _buildProvinceDropdown(),
            SizedBox(height: 5),
            _PlaceSlideDetailPreviewMini(),
            SizedBox(height: 5),
            _PlaceSlideDetailPreviewHeadText(),
            SizedBox(height: 5),
            _PlaceSlideDetailPreviewHorizon(),
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
          'หมวดหมู่ : สุขภาพ',
          style: TextStyle(
            color: const Color.fromARGB(255, 255, 0, 0),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildProvinceDropdown() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      child: PopupMenuButton<String>(
        onSelected: (String newValue) {
          setState(() {
            _selectedProvince = newValue;
          });
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(color: const Color.fromARGB(255, 255, 0, 0)),
            borderRadius: BorderRadius.circular(10),
            color: const Color.fromARGB(255, 255, 0, 0),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _selectedProvince ?? 'ทั้งหมด',
                style: TextStyle(
                  color: const Color.fromARGB(255, 255, 255, 255),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Icon(Icons.arrow_drop_down,
                  color: const Color.fromARGB(255, 255, 255, 255)),
            ],
          ),
        ),
        itemBuilder: (BuildContext context) {
          return _provinces.map((String province) {
            return PopupMenuItem<String>(
              value: province,
              child: SizedBox(
                height: 50,
                child: Center(
                  child: Text(
                    province,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: const Color.fromARGB(255, 255, 0, 0),
                    ),
                  ),
                ),
              ),
            );
          }).toList();
        },
      ),
    );
  }

  Widget _PlaceSlideDetailPreviewMini() {
    final List<Map<String, String>> items = [
      {
        'image': 'assets/image1.png',
        'label': 'สถานที่ 1',
      },
      {
        'image': 'assets/image2.png',
        'label': 'สถานที่ 2',
      },
      {
        'image': 'assets/image3.png',
        'label': 'สถานที่ 3',
      },
      {
        'image': 'assets/image4.png',
        'label': 'สถานที่ 4',
      },
      {
        'image': 'assets/image5.png',
        'label': 'สถานที่ 5',
      },
      {
        'image': 'assets/image6.png',
        'label': 'สถานที่ 6',
      },
      {
        'image': 'assets/image7.png',
        'label': 'สถานที่ 7',
      },
      {
        'image': 'assets/image8.png',
        'label': 'สถานที่ 8',
      },
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'สถานที่แนะนำ',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: const Color.fromARGB(255, 255, 0, 0),
              ),
            ),
          ),
          SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: items.map((item) {
                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: _buildBoxItem(
                    item['image']!,
                    item['label']!,
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBoxItem(String imagePath, String label) {
    return Column(
      children: [
        Container(
          width: 120,
          height: 230,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(8),
            image: DecorationImage(
              image: AssetImage(imagePath),
              fit: BoxFit.cover,
            ),
          ),
        ),
        SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: const Color.fromARGB(255, 255, 0, 0),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _PlaceSlideDetailPreviewHeadText() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          'สถานที่ทั้งหมด',
          style: TextStyle(
            color: const Color.fromARGB(255, 255, 0, 0),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _PlaceSlideDetailPreviewHorizon() {
    final List<Map<String, String>> itemsHorizontal = [
      {
        'image': 'assets/image1.png',
        'label': 'สถานที่ 1',
      },
      {
        'image': 'assets/image2.png',
        'label': 'สถานที่ 2',
      },
      {
        'image': 'assets/image3.png',
        'label': 'สถานที่ 3',
      },
      {
        'image': 'assets/image4.png',
        'label': 'สถานที่ 4',
      },
      {
        'image': 'assets/image5.png',
        'label': 'สถานที่ 5',
      },
      {
        'image': 'assets/image6.png',
        'label': 'สถานที่ 6',
      },
      {
        'image': 'assets/image7.png',
        'label': 'สถานที่ 7',
      },
      {
        'image': 'assets/image8.png',
        'label': 'สถานที่ 8',
      },
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              children: itemsHorizontal.map((itemHorizontal) {
                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: _buildBoxItemHorizontal(
                    itemHorizontal['image']!,
                    itemHorizontal['label']!,
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBoxItemHorizontal(String imagePath, String label) {
    return Row(
      children: [
        Container(
          width: 260,
          height: 120,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(8),
            image: DecorationImage(
              image: AssetImage(imagePath),
              fit: BoxFit.cover,
            ),
          ),
          child: SizedBox(height: 5),
        ),
        SizedBox(width: 16),
        Text(
          label,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: const Color.fromARGB(255, 255, 0, 0),
          ),
          textAlign: TextAlign.center,
        ),
      ],
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
