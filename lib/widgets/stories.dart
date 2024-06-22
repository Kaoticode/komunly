import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:komunly/constants/constants.dart';
import 'package:komunly/pages/story_page.dart';
import 'package:komunly/pages/upload_page.dart';
import 'package:komunly/repository/api.repository.dart';
import 'package:komunly/theme/colors.dart';
import 'package:komunly/widgets/bottom_modal.dart';
import 'package:komunly/widgets/premiumUser.dart';
import 'package:komunly/widgets/snackbars.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StoriesWidget extends StatefulWidget {
  const StoriesWidget({super.key});

  @override
  State<StoriesWidget> createState() => _StoriesWidgetState();
}

class _StoriesWidgetState extends State<StoriesWidget> {
  final scrollController = ScrollController();
  final List<dynamic> StoriesList = [];
  bool isLoading = false;
  int page = 1;
  int limit = 15;

  @override
  void initState() {
    super.initState();
    fetchStories();
  }

  Future<void> fetchStories() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('access_token');
    String apiUrl = "$API_URL/stories?limit=$limit&page=$page";

    try {
      var response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> newData = json.decode(response.body);

        setState(() {
          StoriesList.addAll(newData);
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
    final List<Map<String, dynamic>> _bottomSheetOptions = [
      {
        "title": "Ver mi historia",
        "icon": Icons.remove_red_eye,
        "onPressed": (context) {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => const UploadPage(postType: "Story")));
        }
      },
      {
        "title": "Subir historia",
        "icon": Icons.upload,
        "onPressed": (context) {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => const UploadPage(
                    postType: "Story",
                  )));
        }
      },
    ];

    void _showBottomSheet(BuildContext context) {
      showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return CustomBottomSheet(options: _bottomSheetOptions);
        },
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5),
        child: Row(
          children: [
            Column(
              children: [
                GestureDetector(
                  onTap: () {
                    _showBottomSheet(context);
                  },
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                            colors: [Color(0xFFFFE0DF), Color(0xFFE1F6F4)])),
                    child: const Center(
                      child: Icon(
                        Icons.add,
                        color: black,
                        size: 28,
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                const Text(
                  "Mi historia",
                  style: TextStyle(color: Colors.white),
                )
              ],
            ),
            const SizedBox(
              width: 10,
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: 85,
              child: ListView.builder(
                itemCount: StoriesList.length,
                scrollDirection: Axis.horizontal,
                itemBuilder: (BuildContext context, int index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 15),
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (_) => StoryPage(
                                        storiesList: StoriesList,
                                        initialIndex: index,
                                      )),
                            );
                          },
                          child: Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                    image: NetworkImage(PROFILE_IMG_URL +
                                        "/" +
                                        StoriesList[index]['author']
                                            ['profilePicture']),
                                    fit: BoxFit.cover)),
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                       StoriesList[index]['author']["premium"] == true
                        ? Row(
                            children: [
                              PremiumUser(
                                  username: StoriesList[index]['author']["username"], fontSize: 14),
                                  const SizedBox(width: 5,),
                              StoriesList[index]['author']["verificado"] == true
                                  ? const Icon(Icons.check, color: primary, size: 14,)
                                  : const SizedBox.shrink(),
                            ],
                          )
                        : Row(
                            children: [
                              Text(
                               StoriesList[index]['author']["username"],
                                style: const TextStyle(
                                    fontSize: 14, color: Colors.white),
                              ),
                                const SizedBox(width: 5,),
                             StoriesList[index]['author']["verificado"] == true
                                  ? const Icon(Icons.check, color: primary, size: 14,)
                                  : const SizedBox.shrink()
                            ],
                          ),
                       
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
