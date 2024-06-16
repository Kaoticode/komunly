import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:komunly/constants/constants.dart';
import 'package:komunly/functions/functions.dart';
import 'package:komunly/pages/chat/chat_page.dart';
import 'package:komunly/pages/profile/edit_profile_page.dart';
import 'package:komunly/pages/user/login_page.dart';
import 'package:komunly/pages/seguidores_page.dart';
import 'package:komunly/pages/seguidos_page.dart';
import 'package:komunly/pages/user_story_page.dart';
import 'package:komunly/widgets/bottom_modal.dart';
import 'package:komunly/widgets/infoCard.dart';
import 'package:komunly/widgets/posts.dart';
import 'package:komunly/widgets/snackbars.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class ProfilePage extends StatefulWidget {
  final String? id;
  final String? profilePicture;
  final String? username;
  final String? description;
  final String? bankNumber;
  final String? createdAt;
  final int? posts;
  final int? seguidores;
  final int? seguidos;
  final bool? isPublic;

  const ProfilePage({
    super.key,
    this.id,
    this.profilePicture,
    this.username,
    this.description,
    this.bankNumber,
    this.createdAt,
    this.posts,
    this.seguidores,
    this.seguidos,
    this.isPublic,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  late String profilePicture;
  late String username;
  late String description;
  late String bankNumber;
  late String createdAt;
  late int posts;
  late int seguidores;
  late int seguidos;
  late bool isPublic;
  late bool isFollowed;
  late String myUserId;
  late String principalId;
  bool? seeProfile;
  late TabController _tabController;
  late List<dynamic> StoriesList = [];
  bool isLoading = false;
  int page = 1;
  int limit = 15;

  Future<bool> isaFollowing() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? myUserId = prefs.getString('user_id');
    if (widget.id == null || myUserId == widget.id || isFollowed || isPublic) {
      return true;
    } else {
      return false;
    }
  }

  Future<void> getMyUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    myUserId = prefs.getString('user_id')!;
  }

  void fetchProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('access_token');
    String apiUrl =
        "$API_URL/${await checkProfileId(widget.id) ? 'auth/me' : 'users/getProfile/${widget.id}'}";

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
          profilePicture = jsonResponse["profilePicture"] ?? DEFAULT_IMAGE;
          username = jsonResponse['username'];
          posts = jsonResponse['postCount'];
          seguidores = jsonResponse['followersCount'];
          seguidos = jsonResponse['followingsCount'];
          description = jsonResponse['description'];
          bankNumber = jsonResponse['bankNumber'] ?? "**** **** **** ****";
          isPublic = jsonResponse['isPublic'];
          isFollowed = jsonResponse['isFollowed'] ?? true;
          createdAt = jsonResponse['createdAt'];
        });
        updateSeeProfile();
        fetchUsersStories();
      } else {
        if (response.statusCode == 401 ||
            response.statusCode == 400 ||
            response.statusCode == 400) {
          refreshTokens();
        } else {
          /* 
        var responseData = json.decode(response.body);
          showSnackMessage(context, responseData['message'], "ERROR"); 
        */
        }
      }
    } catch (e) {
      showSnackMessage(context, "Error de conexión: $e", "ERROR");
    }
  }

  void fetchUsersStories() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('access_token');
    String? userId = prefs.getString('user_id');
    String apiUrl =
        "$API_URL/${await checkProfileId(widget.id) ? 'stories/$userId' : 'stories/${widget.id}'}";

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
          StoriesList = json.decode(response.body);
        });
      } else {
        if (response.statusCode == 401 || response.statusCode == 400) {
          refreshTokens();
        } else {
          var responseData = json.decode(response.body);
          showSnackMessage(context, responseData['message'], "ERROR");
        }
      }
    } catch (e) {
      showSnackMessage(context, "Error de conexión: $e", "ERROR");
    }
  }

  Future<void> followUser() async {
    print(widget.id);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('access_token');
    String apiUrl = "$API_URL/follows";

    try {
      Navigator.pop(context);
      var response = await http.post(Uri.parse(apiUrl),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $accessToken',
          },
          body: jsonEncode({
            "following": widget.id,
          }));

      if (response.statusCode == 201) {
        setState(() {
          fetchProfile();
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

  Future<void> sendFollowRequest() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('access_token');
    String apiUrl = "$API_URL/follows/request";

    try {
      Navigator.pop(context);
      var response = await http.post(Uri.parse(apiUrl),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $accessToken',
          },
          body: jsonEncode({
            "following": widget.id,
          }));

      if (response.statusCode == 201) {
        setState(() {
          fetchProfile();
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

  Future<void> unfollowUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('access_token');
    String apiUrl = "$API_URL/follows/${widget.id}";

    try {
      Navigator.pop(context);
      var response = await http.delete(Uri.parse(apiUrl), headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      });

      if (response.statusCode == 200) {
        setState(() {
          fetchProfile();
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

  Future<void> bloquearUsuario(block_to) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('access_token');
    String apiUrl = "$API_URL/blocks";

    try {
      Navigator.pop(context);
      var response = await http.post(Uri.parse(apiUrl),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $accessToken',
          },
          body: jsonEncode({"block_to": block_to}));

      if (response.statusCode == 201) {
        showSnackMessage(context, "Usuario bloqueado con éxito", "SUCCESS");
        fetchProfile();
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
        fetchProfile();
        updateSeeProfile();
        getMyUserId();
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

  void updateSeeProfile() async {
    bool result = await isaFollowing();
    setState(() {
      seeProfile = result;
    });
  }

  @override
  void initState() {
    super.initState();
    profilePicture = widget.profilePicture ?? DEFAULT_IMAGE;
    username = widget.username ?? "Usuario";
    description = widget.description ?? "Biografía";
    bankNumber = widget.bankNumber ?? "1";
    createdAt = widget.createdAt ?? "2024-05-06T23:39:16.018+00:00";
    posts = widget.posts ?? 0;
    seguidores = widget.seguidores ?? 0;
    seguidos = widget.seguidos ?? 0;
    isPublic = widget.isPublic ?? false;
    isFollowed = false;
    seeProfile = false;

    _tabController = TabController(length: 3, vsync: this);
    fetchProfile();
    updateSeeProfile();
    getMyUserId();
    getPrincipalId();
  }

  Future<void> getPrincipalId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? myUserId = prefs.getString('user_id');
    if (widget.id == null) {
      principalId = myUserId ?? "";
    } else {
      principalId = widget.id ?? "";
    }
    print(principalId);
  }

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> checkUserOptions() {
      if (isFollowed) {
        return {
          "title": "Dejar de seguir",
          "icon": Icons.send_rounded,
          "onPressed": (context) {
            unfollowUser();
          }
        };
      } else if (!isFollowed && isPublic) {
        return {
          "title": "Seguir",
          "icon": Icons.send_rounded,
          "onPressed": (context) {
            followUser();
          }
        };
      } else if (!isFollowed && !isPublic) {
        return {
          "title": "Mandar Solicitud",
          "icon": Icons.send_rounded,
          "onPressed": (context) {
            sendFollowRequest();
          }
        };
      } else {
        return {};
      }
    }

    final userProfile = [
      checkUserOptions(),
      {
        "title": "Bloquear usuario",
        "icon": Icons.person_off,
        "onPressed": (context) {
          bloquearUsuario(widget.id);
        }
      },
      {
        "title": "Enviar Mensaje",
        "icon": Icons.near_me,
        "onPressed": (context) {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => ChatPage(
                    userId: widget.id!,
                    username: username,
                    profilePicture: profilePicture,
                  )));
        }
      },
    ];

    final myProfile = [
      {
        "title": "Editar Perfil",
        "icon": Icons.edit,
        "onPressed": (context) {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => EditProfilePage(
                  imagen: profilePicture,
                  username: username,
                  description: description,
                  isPublic: isPublic)));
        }
      },
      {
        "title": "Configuración",
        "icon": Icons.settings,
        "onPressed": (context) {}
      },
      {
        "title": "Compartir perfil",
        "icon": Icons.send_rounded,
        "onPressed": (context) {}
      },
      {
        "title": "Cerrar sesión",
        "icon": Icons.logout,
        "onPressed": (context) {
          cerrarSesion(context);
        }
      },
    ];

    openModal() async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? myUserId = prefs.getString('user_id');
      if (widget.id == null || widget.id == myUserId) {
        showModalBottomSheet(
          context: context,
          builder: (BuildContext context) {
            return CustomBottomSheet(options: myProfile);
          },
        );
        return;
      } else {
        showModalBottomSheet(
          context: context,
          builder: (BuildContext context) {
            return CustomBottomSheet(options: userProfile);
          },
        );
        return;
      }
    }

    var media = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.black,
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: media.height / 2.5,
              floating: false,
              pinned: false,
              backgroundColor: Colors.black,
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (StoriesList.isNotEmpty) {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (_) => UserStoryPage(
                                    storiesList: StoriesList,
                                  )));
                        } else {
                          showSnackMessage(
                              context,
                              "Por el momento no hay nada que ver por aqui...",
                              "WARNING");
                        }
                      },
                      child: Image.network(
                        '${PROFILE_IMG_URL}/$profilePicture',
                        fit: BoxFit.cover,
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        height: 50,
                        color: Colors.black.withOpacity(0.5),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(posts.toString(),
                                    style:
                                        const TextStyle(color: Colors.white)),
                                const Text("Posts",
                                    style: TextStyle(color: Colors.white)),
                              ],
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (_) => SeguidoresPage(
                                        userid: widget.id ?? myUserId)));
                              },
                              child: GestureDetector(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(seguidores.toString(),
                                        style: const TextStyle(
                                            color: Colors.white)),
                                    const Text("Seguidores",
                                        style: TextStyle(color: Colors.white)),
                                  ],
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (_) => SeguidosPage(
                                        userid: widget.id ?? myUserId)));
                              },
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(seguidos.toString(),
                                      style:
                                          const TextStyle(color: Colors.white)),
                                  const Text("Seguidos",
                                      style: TextStyle(color: Colors.white)),
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                openModal();
                              },
                              child: const Text("Acciones",
                                  style: TextStyle(color: Colors.white)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverPersistentHeader(
              delegate: _SliverAppBarDelegate(
                TabBar(
                  indicatorSize: TabBarIndicatorSize.tab,
                  automaticIndicatorColorAdjustment: true,
                  indicatorColor: const Color.fromARGB(255, 225, 255, 0),
                  labelColor: const Color.fromARGB(255, 225, 255, 0),
                  unselectedLabelColor: Colors.white,
                  controller: _tabController,
                  tabs: const [
                    Tab(
                      icon: Icon(Icons.image),
                    ),
                    Tab(
                      icon: Icon(Icons.repeat),
                    ),
                    Tab(
                      icon: Icon(Icons.info),
                    ),
                  ],
                ),
              ),
              pinned: true,
            ),
          ];
        },
        body: seeProfile == null || !seeProfile!
            ? const profileNoFollowed()
            : profileFollowed(
                principalId: principalId,
                tabController: _tabController,
                username: username,
                createdAt: createdAt,
                description: description,
                bankNumber: bankNumber,
              ),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}

