import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:komunly/constants/constants.dart';
import 'package:http/http.dart' as http;
import 'package:komunly/pages/user/login_page.dart';
import 'package:komunly/widgets/snackbars.dart';
import 'package:komunly/widgets/storyViewers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserStoryPage extends StatefulWidget {
  final List<dynamic> storiesList;
  const UserStoryPage({Key? key, required this.storiesList}) : super(key: key);

  @override
  State<UserStoryPage> createState() => _UserStoryPageState();
}

class _UserStoryPageState extends State<UserStoryPage> {
  late String myUserId;
  late bool isMyStory = false; // Inicializar como false

  @override
  void initState() {
    super.initState();
    getMyUserId();
  }

  Future<void> getMyUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    myUserId = prefs.getString('user_id') ?? ""; // Manejar el caso null
    checkStoryOwner();
  }

  void checkStoryOwner() {
    String authorId = widget.storiesList[currentStoryIndex]["author"]["_id"];
    setState(() {
      // Actualizar isMyStory después de obtener myUserId
      isMyStory = (myUserId == authorId);
    });
    // Llamar a print después de actualizar isMyStory
    printCurrentStoryId();
  }

  void printCurrentStoryId() {
    storieViewed(widget.storiesList[currentStoryIndex]["_id"]);
  }

  Future<void> storieViewed(storieId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('access_token');
    String? myUserId = prefs.getString('user_id');
    String apiUrl = "$API_URL/stories/$storieId/viewers";

    try {
      var response = await http.post(Uri.parse(apiUrl),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $accessToken',
          },
          body: jsonEncode({
            "userId": myUserId,
          }));

      if (response.statusCode == 201) {
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
                getMyUserId();
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

  int currentStoryIndex = 0;

  // Método para ir a la historia anterior
  void goToPrevStory() {
    setState(() {
      if (currentStoryIndex > 0) {
        currentStoryIndex--;
      }
    });
    printCurrentStoryId();
  }

  // Método para ir a la siguiente historia
  void goToNextStory() {
    setState(() {
      if (currentStoryIndex < widget.storiesList.length - 1) {
        currentStoryIndex++;
      }
    });
    printCurrentStoryId();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.network(
              '$STORY_IMG_URL/${widget.storiesList[currentStoryIndex]["fileName"]}',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: GestureDetector(
              onTapUp: (details) {
                final screenWidth = MediaQuery.of(context).size.width;
                if (details.globalPosition.dx < screenWidth / 2) {
                  goToPrevStory();
                } else {
                  goToNextStory();
                }
              },
            ),
          ),
          Positioned(
            top: 40,
            left: 20,
            child: Text(
              widget.storiesList[currentStoryIndex]["author"]["username"],
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    offset: Offset(0, 1),
                    blurRadius: 3,
                    color: Colors.black.withOpacity(0.5),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 40,
            right: 20,
            child: IconButton(
              icon: Icon(Icons.close, color: Colors.red),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),
          Positioned(
            bottom: 10,
            left: 10,
            child: isMyStory
                ? 
                GestureDetector(
                  onTap: (){
                     showModalBottomSheet(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return StoryViewers(
                                           storyId: widget.storiesList[currentStoryIndex]["_id"]);
                                    },
                                  );
                  },
                  child: const Icon(Icons.remove_red_eye) ,
                )
                : const SizedBox(), // Si no es mi historia, mostrar un SizedBox()
          ),
        ],
      ),
    );
  }
}
