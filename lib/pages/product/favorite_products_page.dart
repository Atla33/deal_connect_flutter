import 'package:deal_connect_flutter/models/product.dart';
import 'package:deal_connect_flutter/pages/product/product_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:deal_connect_flutter/config/custom_colors.dart';

class FavoriteProductsPage extends StatefulWidget {
  final int loggedInUserId;

  FavoriteProductsPage({required this.loggedInUserId});

  @override
  _FavoriteProductsPageState createState() => _FavoriteProductsPageState();
}

class _FavoriteProductsPageState extends State<FavoriteProductsPage> {
  List<Product> favoritedProducts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadFavoritedProducts();
  }

  void loadFavoritedProducts() async {
    setState(() {
      isLoading = true;
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String>? favoritedProductJsonList =
          prefs.getStringList('favoritedProducts');

      if (favoritedProductJsonList != null) {
        List<Product> loadedProducts =
            favoritedProductJsonList.map((productJson) {
          return Product.fromJson(jsonDecode(productJson));
        }).toList();

        setState(() {
          favoritedProducts = loadedProducts;
        });
      } else {
        setState(() {
          favoritedProducts = [];
        });
      }
    } catch (error) {
      setState(() {
        favoritedProducts = [];
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void removeFavorite(int productId) async {
    setState(() {
      favoritedProducts.removeWhere((product) => product.id == productId);
    });
    final prefs = await SharedPreferences.getInstance();
    final List<String> favoritedProductJsonList = favoritedProducts
        .map((product) => jsonEncode(product.toJson()))
        .toList();
    await prefs.setStringList('favoritedProducts', favoritedProductJsonList);
  }

  void showRemoveConfirmationDialog(int productId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Remover Produto da Lista de Favoritos'),
          content: const Text(
              'Você realmente quer remover este produto da lista de favoritos?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Não'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Sim'),
              onPressed: () {
                Navigator.of(context).pop();
                removeFavorite(productId);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: CustomColors.customSwatchColor,
        title: const Text(
          "Produtos Favoritos",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : favoritedProducts.isEmpty
              ? const Center(child: Text("Nenhum produto favoritado"))
              : GridView.builder(
                  padding: const EdgeInsets.all(10),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 3 / 4,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: favoritedProducts.length,
                  itemBuilder: (context, index) {
                    final product = favoritedProducts[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProductDetailPage(
                              product: product,
                              loggedInUserId: widget.loggedInUserId,
                            ),
                          ),
                        );
                      },
                      child: Card(
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: Image.network(
                                product.imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Center(
                                      child: Text("Erro ao carregar a imagem"));
                                },
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.title,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "R\$ ${product.price}",
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Align(
                              alignment: Alignment.bottomRight,
                              child: IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () =>
                                    showRemoveConfirmationDialog(product.id),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
