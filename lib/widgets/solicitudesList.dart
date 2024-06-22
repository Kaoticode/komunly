import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:komunly/constants/constants.dart';
import 'package:komunly/pages/user/login_page.dart';
import 'package:komunly/utils/widgets.dart';
import 'package:komunly/widgets/snackbars.dart';
import 'package:shared_preferences/shared_preferences.dart';

class solicitudesList extends StatefulWidget {
  final String direction;
  const solicitudesList({super.key, required this.direction});

  @override
  State<solicitudesList> createState() => _solicitudesListState();
}

class _solicitudesListState extends State<solicitudesList> {
  late String myUserId;
  late String userDirection;
  final scrollController = ScrollController();
  List<dynamic> solicitudesData = [];
  int page = 1;
  int limit = 10;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    scrollController.addListener(_scrollListener);
    getMyUserId();
    fetchSolicitudes();
    userDirection = (widget.direction == "pending") ? "follower" : "following";
  }

  Future<void> fetchSolicitudes() async {
    if (isLoading) return;
    setState(() {
      isLoading = true;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('access_token');
    String apiUrl =
        "$API_URL/follows/request/${widget.direction}?page=$page&limit=$limit";

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
          solicitudesData.addAll(newData);
          isLoading = false;
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

  Future<void> rechazarSolicitud(solicitudId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('access_token');
    String apiUrl = "$API_URL/follows/request/decline/$solicitudId";

    try {
      var response = await http.delete(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          solicitudesData
              .removeWhere((element) => element['_id'] == solicitudId);
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

  Future<void> aceptarSolicitud(followerId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('access_token');
    String apiUrl = "$API_URL/follows/request/accept/$followerId";

    try {
      var response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 201) {
        setState(() {
          solicitudesData.removeWhere(
              (element) => element["follower"]['_id'] == followerId);
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

  Future<void> cancelarSolicitud(followerId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('access_token');
    String apiUrl = "$API_URL/follows/request/accept/$followerId";

    try {
      var response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 201) {
        setState(() {
          solicitudesData.removeWhere(
              (element) => element["follower"]['_id'] == followerId);
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
        fetchSolicitudes();
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

  void _scrollListener() {
    if (!isLoading &&
        scrollController.position.pixels ==
            scrollController.position.maxScrollExtent) {
      setState(() {
        isLoading = true;
      });
      page++;
      fetchSolicitudes();
      print("CARGANDO");
    }
  }

  Future<void> getMyUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    myUserId = prefs.getString('user_id')!;
  }

  Widget _buildUserCard(dynamic solicitudesData) {
    return Card(
      color: Colors.grey[900],
      shape: const RoundedRectangleBorder(),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundImage: NetworkImage(
                  "$PROFILE_IMG_URL/${solicitudesData[userDirection]["profilePicture"] ?? "$DEFAULT_IMAGE"}"),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Text(
                    solicitudesData[userDirection]["username"],
                    style: const TextStyle(fontSize: 14, color: Colors.white),
                  ),
                  Text(
                    solicitudesData[userDirection]["username"],
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (widget.direction == "pending") ...[
                  GestureDetector(
                    onTap: () {
                      rechazarSolicitud(solicitudesData["_id"]);
                    },
                    child: const Icon(
                      Icons.close,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  GestureDetector(
                    onTap: () {
                      aceptarSolicitud(solicitudesData["follower"]["_id"]);
                    },
                    child: const Icon(
                      Icons.check,
                      color: Colors.green,
                    ),
                  ),
                ] else ...[
                  GestureDetector(
                      onTap: () {
                        rechazarSolicitud(solicitudesData["_id"]);
                      },
                      child: const Text(
                        "Cancelar solicitud",
                        style: TextStyle(color: Colors.red),
                      )),
                ]
              ],
            )
          ],
        ),
      ),
    );
  }

 


  checkDirection() {
    if (widget.direction == "sent") {
      return "enviadas";
    } else {
      return "recibidas";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Text(
            'Solicitudes de seguimiento ${checkDirection()}',
            style: const TextStyle(fontSize: 20, color: Colors.white),
          ),
          const SizedBox(height: 5),
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              itemCount: solicitudesData.isEmpty
                  ? 1
                  : solicitudesData.length + (isLoading ? 1 : 0),
              itemBuilder: (BuildContext context, int index) {
                if (solicitudesData.isEmpty) {
                  if (isLoading) {
                    return buildLoaderSmallItem();
                  } else {
                    return buildListVacia();
                  }
                } else if (index < solicitudesData.length) {
                  return _buildUserCard(solicitudesData[index]);
                } else if (isLoading) {
                  return buildLoaderSmallItem();
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}
