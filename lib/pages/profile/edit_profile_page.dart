import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:komunly/constants/constants.dart';
import 'package:komunly/pages/upload_page.dart';
import 'package:komunly/repository/api.repository.dart';
import 'package:komunly/theme/colors.dart';
import 'package:komunly/widgets/appBar.dart';
import 'package:komunly/widgets/snackbars.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditProfilePage extends StatefulWidget {
  final String username;
  final String description;
  final String imagen;
  final bool isPublic;
  const EditProfilePage(
      {super.key,
      required this.isPublic,
      required this.username,
      required this.imagen,
      required this.description});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _usernameController;
  late TextEditingController _descriptionController;
  late bool _isPublic;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.username);
    _descriptionController = TextEditingController(text: widget.description);
    _isPublic = widget.isPublic;
  }

  Future<void> _updateProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('access_token');
    String apiUrl = "$API_URL/users";
    final String username = _usernameController.text;
    final String description = _descriptionController.text;

    try {
      var response = await http.patch(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: json.encode({
          "username": username,
          "description": description,
          "isPublic": _isPublic
        }),
      );

      if (response.statusCode == 200) {
        showSnackMessage(
            context, "Perfil actualizado correctamente", "SUCCESS");
        setState(() {});
      } else if (response.statusCode == 401 || response.statusCode == 400) {
        refreshTokens(context);
      } else {
        var responseData = json.decode(response.body);
        showSnackMessage(context, responseData['message'], "ERROR");
      }
    } catch (e) {
      showSnackMessage(context, "Error de conexión: $e", "ERROR");
    }
  }

 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: const CustomAppBar(title: "Editar Perfil"),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const UploadPage(postType: "Profile")));
              },
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 75,
                    backgroundImage: NetworkImage(
                      "$PROFILE_IMG_URL/${widget.imagen}",
                    ),
                  ),
                  Positioned(
                    bottom: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.all(6.0),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        size: 20,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            EditInput(
              inputController: _usernameController,
              icon: const Icon(Icons.person),
              placeholder: "username",
              hint: "Nombre de usuario",
            ),
            const SizedBox(height: 20),
            EditInput(
              inputController: _descriptionController,
              icon: const Icon(Icons.edit),
              placeholder: "biografia",
              hint: "Biografía",
            ),
            const SizedBox(height: 20),
            DropdownButton<bool>(
              dropdownColor: Colors.black,
              menuMaxHeight: double.infinity,
              value: _isPublic,
              onChanged: (bool? newValue) {
                setState(() {
                  _isPublic = newValue ?? false;
                });
              },
              items:
                  <bool>[true, false].map<DropdownMenuItem<bool>>((bool value) {
                return DropdownMenuItem<bool>(
                  value: value,
                  child: Text(
                    value ? 'Publica' : 'Privada',
                    style: const TextStyle(color: Colors.white),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                _updateProfile();
              },
              child: Container(
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                  color: primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Center(
                  child: Text(
                    'Actualizar perfil',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EditInput extends StatelessWidget {
  const EditInput({
    super.key,
    required this.inputController,
    required this.placeholder,
    required this.icon,
    required this.hint,
  });

  final TextEditingController inputController;
  final String placeholder;
  final Icon icon;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: inputController,
      keyboardType: TextInputType.text,
      style: const TextStyle(color: Colors.white, fontSize: 16),
      decoration: InputDecoration(
        helperMaxLines: 1,
        labelText: placeholder,
        labelStyle:
            TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide:
              BorderSide(color: Colors.white.withOpacity(0.6), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.white, width: 2),
        ),
        hintText: hint,
        hintStyle:
            TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 16),
        prefixIcon: icon,
      ),
    );
  }
}
