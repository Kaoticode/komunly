// ignore_for_file: non_constant_identifier_names

import 'package:flutter/cupertino.dart';

enum UserState { available, away, busy }

ValueNotifier<UserModel> currentUser = ValueNotifier(UserModel());

class UserModel {
  late String id = '';
  late String fullname = '';
  late String email = '';
  late String password = '';
  late String nie = '';
  
//  String role;

  UserModel();

  UserModel.fromJSON(Map<String, dynamic> jsonMap) {
    try {
      id = jsonMap['_id'] ?? '';
      
      fullname = jsonMap['fullname'] ?? 'Complete';
      email = jsonMap['email'] ?? '';
      password = jsonMap['password'] ?? '';
      nie = jsonMap['nie'] ?? '';
    } catch (value) {}
  }
}

