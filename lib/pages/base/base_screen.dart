import 'package:deal_connect_flutter/pages/bus/bus_schedule_page.dart';
import 'package:deal_connect_flutter/pages/product/favorite_products_page.dart';
import 'package:deal_connect_flutter/pages/product/product_view_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/custom_colors.dart';
import '../home/home_tab.dart';
import '../profile/profile_tab.dart';

class BaseScreen extends StatefulWidget {
  const BaseScreen({super.key});

  @override
  State<BaseScreen> createState() => _BaseScreenState();
}

class _BaseScreenState extends State<BaseScreen> {
  int currentIndex = 0;
  final pageController = PageController();
  int? loggedInUserId;
  @override
  void initState() {
    super.initState();
    loadUserId();
  }

  void loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final String? userIdString = prefs.getString('user_id');
    if (userIdString != null) {
      setState(() {
        loggedInUserId = int.tryParse(userIdString);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return loggedInUserId == null
        ? Scaffold(
            body: Center(child: CircularProgressIndicator()),
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: currentIndex,
              onTap: (index) => setState(() => currentIndex = index),
              type: BottomNavigationBarType.fixed,
              selectedItemColor: CustomColors.customSwatchColor,
              unselectedItemColor: Colors.grey.withAlpha(250),
              items: const [
                BottomNavigationBarItem(
                    icon: Icon(Icons.home_outlined), label: 'Home'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.favorite_border_outlined),
                    label: 'Favoritos'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.production_quantity_limits_outlined),
                    label: 'Meus Produtos'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.person_outline), label: 'Perfil'),
              ],
            ),
          )
        : Scaffold(
            body: PageView(
              physics: const NeverScrollableScrollPhysics(),
              controller: pageController,
              children: [
                HomeTab(),
                FavoriteProductsPage(loggedInUserId: loggedInUserId!),
                const BusSchedulePage(),
                const ProductViewScreen(),
                const ProfileTab(),
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
              selectedItemColor: CustomColors.customSwatchColor,
              unselectedItemColor: Colors.grey.withAlpha(250),
              items: const [
                BottomNavigationBarItem(
                    icon: Icon(Icons.home_outlined), label: 'Home'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.favorite_border_outlined),
                    label: 'Favoritos'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.bus_alert), label: 'Intinerário'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.production_quantity_limits_outlined),
                    label: 'Meus Produtos'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.person_outline), label: 'Perfil'),
              ],
            ),
          );
  }
}
