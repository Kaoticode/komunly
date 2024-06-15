// ignore_for_file: non_constant_identifier_names

import 'package:flutter/cupertino.dart';

enum UserState { available, away, busy }

ValueNotifier<List<EntitieModel>> currentEntities = ValueNotifier(<EntitieModel>[]);

class EntitieModel {
  late String id = '';
  late int type = 0;
  late String fullname = '';
  late List<String> nies = [];

  EntitieModel();
  EntitieModel.fromJSON(Map<String, dynamic> jsonMap) {
    try {
      id = jsonMap['_id'] ?? '';
      fullname = jsonMap['fullname'] ?? '';
      type = jsonMap['type'] ?? 0;
      nies = List<String>.from(jsonMap['nies'] ?? []);
    } catch (value) {}
  }
}




class VoteModel {
  late String from_id = '';
  late String value = '';
  
//  String role;

  VoteModel();

  VoteModel.fromJSON(Map<String, dynamic> jsonMap) {
    try {
      
      from_id = jsonMap['from_id'] ?? '';
      value = jsonMap['value'] ?? '';
    } catch (value) {}
  }
}
