import 'package:deal_connect_flutter/pages/Verification/verify_code_screen.dart';
import 'package:deal_connect_flutter/service/consumer_api_creat.dart';
import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../components/custom_text_fild.dart';
import '../../config/custom_colors.dart';

class SignUpScreen extends StatefulWidget {
  SignUpScreen({Key? key}) : super(key: key);

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final usernameController = TextEditingController();
  final phoneController = TextEditingController();

  final phoneFormatter = MaskTextInputFormatter(
    mask: '+55 (##) #####-####',
    filter: {'#': RegExp(r'[0-9]')},
  );

  Future<void> _registerUser(BuildContext context) async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final username = usernameController.text.trim();
    final phone = phoneController.text.trim();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      await ConsumerApiCreat().createUser(
        name: name,
        email: email,
        password: password,
        username: username,
        phone: phone,
      );

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('email', email);

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => VerifyCodeScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro ao cadastrar o usuário'),
          backgroundColor: Colors.red,
        ),
      );
      print('Erro ao cadastrar o usuário: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: CustomColors.customSwatchColor,
      body: SingleChildScrollView(
        child: SizedBox(
          height: size.height,
          width: size.width,
          child: Stack(
            children: [
              Column(
                children: [
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Cadastro',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 35,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 40,
                    ),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(45)),
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          CustomTextFild(
                            icon: Icons.person,
                            label: 'Nome',
                            customcontroller: nameController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor, insira o nome';
                              }
                              return null;
                            },
                          ),
                          CustomTextFild(
                            icon: Icons.email,
                            label: 'Email',
                            customcontroller: emailController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor, insira o email';
                              }
                              return null;
                            },
                          ),
                          CustomTextFild(
                            icon: Icons.lock,
                            label: 'Senha',
                            isSecret: true,
                            customcontroller: passwordController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor, insira a senha';
                              }
                              return null;
                            },
                          ),
                          CustomTextFild(
                            icon: Icons.lock,
                            label: 'Confirme a Senha',
                            isSecret: true,
                            customcontroller: confirmPasswordController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor, confirme a senha';
                              }
                              if (value != passwordController.text) {
                                return 'As senhas não coincidem';
                              }
                              return null;
                            },
                          ),
                          CustomTextFild(
                            icon: Icons.person,
                            label: 'Apelido',
                            customcontroller: usernameController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor, insira o apelido';
                              }
                              return null;
                            },
                          ),
                          CustomTextFild(
                            icon: Icons.phone,
                            label: 'Celular',
                            inputFormatters: [phoneFormatter],
                            customcontroller: phoneController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor, insira o celular';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          // Botão Cadastrar
                          SizedBox(
                            height: 50,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: CustomColors.customSwatchColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                              ),
                              onPressed: () async {
                                await _registerUser(context);
                              },
                              child: const Text(
                                'Cadastrar usuário',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
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
              Positioned(
                left: 10,
                top: 10,
                child: SafeArea(
                  child: IconButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 35,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
