import 'package:flutter/material.dart';
import '../../config/custom_colors.dart';
import '../home/home_tab.dart';


class BaseScreen extends StatefulWidget {
 const BaseScreen({super.key});

  @override
  State<BaseScreen> createState() => _BaseScreenState();
}

class _BaseScreenState extends State<BaseScreen> {
  int currentIndex = 0;
  final pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        physics: const NeverScrollableScrollPhysics(),
        controller: pageController,
        children: [
        HomeTab(),
          Container(color: CustomColors.customSwatchColor.shade100,),
          Container(color: CustomColors.customSwatchColor.shade300,),
          Container(color: CustomColors.customSwatchColor.shade600,),
          Container(color: CustomColors.customSwatchColor.shade900,),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() {
            currentIndex = index;
            pageController.jumpToPage(index);
          });
        },
        type: BottomNavigationBarType.fixed,
        /*backgroundColor: CustomColors.customSwatchColor,*/
        selectedItemColor: CustomColors.customSwatchColor,
        unselectedItemColor: Colors.grey.withAlpha(250),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home'
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border_outlined),
            label: 'Favoritos'
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.production_quantity_limits_outlined),
            label: 'Meus Produtos'
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Perfil'
          ),
        ],
      ),
    );
  }
}