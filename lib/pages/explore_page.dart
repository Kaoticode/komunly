import 'package:flutter/material.dart';
import 'package:komunly/theme/colors.dart';
import 'package:komunly/widgets/calendar.dart';
import 'package:komunly/widgets/posts.dart';
import 'package:komunly/widgets/user/usersList.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          centerTitle: true,
          title: const Text(
            'Explore',
            style: TextStyle(color: Colors.white, fontSize: 22),
          ),
          bottom: const TabBar(
            indicatorSize: TabBarIndicatorSize.tab,
            automaticIndicatorColorAdjustment: true,
            indicatorColor: primary,
            labelColor: primary,
            unselectedLabelColor: Colors.white,
            tabs: [
              Tab(text: 'Posts'),
              Tab(text: 'Usuarios'),
              Tab(text: 'Eventos'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            PostsWidget(postHeight: 260, endpoint: 'posts?',),
            const UsersList(),
            const Calendar(),
          ],
        ),
      ),
    );
  }
}
