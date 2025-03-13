import 'package:flutter/material.dart';
import 'package:murazi_dev/favorite.dart';
import 'package:murazi_dev/homepage.dart';
import 'package:murazi_dev/notification.dart';
import 'package:murazi_dev/userpage.dart';
import 'package:murazi_dev/models/place.dart';
import 'package:murazi_dev/services/place_service.dart';
import 'package:murazi_dev/placedetail.dart';
import 'dart:convert';

class LoveCatalogPage extends StatefulWidget {
  const LoveCatalogPage({super.key});

  @override
  _LoveCatalogPageState createState() => _LoveCatalogPageState();
}

class _LoveCatalogPageState extends State<LoveCatalogPage> {
  int _selectedIndex = 0;
  String? _selectedProvince;
  final PlaceService _placeService = PlaceService();
  List<Place> _places = [];
  bool _isLoading = true;

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

  @override
  void initState() {
    super.initState();
    _loadPlaces();
  }

  Future<void> _loadPlaces() async {
    try {
      setState(() {
        _isLoading = true;
      });
      final places = await _placeService.getPlacesByCategory('ความรัก');
      setState(() {
        _places = places;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading places: $e');
      setState(() {
        _isLoading = false;
      });
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
            SizedBox(height: 0),
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
          'หมวดหมู่ : ความรัก',
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
          _loadFilteredPlaces();
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
          return [
            PopupMenuItem<String>(
              value: null,
              child: SizedBox(
                height: 50,
                child: Center(
                  child: Text(
                    'ทั้งหมด',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: const Color.fromARGB(255, 255, 0, 0),
                    ),
                  ),
                ),
              ),
            ),
            ..._provinces.map((String province) {
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
            }),
          ];
        },
      ),
    );
  }

  Widget _PlaceSlideDetailPreviewMini() {
    List<Place> filteredPlaces = _getFilteredPlaces();

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
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : filteredPlaces.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Text(
                          'ไม่พบสถานที่ในจังหวัด ${_selectedProvince ?? "ที่เลือก"}',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    )
                  : SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: filteredPlaces.map((place) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        PlaceDetailPage(place: place),
                                  ),
                                );
                              },
                              child: _buildBoxItem(
                                place.bannerImage,
                                place.name,
                              ),
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
              image: MemoryImage(base64Decode(imagePath.split(',')[1])),
              fit: BoxFit.cover,
            ),
          ),
        ),
        SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
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
    List<Place> filteredPlaces = _getFilteredPlaces();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: _isLoading
          ? Center(child: CircularProgressIndicator())
          : filteredPlaces.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                      'ไม่พบสถานที่ในจังหวัด ${_selectedProvince ?? "ที่เลือก"}',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                )
              : SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Column(
                    children: filteredPlaces.map((place) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    PlaceDetailPage(place: place),
                              ),
                            );
                          },
                          child: _buildBoxItemHorizontal(
                            place.bannerImage,
                            place.name,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
    );
  }

  Widget _buildBoxItemHorizontal(String imagePath, String label) {
    return Row(
      children: [
        Container(
          width: 180,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(8),
            image: DecorationImage(
              image: MemoryImage(base64Decode(imagePath.split(',')[1])),
              fit: BoxFit.cover,
            ),
          ),
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

  List<Place> _getFilteredPlaces() {
    if (_selectedProvince == null) {
      return _places;
    }
    return _places.where((place) {
      final province = place.address['province'] as String?;
      return province == _selectedProvince;
    }).toList();
  }

  void _loadFilteredPlaces() {
    setState(() {
      _isLoading = true;
    });

    // จำลองการโหลดข้อมูลใหม่
    Future.delayed(Duration(milliseconds: 300), () {
      setState(() {
        _isLoading = false;
      });
    });
  }
}
