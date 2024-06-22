import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:komunly/constants/constants.dart';
import 'package:komunly/repository/api.repository.dart';
import 'package:komunly/utils/widgets.dart';
import 'package:komunly/widgets/snackbars.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StoryViewers extends StatefulWidget {
  final String storyId;

  const StoryViewers({Key? key, required this.storyId}) : super(key: key);

  @override
  State<StoryViewers> createState() => _StoryViewersState();
}

class _StoryViewersState extends State<StoryViewers> {
  late String myUserId;
  final scrollController = ScrollController();
  List<dynamic> storyViewers = [];
  int page = 1;
  int limit = 10;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    scrollController.addListener(_scrollListener);
    fetchStoryViewers();
  }

  Future<void> fetchStoryViewers() async {
    if (isLoading) return;
    setState(() {
      isLoading = true;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('access_token');
    String apiUrl =
        "$API_URL/stories/${widget.storyId}/viewers?page=$page&limit=$limit";

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
          storyViewers.addAll(newData);
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
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[800],
      ),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              "Espectadores de mi historia",
              style: TextStyle(color: Colors.white, fontSize: 22),
            ),
          ),
          Expanded(
            child:  ListView.builder(
              controller: scrollController,
              itemCount: storyViewers.isEmpty
                  ? 1
                  : storyViewers.length + (isLoading ? 1 : 0),
              itemBuilder: (BuildContext context, int index) {
                if (storyViewers.isEmpty) {
                  if (isLoading) {
                    return buildLoaderSmallItem();
                  } else {
                    return buildListVacia();
                  }
                } else if (index < storyViewers.length) {
                  return viewerCard(storyViewers[index]);
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

  Widget viewerCard(dynamic storyViewers) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: GestureDetector(
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
                        "$PROFILE_IMG_URL/${storyViewers["user"]["profilePicture"] ?? DEFAULT_IMAGE}")),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        storyViewers["user"]["username"],
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        storyViewers["user"]["username"],
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
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

  void _scrollListener() {
    if (!isLoading &&
        scrollController.position.pixels ==
            scrollController.position.maxScrollExtent) {
      page++;
      fetchStoryViewers();
    }
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }
}
