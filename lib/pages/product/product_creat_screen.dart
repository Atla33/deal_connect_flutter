import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../config/custom_colors.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http_parser/http_parser.dart';

class ProductCreateScreen extends StatefulWidget {
  const ProductCreateScreen({Key? key}) : super(key: key);

  @override
  State<ProductCreateScreen> createState() => _ProductCreateScreenState();
}

class _ProductCreateScreenState extends State<ProductCreateScreen> {
  final Dio _dio = Dio();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  File? _image;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _typeController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  String? _accessToken;
  String? _userId;
  final NumberFormat _currencyFormat =
      NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

  @override
  void initState() {
    super.initState();
    _loadUserCredentials();
    _priceController.addListener(_formatPrice);
  }

  @override
  void dispose() {
    _priceController.removeListener(_formatPrice);
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _loadUserCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _accessToken = prefs.getString('access_token');
      _userId = prefs.getString('user_id');
    });
  }

  void _formatPrice() {
    String text = _priceController.text;
    if (text.isEmpty) return;

    text = text.replaceAll(RegExp(r'[^\d]'), '');
    if (text.isEmpty) return;

    double value = double.parse(text) / 100;
    String formatted = _currencyFormat.format(value);

    _priceController.value = TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  Future<void> getImage() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _image = File(image.path);
      });
    }
  }

  void removeImage() {
    setState(() {
      _image = null;
    });
  }

  Future<void> submitProduct() async {
    if (!_formKey.currentState!.validate() || _image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please fill all the fields and select an image!')),
      );
      return;
    }

    final String name = _nameController.text;
    final String type = _typeController.text;
    final String description = _descriptionController.text;
    final double? price =
        _currencyFormat.parse(_priceController.text).toDouble();

    if (price == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid price')),
      );
      return;
    }

    int? userIdInt = int.tryParse(_userId ?? '');
    if (userIdInt == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid user ID')),
      );
      return;
    }

    String fileName = _image!.path.split('/').last;
    String fileExtension = fileName.split('.').last;
    MediaType? mediaType;

    switch (fileExtension.toLowerCase()) {
      case 'jpg':
      case 'jpeg':
        mediaType = MediaType('image', 'jpeg');
        break;
      case 'png':
        mediaType = MediaType('image', 'png');
        break;
      case 'gif':
        mediaType = MediaType('image', 'gif');
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unsupported image type')),
        );
        return;
    }

    FormData formData = FormData.fromMap({
      'name': name,
      'type': type,
      'description': description,
      'value': price.toStringAsFixed(2), // Garantir duas casas decimais
      'userId': userIdInt,
      'image': await MultipartFile.fromFile(
        _image!.path,
        filename: fileName,
        contentType: mediaType,
      ),
    });

    try {
      var response = await _dio.post(
        'https://deal-conect-b7ef7c62c9d7.herokuapp.com/product',
        data: formData,
        options: Options(headers: {'Authorization': 'Bearer $_accessToken'}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product successfully created!')),
        );
        Navigator.pop(context);
      } else {
        String errorMsg =
            "Failed to create the product: ${response.statusCode}";
        if (response.data != null) {
          errorMsg += "\nError Details: ${response.data}";
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMsg)),
        );
      }
    } on DioError catch (e) {
      String errorMessage = 'Error while creating product';
      if (e.response != null) {
        errorMessage += ': ${e.response!.data}';
      } else {
        errorMessage += ": ${e.message}";
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Colors.white.withAlpha(230), // Define a cor de fundo do Scaffold
      appBar: AppBar(
        centerTitle: true,
        title:
            const Text('Deal Connect', style: TextStyle(color: Colors.white)),
        backgroundColor: CustomColors.customSwatchColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: _buildInputDecoration(
                      'Nome do Produto', Icons.production_quantity_limits),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _typeController,
                  decoration: _buildInputDecoration(
                      'Tipo do Produto (ex: Eletrônicos, Vestuário, etc)',
                      Icons.category),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _descriptionController,
                  decoration: _buildInputDecoration(
                      'Descrição do Produto', Icons.description),
                  maxLines: 3,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _priceController,
                  decoration: _buildInputDecoration(
                      'Preço do Produto', Icons.monetization_on),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 20),
                _image == null
                    ? const Center(child: Text('Nenhuma imagem selecionada.'))
                    : Center(child: Image.file(_image!)),
                const SizedBox(height: 10),
                FloatingActionButton(
                  onPressed: getImage,
                  tooltip: 'Selecionar Imagem',
                  child: const Icon(
                    Icons.add_a_photo,
                    color: Colors.white,
                  ),
                  backgroundColor: CustomColors.customSwatchColor,
                ),
                if (_image != null)
                  TextButton(
                    onPressed: removeImage,
                    child: const Text('Remover Imagem'),
                  ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    submitProduct();
                  },
                  child: const Text('Registrar Produto',
                      style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CustomColors.customSwatchColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      filled: true,
      fillColor: Colors.white.withAlpha(230),
      labelStyle: const TextStyle(color: Colors.black54),
    );
  }
}
