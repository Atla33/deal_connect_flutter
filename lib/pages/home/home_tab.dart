import 'package:deal_connect_flutter/config/custom_colors.dart';
import 'package:deal_connect_flutter/pages/home/components/category_tile.dart';
import 'package:flutter/material.dart';

class HomeTab extends StatefulWidget {
   HomeTab({Key? key}) : super(key: key);

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final List<String> categories = [
      'Salgados',
      'Doces',
      'Bebidas',
      'Lanches',
      'Beleza',
      'Tecnologia',
      'Livros',
      'Vestuário',
  ];

 String selectedCategory = 'Salgados';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //AppBar
      appBar: AppBar(
        backgroundColor: CustomColors.customSwatchColor,
        centerTitle: true,
        title: const Text.rich(
          TextSpan( 
            style: TextStyle(fontSize: 30),
            children: [
          TextSpan(text: 'Deal', style: TextStyle(color: Colors.white , fontWeight: FontWeight.bold)),
          TextSpan(text: 'Connect', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ])), 
      ),

      body: Column(
        children: [

          //pesquisa
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20, 
              vertical: 10
            ),
            child: TextFormField(
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                isDense: true,
                hintText:'Pesquisar...',
                hintStyle: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 14,
                ),
                prefixIcon: Icon(
                  Icons.search, 
                  color: CustomColors.customSwatchColor,
                  size: 21,
                  ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(60),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          //categorias
          Container(
            padding: const EdgeInsets.only(left:25),
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemBuilder: (_,index){
                return CategoryTile(
                  onPressed: () {
                    setState((){
                      selectedCategory = categories[index];
                    });
                  },
                  category: categories[index],
                  isSelected: categories[index] == selectedCategory,
                );
              }, 
              separatorBuilder: (_,index) =>
               const SizedBox(width: 10,), 
              itemCount: categories.length,
              shrinkWrap: true,
              ),
          ),
        ],
      ),
    );
  }
}