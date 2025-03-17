import 'dart:async';
import 'package:flutter/material.dart';
import 'package:murazi_dev/favorite.dart';
import 'package:murazi_dev/notification.dart';
import 'package:murazi_dev/typecatalogdetail/money.dart';
import 'package:murazi_dev/userpage.dart';
import 'package:murazi_dev/typecatalogdetail/love.dart';
import 'package:murazi_dev/typecatalogdetail/business.dart';
import 'package:murazi_dev/typecatalogdetail/investment.dart';
import 'package:murazi_dev/typecatalogdetail/healthcare.dart';
import 'package:murazi_dev/typecatalogdetail/lottery.dart';
import 'package:murazi_dev/typecatalogdetail/family.dart';
import 'package:murazi_dev/models/place.dart';
import 'package:murazi_dev/services/place_service.dart';
import 'package:murazi_dev/placedetail.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _MuraziHomePageState createState() => _MuraziHomePageState();
}

class _MuraziHomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  late PageController _pageController;
  late Timer _timer;
  int _currentPage = 0;
  final PlaceService _placeService = PlaceService();
  List<Place> _places = [];

  final List<Map<String, String>> _iconData1 = [
    {'image': 'asset/icondata/love.png', 'label': 'ความรัก'},
    {'image': 'asset/icondata/business.png', 'label': 'การงาน'},
    {'image': 'asset/icondata/money.png', 'label': 'โชคลาภ'},
    {'image': 'asset/icondata/investment.png', 'label': 'การค้าขาย'},
    {'image': 'asset/icondata/healthcare.png', 'label': 'สุขภาพ'},
    {'image': 'asset/icondata/family.png', 'label': 'ขอบุตร'},
    {'image': 'asset/icondata/lottery.png', 'label': 'ขอหวย'},
  ];

  @override
  void initState() {
    super.initState();
    _loadPlaces();
    _pageController = PageController();
    _startAutoSlide();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _timer.cancel();
    super.dispose();
  }

  Future<void> _loadPlaces() async {
    try {
      final places = await _placeService.getAllPlaces();
      setState(() {
        _places = places;
      });
    } catch (e) {
      print('Error loading places: $e');
    }
  }

  void _startAutoSlide() {
    _timer = Timer.periodic(Duration(seconds: 2), (Timer timer) {
      if (_currentPage < 4) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      _pageController.animateToPage(
        _currentPage,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
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

    Navigator.pushReplacement(
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
            _buildSearchRow(),
            SizedBox(height: 5),
            _buildPlacePreviewSlide(),
            SizedBox(height: 5),
            _TypeIconRow(),
            SizedBox(height: 5),
            _PlaceSlidePreviewMini(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildSearchRow() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'ค้นหาสถานที่',
                hintStyle: TextStyle(
                  color: const Color.fromARGB(255, 255, 255, 255),
                  fontWeight: FontWeight.bold,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: const Color.fromARGB(255, 255, 0, 0),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: const Color.fromARGB(255, 255, 0, 0),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: const Color.fromARGB(255, 255, 0, 0),
                  ),
                ),
                filled: true,
                fillColor: const Color.fromARGB(255, 255, 0, 0),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                prefixIcon: const Icon(
                  Icons.search,
                  color: Color.fromARGB(255, 255, 255, 255),
                ),
              ),
              style: TextStyle(
                fontSize: 16,
                color: const Color.fromARGB(255, 255, 255, 255),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlacePreviewSlide() {
    double screenWidth = MediaQuery.of(context).size.width;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      child: SizedBox(
        height: 200,
        child: _places.isEmpty
            ? Center(child: CircularProgressIndicator())
            : PageView.builder(
                controller: _pageController,
                onPageChanged: (int page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                itemCount: _places.length,
                itemBuilder: (context, index) {
                  return _buildPlaceContainer(screenWidth, _places[index]);
                },
              ),
      ),
    );
  }

  Widget _buildPlaceContainer(double screenWidth, Place place) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PlaceDetailPage(place: place),
          ),
        );
      },
      child: Container(
        width: screenWidth * 0.96,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: const Color.fromARGB(255, 255, 0, 0),
          ),
          image: DecorationImage(
            image: NetworkImage(place.bannerImage),
            fit: BoxFit.cover,
          ),
        ),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              place.name,
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              place.categories.join(', '),
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _TypeIconRow() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'หมวดหมู่',
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
              children: _iconData1.map((icon) {
                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: GestureDetector(
                    onTap: () {
                      if (icon['label'] == 'ความรัก') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LoveCatalogPage(),
                          ),
                        );
                      } else if (icon['label'] == 'การงาน') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BusinessCatalogPage(),
                          ),
                        );
                      } else if (icon['label'] == 'โชคลาภ') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MoneyCatalogPage(),
                          ),
                        );
                      } else if (icon['label'] == 'การค้าขาย') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => InvestmentCatalogPage(),
                          ),
                        );
                      } else if (icon['label'] == 'สุขภาพ') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HealthCareCatalogPage(),
                          ),
                        );
                      } else if (icon['label'] == 'ขอบุตร') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FamilyCatalogPage(),
                          ),
                        );
                      } else if (icon['label'] == 'ขอหวย') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LotteryCatalogPage(),
                          ),
                        );
                      }
                    },
                    child: _buildIconItem(
                      icon['image']!,
                      icon['label']!,
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

  Widget _buildIconItem(String imagePath, String label) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.asset(
            imagePath,
            height: 80,
            width: 80,
            fit: BoxFit.cover,
          ),
        ),
        SizedBox(
          height: 5,
          width: 5,
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: const Color.fromARGB(255, 255, 0, 0),
          ),
        ),
      ],
    );
  }

  Widget _PlaceSlidePreviewMini() {
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
          _places.isEmpty
              ? Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _getRandomPlaces(8).map((place) {
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
                          child: _buildRecommendedPlaceItem(place),
                        ),
                      );
                    }).toList(),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildRecommendedPlaceItem(Place place) {
    return Column(
      children: [
        Container(
          width: 120,
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
          width: 120,
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

  List<Place> _getRandomPlaces(int count) {
    if (_places.isEmpty) return [];
    List<Place> placesCopy = List.from(_places);
    placesCopy.shuffle();
    return placesCopy
        .take(count > placesCopy.length ? placesCopy.length : count)
        .toList();
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      items: const [
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
