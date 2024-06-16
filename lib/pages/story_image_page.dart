import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:komunly/constants/constants.dart';
import 'package:komunly/pages/user/login_page.dart';
import 'package:komunly/widgets/snackbars.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class StoryImagePage extends StatefulWidget {
  final File image;

  const StoryImagePage({super.key, required this.image});

  @override
  State<StoryImagePage> createState() => _StoryImagePageState();
}

class _StoryImagePageState extends State<StoryImagePage> {
  Future<void> enviarImagenAlAPI(File image) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('access_token');
    String apiUrl = "$API_URL/stories";

    var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
    request.headers.addAll({
      'Authorization': 'Bearer $accessToken',
    });
    request.fields['type'] = 'free';
    request.fields['caption'] = 'Probando desde app';
    request.files.add(await http.MultipartFile.fromPath(
      'storieImage',
      image.path,
    ));

    try {
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201) {
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
          'Subir historia',
          style: TextStyle(fontSize: 22, color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              openStoryOptions(context);
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Hero(
              tag: 'image_hero',
              child: Image.file(
                widget.image,
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
                      "Publicar",
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

void openStoryOptions(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.black87,
    builder: (BuildContext context) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            leading: const Icon(Icons.format_color_text_rounded,
                color: Colors.white),
            title: const Text('Añadir texto',
                style: TextStyle(color: Colors.white)),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.draw, color: Colors.white),
            title: const Text('Dibujar', style: TextStyle(color: Colors.white)),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.music_note, color: Colors.white),
            title: const Text('Añadir música',
                style: TextStyle(color: Colors.white)),
            onTap: () => Navigator.pop(context),
          ),
        ],
      );
    },
  );
}
