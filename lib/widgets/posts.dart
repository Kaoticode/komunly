import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:komunly/constants/constants.dart';
import 'package:komunly/functions/functions.dart';
import 'package:komunly/models/user.model.dart';
import 'package:komunly/repository/social.repository.dart';
import 'package:komunly/theme/colors.dart';
import 'package:komunly/utils/reusables.dart';
import 'package:komunly/utils/widgets.dart';
import 'package:komunly/widgets/commentList.dart';
import 'package:komunly/widgets/premiumUser.dart';
import 'package:komunly/widgets/snackbars.dart';
import 'package:komunly/widgets/user/usersListSend.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class PostsWidget extends StatefulWidget {
  final double postHeight;
  final String endpoint;
  const PostsWidget(
      {super.key, required this.postHeight, required this.endpoint});

  @override
  State<PostsWidget> createState() => _PostsWidgetState();
}

class _PostsWidgetState extends State<PostsWidget> {
  final scrollController = ScrollController();
  final List<dynamic> PostsList = [];
  bool isLoading = false;
  int page = 1;
  int limit = 15;

  @override
  void initState() {
    super.initState();
    scrollController.addListener(_scrollListener);
    fetchPosts();
  }
  Future<void> fetchPosts() async {
    if (isLoading) return;
    setState(() {
      isLoading = true;
    });
    String apiUrl = "${widget.endpoint}limit=$limit&page=$page";
    try {
      var response = await getPosts(context, apiUrl);
      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response!.body);
        List<dynamic> newData = jsonResponse!['data'] ?? [];

        setState(() {
          PostsList.addAll(newData);
        });
      } else {
        var responseData = json.decode(response.body);
        showSnackMessage(context, responseData!['message'] ?? '', "ERROR");
      }
    } catch (e) {
      showSnackMessage(context, "Error de conexión: $e", "ERROR");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }


  Future<void> postLike(int index, String postLiked, String userLiked) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('access_token');
    String apiUrl = "$API_URL/likes";

    try {
      setState(() {
        PostsList[index]["likesCount"] = PostsList[index]["likesCount"] + 1;
        PostsList[index]["isLiked"] = true;
      });

      var response = await http.post(Uri.parse(apiUrl),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $accessToken',
          },
          body: jsonEncode({"post_liked": postLiked, "user_liked": userLiked}));

      if (response.statusCode == 201) {
      } else if (response.statusCode == 401 || response.statusCode == 400) {
        fetchPosts();
        setState(() {
          PostsList[index]["likesCount"] = PostsList[index]["likesCount"] - 1;
          PostsList[index]["isLiked"] = false;
        });
      } else {
        var responseData = json.decode(response.body);
        showSnackMessage(context, responseData['message'], "ERROR");
        setState(() {
          PostsList[index]["likesCount"] = PostsList[index]["likesCount"] - 1;
          PostsList[index]["isLiked"] = false;
        });
      }
    } catch (e) {
      showSnackMessage(context, "Error de conexión: $e", "ERROR");
      setState(() {
        PostsList[index]["likesCount"] = PostsList[index]["likesCount"] - 1;
        PostsList[index]["isLiked"] = false;
      });
    }
  }

  Future<void> removeLike(int index, String postLiked) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('access_token');
    String apiUrl = "$API_URL/likes/$postLiked";
    try {
      setState(() {
        PostsList[index]["likesCount"] = PostsList[index]["likesCount"] - 1;
        PostsList[index]["isLiked"] = false;
      });
      var response = await http.delete(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );
      if (response.statusCode == 200) {
      } else if (response.statusCode == 401 || response.statusCode == 400) {
        fetchPosts();
        setState(() {
          PostsList[index]["likesCount"] = PostsList[index]["likesCount"] + 1;
          PostsList[index]["isLiked"] = true;
        });
      } else {
        var responseData = json.decode(response.body);
        showSnackMessage(context, responseData['message'], "ERROR");
        setState(() {
          PostsList[index]["likesCount"] = PostsList[index]["likesCount"] + 1;
          PostsList[index]["isLiked"] = true;
        });
      }
    } catch (e) {
      showSnackMessage(context, "Error de conexión: $e", "ERROR");
      setState(() {
        PostsList[index]["likesCount"] = PostsList[index]["likesCount"] + 1;
        PostsList[index]["isLiked"] = true;
      });
    }
  }

  postRepost(int index, String post_reposted, String user_reposted) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('access_token');
    String apiUrl = "$API_URL/reposts";

    try {
      setState(() {
        PostsList[index]["isReposted"] = true;
        PostsList[index]["repostsCount"] = PostsList[index]["repostsCount"] + 1;
      });
      var response = await http.post(Uri.parse(apiUrl),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $accessToken',
          },
          body: jsonEncode({
            "post_reposted": post_reposted,
            "user_reposted": user_reposted,
            "caption": "Caption del repost"
          }));

      if (response.statusCode == 201) {
      } else if (response.statusCode == 401 || response.statusCode == 400) {
        fetchPosts();
        setState(() {
          PostsList[index]["isReposted"] = false;
          PostsList[index]["repostsCount"] =
              PostsList[index]["repostsCount"] - 1;
        });
      } else {
        var responseData = json.decode(response.body);
        showSnackMessage(context, responseData['message'], "ERROR");
        setState(() {
          PostsList[index]["isReposted"] = false;
          PostsList[index]["repostsCount"] =
              PostsList[index]["repostsCount"] - 1;
        });
      }
    } catch (e) {
      showSnackMessage(context, "Error de conexión: $e", "ERROR");
      setState(() {
        PostsList[index]["isReposted"] = false;
        PostsList[index]["repostsCount"] = PostsList[index]["repostsCount"] - 1;
      });
    }
  }

  removeRepost(int index) {
    setState(() {
      PostsList[index]["isReposted"] = false;
      PostsList[index]["repostsCount"] = PostsList[index]["repostsCount"] - 1;
    });
  }

  postBookmark(int index, String postBookmarked) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('access_token');
    String apiUrl = "$API_URL/bookmarks";

    try {
      setState(() {
        PostsList[index]["isBookmarked"] = true;
      });
      var response = await http.post(Uri.parse(apiUrl),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $accessToken',
          },
          body: jsonEncode({
            "postBookmarked": postBookmarked,
          }));

      if (response.statusCode == 201) {
      } else if (response.statusCode == 401 || response.statusCode == 400) {
        fetchPosts();
        setState(() {
          PostsList[index]["isBookmarked"] = false;
        });
      } else {
        var responseData = json.decode(response.body);
        showSnackMessage(context, responseData['message'], "ERROR");
        setState(() {
          PostsList[index]["isBookmarked"] = false;
        });
      }
    } catch (e) {
      showSnackMessage(context, "Error de conexión: $e", "ERROR");
      setState(() {
        PostsList[index]["isBookmarked"] = false;
      });
    }
  }

  removeBookmark(int index, String postBookmarked) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('access_token');
    String apiUrl = "$API_URL/bookmarks/$postBookmarked";

    try {
      setState(() {
        PostsList[index]["isBookmarked"] = false;
      });
      var response = await http.delete(Uri.parse(apiUrl), headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      });

      if (response.statusCode == 200) {
      } else if (response.statusCode == 401 || response.statusCode == 400) {
        fetchPosts();
        setState(() {
          PostsList[index]["isBookmarked"] = true;
        });
      } else {
        var responseData = json.decode(response.body);
        showSnackMessage(context, responseData['message'], "ERROR");
        setState(() {
          PostsList[index]["isBookmarked"] = true;
        });
      }
    } catch (e) {
      showSnackMessage(context, "Error de conexión: $e", "ERROR");
      setState(() {
        PostsList[index]["isBookmarked"] = true;
      });
    }
  }

  eliminarPost(String postBookmarked) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('access_token');
    String apiUrl = "$API_URL/bookmarks/$postBookmarked";
    try {
      var response = await http.delete(Uri.parse(apiUrl), headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      });

      if (response.statusCode == 200) {
      } else if (response.statusCode == 401 || response.statusCode == 400) {
        fetchPosts();
      } else {
        var responseData = json.decode(response.body);
        showSnackMessage(context, responseData['message'], "ERROR");
      }
    } catch (e) {
      showSnackMessage(context, "Error de conexión: $e", "ERROR");
    }
  }

  reportarPost(String postId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('access_token');
    String apiUrl = "$API_URL/reports";
    try {
      var response = await http.post(Uri.parse(apiUrl),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $accessToken',
          },
          body: jsonEncode({"post_id": postId, "reason": "spam"}));

      if (response.statusCode == 201) {
        showSnackMessage(context, "Post reportado con éxito", "SUCCESS");
      } else if (response.statusCode == 401 || response.statusCode == 400) {
        fetchPosts();
      } else {
        var responseData = json.decode(response.body);
        showSnackMessage(context, responseData['message'], "ERROR");
      }
    } catch (e) {
      showSnackMessage(context, "Error de conexión: $e", "ERROR");
    }
  }

  void openRepostModal(bool isReposted, BuildContext context, int index,
      String post_reposted, String user_reposted) {
    showModalBottomSheet(
      isDismissible: true,
      isScrollControlled: true,
      context: context,
      backgroundColor: Colors.grey[700],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Container(
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(32),
                ),
                height: 40,
                width: 40,
                child: const Icon(
                  Icons.repeat,
                  color: Colors.white,
                ),
              ),
              title: Text(
                "Repostear publicación ${(isReposted ? "(ya reposteada)" : "")}",
                style: const TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                postRepost(index, post_reposted, user_reposted);
              },
            ),
            ListTile(
              leading: Container(
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(32),
                ),
                height: 40,
                width: 40,
                child: const Icon(
                  Icons.near_me,
                  color: Colors.white,
                ),
              ),
              title: const Text(
                "Compartir en mi historia (esto no funciona aun)",
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            SizedBox(
                height: 500,
                child: UsersListSend(
                  postId: post_reposted,
                )),
          ],
        );
      },
    );
  }

  void openPostModal(ownerId, postId) {
    showModalBottomSheet(
      isDismissible: true,
      isScrollControlled: true,
      context: context,
      backgroundColor: Colors.grey[700],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Container(
                decoration: const BoxDecoration(
                  color: Colors.black,
                  shape: BoxShape.circle,
                ),
                height: 40,
                width: 40,
                child: const Icon(
                  Icons.near_me,
                  color: Colors.white,
                ),
              ),
              title: Text(
                ownerId == currentUser.value.id ? "Eliminar post" : "Reportar",
                style: const TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                ownerId == currentUser.value.id
                    ? eliminarPost(postId)
                    : reportarPost(postId);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var postHeight = 400.00;
    return SizedBox(
      height: MediaQuery.of(context).size.height - widget.postHeight,
      child: ListView.builder(
        controller: scrollController,
        itemCount:
            PostsList.isEmpty ? 1 : PostsList.length + (isLoading ? 1 : 0),
        itemBuilder: (BuildContext context, int index) {
          if (PostsList.isEmpty) {
            if (isLoading) {
              return buildLoaderPostItem();
            } else {
              return buildListVacia();
            }
          } else if (index < PostsList.length) {
            final post = PostsList[index];
            final isRepost = post['repost'].isNotEmpty;
            return Padding(
              padding: const EdgeInsets.all(10),
              child: Stack(
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        height: postHeight,
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                                color: grey.withOpacity(0.4),
                                spreadRadius: 2,
                                blurRadius: 15,
                                offset: const Offset(0, 1))
                          ],
                          image: DecorationImage(
                              image: NetworkImage(isRepost
                                  ? "$POST_IMG_URL/" +
                                      post["repost"][0]['fileName']
                                  : "$POST_IMG_URL/" + post['fileName']),
                              fit: BoxFit.cover),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                          ),
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE5E5E5).withOpacity(0.5),
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(20),
                            bottomRight: Radius.circular(20),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Text(
                            post['author'][0]["premium"] == true
                                ? "${post['author'][0]['username']}: ${post['caption']}"
                                : "${post['author'][0]['username']}: ${post['caption']}",
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      )
                    ],
                  ),
                  Container(
                      width: double.infinity,
                      height: postHeight,
                      decoration: BoxDecoration(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                          ),
                          color: black.withOpacity(0.25))),
                  Container(
                    width: double.infinity,
                    height: postHeight,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    backgroundImage: NetworkImage(
                                      post['author'][0]?.containsKey(
                                                  'profilePicture') ==
                                              true
                                          ? "$PROFILE_IMG_URL/" +
                                              post['author'][0]
                                                  ['profilePicture']
                                          : "$PROFILE_IMG_URL/$DEFAULT_IMAGE",
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 8,
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          (isRepost &&
                                                  post['author'][0]
                                                          ['premium'] ==
                                                      true)
                                              ? PremiumUser(
                                                  username:
                                                      "Reposteado por ${post['author'][0]['username']}",
                                                  fontSize: 15)
                                              : (!isRepost &&
                                                      post['author'][0]
                                                              ['premium'] ==
                                                          true)
                                                  ? PremiumUser(
                                                      username: post['author']
                                                          [0]['username'],
                                                      fontSize: 15)
                                                  : (isRepost)
                                                      ? Text(
                                                          "Reposteado por ${post['author'][0]['username']}",
                                                          style:
                                                              const TextStyle(
                                                                  color: white),
                                                        )
                                                      : Text(
                                                          post['author'][0]
                                                              ['username'],
                                                          style:
                                                              const TextStyle(
                                                                  color:
                                                                      white)),
                                          const SizedBox(
                                            width: 5,
                                          ),
                                          (post['author'][0]['premium'] == true)
                                              ? iconoVerificado
                                              : const SizedBox.shrink(),
                                        ],
                                      ),
                                      Text(
                                        formatRelativeTime(post["createdAt"]),
                                        style: TextStyle(
                                            fontSize: 13,
                                            color: white.withOpacity(0.8)),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                              GestureDetector(
                                onTap: () {
                                  openPostModal(
                                      post["author"][0]["_id"], post["_id"]);
                                },
                                child: const Icon(
                                  Icons.more_vert,
                                  color: white,
                                  size: 20,
                                ),
                              )
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  post["isLiked"]
                                      ? removeLike(index, post["_id"])
                                      : postLike(index, post["_id"],
                                          post["author"][0]["_id"]);
                                },
                                child: Container(
                                  width: 70,
                                  height: 27,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(27),
                                      color: const Color(0xFFE5E5E5)
                                          .withOpacity(0.5)),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Icon(
                                        Icons.favorite,
                                        color: post["isLiked"] ? red : white,
                                        size: 14,
                                      ),
                                      Text(
                                        post["likesCount"].toString(),
                                        style: const TextStyle(
                                            fontSize: 13, color: white),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  showModalBottomSheet(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return CommentsList(postId: post["_id"]);
                                    },
                                  );
                                },
                                child: Container(
                                  width: 70,
                                  height: 27,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(27),
                                      color: const Color(0xFFE5E5E5)
                                          .withOpacity(0.5)),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      const Icon(
                                        Icons.chat_bubble,
                                        color: white,
                                        size: 14,
                                      ),
                                      Text(
                                        post['commentsCount'].toString(),
                                        style: const TextStyle(
                                            fontSize: 13, color: white),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  openRepostModal(
                                      post['isReposted'],
                                      context,
                                      index,
                                      post["_id"],
                                      post["author"][0]["_id"]);
                                },
                                child: Container(
                                  width: 70,
                                  height: 27,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(27),
                                      color: const Color(0xFFE5E5E5)
                                          .withOpacity(0.5)),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      const Icon(
                                        Icons.share,
                                        color: white,
                                        size: 14,
                                      ),
                                      Text(
                                        post['repostsCount'].toString(),
                                        style: const TextStyle(
                                            fontSize: 13, color: white),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  post["isBookmarked"]
                                      ? removeBookmark(index, post["_id"])
                                      : postBookmark(index, post["_id"]);
                                },
                                child: Container(
                                  width: 70,
                                  height: 27,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(27),
                                      color: const Color(0xFFE5E5E5)
                                          .withOpacity(0.5)),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Icon(
                                        Icons.bookmark,
                                        color: post['isBookmarked']
                                            ? primary
                                            : white,
                                        size: 14,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          } else if (isLoading) {
            return buildLoaderPostItem();
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  void _scrollListener() {
    if (!isLoading &&
        scrollController.position.pixels ==
            scrollController.position.maxScrollExtent) {
      page++;
      fetchPosts();
    }
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }
}
