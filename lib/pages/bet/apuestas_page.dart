import 'package:flutter/material.dart';
import 'package:komunly/theme/colors.dart';
import 'package:komunly/widgets/appBar.dart';
import 'package:komunly/widgets/bet/bets.dart';

class ApuestasPage extends StatefulWidget {
  const ApuestasPage({super.key});

  @override
  _ApuestasPageState createState() => _ApuestasPageState();
}

class _ApuestasPageState extends State<ApuestasPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: black,
      appBar: const PreferredSize(
          preferredSize: Size.fromHeight(60), child: CustomAppBar(title: "Apuestas",)),
      body: getBody(),
    );
  }

  

  Widget getBody() {
    return const SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BetsWidget()
        ],
      ),
    );
  }
}
