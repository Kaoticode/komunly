import 'dart:async';
import 'dart:ffi';
import 'package:crypto/models/entities.model.dart';
import 'package:crypto/models/user.model.dart';
import 'package:crypto/models/votations.model.dart';
import 'package:crypto/repository/user.repository.dart';
import 'package:crypto/repository/votations.repository.dart';
import 'package:crypto/screen/home/home.dart';
import 'package:crypto/screen/home/votations.dart';
import 'package:crypto/utils/helper.dart';

import 'package:flutter/material.dart';


import '../../Library/carousel_pro/src/carousel_pro.dart';

class VoteVotations extends StatefulWidget {
  final VotationModel votation;
  const VoteVotations({super.key, required this.votation});
  @override
  createState() => _votationState();
}

class _votationState extends State<VoteVotations> {
  @override
  int vote = -1;
  String errorMessage = '';
  int dissabled = 0;
  void initState() {
    DateTime tryNow = new DateTime.now();
    //SI, intente usar map pero no hace el bucle debe ser por venir de currentValue    
    for(var i=0; i<widget.votation.votes.length; i++){
      if(widget.votation.votes[i].from_id == currentUser.value.id){
        setState(() {
          dissabled = -1;
          errorMessage = 'Ya votaste';
        });
      }
    }

    if(tryNow.compareTo(widget.votation.timeStart) > 0 && tryNow.compareTo(widget.votation.timeEnd) < 0){
      
    } else setState(() {
          dissabled = -1;
    });
    
    super.initState();
    
  }

  Widget build(BuildContext context) {
    
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            
            SizedBox(height: 10.0),
            BackButton(color: Colors.white),
            SizedBox(height: 20.0),
            Text(
              widget.votation.title,
              style: TextStyle(
                fontSize: 20.0,
                height: 1.5,
                color: Color.fromARGB(255, 178, 179, 182),
                fontWeight: FontWeight.w600,
              ),
            ),

            Text(
              widget.votation.description,
              style: TextStyle(
                fontSize: 15.0,
                height: 1.5,
                color: Color.fromARGB(255, 178, 179, 182),
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 15.0),

            ListView.builder(
                  shrinkWrap: true,
                  physics: BouncingScrollPhysics(),
                  itemCount: widget.votation.options.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      onTap: () {
                        setState(() {
                          vote = index;
                        });
                      },
                      leading: CircleAvatar(backgroundColor: index == vote ? Color.fromARGB(255, 30, 158, 30) : const Color.fromARGB(255, 126, 151, 126), radius: 5),
                      title: Text(widget.votation.options[index], style: TextStyle(color: Color.fromARGB(255, 178, 179, 182),)),
                      trailing: Text(dissabled == 0 ? '?%' : getPercentageOfVotations(widget.votation, index).toString() + '%' , style: TextStyle(color: Colors.white)),
                    );
                  },
                ),
            Text(
              'Mas Información',
              style: TextStyle(
                fontSize: 15.0,
                height: 1.5,
                color: Color.fromARGB(255, 178, 179, 182),
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 10,),
            Text(errorMessage, style: TextStyle(color: Colors.redAccent)),
             Padding(
                        padding: const EdgeInsets.only(
                            left: 20.0, right: 20.0, top: 40.0),
                        child: GestureDetector(
                          onTap: () async {
                            if(dissabled != -1){
                              if(vote != -1){
                                  if(await addVoteVotation(currentUser.value.id, widget.votation.id, vote)){
                                    Helper.nextScreen(context, home());
                                    
                                  }
                              } else {
                                setState(() {
                                  errorMessage = 'Selecciona una opción';
                                });
                              }
                            } else {
                                setState(() {
                                  errorMessage = 'Ya votaste o la votación esta cerrada,';
                                });
                              }
                          },
                          child: Container(
                            height: 50.0,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(0.0)),
                              color: Colors.greenAccent,
                            ),
                            child: Center(
                              child: Text(
                                "Votar",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 20.0,
                                    letterSpacing: 1.0),
                              ),
                            ),
                          ),
                        ),
                      ),
          ],
        ),)
      ),
    );
  }
}
 