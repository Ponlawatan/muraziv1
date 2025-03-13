import 'package:flutter/material.dart';
import 'package:murazi_dev/homepage.dart';
import 'package:murazi_dev/notification.dart';
import 'package:murazi_dev/userpage.dart';
import 'package:murazi_dev/placedetail.dart';
import 'package:murazi_dev/models/place.dart';
import 'package:murazi_dev/services/favorite_service.dart';

class FavoritePage extends StatefulWidget {
  const FavoritePage({super.key});

  @override
  FavoritePageState createState() => FavoritePageState();
}

class FavoritePageState extends State<FavoritePage> {
  int _selectedIndex = 1;
  List<Place> favoritePlaces = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchFavoritePlaces();
  }

  Future<void> fetchFavoritePlaces() async {
    setState(() {
      isLoading = true;
    });

    try {
      final places = await FavoriteService.getFavoritePlaces();
      print('Received places in FavoritePage: $places');

      if (places.isEmpty) {
        print('No favorite places found');
        setState(() {
          favoritePlaces = [];
          isLoading = false;
        });
        return;
      }

      setState(() {
        try {
          favoritePlaces = places.map((json) {
            final modifiedJson = Map<String, dynamic>.from({
              ...json,
              'id': json['_id'],
              'name': json['name'] ?? '',
              'bannerImage': json['bannerImage'] ?? '',
              'categories': (json['categories'] as List?)?.cast<String>() ?? [],
              'description': json['description'] ?? '',
              'googleMapUrl': json['googleMapUrl'] ?? '',
            });
            print('Modified JSON for Place: $modifiedJson');
            return Place.fromJson(modifiedJson);
          }).toList();
        } catch (e) {
          print('Error converting places: $e');
          print('Error details for each place:');
          for (var json in places) {
            print('Place data: $json');
          }
          favoritePlaces = [];
        }
        isLoading = false;
      });
    } catch (e) {
      print('Error in fetchFavoritePlaces: $e');
      setState(() {
        isLoading = false;
        favoritePlaces = [];
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('ไม่สามารถโหลดสถานที่ที่ถูกใจได้ กรุณาลองใหม่อีกครั้ง'),
          backgroundColor: Colors.red,
        ),
      );
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
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              fetchFavoritePlaces();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(height: 10),
          _HeadText(),
          SizedBox(height: 5),
          Expanded(
            child: isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      color: const Color.fromARGB(255, 255, 0, 0),
                    ),
                  )
                : favoritePlaces.isEmpty
                    ? Center(
                        child: Text(
                          'ยังไม่มีสถานที่ที่ถูกใจ',
                          style: TextStyle(fontSize: 16),
                        ),
                      )
                    : GridView.builder(
                        padding: EdgeInsets.all(8),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                          childAspectRatio: 1,
                        ),
                        itemCount: favoritePlaces.length,
                        itemBuilder: (context, index) {
                          final place = favoritePlaces[index];
                          return FavoritePlaceCard(place: place);
                        },
                      ),
          ),
        ],
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
          'สถานที่ถูกใจ',
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

class FavoritePlaceCard extends StatelessWidget {
  final Place place;

  const FavoritePlaceCard({super.key, required this.place});

  @override
  Widget build(BuildContext context) {
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
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 3,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                place.bannerImage,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[200],
                    child: Icon(
                      Icons.image_not_supported,
                      color: Colors.grey[400],
                    ),
                  );
                },
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.7),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Text(
                    place.name,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
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
