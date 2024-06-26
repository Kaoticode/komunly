import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:komunly/constants/constants.dart';
import 'package:komunly/functions/functions.dart';
import 'package:komunly/models/user.model.dart';
import 'package:komunly/pages/social/post_page.dart';
import 'package:komunly/repository/social.repository.dart';
import 'package:komunly/utils/widgets.dart';
import 'package:komunly/widgets/bottom_modal.dart';
import 'package:komunly/widgets/snackbars.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatPage extends StatefulWidget {
  final String userId;
  final String profilePicture;
  final String username;
  const ChatPage(
      {super.key,
      required this.userId,
      required this.username,
      required this.profilePicture});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final scrollController = ScrollController();
  List<dynamic> messages = [];
  bool isLoading = false;
  int page = 1;
  int limit = 10;

  @override
  void initState() {
    super.initState();
    scrollController.addListener(_scrollListener);
    fetchMensajes();
    scrollController.animateTo(
      0.0,
      curve: Curves.easeOut,
      duration: const Duration(milliseconds: 300),
    );
    
  }

  Future<void> fetchMensajes() async {
    if (isLoading) return;
    setState(() {
      isLoading = true;
    });
    try {
      var response = await getMessagesChatEndpoint(context, 'messages/chat/${widget.userId}', page, limit);
      var jsonResponse = json.decode(response.body);
      if (response.statusCode == 200) {
        List<dynamic> newMessages = jsonResponse['data'];
        setState(() {
          messages.addAll(newMessages);
        });

      } else {
        showSnackMessage(context,
            "Error al obtener los mensajes: ${response.statusCode}", "ERROR");
      }
    } catch (e) {
      showSnackMessage(context, "Error de conexión: $e", "ERROR");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> sendMessage(body) async {
    try {
      var response = await sendMessageChat(context, {
            "receiverId": widget.userId,
            "type": "TEXT",
            "body": body,
          });
      if (response.statusCode == 201) {
        fetchMensajes();
      }  else {
        var responseData = json.decode(response.body);
        showSnackMessage(context, responseData['message'], "ERROR");
      }
    } catch (e) {
      showSnackMessage(context, "Error de conexión: $e", "ERROR");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> deleteMessage(messageId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('access_token');
    String apiUrl = "$API_URL/messages/$messageId";

    try {
      var response = await http.delete(Uri.parse(apiUrl), headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      });

      if (response.statusCode == 200) {
        print("Borrado con exito");
        fetchMensajes();
      }  else {
        var responseData = json.decode(response.body);
        showSnackMessage(context, responseData['message'], "ERROR");
      }
    } catch (e) {
      showSnackMessage(context, "Error de conexión: $e", "ERROR");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  final chatOptions = [
    {
      "title": "Recargar chat",
      "icon": Icons.refresh,
      "onPressed": (context) {}
    },
    {
      "title": "Enviar Mensaje",
      "icon": Icons.near_me,
      "onPressed": (context) {}
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        elevation: 1,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black, size: 24),
        leadingWidth: 24,
        title: Row(
          children: [
            Container(
              width: 35.0,
              height: 35.0,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image:
                      NetworkImage("$PROFILE_IMG_URL/" + widget.profilePicture),
                  fit: BoxFit.cover,
                ),
              ),
            ),

            const SizedBox(width: 8), // Espacio entre la imagen y el texto
            Text(
              widget.username,
              style: TextStyle(color: Colors.black, fontSize: 24),
            ),
          ],
        ),
        actions: [
          GestureDetector(
            onTap: () {
              showModalBottomSheet(
                context: context,
                builder: (BuildContext context) {
                  return CustomBottomSheet(options: chatOptions);
                },
              );
            },
            child: const Icon(Icons.more_vert),
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              itemCount:
                  messages.isEmpty ? 1 : messages.length + (isLoading ? 1 : 0),
              itemBuilder: (BuildContext context, int index) {
                if (messages.isEmpty) {
                  if (isLoading) {
                    return buildLoaderMessage();
                  } else {
                    return buildListVacia();
                  }
                } else if (index < messages.length) {
                  return Container(
                    margin: const EdgeInsets.symmetric(
                        vertical: 10.0, horizontal: 10.0),
                    child: Row(
                      mainAxisAlignment:
                          messages[index]["sender"]["_id"] == currentUser.value.id
                              ? MainAxisAlignment.end
                              : MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment:
                              messages[index]["sender"]["_id"] == currentUser.value.id
                                  ? CrossAxisAlignment.end
                                  : CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: () {
                                messages[index]["type"] == "POST"
                                    ? Navigator.of(context)
                                        .push(MaterialPageRoute(
                                            builder: (_) => PostPage(
                                                  postId: messages[index]
                                                      ["body"],
                                                )))
                                    : "";
                              },
                              onLongPress: () {
                                messages[index]["sender"]["_id"] == currentUser.value.id
                                    ? deleteMessage(messages[index]["_id"])
                                    : print("No borrar");
                              },
                              child: Container(
                                padding: const EdgeInsets.all(10.0),
                                decoration: BoxDecoration(
                                  color: messages[index]["sender"]["_id"] ==
                                          currentUser.value.id
                                      ? Colors.blue
                                      : Colors.grey,
                                  borderRadius: messages[index]["sender"]
                                              ["_id"] ==
                                          currentUser.value.id
                                      ? const BorderRadius.only(
                                          topLeft: Radius.circular(15.0),
                                          bottomLeft: Radius.circular(15.0),
                                          topRight: Radius.circular(15.0),
                                        )
                                      : const BorderRadius.only(
                                          topRight: Radius.circular(15.0),
                                          bottomRight: Radius.circular(15.0),
                                          topLeft: Radius.circular(15.0),
                                        ),
                                ),
                                child: Text(
                                  checkMessageText(messages[index]["type"],
                                      messages[index]["body"]),
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                            const SizedBox(height: 5.0),
                            Text(
                              formatRelativeTime(messages[index]["createdAt"]),
                              style: const TextStyle(
                                  fontSize: 12.0, color: Colors.grey),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                } else if (isLoading) {
                  return buildLoaderMessage();
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: "Escribe un mensaje",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25.0),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 14.0),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    sendMessage(_messageController.text);
                    _messageController.clear();
                  },
                  icon: const Icon(Icons.send),
                  color: Colors.blue,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _scrollListener() {
    if (!isLoading &&
        scrollController.position.pixels ==
            scrollController.position.maxScrollExtent) {
      page++;
      fetchMensajes();
    }
  }
}

String checkMessageText(type, texto) {
  if (type == "TEXT") {
    return texto;
  }
  if (type == "POST") {
    return "Pulsa para ver la publicación";
  }
  if (type == "STORY") {
    return "Has respondido a tu historia: $texto";
  }
  return "Mensaje desconocido";
}
