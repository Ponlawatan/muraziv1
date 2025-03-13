import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class FavoriteService {
  static const String baseUrl = 'http://localhost:5000/api';

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // เช็คสถานะการถูกใจ
  static Future<bool> checkFavoriteStatus(String placeId) async {
    try {
      final token = await getToken();
      if (token == null) return false;

      final response = await http.get(
        Uri.parse('$baseUrl/favorite-status/$placeId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['isFavorited'];
      }
      return false;
    } catch (e) {
      print('Error checking favorite status: $e');
      return false;
    }
  }

  // เพิ่ม/ลบจากรายการโปรด
  static Future<bool> toggleFavorite(String placeId) async {
    try {
      final token = await getToken();
      if (token == null) return false;

      final response = await http.post(
        Uri.parse('$baseUrl/places/$placeId/favorite'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['isFavorited'];
      }
      return false;
    } catch (e) {
      print('Error toggling favorite: $e');
      return false;
    }
  }

  // ดึงรายการสถานที่ที่ถูกใจ
  static Future<List<dynamic>> getFavoritePlaces() async {
    try {
      final token = await getToken();
      if (token == null) {
        print('Error: No token found');
        return [];
      }

      print('Fetching favorite places with token: $token');
      final response = await http.get(
        Uri.parse('$baseUrl/favorite-places'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('Response status: ${response.statusCode}');
      print('Raw response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> places = json.decode(response.body);
        print('Decoded places: $places');

        final filteredPlaces = places.where((item) {
          print('Processing item: $item');
          return item != null &&
              item['_id'] != null &&
              item['name'] != null &&
              item['bannerImage'] != null;
        }).toList();

        print('Filtered places: $filteredPlaces');
        return filteredPlaces;
      }

      print('Invalid response status: ${response.statusCode}');
      return [];
    } catch (e) {
      print('Error fetching favorite places: $e');
      return [];
    }
  }
}
