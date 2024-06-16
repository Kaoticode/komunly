import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:komunly/constants/constants.dart';
import 'package:komunly/pages/user/login_page.dart';
import 'package:komunly/widgets/appBar.dart';
import 'package:komunly/widgets/snackbars.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class ProfileImagePage extends StatefulWidget {
  final File image;

  const ProfileImagePage({super.key, required this.image});

  @override
  State<ProfileImagePage> createState() => _ProfileImagePageState();
}

class _ProfileImagePageState extends State<ProfileImagePage> {
  Future<void> enviarImagenAlAPI(File image) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('access_token');
    String apiUrl = "$API_URL/users/profilePicture";

    var request = http.MultipartRequest('PUT', Uri.parse(apiUrl));
    request.headers.addAll({
      'Authorization': 'Bearer $accessToken',
    });
    request.files.add(await http.MultipartFile.fromPath(
      'profilePicture',
      image.path,
    ));

    try {
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        Navigator.pop(context);
      } else if (response.statusCode == 401 || response.statusCode == 400) {
        refreshTokens();
      } else {
        var responseData = json.decode(response.body);
        showSnackMessage(context, responseData['message'], "ERROR");
      }
    } catch (e) {
      showSnackMessage(context, "Error de conexión: $e", "ERROR");
    }
  }

  Future<void> refreshTokens() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    String? refreshToken = prefs.getString('refresh_token');
    String apiUrl = "$API_URL/auth/refreshTokens";

    try {
      var response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({"refreshToken": refreshToken}),
      );

      if (response.statusCode == 201) {
        var jsonResponse = json.decode(response.body);
        String accessToken = jsonResponse['access_token'];
        await prefs.setString('access_token', accessToken);
        showSnackMessage(context,
            "Tokens Refrescados, vuelve a ejecutar la función", "SUCCESS");
      } else if (response.statusCode != 201) {
        await prefs.remove('access_token');
        await prefs.remove('refresh_token');
        await prefs.remove('user_id');
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (Route<dynamic> route) => false,
        );
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
      appBar: CustomAppBar(title: "Actualizar imagen"),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                image: FileImage(widget.image),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const Divider(),
          GestureDetector(
            onTap: () async {
              await enviarImagenAlAPI(widget.image);
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(32),
                color: Colors.white,
              ),
              height: 50,
              child: const Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Actualizar",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(width: 10),
                    Icon(
                      Icons.send,
                      color: Colors.black,
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
