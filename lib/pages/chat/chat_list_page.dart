import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:komunly/constants/constants.dart';
import 'package:komunly/pages/user/login_page.dart';
import 'package:komunly/theme/colors.dart';
import 'package:komunly/widgets/appBar.dart';
import 'package:komunly/pages/chat/chat_page.dart';
import 'package:komunly/widgets/snackbars.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatList extends StatefulWidget {
  const ChatList({Key? key}) : super(key: key);

  @override
  _ChatListState createState() => _ChatListState();
}

class _ChatListState extends State<ChatList> {
  final scrollController = ScrollController();
  List<dynamic> chatList = [];
  late String? myUserId;
  bool isLoading = false;
  int page = 1;
  int limit = 15;

  @override
  void initState() {
    super.initState();
    fetchUserId();
  }

  void fetchMessageList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('access_token');
    String apiUrl = "$API_URL/messages/chat";

    try {
      var response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          var jsonResponse = json.decode(response.body);
          chatList = jsonResponse['data'];
        });
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
            fetchMessageList();
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

  void fetchUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    myUserId = prefs.getString('user_id');
    fetchMessageList();
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
                      .where((participant) => participant['_id'] != myUserId)
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
