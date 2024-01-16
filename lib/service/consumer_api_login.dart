
import 'package:dio/dio.dart';

class ConsumerApiLogin {
  static String tokem = "";
  static String role = "";
  static String phone = "";

  ConsumerApiLogin._();

  static Future<bool> autenticacao(String email, String password) async {
    try {
      final dio = Dio();
      final response = await dio.post(
        'https://deal-conect-b7ef7c62c9d7.herokuapp.com/login',
        data: {'email': email, 'password': password},
      );

      print(response.statusCode);

      tokem = response.data['token']['access_token'];
      role = response.data['user']['role'];
      phone = response.data['user']['phone'];

      print(role);
      print(tokem);
      print(phone);

      return true;
    } catch (e) {
      print(e); // Adicionado tratamento de erro
      return false;
    }
  }
}