import 'package:deal_connect_flutter/pages/screens/sign_in_screen.dart';
import 'package:flutter/material.dart';
import 'package:avatar_glow/avatar_glow.dart';
import '../../service/consumer_api_user.dart';
import '../../config/custom_colors.dart';
import '../editProfile/editprofilescreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({Key? key}) : super(key: key);

  @override
  _ProfileTabState createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  late Future<Map<String, String>> _userDataFuture;

  @override
  void initState() {
    super.initState();
    _userDataFuture = ConsumerApiUser.getUserData();
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Você deseja sair do aplicativo?'),
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
                _logout(context);
              },
            ),
          ],
        );
      },
    );
  }

  void _logout(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => SignInScreen()),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Deletar Conta'),
          content: const Text('Você realmente quer deletar sua conta?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Não'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Sim'),
              onPressed: () async {
                Navigator.of(context).pop();
                bool success = await ConsumerApiUser.deleteUser();
                if (success) {
                  // Limpar as preferências compartilhadas
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  await prefs.clear();

                  // Navegar para a tela de login
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => SignInScreen(),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content:
                          Text('Erro ao deletar a conta. Tente novamente.'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _onProfileUpdated() {
    setState(() {
      _userDataFuture = ConsumerApiUser.getUserData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, String>>(
      future: _userDataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Text('Erro ao carregar os dados do usuário');
        } else {
          final userData = snapshot.data ?? {};

          return Scaffold(
            appBar: AppBar(
              backgroundColor: CustomColors.customSwatchColor,
              centerTitle: true,
              automaticallyImplyLeading: false,
              title: const Text.rich(
                TextSpan(
                  style: TextStyle(fontSize: 25),
                  children: [
                    TextSpan(
                      text: 'Perfil',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              iconTheme: const IconThemeData(color: Colors.white),
              actions: [
                IconButton(
                  onPressed: () => _showLogoutDialog(context),
                  icon: const Icon(Icons.logout),
                ),
              ],
            ),
            body: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: CustomColors.customSwatchColor,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          height: 150,
                          width: MediaQuery.of(context).size.width,
                        ),
                        Container(
                          padding: const EdgeInsets.only(top: 90),
                          child: AvatarGlow(
                            endRadius: 60,
                            duration: const Duration(milliseconds: 2000),
                            glowColor: Colors.white,
                            repeat: true,
                            repeatPauseDuration:
                                const Duration(milliseconds: 100),
                            startDelay: const Duration(milliseconds: 100),
                            child: CircleAvatar(
                              backgroundColor: Colors.white,
                              radius: 50,
                              child: Text(
                                userData['name']?.substring(0, 1) ?? '',
                                style: TextStyle(
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold,
                                  color: CustomColors.customSwatchColor,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    userData['username'] ?? '',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        color: CustomColors.customSwatchColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          ListTile(
                            title: const Text(
                              "Nome",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              userData['name'] ?? '',
                              style: const TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const Divider(
                            color: Colors.white,
                          ),
                          ListTile(
                            title: const Text(
                              "Telefone",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              userData['phone'] ?? '',
                              style: const TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const Divider(
                            color: Colors.white,
                          ),
                          ListTile(
                            title: const Text(
                              "E-mail",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              userData['email'] ?? '',
                              style: const TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const Divider(
                            color: Colors.white,
                          ),
                          const SizedBox(height: 20),
                          Container(
                            alignment: Alignment.center,
                            padding: const EdgeInsets.all(8.0),
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EditProfileScreen(
                                      userData: userData,
                                      onProfileUpdated: _onProfileUpdated,
                                    ),
                                  ),
                                );
                              },
                              child: const Text('Editar'),
                            ),
                          ),
                          Container(
                            alignment: Alignment.center,
                            padding: const EdgeInsets.all(8.0),
                            child: ElevatedButton(
                              onPressed: () =>
                                  _showDeleteAccountDialog(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                              ),
                              child: const Text('Deletar Conta'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }
}
