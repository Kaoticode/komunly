import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:komunly/constants/constants.dart';
import 'package:komunly/pages/user/login_page.dart';
import 'package:komunly/widgets/snackbars.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class PostImagePage extends StatefulWidget {
  final File image;

  const PostImagePage({super.key, required this.image});

  @override
  State<PostImagePage> createState() => _PostImagePageState();
}

class _PostImagePageState extends State<PostImagePage> {
  final TextEditingController _captionController = TextEditingController();
  var publicarText = "Publicar";

  Future<void> enviarImagenAlAPI(File image) async {
    setState(() {
      publicarText = "Publicando...";
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('access_token');
    String apiUrl = "$API_URL/posts";

    var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
    request.headers.addAll({
      'Authorization': 'Bearer $accessToken',
    });
    // request.fields['type'] = 'free';
    request.fields['caption'] = _captionController.text;
    request.files.add(await http.MultipartFile.fromPath(
      'postImage',
      image.path,
    ));

    try {
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201) {
        setState(() {
          publicarText = "Publicada";
        });
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
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Subir post',
          style: TextStyle(fontSize: 22, color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            color: Colors.red,
            height: 300,
            width: 300,
            child: Image.file(widget.image, fit: BoxFit.cover),
          ),
          const Divider(),
          TextField(
            controller: _captionController,
            decoration: InputDecoration(
              labelText: 'Caption',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
            ),
            style: const TextStyle(
                color: Colors.white), // Color del texto cuando se escribe
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
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      publicarText,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Icon(
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
