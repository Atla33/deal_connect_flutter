import 'package:dio/dio.dart';

class ConsumerApiCreat {
  final Dio dio = Dio();

  Future<void> createUser({
    required String name,
    required String phone,
    required String email,
    required String username,
    required String password,
  }) async {
    const role = 'USER';

    final data = {
      'name': name,
      'phone': phone,
      'email': email,
      'username': username,
      'password': password,
      'role': role,
    };

    try {
      final response = await dio.post(
        'https://deal-conect-b7ef7c62c9d7.herokuapp.com/user',
        data: data,
      );

      if (response.statusCode == 201) {
        print('Usuário criado com sucesso');
      } else {
        print('Erro ao criar o usuário');
      }
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 409) {
        print('Erro ao criar o usuário: O usuário já existe');
      } else {
        print('Erro ao criar o usuário: $e');
      }
    }
  }
}
