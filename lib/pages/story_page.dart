import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:komunly/constants/constants.dart';
import 'package:komunly/models/user.model.dart';
import 'package:komunly/repository/social.repository.dart';
import 'package:komunly/widgets/snackbars.dart';

class StoryPage extends StatefulWidget {
  final List<dynamic> storiesList;
  final int initialIndex;

  const StoryPage({
    Key? key,
    required this.storiesList,
    required this.initialIndex,
  }) : super(key: key);

  @override
  State<StoryPage> createState() => _StoryPageState();
}

class _StoryPageState extends State<StoryPage> {
  final TextEditingController _answerController = TextEditingController();
  late int currentAuthorIndex;
  late int currentStoryIndex;
  late bool isMyStory = false;

  @override
  void initState() {
    super.initState();
    currentAuthorIndex = widget.initialIndex;
    currentStoryIndex = 0;
    checkStoryOwner();// Llamamos a la función getMyUserId sin await
  }

  

  void checkStoryOwner() {
    if (currentUser.value.id == widget.storiesList[currentStoryIndex]["author"]["_id"]) {
      isMyStory = true;
    } else {
      isMyStory = false;
    }
    // Después de asignar el valor de isMyStory, podemos imprimirlo
    printCurrentStoryId();
  }

  void printCurrentStoryId() {
    storieViewed(widget.storiesList[currentAuthorIndex]["stories"]
        [currentStoryIndex]["_id"]);
    print(
        "El id de la historia actual ${widget.storiesList[currentAuthorIndex]["stories"][currentStoryIndex]["_id"]}");
    print(
        "El id del autor de la historia actual ${widget.storiesList[currentStoryIndex]["author"]["_id"]}");
    print("es mi historia? $isMyStory");
  }

  void goToNextStory() {
    setState(() {
      if (!isLastStory()) {
        currentStoryIndex++;
      } else if (!isLastAuthor()) {
        currentAuthorIndex++;
        currentStoryIndex = 0;
      } else {
        Navigator.of(context).pop();
      }
    });

    printCurrentStoryId();
  }

  void goToPrevStory() {
    setState(() {
      if (!isFirstStory()) {
        currentStoryIndex--;
      } else if (!isFirstAuthor()) {
        currentAuthorIndex--;
        currentStoryIndex = lastStoryIndex();
      } else {
        Navigator.of(context).pop();
      }
    });

    printCurrentStoryId();
  }

  bool isLastStory() {
    return currentStoryIndex >= storiesForCurrentAuthor().length - 1;
  }

  bool isLastAuthor() {
    return currentAuthorIndex >= widget.storiesList.length - 1;
  }

  bool isFirstStory() {
    return currentStoryIndex <= 0;
  }

  bool isFirstAuthor() {
    return currentAuthorIndex <= 0;
  }

  List<dynamic> storiesForCurrentAuthor() {
    return widget.storiesList[currentAuthorIndex]["stories"];
  }

  int lastStoryIndex() {
    return storiesForCurrentAuthor().length - 1;
  }

  Map<String, dynamic> get currentStory {
    return storiesForCurrentAuthor()[currentStoryIndex];
  }

  Future<void> storieViewed(storieId) async {
    try {
      var response = await userStorieViewed(context, 'stories/$storieId/viewers', {
            "userId": currentUser.value.id,
      });
      if (response.statusCode == 201) {
        print("vista");
      } else {
        var responseData = json.decode(response.body);
        showSnackMessage(context, responseData['message'], "ERROR");
      }
    } catch (e) {
      showSnackMessage(context, "Error de conexión: $e", "ERROR");
    }
  }

  Future<void> responderStory() async {
    try {
      var response = await resStorie(context, {
            "receiverId": widget.storiesList[currentStoryIndex]["author"]
                ["_id"],
            "body": _answerController.text,
            "type": "STORY",
          });
      if (response.statusCode == 201) {
        _answerController.clear();
         showSnackMessage(context, "Historia respondida con éxito", "SUCCESS");
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
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.network(
              '$STORY_IMG_URL/${currentStory["fileName"]}',
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
              widget.storiesList[currentAuthorIndex]["author"]["username"],
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    offset: const Offset(0, 1),
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
              icon: const Icon(Icons.close, color: Colors.red),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),
          Positioned(
            bottom: 10,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30.0),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 10,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _answerController,
                        decoration: const InputDecoration(
                          hintText: "Enviar mensaje",
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 15),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.near_me),
                      color: Colors.white,
                      onPressed: () {
                        responderStory();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
