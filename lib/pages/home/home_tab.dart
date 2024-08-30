import 'package:deal_connect_flutter/config/custom_colors.dart';
import 'package:deal_connect_flutter/pages/home/components/category_tile.dart';
import 'package:deal_connect_flutter/pages/product/product_detail_page.dart'
    as detail_page;
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:deal_connect_flutter/models/product.dart';
import 'package:intl/intl.dart'; // Importar o pacote intl

class HomeTab extends StatefulWidget {
  HomeTab({Key? key}) : super(key: key);

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final List<String> categories = [
    'Todos',
    'Salgados',
    'Doces',
    'Bebidas',
    'Lanches',
    'Beleza',
    'Tecnologia',
    'Livros',
    'Vestuário',
    'Almoço',
  ];
  String selectedCategory = 'Todos';
  List<Product> products = [];
  List<Product> filteredProducts = [];
  final Dio _dio = Dio();
  int? loggedInUserId;
  TextEditingController searchController = TextEditingController();
  final NumberFormat currencyFormat =
      NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

  @override
  void initState() {
    super.initState();
    getLoggedInUserId();
    getAllProducts();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> getLoggedInUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      loggedInUserId = prefs.getInt('userId');
      print("Logged in user ID: $loggedInUserId");
    });
  }

  Future<void> getAllProducts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('access_token');

    if (accessToken == null) {
      print("Token de acesso não encontrado.");
      return;
    }

    try {
      Response response = await _dio.get(
        'https://deal-conect-b7ef7c62c9d7.herokuapp.com/product/',
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );

      if (response.statusCode == 200 && response.data is List) {
        if (mounted) {
          setState(() {
            products = (response.data as List<dynamic>)
                .map((json) => Product.fromJson(json))
                .toList();
            filterProducts('');
            print("Produtos carregados: ${products.length}");
          });
        }
      } else {
        print("Falha ao recuperar produtos: ${response.statusCode}");
      }
    } catch (e) {
      print("Erro ao recuperar produtos: $e");
    }
  }

  void filterProducts(String query) {
    List<Product> tempFilteredProducts = products.where((product) {
      return product.isVisible &&
          (product.title.toLowerCase().contains(query.toLowerCase()) ||
              product.user.name.toLowerCase().contains(query.toLowerCase()) ||
              product.type.toLowerCase().contains(query.toLowerCase()));
    }).toList();

    if (selectedCategory != 'Todos') {
      tempFilteredProducts = tempFilteredProducts.where((product) {
        return product.type.toLowerCase() == selectedCategory.toLowerCase();
      }).toList();
    }

    setState(() {
      filteredProducts = tempFilteredProducts;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Product> visibleProducts = filteredProducts;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: CustomColors.customSwatchColor,
        centerTitle: true,
        title: const Text.rich(
          TextSpan(
            style: TextStyle(fontSize: 30),
            children: [
              TextSpan(
                  text: 'Deal',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
              TextSpan(
                  text: 'Connect',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: TextFormField(
              controller: searchController,
              onChanged: (value) {
                filterProducts(value);
              },
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                isDense: true,
                hintText: 'Pesquisar...',
                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                prefixIcon: Icon(Icons.search,
                    color: CustomColors.customSwatchColor, size: 21),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(60),
                    borderSide: BorderSide.none),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.only(left: 25),
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemBuilder: (_, index) {
                return CategoryTile(
                  onPressed: () {
                    setState(() {
                      selectedCategory = categories[index];
                      filterProducts(searchController.text);
                    });
                  },
                  category: categories[index],
                  isSelected: categories[index] == selectedCategory,
                );
              },
              separatorBuilder: (_, index) => const SizedBox(
                width: 10,
              ),
              itemCount: categories.length,
            ),
          ),
          Expanded(
            child: visibleProducts.isEmpty
                ? Center(
                    child: Text(
                      'Ainda não tem nenhum produto cadastrado nesta categoria',
                      style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(10),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.8,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: visibleProducts.length,
                    itemBuilder: (context, index) {
                      var product = visibleProducts[index];
                      return GestureDetector(
                        onTap: () {
                          var productDetails = product;
                          print("Produto selecionado ID: ${productDetails.id}");
                          print("Usuário logado ID: $loggedInUserId");
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  detail_page.ProductDetailPage(
                                product: productDetails,
                                loggedInUserId: loggedInUserId ?? 0,
                              ),
                            ),
                          );
                        },
                        child: Card(
                          clipBehavior: Clip.antiAlias,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child: Image.network(product.imageUrl,
                                    fit: BoxFit.cover),
                              ),
                              ListTile(
                                title: Text(product.title),
                                subtitle:
                                    Text(currencyFormat.format(product.price)),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
