import 'package:flutter/material.dart';
import 'package:murazi_dev/favorite.dart';
import 'package:murazi_dev/homepage.dart';
import 'package:murazi_dev/notification.dart';
import 'package:murazi_dev/userpage.dart';
import 'package:murazi_dev/models/place.dart';
import 'package:murazi_dev/services/place_service.dart';
import 'package:murazi_dev/placedetail.dart';
import 'dart:convert';

class InvestmentCatalogPage extends StatefulWidget {
  const InvestmentCatalogPage({super.key});

  @override
  _InvestmentCatalogPageState createState() => _InvestmentCatalogPageState();
}

class _InvestmentCatalogPageState extends State<InvestmentCatalogPage> {
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
      final places = await _placeService.getPlacesByCategory('การค้าขาย');
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

  Future<void> _loadFilteredPlaces() async {
    try {
      setState(() {
        _isLoading = true;
      });
      List<Place> filteredPlaces;
      if (_selectedProvince == null || _selectedProvince == 'ทั้งหมด') {
        filteredPlaces = await _placeService.getPlacesByCategory('การค้าขาย');
      } else {
        final allPlaces = await _placeService.getPlacesByCategory('การค้าขาย');
        filteredPlaces = allPlaces
            .where((place) => place.address['province'] == _selectedProvince)
            .toList();
      }
      setState(() {
        _places = filteredPlaces;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading filtered places: $e');
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
          'หมวดหมู่ : การค้าขาย',
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
    return LayoutBuilder(
      builder: (context, constraints) {
        double maxWidth = constraints.maxWidth;
        double itemWidth = maxWidth > 600 ? 180 : 140;

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 5),
              _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : _places.isEmpty
                      ? Center(
                          child: Text(
                            'ไม่พบสถานที่ในจังหวัด ${_selectedProvince ?? "ที่เลือก"}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                        )
                      : SizedBox(
                          height: 220,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _places.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 10),
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => PlaceDetailPage(
                                          place: _places[index],
                                        ),
                                      ),
                                    );
                                  },
                                  child:
                                      _buildBoxItem(_places[index], itemWidth),
                                ),
                              );
                            },
                          ),
                        ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBoxItem(Place place, double width) {
    return Column(
      children: [
        Container(
          width: width,
          height: 160,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
            image: DecorationImage(
              image: NetworkImage(place.bannerImage),
              fit: BoxFit.cover,
              onError: (error, stackTrace) {
                print('Error loading image: $error');
              },
            ),
          ),
        ),
        SizedBox(height: 8),
        SizedBox(
          width: width,
          child: Text(
            place.name,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: const Color.fromARGB(255, 255, 0, 0),
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _PlaceSlideDetailPreviewHeadText() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          'แนะนำสำหรับคุณ',
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
    return LayoutBuilder(
      builder: (context, constraints) {
        double maxWidth = constraints.maxWidth;
        double itemWidth = maxWidth > 600 ? 300 : 240;

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: _isLoading
              ? Center(child: CircularProgressIndicator())
              : _places.isEmpty
                  ? Center(
                      child: Text(
                        'ไม่พบสถานที่ในจังหวัด ${_selectedProvince ?? "ที่เลือก"}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                    )
                  : SizedBox(
                      height: 340,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _getFilteredPlaces().length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 16),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PlaceDetailPage(
                                      place: _getFilteredPlaces()[index],
                                    ),
                                  ),
                                );
                              },
                              child: _buildBoxItemHorizontal(
                                  _getFilteredPlaces()[index], itemWidth),
                            ),
                          );
                        },
                      ),
                    ),
        );
      },
    );
  }

  List<Place> _getFilteredPlaces() {
    if (_places.isEmpty) return [];
    List<Place> placesCopy = List.from(_places);
    placesCopy.shuffle();
    return placesCopy.take(8).toList();
  }

  Widget _buildBoxItemHorizontal(Place place, double width) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: width,
          height: 230,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
            image: DecorationImage(
              image: NetworkImage(place.bannerImage),
              fit: BoxFit.cover,
              onError: (error, stackTrace) {
                print('Error loading image: $error');
              },
            ),
          ),
        ),
        SizedBox(height: 8),
        SizedBox(
          width: width,
          child: Text(
            place.name,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color.fromARGB(255, 255, 0, 0),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        SizedBox(height: 4),
        SizedBox(
          width: width,
          child: Text(
            place.address['province'] ?? '',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
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
