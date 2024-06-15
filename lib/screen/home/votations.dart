import 'dart:async';
import 'dart:ffi';
import 'package:crypto/models/entities.model.dart';
import 'package:crypto/models/votations.model.dart';
import 'package:crypto/repository/user.repository.dart';
import 'package:crypto/repository/votations.repository.dart';
import 'package:crypto/screen/home/vote.dart';
import 'package:crypto/utils/helper.dart';

import 'package:flutter/material.dart';


import '../../Library/carousel_pro/src/carousel_pro.dart';

class Votations extends StatefulWidget {
  final EntitieModel entitie;
  const Votations({super.key, required this.entitie});
  @override
  createState() => _votationState();
}

class _votationState extends State<Votations> {
  @override
  
  void initState() {
    super.initState();
    () async {
      await Future.delayed(Duration.zero);
      await getVotations(widget.entitie.id);
    }();
  }

  Widget build(BuildContext context) {
    
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(padding: EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            
            SizedBox(height: 20.0),
            BackButton(color: Colors.white),
            SizedBox(height: 10.0),
            Text(
              "Votaciones de la Organización",
              style: TextStyle(
                fontSize: 20.0,
                height: 1.5,
                color: Color.fromARGB(255, 178, 179, 182),
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 15.0),
            ValueListenableBuilder(valueListenable: currentVotations, 
            builder: (BuildContext context, value, Widget? child) {
                return ListView.builder(
                  shrinkWrap: true,
                  physics: BouncingScrollPhysics(),
                  itemCount: value.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      onTap: () {
                        Helper.nextScreen(context, VoteVotations(votation: value[index]));
                      },
                      leading: CircleAvatar(backgroundColor: const Color.fromARGB(255, 126, 151, 126),),
                      title: Text(value[index].title, style: TextStyle(color: Color.fromARGB(255, 178, 179, 182),)),
                      trailing: Icon(Icons.forward, color: Color.fromARGB(255, 178, 179, 182)),
                    );
                  },
                );
            })
          ],
        ),)
      ),
    );
  }
}
 