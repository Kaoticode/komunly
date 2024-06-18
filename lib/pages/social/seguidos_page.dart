import 'package:flutter/material.dart';
import 'package:komunly/theme/colors.dart';
import 'package:komunly/widgets/appBar.dart';
import 'package:komunly/widgets/solicitudesList.dart';
import 'package:komunly/widgets/user/usersFollowingsList.dart';

class SeguidosPage extends StatefulWidget {
  final String userid;
  const SeguidosPage({super.key, required this.userid});

  @override
  State<SeguidosPage> createState() => _SeguidosPageState();
}

class _SeguidosPageState extends State<SeguidosPage> {
  @override
  void initState() {
    print(widget.userid);
    super.initState();
  }

 @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: const CustomAppBar(title: "Seguidos"),
      body: Column(
        children: [
          GestureDetector(
            onTap: () {
              showModalBottomSheet(
                context: context,
                builder: (BuildContext context) {
                  return solicitudesList(
                    direction: 'sent',
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
                  "Ver solicitudes de seguimiento enviadas",
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                )),
              ),
            ),
          ),
          Expanded(
            child: UsersFollowingList(
              userId: widget.userid,
            ),
          ),
        ],
      ),
    );
  }
}
