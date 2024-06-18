import 'package:flutter/material.dart';
import 'package:komunly/theme/colors.dart';
import 'package:komunly/widgets/posts.dart';
import 'package:komunly/widgets/premiumUser.dart';
import 'package:komunly/widgets/stories.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: black,
      appBar: PreferredSize(
          preferredSize: const Size.fromHeight(60), child: getAppBar()),
      body: getBody(),
    );
  }

  Widget getAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: black,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
         const PremiumUser(username: "Komunly", fontSize: 26,),
          IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.notification_add,
                color: white,
                size: 22,
              ))
        ],
      ),
    );
  }

  Widget getBody() {
    return const SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StoriesWidget(),
            ],
          ),
          PostsWidget(postHeight: 260, endpoint: 'posts',),
        ],
      ),
    );
  }
}
