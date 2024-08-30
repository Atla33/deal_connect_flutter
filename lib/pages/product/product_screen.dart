import 'package:flutter/material.dart';
import 'package:deal_connect_flutter/config/custom_colors.dart';
import 'package:deal_connect_flutter/service/consumer_api_product.dart';
import 'package:deal_connect_flutter/models/product.dart';
import 'package:intl/intl.dart';

import 'edit_product_screen.dart';

class ProductPage extends StatefulWidget {
  final Product product;

  const ProductPage({super.key, required this.product});

  @override
  _ProductDetailPageState createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductPage> {
  final ConsumerApiProduct api = ConsumerApiProduct();
  final NumberFormat currencyFormat =
      NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
  late Product product;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    product = widget.product;
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

  void confirmDeletion() async {
    final bool shouldDelete = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Confirmar Exclusão'),
            content: Text('Você realmente deseja excluir este produto?'),
            actions: [
              TextButton(
                child: Text('Não'),
                onPressed: () => Navigator.of(context).pop(false),
              ),
              TextButton(
                child: Text('Sim'),
                onPressed: () => Navigator.of(context).pop(true),
              ),
            ],
          ),
        ) ??
        false;

    if (shouldDelete) {
      deleteProduct(product.id);
    }
  }

  void deleteProduct(int productId) async {
    bool deleted = await api.deleteProduct(productId);
    if (deleted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Produto excluído com sucesso!')));
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Falha ao excluir produto')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white.withAlpha(230),
      appBar: AppBar(
        backgroundColor: CustomColors.customSwatchColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title:
            Text('Detalhes do Produto', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: Image.network(product.imageUrl, fit: BoxFit.cover),
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade600,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
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
                              icon: Icon(Icons.edit,
                                  color: Colors.blue, size: 30),
                              onPressed: () async {
                                bool? result = await Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        EditProductScreen(productData: {
                                      'id': product.id,
                                      'name': product.title,
                                      'type': product.type,
                                      'value': product.price.toString(),
                                      'image': product.imageUrl,
                                      'description': product.description,
                                    }),
                                  ),
                                );
                                if (result == true) {
                                  _fetchProductDetails();
                                }
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.delete,
                                  color: Colors.red, size: 30),
                              onPressed: confirmDeletion,
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
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
