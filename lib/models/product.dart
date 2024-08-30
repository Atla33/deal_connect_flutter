import 'package:deal_connect_flutter/models/user.dart';

class Product {
  final int id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  final int userId;
  final User user;
  final String type;
  bool isVisible;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.userId,
    required this.user,
    required this.type,
    this.isVisible = true,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    String baseUrl = "https://example.com/storage/v1/object/sign/";
    String imageUrl = json['image'] ?? 'images/default.jpg';
    if (!imageUrl.startsWith('http')) {
      imageUrl = baseUrl + imageUrl;
    }

    return Product(
      id: json['id'] ?? 0,
      title: json['name'] ?? 'No Title',
      description: json['description'] ?? 'No Description',
      price: double.tryParse(json['value']?.toString() ?? '0') ?? 0.0,
      imageUrl: imageUrl,
      userId: json['userId'] ?? 0,
      user: User.fromJson(json['user'] ?? {}),
      type: json['type'] ?? 'No Type',
      isVisible: json['isVisible'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': title,
      'description': description,
      'value': price.toString(),
      'image': imageUrl,
      'userId': userId,
      'user': user.toJson(),
      'type': type,
      'isVisible': isVisible,
    };
  }
}
