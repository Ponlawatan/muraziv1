import 'package:flutter/material.dart';
import 'package:murazi_dev/models/place.dart';
import 'package:murazi_dev/services/place_service.dart';
import 'package:murazi_dev/placedetail.dart';

class PlaceByProvinceScreen extends StatefulWidget {
  const PlaceByProvinceScreen({super.key});

  @override
  _PlaceByProvinceScreenState createState() => _PlaceByProvinceScreenState();
}

class _PlaceByProvinceScreenState extends State<PlaceByProvinceScreen> {
  final PlaceService _placeService = PlaceService();
  List<Place> _places = [];
  List<String> _provinces = [];
  String? _selectedProvince;
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      setState(() => _isLoading = true);

      // ดึงรายการจังหวัด
      final provinces = await _placeService.getAllProvinces();

      if (provinces.isEmpty) {
        setState(() {
          _provinces = [];
          _places = [];
          _isLoading = false;
          _errorMessage = 'ไม่พบข้อมูลจังหวัด';
        });
        return;
      }

      // เริ่มต้นเลือกจังหวัดแรก
      final firstProvince = provinces.first;
      final places = await _placeService.getPlacesByProvince(firstProvince);

      setState(() {
        _provinces = provinces;
        _selectedProvince = firstProvince;
        _places = places;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _onProvinceChanged(String? province) async {
    if (province == null) return;

    try {
      setState(() {
        _isLoading = true;
        _selectedProvince = province;
      });

      final places = await _placeService.getPlacesByProvince(province);

      setState(() {
        _places = places;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ค้นหาสถานที่ตามจังหวัด'),
        backgroundColor: const Color.fromARGB(255, 255, 0, 0),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(child: Text('เกิดข้อผิดพลาด: $_errorMessage'))
              : Column(
                  children: [
                    // ส่วนเลือกจังหวัด
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 12.0),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            hint: Text('เลือกจังหวัด'),
                            value: _selectedProvince,
                            items: _provinces.map((province) {
                              return DropdownMenuItem<String>(
                                value: province,
                                child: Text(province),
                              );
                            }).toList(),
                            onChanged: _onProvinceChanged,
                          ),
                        ),
                      ),
                    ),

                    // ส่วนแสดงรายการสถานที่
                    Expanded(
                      child: _places.isEmpty
                          ? Center(
                              child: Text('ไม่พบข้อมูลสถานที่ในจังหวัดนี้'))
                          : ListView.builder(
                              itemCount: _places.length,
                              itemBuilder: (context, index) {
                                final place = _places[index];
                                return Card(
                                  margin: EdgeInsets.symmetric(
                                      horizontal: 16.0, vertical: 8.0),
                                  elevation: 3.0,
                                  child: ListTile(
                                    leading: ClipRRect(
                                      borderRadius: BorderRadius.circular(4.0),
                                      child: Image.network(
                                        place.bannerImage,
                                        width: 50,
                                        height: 50,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                Icon(Icons.image_not_supported),
                                      ),
                                    ),
                                    title: Text(place.name),
                                    subtitle: Text(place.categories.join(", ")),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              PlaceDetailPage(place: place),
                                        ),
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
    );
  }
}
