import 'dart:convert';
import 'package:komunly/constants/constants.dart';
import 'package:komunly/pages/user/login_page.dart';
import 'package:komunly/pages/profile/profile_page.dart';
import 'package:komunly/utils/widgets.dart';
import 'package:komunly/widgets/snackbars.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UsersFollowersList extends StatefulWidget {
  final String userId;
  const UsersFollowersList({
    Key? key,
    required this.userId,
  }) : super(key: key);

  @override
  State<UsersFollowersList> createState() => _UsersState();
}

class _UsersState extends State<UsersFollowersList> {
  final scrollController = ScrollController();
  List<dynamic> usersData = [];
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
    String apiUrl =
        "$API_URL/follows/follower/${widget.userId}?page=$page&limit=$limit${checkSearch()}";

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
            // Si search está vacío, no limpiar la lista
            usersData.addAll(newData);
          } else {
            // Si search no está vacío, limpiar la lista
            usersData.clear();
            usersData.addAll(newData);
          }
        });
      } else if (response.statusCode == 401 || response.statusCode == 400) {
        refreshTokens();
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
        fetchUsers();
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
    return Column(
      children: [

        Padding(
          padding:
              const EdgeInsets.only(left: 8.0, top: 16, right: 8.0, bottom: 8),
          child: TextField(
            cursorColor: Colors.grey[600],
            style: TextStyle(
              color: Colors.white,
            ),
            onChanged: (texto) {
              search = texto;
            },
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              labelText: "Buscar Usuarios",
              labelStyle: TextStyle(
                color: Colors.white,
              ),
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
                            return _buildUserCard(usersData[index]);
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

  Widget _buildUserCard(dynamic userData) {
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
                    "$PROFILE_IMG_URL/${userData["follower"]["profilePicture"] ?? "$DEFAULT_IMAGE"}"),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Text(
                      userData["follower"]["username"],
                      style: const TextStyle(fontSize: 14, color: Colors.white),
                    ),
                    Text(
                      userData["follower"]["username"],
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ProfilePage(
                        id: userData["follower"]["_id"],
                        profilePicture: userData["follower"]
                                ["profilePicture"] ??
                            DEFAULT_IMAGE,
                        username: userData["follower"]["username"] ?? "Usuario",
                        description: userData["description"] ??
                            "Biografía no disponible",
                        bankNumber:
                            userData["bankNumber"] ?? "**** **** **** ****",
                        createdAt:
                            userData["createdAt"] ?? "Fecha no disponible",
                        posts: userData["postsCount"] ?? 0,
                        seguidores: userData["followersCount"] ?? 0,
                        seguidos: userData["followingsCount"] ?? 0,
                        isPublic: userData["isPublic"] ?? false,
                      ),
                    ),
                  );
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  decoration: const BoxDecoration(
                    color: Color.fromARGB(255, 225, 255, 0),
                  ),
                  child: const Text(
                    "Ver",
                    style: TextStyle(
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
