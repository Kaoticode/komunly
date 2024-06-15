import 'dart:async';
import 'dart:ffi';
import 'package:cache_manager/cache_manager.dart';
import 'package:crypto/models/entities.model.dart';
import 'package:crypto/models/user.model.dart';
import 'package:crypto/repository/user.repository.dart';
import 'package:crypto/screen/home/votations.dart';
import 'package:crypto/utils/helper.dart';
import 'package:flutter/material.dart';
import '../../Library/carousel_pro/src/carousel_pro.dart';

class home extends StatefulWidget {
  _homeState createState() => _homeState();
}

class _homeState extends State<home> {
  @override
  
  void initState() {
    super.initState();
    () async {
      await Future.delayed(Duration.zero);
      await getUser();
    }();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            ///
            /// Header image slider
            ///
            SizedBox(
                height: 210.0,
                width: double.infinity,
                child: new Carousel(
                  boxFit: BoxFit.cover,
                  dotColor: Colors.white.withOpacity(0.8),
                  dotSize: 5.5,
                  dotSpacing: 16.0,
                  dotBgColor: Colors.transparent,
                  showIndicator: true,
                  overlayShadow: true,
                  overlayShadowColors: Theme.of(context)
                      .scaffoldBackgroundColor
                      .withOpacity(0.9),
                  overlayShadowSize: 0.25,
                  images: [
                    AssetImage("assets/image/banner/banner2.png"),
                    AssetImage("assets/image/banner/banner3.jpg"),
                    AssetImage("assets/image/banner/banner2.png"),
                    AssetImage("assets/image/banner/banner3.jpg"),
                  ],
                )),
            Padding(padding: EdgeInsets.all(16.0),
            child: Text(
              'Bienvenido '+ currentUser.value.fullname,
                        style: TextStyle(
                          fontSize: 14.0,
                          height: 1.5,
                          color: Color.fromARGB(255, 156, 157, 160),
                          fontWeight: FontWeight.w600,
                        ),
            ),),
            
            Padding(padding: EdgeInsets.all(16.0),
              child: Text(
              "Organizaciones Actuales",
                        style: TextStyle(
                          fontSize: 20.0,
                          height: 1.5,
                          color: Color.fromARGB(255, 178, 179, 182),
                          fontWeight: FontWeight.w600,
                        ),
            )),
            ValueListenableBuilder(valueListenable: currentEntities, 
            builder: (BuildContext context, value, Widget? child) {
                return ListView.builder(
                  shrinkWrap: true,
                  physics: BouncingScrollPhysics(),
                  itemCount: value.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      onTap: () {
                        Helper.nextScreen(context, Votations(entitie: value[index]));
                      },
                      leading: CircleAvatar(backgroundColor: const Color.fromARGB(255, 126, 151, 126),),
                      title: Text(value[index].fullname, style: TextStyle(color: Color.fromARGB(255, 178, 179, 182),)),
                      trailing: Icon(Icons.forward, color: Color.fromARGB(255, 178, 179, 182)),
                    );
                  },
                );
            })
          ],
        ),
      ),
    );
  }
}
 