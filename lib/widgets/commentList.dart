import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:komunly/constants/constants.dart';
import 'package:komunly/pages/user/login_page.dart';
import 'package:komunly/utils/widgets.dart';
import 'package:komunly/widgets/snackbars.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CommentsList extends StatefulWidget {
  final String postId;

  const CommentsList({Key? key, required this.postId}) : super(key: key);

  @override
  State<CommentsList> createState() => _CommentsListState();
}

class _CommentsListState extends State<CommentsList> {
  final scrollController = ScrollController();
  TextEditingController _comentarioController = TextEditingController();
  List<dynamic> comments = [];
  int page = 1;
  int limit = 10;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    scrollController.addListener(_scrollListener);
    fetchComments();
  }

  Future<void> fetchComments() async {
    if (isLoading) return;
    setState(() {
      isLoading = true;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('access_token');
    String apiUrl =
        "$API_URL/comments/getComments/${widget.postId}?page=$page&limit=$limit";
    print(apiUrl);

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
          comments.addAll(newData);
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

  Future<void> postComment(String comentario) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('access_token');
    String? userId = prefs.getString('user_id');
    String apiUrl = "$API_URL/comments";
    print(apiUrl);

    try {
      var response = await http.post(Uri.parse(apiUrl),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $accessToken',
          },
          body: jsonEncode({
            'post_commented': widget.postId,
            'authorId': userId,
            'commentText': comentario
          }));

      if (response.statusCode == 201) {
        Navigator.pop(context);
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

  Future<void> deleteComment(String id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('access_token');
    String apiUrl = "$API_URL/comments/$id";
    try {
      var response = await http.delete(Uri.parse(apiUrl), headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      });

      if (response.statusCode == 201) {
        showSnackMessage(context, "Comentario eliminado con éxito", "SUCCESS");
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
        fetchComments();
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

  Widget commentCard(dynamic comments) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: GestureDetector(
        onLongPress: () async {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          String? userId = prefs.getString('user_id');
          if (userId == comments["comment_by"]["_id"]) {
            deleteComment(comments["_id"]);
          } else {
            print("No puedes Borrar comentario");
          }
        },
        onDoubleTap: () {
          print("Like comment");
        },
        child: Card(
          color: Colors.grey[900],
          shape: const RoundedRectangleBorder(),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: NetworkImage(
                    "$PROFILE_IMG_URL/${comments["comment_by"]["profilePicture"] ?? "$DEFAULT_IMAGE"}",
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        comments["comment_by"]["username"],
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        comments["commentText"],
                        style: const TextStyle(
                          fontSize: 14,
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[800],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _comentarioController,
                    decoration: const InputDecoration(
                      hintText: 'Escribe tu comentario...',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.near_me,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    String comentario = _comentarioController.text;
                    postComment(comentario);
                    _comentarioController.clear();
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              itemCount:
                  comments.isEmpty ? 1 : comments.length + (isLoading ? 1 : 0),
              itemBuilder: (BuildContext context, int index) {
                if (comments.isEmpty) {
                  if (isLoading) {
                    return buildLoaderSmallItem();
                  } else {
                    return buildListVacia();
                  }
                } else if (index < comments.length) {
                  return commentCard(comments[index]);
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

  void _scrollListener() {
    if (!isLoading &&
        scrollController.position.pixels ==
            scrollController.position.maxScrollExtent) {
      page++;
      fetchComments();
    }
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }
}
