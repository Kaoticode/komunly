import 'package:flutter/material.dart';
import 'package:komunly/pages/user/login_page.dart';
import 'package:komunly/pages/root_app.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter UI Tutorial',
      home: FutureBuilder<Widget>(
        future: determineHomePage(),
        builder: (BuildContext context, AsyncSnapshot<Widget> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else {
            return snapshot.data!;
          }
        },
      ),
    );
  }
}

Future<Widget> determineHomePage() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? accessToken = prefs.getString('access_token');
  String? userId = prefs.getString('user_id');

  if (accessToken != null && userId != null) {
    return const RootPage();
  } else {
    return const LoginPage();
  }
}
