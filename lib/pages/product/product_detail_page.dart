import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:deal_connect_flutter/config/custom_colors.dart';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:deal_connect_flutter/models/product.dart';
import 'package:intl/intl.dart';
import 'package:deal_connect_flutter/service/consumer_api_product.dart';

class ProductDetailPage extends StatefulWidget {
  final Product product;
  final int loggedInUserId;
  static List<Product> favoritedProducts = [];

  const ProductDetailPage({
    Key? key,
    required this.product,
    required this.loggedInUserId,
  }) : super(key: key);

  @override
  _ProductDetailPageState createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  bool isLiked = false;
  late Product product;
  bool _isLoading = true;
  final ConsumerApiProduct api = ConsumerApiProduct();

  @override
  void initState() {
    super.initState();
    product = widget.product;
    loadFavoritedProducts();
    _fetchProductDetails();
  }

  Future<void> _fetchProductDetails() async {
    try {
      Product updatedProduct = await api.getProductById(widget.product.id);
      setState(() {
        product = updatedProduct;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar os detalhes do produto')),
      );
    }
  }

  void loadFavoritedProducts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String>? favoritedProductJsonList =
          prefs.getStringList('favoritedProducts');

      if (favoritedProductJsonList != null) {
        setState(() {
          ProductDetailPage.favoritedProducts = favoritedProductJsonList
              .map((productJson) => Product.fromJson(jsonDecode(productJson)))
              .toList();

          isLiked = ProductDetailPage.favoritedProducts
              .any((product) => product.id == widget.product.id);
        });
      }
    } catch (error) {
      // Handle error
    }
  }

  void saveFavoritedProducts() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> favoritedProductJsonList = ProductDetailPage
        .favoritedProducts
        .map((product) => jsonEncode(product.toJson()))
        .toList();
    await prefs.setStringList('favoritedProducts', favoritedProductJsonList);
  }

  void toggleFavorite() {
    setState(() {
      if (isLiked) {
        ProductDetailPage.favoritedProducts
            .removeWhere((product) => product.id == widget.product.id);
        isLiked = false;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Produto removido dos favoritos")),
        );
      } else {
        ProductDetailPage.favoritedProducts.add(widget.product);
        isLiked = true;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Produto adicionado aos favoritos")),
        );
      }
      saveFavoritedProducts();
    });
  }

  void launchWhatsApp() async {
    final phoneNumber = widget.product.user.phone;
    final message = "Olá, vi seu anúncio e gostaria de realizar uma compra.";
    final encodedMessage = Uri.encodeComponent(message);
    final url = "https://wa.me/$phoneNumber?text=$encodedMessage";

    if (await canLaunch(url)) {
      await launch(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                "Não foi possível abrir o WhatsApp. Verifique se o app está instalado no seu dispositivo.")),
      );
      print('Não foi possível lançar $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    final NumberFormat currencyFormat = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
    );

    return Scaffold(
      backgroundColor: Colors.white.withAlpha(230),
      appBar: AppBar(
        backgroundColor: CustomColors.customSwatchColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Detalhes do Produto',
            style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: Image.network(product.imageUrl),
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(32),
                    color: Colors.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                product.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontSize: 27, fontWeight: FontWeight.bold),
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                isLiked
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: Colors.red,
                                size: 30,
                              ),
                              onPressed: toggleFavorite,
                            ),
                          ],
                        ),
                        Text(
                          currencyFormat.format(product.price),
                          style: const TextStyle(
                              fontSize: 23,
                              fontWeight: FontWeight.bold,
                              color: Colors.black),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          "Descrição:",
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: SingleChildScrollView(
                              child: Text(
                                product.description,
                                style:
                                    const TextStyle(fontSize: 16, height: 1.5),
                              ),
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: launchWhatsApp,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: CustomColors.customSwatchColor,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                          ),
                          child: const Text(
                            "Contato via WhatsApp",
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
