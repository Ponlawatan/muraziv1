import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/place.dart';

class PlaceService {
  static const String baseUrl = 'http://localhost:5000/api';

  // ดึงข้อมูลสถานที่ทั้งหมด - ไม่ต้องแก้ไข
  Future<List<Place>> getAllPlaces() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/places'));

      if (response.statusCode == 200) {
        List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((json) => Place.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load places');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // เพิ่มสถานที่ใหม่ - ต้องแก้ไข URL
  Future<Place> createPlace(Place place) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/addplaces'), // เปลี่ยนจาก /places เป็น /addplaces
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': place.name,
          'bannerImage': place.bannerImage,
          'categories': place.categories,
          'googleMapUrl': place.googleMapUrl,
          'description': place.description,
        }),
      );

      if (response.statusCode == 201) {
        return Place.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to create place');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<List<Place>> getPlacesByCategory(String category) async {
    try {
      final response =
          await http.get(Uri.parse('$baseUrl/places/category/$category'));

      if (response.statusCode == 200) {
        List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((json) => Place.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load places by category');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // เพิ่มฟังก์ชันสำหรับดึงรายการจังหวัดทั้งหมด
  Future<List<String>> getAllProvinces() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/provinces'));

      if (response.statusCode == 200) {
        List<dynamic> provinces = json.decode(response.body);
        return List<String>.from(provinces);
      } else {
        throw Exception('ไม่สามารถดึงข้อมูลจังหวัดได้');
      }
    } catch (e) {
      print('Error getting provinces: $e');
      throw Exception('เกิดข้อผิดพลาดในการดึงข้อมูลจังหวัด');
    }
  }

  // เพิ่มฟังก์ชันสำหรับดึงข้อมูลสถานที่ตามจังหวัด
  Future<List<Place>> getPlacesByProvince(String province) async {
    try {
      final response = await http.get(Uri.parse(
          '$baseUrl/places/province/${Uri.encodeComponent(province)}'));

      if (response.statusCode == 200) {
        List<dynamic> placesJson = json.decode(response.body);
        return placesJson.map((place) => Place.fromJson(place)).toList();
      } else {
        throw Exception('ไม่สามารถดึงข้อมูลสถานที่ได้');
      }
    } catch (e) {
      print('Error getting places by province: $e');
      throw Exception('เกิดข้อผิดพลาดในการดึงข้อมูลสถานที่');
    }
  }

  // endpoints อื่นๆ ยังคงเหมือนเดิม...
}
