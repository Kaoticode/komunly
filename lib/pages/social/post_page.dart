import 'package:flutter/material.dart';
import 'package:komunly/widgets/appBar.dart';
import 'package:komunly/widgets/posts.dart';

class PostPage extends StatefulWidget {
  final String postId;

  PostPage({super.key, required this.postId});

  @override
  State<PostPage> createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: CustomAppBar(title: "Post Details"),
      body: PostsWidget(postHeight: 0, endpoint: 'posts?',),
    );
  }
}
