import 'package:flutter/material.dart';
import 'package:komunly/theme/colors.dart';
import 'package:komunly/widgets/appBar.dart';
import 'package:komunly/widgets/solicitudesList.dart';
import 'package:komunly/widgets/user/usersFollowersList.dart';

class FollowersPage extends StatefulWidget {
  final String userid;
  final String typeComponent;
  const FollowersPage({super.key, required this.userid, required this.typeComponent});

  @override
  State<FollowersPage> createState() => _SeguidoresPageState();
}

class _SeguidoresPageState extends State<FollowersPage> {
  @override
  void initState() {
    print(widget.userid);
    super.initState();
    
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: CustomAppBar(title: widget.typeComponent == 'pending' ? 'Seguidores' : 'Seguidos'),
      body: Column(
        children: [
          GestureDetector(
            onTap: () {
              showModalBottomSheet(
                context: context,
                builder: (BuildContext context) {
                  return solicitudesList(
                    direction: widget.typeComponent,
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
