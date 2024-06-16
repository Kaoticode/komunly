import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const CustomAppBar({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: AppBar(
        backgroundColor: Colors.black,
        leadingWidth: 16,
        title: Text(
          title,
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          iconSize: 18,
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white,),
          onPressed: () => Navigator.of(context).pop(),
        ),
        automaticallyImplyLeading: true,
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
