import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:komunly/constants/constants.dart';
import 'package:komunly/repository/user.repository.dart';
import 'package:komunly/widgets/notificationItem.dart';
import 'package:komunly/widgets/snackbars.dart';
import 'package:shimmer/shimmer.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({Key? key}) : super(key: key);

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final scrollController = ScrollController();
  List<dynamic> notifications = [];
  bool isLoading = false;
  int page = 1;
  int limit = 15;

  @override
  void initState() {
    super.initState();
    scrollController.addListener(_scrollListener);
    fetchNotificaciones();
  }

  Future<void> fetchNotificaciones() async {
    if (isLoading) return;
    setState(() {
      isLoading = true;
    });

    
    try {
    var response = await getUserNotifications(context, 'notifications?page=$page&limit=$limit');
      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        List<dynamic> newData = jsonResponse['data'];

        setState(() {
          notifications.addAll(newData);
        });
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
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.black,
        title: const Text(
          'Notificaciones',
          style: TextStyle(color: Colors.white, fontSize: 22),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: Stack(
          children: [
            ListView.builder(
              controller: scrollController,
              itemCount: notifications.length + (isLoading ? 1 : 0),
              itemBuilder: (BuildContext context, int index) {
                if (index < notifications.length) {
                  return NotificationItem(
                    profilePicture: transference(notifications[index]['type'])
                        ? "$PROFILE_IMG_URL/$DEFAULT_IMAGE"
                        : "$PROFILE_IMG_URL/${notifications[index]['notify_by']['profilePicture'] ?? DEFAULT_IMAGE}",
                    username: transference(notifications[index]['type'])
                        ? "Komunly"
                        : notifications[index]['notify_by']['username']!,
                    description: description(notifications[index]['type'],
                        notifications[index]['amount']),
                    action: notifications[index]['type'],
                    user_id: (notifications[index]['type'] == "DEPOSIT" ||
                            notifications[index]['type'] == "DEPOSIT" ||
                            notifications[index]['type'] == "DEPOSIT")
                        ? null
                        : notifications[index]['notify_by']['_id'],
                    post_id: (notifications[index]['type'] == "COMMENT" ||
                            notifications[index]['type'] == "LIKE" ||
                            notifications[index]['type'] == "REPOST")
                        ? notifications[index]['post']['_id']
                        : null,
                    premium:
                        (notifications[index]['notify_by']?['premium'] ?? false),
                    verificado: (notifications[index]['notify_by']
                            ?['verificado'] ??
                        false),
                  );
                } else {
                  return _buildLoader();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _scrollListener() {
    if (!isLoading &&
        scrollController.position.pixels ==
            scrollController.position.maxScrollExtent) {
      page++;
      fetchNotificaciones();
    }
  }

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

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }
}

bool transference(type) {
  if (type == "DEPOSIT") {
    return true;
  }
  return false;
}

String description(String type, int? amount) {
  switch (type) {
    case "LIKE":
      return "te ha dado like";
    case "COMMENT":
      return "te ha dejado un comentario";
    case "TRANFERENCE":
      return "te ha enviado $amount komuns";
    case "CHARGE":
      return "Has gastado $amount komuns";
    case "DEPOSIT":
      return "Has ganado $amount komuns";
    case "REPOST":
      return "ha reposteado tu publicación";
      case "FOLLOW":
      return "ha comenzado a seguirte";
    case "REQUEST":
      return "ha solicitado seguirte";
    default:
      return "DESCRIPCIÓN DESCONOCIDA";
  }
}
