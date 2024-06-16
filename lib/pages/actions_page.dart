import 'package:flutter/material.dart';
import 'package:komunly/pages/apuestas_page.dart';
import 'package:komunly/pages/chat/chat_list_page.dart';
import 'package:komunly/pages/create_events_page.dart';
import 'package:komunly/pages/gambling_page.dart';
import 'package:komunly/pages/transactions_page.dart';
import 'package:komunly/pages/upload_page.dart';


class Action {
  final IconData icon;
  final String title;
  final String route;

  Action({required this.icon, required this.title, required this.route});
}

final List<Action> _actions = [
   Action(icon: Icons.upload, title: 'Postear', route: "PostearPage"),
   Action(icon: Icons.monetization_on, title: 'Apuestas', route: "ApuestasPage"),
  Action(icon: Icons.message, title: 'Chat', route: "ChatPage"),
  Action(icon: Icons.send, title: 'Transacciones', route: "TransactionsPage"),
  Action(icon: Icons.monetization_on, title: 'Ruleta', route: "GamblingPage"),
  Action(icon: Icons.calendar_month, title: 'Crear Eventos', route: "CreateEventsPage"),
];


class ActionsPage extends StatelessWidget {
  const ActionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leadingWidth: 16,
        title: const Text(
          "Acciones",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        itemCount: _actions.length,
        itemBuilder: (context, index) {
          final action = _actions[index];
          return _buildListItem(
            icon: action.icon,
            title: action.title,
            onTap: () => _navigateToRoute(context, action.route),
          );
        },
      ),
    );
  }

  Widget _buildListItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      color: Colors.grey[900],
      child: InkWell(
        onTap: onTap,
        child: ListTile(
          leading: Icon(
            icon,
            color: Colors.white,
          ),
          title: Text(
            title,
            style: const TextStyle(color: Colors.white),
          ),
          trailing: const Icon(
            Icons.arrow_outward_sharp,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  void _navigateToRoute(BuildContext context, String route) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => _buildDestinationPage(route)));
  }

  Widget _buildDestinationPage(String route) {
    return {
      "PostearPage": const UploadPage(postType: "Post"),
      "ChatPage": const ChatList(),
      "TransactionsPage": const TransactionsPage(),
      "GamblingPage": const GamblingPage(),
      "CreateEventsPage": const CreateEvents(),
      "ApuestasPage": const ApuestasPage(),
    }[route] ?? Container();
  }
}
