import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConsumerApiFavorite {
  final Dio _dio = Dio();
  final String baseUrl =
      'https://deal-conect-b7ef7c62c9d7.herokuapp.com/favorites';

  ConsumerApiFavorite() {
    _dio.interceptors.add(LogInterceptor(
      responseBody: true,
      requestBody: true,
      requestHeader: true,
      responseHeader: true,
      error: true,
    ));
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('authToken');
  }

  Future<int?> getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('userId');
    if (userId == null) {
      print("No user ID found in SharedPreferences.");
    }
    return userId;
  }

  Future<bool> addFavorite(int productId) async {
    int? userId = await getCurrentUserId();
    String? token = await getToken();
    if (userId == null || token == null) {
      print("User not logged in or no token found.");
      return false;
    }

    try {
      final response = await _dio.post(
        baseUrl,
        data: {
          'userId': userId,
          'productId': productId,
        },
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
      print('Favorite added: ${response.data}');
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Error adding favorite: $e');
      return false;
    }
  }

  Future<bool> removeFavorite(int productId) async {
    int? userId = await getCurrentUserId();
    String? token = await getToken();
    if (userId == null || token == null) {
      print("User not logged in or no token found.");
      return false;
    }

    try {
      final response = await _dio.delete(
        '$baseUrl',
        queryParameters: {'userId': userId, 'productId': productId},
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
      print('Favorite removed: ${response.data}');
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      print('Error removing favorite: $e');
      return false;
    }
  }

  Future<bool> checkFavorite(int productId) async {
    int? userId = await getCurrentUserId();
    String? token = await getToken();
    if (userId == null || token == null) {
      print("User not logged in or no token found.");
      return false;
    }

    try {
      final response = await _dio.get(
        '$baseUrl/check',
        queryParameters: {'userId': userId, 'productId': productId},
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
      print('Check favorite response: ${response.data}');
      return response.data['isFavorite'] ?? false;
    } catch (e) {
      print('Error checking favorite: $e');
      return false;
    }
  }

  Future<bool> favoriteProduct(int productId) async {
    return addFavorite(productId);
  }

  Future<bool> unfavoriteProduct(int productId) async {
    return removeFavorite(productId);
  }
}
