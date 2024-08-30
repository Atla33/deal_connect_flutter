import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConsumerApiLogin {
  static String token = "";
  static String refreshToken = "";
  static String role = "";
  static String phone = "";
  static String userId = "";

  ConsumerApiLogin._();

  static Future<bool> autenticacao(String email, String password) async {
    try {
      final dio = Dio();
      final response = await dio.post(
        'https://deal-conect-b7ef7c62c9d7.herokuapp.com/login',
        data: {'email': email, 'password': password},
      );

      print(response.statusCode);

      token = response.data['token']['access_token'];
      refreshToken = response.data['token']['refresh_token'];
      role = response.data['user']['role'];
      phone = response.data['user']['phone'];
      userId = response.data['user']['id']
          .toString(); // Convertendo o ID do usuário para String

      // Salvando os tokens e o ID do usuário no SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('access_token', token);
      await prefs.setString('refresh_token', refreshToken);
      await prefs.setString(
          'user_id', userId); // Salvando o ID do usuário como String

      print(role);
      print(token);
      print(refreshToken);
      print(phone);
      print(userId); // Imprimir o ID do usuário

      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }
}
