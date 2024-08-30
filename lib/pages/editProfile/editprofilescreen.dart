import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:deal_connect_flutter/service/consumer_api_user.dart';
import '../../components/custom_text_fild.dart';
import '../../config/custom_colors.dart';

class EditProfileScreen extends StatefulWidget {
  final Map<String, String> userData;
  final VoidCallback onProfileUpdated;

  const EditProfileScreen({
    Key? key,
    required this.userData,
    required this.onProfileUpdated,
  }) : super(key: key);

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final usernameController = TextEditingController();
  final phoneController = TextEditingController();

  late final Map<String, String> userData;

  final phoneFormatter = MaskTextInputFormatter(
    mask: '+55 (##) #####-####',
    filter: {'#': RegExp(r'[0-9]')},
  );

  @override
  void initState() {
    super.initState();
    userData = widget.userData;
    nameController.text = userData['name'] ?? '';
    emailController.text = userData['email'] ?? '';
    usernameController.text = userData['username'] ?? '';
    phoneController.text = userData['phone'] ?? '';
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
                        'Editar Perfil',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 35,
                        ),
                      ),
                    ),
                  ),

                  // Formulário
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        CustomTextFild(
                          icon: Icons.person,
                          label: 'Nome',
                          customcontroller: nameController,
                        ),
                        CustomTextFild(
                          icon: Icons.email,
                          label: 'Email',
                          customcontroller: emailController,
                        ),
                        CustomTextFild(
                          icon: Icons.lock,
                          label: 'Nova Senha',
                          isSecret: true,
                          customcontroller: newPasswordController,
                        ),
                        CustomTextFild(
                          icon: Icons.lock,
                          label: 'Confirmar Nova Senha',
                          isSecret: true,
                          customcontroller: confirmPasswordController,
                        ),
                        CustomTextFild(
                          icon: Icons.person,
                          label: 'Apelido',
                          customcontroller: usernameController,
                        ),
                        CustomTextFild(
                          icon: Icons.phone,
                          label: 'Celular',
                          inputFormatters: [phoneFormatter],
                          customcontroller: phoneController,
                        ),

                        // Botão Atualizar
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
                              String newPassword =
                                  newPasswordController.text.trim();
                              String confirmPassword =
                                  confirmPasswordController.text.trim();

                              if (newPassword.isNotEmpty ||
                                  confirmPassword.isNotEmpty) {
                                if (newPassword != confirmPassword) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content:
                                          Text('As novas senhas não coincidem'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                  return;
                                }
                              }

                              Map<String, String> newData = {};

                              if (nameController.text.trim() !=
                                  userData['name']) {
                                newData['name'] = nameController.text.trim();
                              }
                              if (emailController.text.trim() !=
                                  userData['email']) {
                                newData['email'] = emailController.text.trim();
                              }
                              if (usernameController.text.trim() !=
                                  userData['username']) {
                                newData['username'] =
                                    usernameController.text.trim();
                              }
                              if (phoneController.text.trim() !=
                                  userData['phone']) {
                                newData['phone'] = phoneController.text.trim();
                              }
                              if (newPassword.isNotEmpty) {
                                newData['password'] = newPassword;
                              }

                              if (newData.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content:
                                        Text('Nenhuma alteração detectada'),
                                    backgroundColor: Colors.orange,
                                  ),
                                );
                                return;
                              }

                              bool success = await ConsumerApiUser.editUserData(
                                newData,
                              );

                              if (success) {
                                widget
                                    .onProfileUpdated(); // Chama o callback para notificar a atualização
                                Navigator.of(context)
                                    .pop(); // Volta para a tela de perfil
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content:
                                        Text('Dados atualizados com sucesso'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Erro ao atualizar os dados'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            },
                            child: const Text(
                              'Atualizar',
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
