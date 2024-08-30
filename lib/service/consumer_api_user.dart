import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConsumerApiUser {
  static String token = "";
  static String userId = "";

  ConsumerApiUser._();

  static Future<Map<String, String>> getUserData() async {
    Map<String, String> userData = {};

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      token = prefs.getString('access_token') ?? '';
      userId = prefs.getString('user_id') ?? '';

      print('ID do usuário: $userId');

      if (token.isEmpty || userId.isEmpty) {
        print('Token de acesso ou ID do usuário não encontrado');
        return userData;
      }

      final dio = Dio();
      dio.options.headers['Authorization'] = 'Bearer $token';
      final response = await dio.get(
        'https://deal-conect-b7ef7c62c9d7.herokuapp.com/user/$userId',
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        userData['name'] = responseData['name'];
        userData['phone'] = responseData['phone'];
        userData['email'] = responseData['email'];
        userData['username'] = responseData['username'];
        userData['password'] = responseData['password'];
      } else {
        print('Erro ao obter os dados do usuário: ${response.statusCode}');
      }
    } catch (e) {
      print('Erro ao obter os dados do usuário: $e');
    }

    return userData;
  }

  static Future<bool> editUserData(Map<String, String> newUserData) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      token = prefs.getString('access_token') ?? '';
      userId = prefs.getString('user_id') ?? '';

      print('ID do usuário: $userId');
      print('Token do usuário: $token');

      if (token.isEmpty || userId.isEmpty) {
        print('Token de acesso ou ID do usuário não encontrado');
        return false;
      }

      final dio = Dio();
      dio.options.headers['Authorization'] = 'Bearer $token';
      final response = await dio.patch(
        'https://deal-conect-b7ef7c62c9d7.herokuapp.com/user/$userId',
        data: newUserData,
      );

      if (response.statusCode == 200) {
        print('Dados do usuário atualizados com sucesso');
        return true;
      } else {
        print('Erro ao atualizar os dados do usuário: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Erro ao atualizar os dados do usuário: $e');
      return false;
    }
  }

  static Future<bool> deleteUser() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      token = prefs.getString('access_token') ?? '';
      userId = prefs.getString('user_id') ?? '';

      if (token.isEmpty || userId.isEmpty) {
        print('Token de acesso ou ID do usuário não encontrado');
        return false;
      }

      final dio = Dio();
      dio.options.headers['Authorization'] = 'Bearer $token';
      final response = await dio.delete(
        'https://deal-conect-b7ef7c62c9d7.herokuapp.com/user/$userId',
      );

      if (response.statusCode == 200) {
        print('Conta do usuário deletada com sucesso');
        return true;
      } else {
        print('Erro ao deletar a conta do usuário: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Erro ao deletar a conta do usuário: $e');
      return false;
    }
  }
}
