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
}

void main() async {
  // Dados do usuário que você deseja atualizar (apenas os campos que deseja alterar)
  Map<String, String> newUserData = {
    'name': 'Novo Nome', // Exemplo: apenas o nome será atualizado
  };

  // Chamada da função para atualizar os dados do usuário
  bool success = await ConsumerApiUser.editUserData(newUserData);

  // Verificação do resultado da atualização
  if (success) {
    print('Dados do usuário atualizados com sucesso');
  } else {
    print('Falha ao atualizar os dados do usuário');
  }
}
