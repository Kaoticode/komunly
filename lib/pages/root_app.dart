import 'package:flutter/material.dart';
import 'package:komunly/pages/actions_page.dart';
import 'package:komunly/pages/explore_page.dart';
import 'package:komunly/pages/home_page.dart';
import 'package:komunly/pages/notifications_page.dart';
import 'package:komunly/pages/profile/profile_page.dart';

class RootPage extends StatefulWidget {
  const RootPage({super.key});

  @override
  State<RootPage> createState() => _RootState();
}

class _RootState extends State<RootPage> {
  int myCurrentIndex = 0;

  List<Widget> pages = [
    HomePage(),
    const ExplorePage(),
    const ActionsPage(),
    const NotificationsPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[myCurrentIndex],
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: const Color.fromARGB(255, 225, 255, 0),
        unselectedItemColor: Colors.grey,
        currentIndex: myCurrentIndex,
        iconSize: 25,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.black,
        selectedFontSize: 0,
        unselectedFontSize: 0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search_outlined),
            label: '', // Vacío para eliminar el texto
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: '', // Vacío para eliminar el texto
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_outline),
            label: '', // Vacío para eliminar el texto
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outlined),
            label: '', // Vacío para eliminar el texto
          ),
        ],
        onTap: (myNewCurrent) {
          setState(() {
            myCurrentIndex = myNewCurrent;
          });
        },
      ),
    );
  }
}
