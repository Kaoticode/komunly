import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:komunly/constants/constants.dart';
import 'package:komunly/models/user.model.dart';
import 'package:komunly/repository/social.repository.dart';
import 'package:komunly/widgets/snackbars.dart';
import 'package:komunly/widgets/storyViewers.dart';

class UserStoryPage extends StatefulWidget {
  final List<dynamic> storiesList;
  const UserStoryPage({Key? key, required this.storiesList}) : super(key: key);

  @override
  State<UserStoryPage> createState() => _UserStoryPageState();
}

class _UserStoryPageState extends State<UserStoryPage> {
  late bool isMyStory = false; // Inicializar como false

  @override
  void initState() {
    super.initState();
    checkStoryOwner();
  }


  void checkStoryOwner() {
    String authorId = widget.storiesList[currentStoryIndex]["author"]["_id"];
    setState(() {
      // Actualizar isMyStory después de obtener myUserId
      isMyStory = (currentUser.value.id == authorId);
    });
    // Llamar a print después de actualizar isMyStory
    printCurrentStoryId();
  }

  void printCurrentStoryId() {
    storieViewed(widget.storiesList[currentStoryIndex]["_id"]);
  }
  Future<void> storieViewed(storieId) async {
    try {
      var response = await userStorieViewed(context, 'stories/$storieId/viewers', {
            "userId": currentUser.value.id,
          });
      if (response.statusCode == 201) {
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
