import 'dart:io';
import 'package:deal_connect_flutter/models/product.dart';
import 'package:http_parser/http_parser.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConsumerApiProduct {
  final Dio _dio = Dio();

  ConsumerApiProduct() {
    _dio.options.baseUrl = 'https://deal-conect-b7ef7c62c9d7.herokuapp.com';
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        print("Requesting: ${options.method} ${options.path}");
        print("Data: ${options.data}");
        print("Headers: ${options.headers}");
        return handler.next(options);
      },
      onResponse: (response, handler) {
        print("Response: ${response.data}");
        return handler.next(response);
      },
      onError: (DioError e, handler) {
        print("Error: ${e.response?.data}");
        return handler.next(e);
      },
    ));
  }

  Future<List<dynamic>> getAllProducts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('access_token');

    if (accessToken == null) {
      print("Token de acesso não encontrado.");
      return [];
    }

    try {
      Response response = await _dio.get(
        '/product',
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );

      if (response.statusCode == 200 && response.data is List) {
        print("Produtos recuperados com sucesso.");
        return response.data;
      } else {
        print("Falha ao recuperar produtos: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("Erro ao recuperar produtos: $e");
      return [];
    }
  }

  Future<List<dynamic>> getProductsByUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('access_token');
    String? userId = prefs.getString('user_id');

    if (accessToken == null || userId == null) {
      print("Token de acesso ou ID do usuário não encontrado.");
      return [];
    }

    try {
      Response response = await _dio.get(
        '/product/by-user/$userId',
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );

      if (response.statusCode == 200) {
        print("Produtos recuperados com sucesso.");
        return response.data;
      } else {
        print("Falha ao recuperar produtos: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("Erro ao recuperar produtos: $e");
      return [];
    }
  }

  Future<bool> createProduct(
      Map<String, dynamic> productData, File? imageFile) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('access_token');
    String? userId = prefs.getString('user_id');

    if (accessToken == null || userId == null) {
      print("Token de acesso ou userId não encontrado.");
      return false;
    }

    productData['isVisible'] = true;
    productData['userId'] = userId;

    FormData formData = FormData.fromMap({
      ...productData,
      if (imageFile != null)
        'image': await MultipartFile.fromFile(imageFile.path,
            filename: imageFile.path.split('/').last,
            contentType: MediaType('image', 'jpeg')),
    });

    try {
      Response response = await _dio.post(
        '/product',
        data: formData,
        options: Options(headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'multipart/form-data'
        }),
      );

      if (response.statusCode == 200) {
        print("Produto criado com sucesso.");
        return true;
      } else {
        print(
            "Falha ao criar o produto: ${response.statusCode} - ${response.data}");
        return false;
      }
    } catch (e) {
      print("Erro ao criar o produto: $e");
      return false;
    }
  }

  Future<bool> updateProduct(
      int productId, Map<String, dynamic> updatedData, File? imageFile) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('access_token');
    String? userId = prefs.getString('user_id');

    if (accessToken == null || userId == null) {
      print("Token de acesso ou userId não encontrado.");
      return false;
    }

    FormData formData = FormData.fromMap({
      ...updatedData,
      'userId': userId,
      if (imageFile != null)
        'image': await MultipartFile.fromFile(imageFile.path,
            filename: imageFile.path.split('/').last,
            contentType: MediaType('image', 'jpeg')),
    });

    try {
      Response response = await _dio.patch(
        '/product/$productId',
        data: formData,
        options: Options(headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'multipart/form-data'
        }),
      );

      if (response.statusCode == 200) {
        print("Produto atualizado com sucesso.");
        return true;
      } else {
        print(
            "Falha ao atualizar o produto: ${response.statusCode} - ${response.data}");
        return false;
      }
    } catch (e) {
      print("Erro ao atualizar o produto: $e");
      return false;
    }
  }

  Future<bool> deleteProduct(int productId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('access_token');

    if (accessToken == null) {
      print("Token de acesso não encontrado.");
      return false;
    }

    try {
      Response response = await _dio.delete(
        '/product/$productId',
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );

      if (response.statusCode == 200) {
        print("Produto deletado com sucesso.");
        return true;
      } else {
        print("Falha ao deletar o produto: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print("Erro ao deletar o produto: $e");
      return false;
    }
  }

  Future<bool> updateProductVisibility(int productId, bool isVisible) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('access_token');

    if (accessToken == null) {
      print("Token de acesso não encontrado.");
      return false;
    }

    try {
      Response response = await _dio.patch(
        '/product/$productId/visibility',
        data: {'isVisible': isVisible},
        options: Options(headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json'
        }),
      );

      if (response.statusCode == 200) {
        print("Visibilidade do produto atualizada com sucesso.");
        return true;
      } else {
        print(
            "Falha ao atualizar visibilidade do produto: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print("Erro ao atualizar visibilidade do produto: $e");
      return false;
    }
  }

  Future<Product> getProductById(int productId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String accessToken = prefs.getString('access_token') ?? '';
    if (accessToken.isEmpty) {
      throw Exception('Token de acesso não encontrado');
    }

    try {
      Response response = await _dio.get('/product/$productId',
          options: Options(headers: {'Authorization': 'Bearer $accessToken'}));

      if (response.statusCode == 200) {
        return Product.fromJson(response.data);
      } else {
        throw Exception(
            'Failed to load product with status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Erro ao buscar detalhes do produto: $e');
      throw Exception('Erro ao buscar detalhes do produto');
    }
  }
}