class profileNoFollowed extends StatelessWidget {
  const profileNoFollowed({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lock,
              color: Colors.white,
              size: 50,
            ),
            SizedBox(height: 20),
            Text(
              "Este perfil es privado.\nSíguelo para ver sus publicaciones.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class profileFollowed extends StatelessWidget {
  const profileFollowed({
    super.key,
    required TabController tabController,
    required this.username,
    required this.createdAt,
    required this.description,
    required this.bankNumber,
    required this.principalId,
  }) : _tabController = tabController;

  final TabController _tabController;
  final String username;
  final String createdAt;
  final String description;
  final String bankNumber;
  final String principalId;

  @override
  Widget build(BuildContext context) {
    return TabBarView(
      controller: _tabController,
      children: [
        PostsWidget(
          postHeight: 0,
          endpoint: 'posts/$principalId?repost=false&',
        ),
        PostsWidget(
          postHeight: 0,
          endpoint: 'posts/$principalId?repost=true&',
        ),
        CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
                child: InfoCard(
                    username: username,
                    createdAt: createdAt,
                    description: description,
                    bankNumber: bankNumber)),
          ],
        ),
      ],
    );
  }
}

void cerrarSesion(BuildContext context) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.remove('access_token');
  prefs.remove('user_id');
  prefs.remove('refresh_token');
  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (context) => const LoginPage()),
    (Route<dynamic> route) => false,
  );
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _SliverAppBarDelegate(this.tabBar);

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.black,
      child: tabBar,
    );
  }

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
