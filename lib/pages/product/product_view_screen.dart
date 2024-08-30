import 'package:deal_connect_flutter/pages/product/product_creat_screen.dart';
import 'package:flutter/material.dart';
import 'package:deal_connect_flutter/config/custom_colors.dart';
import 'package:deal_connect_flutter/service/consumer_api_product.dart';
import 'package:deal_connect_flutter/pages/product/product_screen.dart';
import 'package:deal_connect_flutter/models/product.dart';

class ProductViewScreen extends StatefulWidget {
  const ProductViewScreen({super.key});

  @override
  _ProductViewScreenState createState() => _ProductViewScreenState();
}

class _ProductViewScreenState extends State<ProductViewScreen> {
  List<Product> products = [];
  bool isLoading = true;
  final ConsumerApiProduct api = ConsumerApiProduct();

  @override
  void initState() {
    super.initState();
    loadProducts();
  }

  Future<void> loadProducts() async {
    try {
      var fetchedProducts = await api.getProductsByUserId();
      setState(() {
        products = fetchedProducts
            .map<Product>((json) => Product.fromJson(json))
            .toList();
        isLoading = false;
      });
    } catch (e) {
      print('Failed to load products: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void navigateAndRefresh() {
    Navigator.of(context)
        .push(
      MaterialPageRoute(
        builder: (context) => ProductCreateScreen(),
      ),
    )
        .then((_) {
      loadProducts();
    });
  }

  void navigateAndEditProduct(Product product) {
    Navigator.of(context)
        .push(
      MaterialPageRoute(
        builder: (context) => ProductPage(product: product),
      ),
    )
        .then((_) {
      loadProducts();
    });
  }

  void confirmDeletion(int productId) async {
    final bool shouldDelete = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Confirmar Exclusão'),
            content: const Text('Você realmente deseja excluir este produto?'),
            actions: [
              TextButton(
                child: const Text('Não'),
                onPressed: () => Navigator.of(context).pop(false),
              ),
              TextButton(
                child: const Text('Sim'),
                onPressed: () => Navigator.of(context).pop(true),
              ),
            ],
          ),
        ) ??
        false;

    if (shouldDelete) {
      deleteProduct(productId);
    }
  }

  void deleteProduct(int productId) async {
    bool deleted = await api.deleteProduct(productId);
    if (deleted) {
      setState(() {
        products.removeWhere((product) => product.id == productId);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Produto excluído com sucesso!')),
        );
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Falha ao excluir produto')),
      );
    }
  }

  void toggleVisibility(Product product) async {
    setState(() {
      product.isVisible = !product.isVisible;
    });
    bool updated =
        await api.updateProductVisibility(product.id, product.isVisible);
    if (updated) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(product.isVisible
              ? 'O anúncio está visível'
              : 'O produto não está mais visível'),
        ),
      );
    } else {
      setState(() {
        product.isVisible = !product.isVisible;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Falha ao atualizar visibilidade do produto')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Deal Connect', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: CustomColors.customSwatchColor,
        iconTheme: const IconThemeData(color: Colors.white),
        automaticallyImplyLeading: false,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return InkWell(
                  onTap: () => navigateAndEditProduct(product),
                  child: Card(
                    elevation: 5,
                    margin:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Image.network(
                          product.imageUrl,
                          width: double.infinity,
                          height: 120,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                            height: 120,
                            color: Colors.grey,
                            alignment: Alignment.center,
                            child: const Icon(Icons.broken_image, size: 48),
                          ),
                        ),
                        ListTile(
                          title: Text(
                            product.title,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          subtitle: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  product.description.length > 80
                                      ? '${product.description.substring(0, 80)}...'
                                      : product.description,
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                              Switch(
                                value: product.isVisible,
                                onChanged: (value) {
                                  toggleVisibility(product);
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(
            bottom: 20.0), // Ajuste o valor conforme necessário
        child: FloatingActionButton(
          onPressed: navigateAndRefresh,
          child: Icon(Icons.add, color: Colors.white),
          backgroundColor: CustomColors.customSwatchColor,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
    );
  }
}
