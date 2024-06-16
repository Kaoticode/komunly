import 'package:flutter/material.dart';
import 'package:komunly/theme/colors.dart';
import 'package:komunly/widgets/appBar.dart';
import 'package:komunly/widgets/solicitudesList.dart';
import 'package:komunly/widgets/usersFollowersList.dart';

class SeguidoresPage extends StatefulWidget {
  final String userid;
  const SeguidoresPage({super.key, required this.userid});

  @override
  State<SeguidoresPage> createState() => _SeguidoresPageState();
}

class _SeguidoresPageState extends State<SeguidoresPage> {
  @override
  void initState() {
    print(widget.userid);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: const CustomAppBar(title: "Seguidores"),
      body: Column(
        children: [
          GestureDetector(
            onTap: () {
              showModalBottomSheet(
                context: context,
                builder: (BuildContext context) {
                  return solicitudesList(
                    direction: 'pending',
                  );
                },
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Container(
                width: double.infinity,
                height: 50,
                color: primary,
                child: const Center(
                    child: Text(
                  "Ver solicitudes de seguimiento recibidas",
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                )),
              ),
            ),
          ),
          Expanded(
            child: UsersFollowersList(
              userId: widget.userid,
            ),
          ),
        ],
      ),
    );
  }
}
