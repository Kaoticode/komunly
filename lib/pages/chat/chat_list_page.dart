import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:komunly/constants/constants.dart';
import 'package:komunly/models/user.model.dart';
import 'package:komunly/repository/social.repository.dart';
import 'package:komunly/theme/colors.dart';
import 'package:komunly/widgets/appBar.dart';
import 'package:komunly/pages/chat/chat_page.dart';
import 'package:komunly/widgets/snackbars.dart';

class ChatList extends StatefulWidget {
  const ChatList({Key? key}) : super(key: key);

  @override
  _ChatListState createState() => _ChatListState();
}

class _ChatListState extends State<ChatList> {
  final scrollController = ScrollController();
  List<dynamic> chatList = [];
  bool isLoading = false;
  @override
  void initState() {
    super.initState();
    fetchMessageList();
  }

  void fetchMessageList() async {
    try {
      var response = await getMessagesChat(context);
      var jsonResponse = json.decode(response.body);
      if (response.statusCode == 201) {
        setState(() {
          chatList = jsonResponse['data'];
        });
      }  else {
        showSnackMessage(context, jsonResponse['message'], "ERROR");
      }
    } catch (e) {
      showSnackMessage(context, "Error de conexión: $e", "ERROR");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: black,
      appBar: const CustomAppBar(
        title: 'Mensajes',
      ),
      body: getBody(),
    );
  }

  Widget getBody() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 10,
            ),
            ListView.builder(
                shrinkWrap: true,
                itemCount: chatList.length,
                itemBuilder: (context, index) {
                  var lastMessageList = chatList[index]['lastMessage'];
                  var lastMessage =
                      lastMessageList.isNotEmpty ? lastMessageList.first : null;
                  var participants = chatList[index]['participants']
                      .where((participant) => participant['_id'] != currentUser.value.id)
                      .toList();

                  if (participants.isNotEmpty && lastMessage != null) {
                    var participant = participants.first;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (_) => ChatPage(
                                  profilePicture: participant["profilePicture"] ?? DEFAULT_IMAGE,
                                  userId: participant['_id'],
                                  username: participant['username'])));
                        },
                        child: Container(
                          height: 80,
                          width: double.infinity,
                          decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                    color: white.withOpacity(0.15),
                                    spreadRadius: 2,
                                    blurRadius: 15,
                                    offset: const Offset(0, 1))
                              ],
                              color: white.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(33)),
                          child: Row(
                            children: [
                              const SizedBox(
                                width: 20,
                              ),
                              Container(
                                width: 55,
                                height: 55,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(28),
                                    border: Border.all(color: black)),
                                child: Center(
                                  child: Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(30),
                                        image: DecorationImage(
                                            image: NetworkImage(
                                              participant['profilePicture'] !=
                                                      null
                                                  ? "$PROFILE_IMG_URL/" +
                                                      participant[
                                                          'profilePicture']
                                                  : "$PROFILE_IMG_URL/" +
                                                      DEFAULT_IMAGE,
                                            ),
                                            fit: BoxFit.cover)),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Flexible(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      participant['username']!,
                                      style: const TextStyle(
                                          fontSize: 15,
                                          color: black,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(lastMessage['body'],
                                        style: TextStyle(
                                            fontSize: 14,
                                            color: black.withOpacity(0.5)))
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                })
          ],
        ),
      ),
    );
  }
}
