import 'dart:convert';
import 'package:komunly/constants/constants.dart';
import 'package:komunly/repository/api.repository.dart';
import 'package:komunly/utils/widgets.dart';
import 'package:komunly/widgets/snackbars.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UsersListSend extends StatefulWidget {
  final String postId;
  const UsersListSend({super.key, required this.postId});

  @override
  State<UsersListSend> createState() => _UsersListSendState();
}

class _UsersListSendState extends State<UsersListSend> {
  final scrollController = ScrollController();
  List<dynamic> usersData = [];
  List<String> buttonText = [];
  int page = 1;
  int limit = 15;
  String search = "";
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    scrollController.addListener(_scrollListener);
    fetchUsers();
  }

  String checkSearch() {
    if (search.isNotEmpty) {
      return "&search=$search";
    } else {
      return "";
    }
  }

  Future<void> fetchUsers() async {
    if (isLoading) return;
    setState(() {
      isLoading = true;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('access_token');
    String apiUrl = "$API_URL/users?page=$page&limit=$limit${checkSearch()}";

    try {
      var response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        List<dynamic> newData = jsonResponse['data'];

        setState(() {
          if (search.isEmpty) {
            usersData.addAll(newData);
            buttonText.addAll(List<String>.filled(newData.length, "Compartir"));
          } else {
            usersData.clear();
            buttonText.clear();
            usersData.addAll(newData);
            buttonText.addAll(List<String>.filled(newData.length, "Compartir"));
          }
        });
      } else if (response.statusCode == 401 || response.statusCode == 400) {
        refreshTokens(context);
      } else {
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

  Future<void> enviarPublicacion(id, int index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('access_token');
    String apiUrl = "$API_URL/messages/";

    try {
      var response = await http.post(Uri.parse(apiUrl),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $accessToken',
          },
          body: jsonEncode({
            "receiverId": id,
            "type": "POST",
            "body": widget.postId,
          }));

      if (response.statusCode == 201) {
        setState(() {
          buttonText[index] = "Compartido";
        });
      } else if (response.statusCode == 401 || response.statusCode == 400) {
        refreshTokens(context);
      } else {
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


  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding:
              const EdgeInsets.only(left: 8.0, top: 16, right: 8.0, bottom: 8),
          child: TextField(
            cursorColor: Colors.grey[600],
            style: const TextStyle(color: Colors.white),
            onChanged: (texto) {
              search = texto;
            },
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              labelText: "Buscar Usuarios",
              labelStyle: const TextStyle(color: Colors.white),
              prefixIcon: Icon(
                Icons.person,
                color: Colors.grey[600],
              ),
              suffixIcon: InkWell(
                onTap: () {
                  fetchUsers();
                },
                child: const Icon(
                  Icons.search,
                  color: Colors.white,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 16.0,
                horizontal: 16.0,
              ),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
              controller: scrollController,
              itemCount: usersData.isEmpty
                  ? 1
                  : usersData.length + (isLoading ? 1 : 0),
              itemBuilder: (BuildContext context, int index) {
                if (usersData.isEmpty) {
                  if (isLoading) {
                    return buildLoaderSmallItem();
                  } else {
                    return buildListVacia();
                  }
                } else if (index < usersData.length) {
                            return _buildUserCard(usersData[index], index);
                } else if (isLoading) {
                  return buildLoaderSmallItem();
                }
                return const SizedBox.shrink();
              },
            ),
        ),
      ],
    );
  }

  Widget _buildUserCard(dynamic userData, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Card(
        color: Colors.grey[900],
        shape: const RoundedRectangleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage(
                    "$PROFILE_IMG_URL/${userData["profilePicture"] ?? "$DEFAULT_IMAGE"}"),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Text(
                      userData["username"],
                      style: const TextStyle(fontSize: 14, color: Colors.white),
                    ),
                    Text(
                      userData["username"],
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: () {
                  enviarPublicacion(userData["_id"], index);
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  decoration: const BoxDecoration(
                    color: Color.fromARGB(255, 225, 255, 0),
                  ),
                  child: Text(
                    buttonText[index],
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ignore: unused_element
  Widget _buildLoader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Card(
        color: Colors.grey[900],
        shape: const RoundedRectangleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: const CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.white,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(
                        height: 16,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(
                        height: 12,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _scrollListener() {
    if (!isLoading &&
        scrollController.position.pixels ==
            scrollController.position.maxScrollExtent) {
      page++;
      fetchUsers();
    }
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }
}
