import 'dart:convert';
import 'dart:io';
// ignore: depend_on_referenced_packages
import 'package:crypto/models/user.model.dart';
import 'package:crypto/repository/api.repository.dart';
import 'package:crypto/repository/entities.repository.dart';
import 'package:crypto/screen/home/home.dart';
import 'package:crypto/utils/helper.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'package:cache_manager/cache_manager.dart';

final dio = Dio();
const String authorizationKey = 'authKey';


Future<void> verifySession(context) async {
  
  if (await getUser()) {
    Helper.nextScreen(context, home());
  }
}
Future<bool> sendLogin(Object useBody) async {
  final response = await apiCallHook('user/login', useBody);
  if (response != null) {
    await WriteCache.setString(
        key: 'session', value: json.decode(response)['token']);
        currentUser.value = UserModel.fromJSON(json.decode(response)['user']);
    
    return true;
  }
  return false;
}
Future<bool> createUser(Map<String, dynamic> useBody) async {
  final response = await apiCallHook('user/create', useBody);
  if (response != null) {
    await sendLogin({'dni': useBody['dni'], 'password': useBody['password'] });
    return true;
  }
  return false;
}
Future<bool> getUser() async {
  
    final response = await apiCallHook('user/get', {});
    if (response != null) {
      if (json.decode(response)['user'] == null) {
        DeleteCache.deleteKey('session');
        return false;
      } else {
        await getMyEntities(List<String>.from(json.decode(response)['entities']));
        currentUser.value = UserModel.fromJSON(
            json.decode(response) != null
                ? json.decode(response)['user']
                : '');
      }
      return true;
    }
  
  return false;
}
/*
Future<bool> updateAddress(Object useBody) async {
  var session = await ReadCache.getString(key: 'session') ?? '';
  if (session != '') {
    final client = http.Client();
    final response = await client.post(
      Uri.parse('$baseUrl/user/update/direction'),
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.acceptHeader: 'application/json',
        "Cookie": 'access_token=$session',
        "authorization": authorizationKey,
      },
      body: json.encode(useBody),
    );
    if (response.statusCode == 202) {
      getUser(false);
      return true;
    }
  }
  return false;
}



Future<bool> updateProfile(Object useBody) async {
  var session = await ReadCache.getString(key: 'session') ?? '';
  if (session != '') {
    final client = http.Client();
    http.Response response = await client.post(
      Uri.parse('$baseUrl/user/update/profile'),
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.acceptHeader: 'application/json',
        "Cookie": 'access_token=$session',
        "authorization": authorizationKey,
      },
      body: json.encode(useBody),
    );
    print(response.body);
    if (response.statusCode == 202) {
      getUser(false);
      return true;
    }
  }
  return false;
}

Future<bool> scanToDataBase(dynamic useBody) async {
  try {
    var session = await ReadCache.getString(key: 'session') ?? '';
    if (session != '') {
      final client = http.Client();
      print(session);
      http.Response response = await client.post(
        Uri.parse('$baseUrl/user/update/scan'),
        headers:{
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.acceptHeader: 'application/json',

          "Cookie": 'access_token=$session',
          "authorization": authorizationKey,
        },
        body: json.encode(useBody),
      );
      print(response.body);
      if (response.statusCode == 202) {
        return true;
      }
    }
  } catch (e) {
    print(e);
    return false;
  }
  return false;
}

Future scanReadyDates(Object useBody) async {
  var session = await ReadCache.getString(key: 'session') ?? '';
  if (session != '') {
    final client = http.Client();
    final response = await client.post(
      Uri.parse('$baseUrl/user/update/dates'),
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.acceptHeader: 'application/json',
        "Cookie": 'access_token=$session',
        "authorization": authorizationKey,
      },
      body: json.encode(useBody),
    );
    if (response.statusCode == 202) {
      return true;
    }
  }
  return false;
}

Future<bool> resetPassword(Object useBody) async {
  var session = await ReadCache.getString(key: 'session') ?? '';

  final client = http.Client();
  final response = await client.post(
    Uri.parse('$baseUrl/user/resetpassword'),
    headers: {
      HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.acceptHeader: 'application/json',
      "Cookie": 'access_token=$session',
      "authorization": authorizationKey,
    },
    body: json.encode(useBody),
  );
  print(response.body);
  if (response.statusCode == 202) {
    return true;
  }

  return false;
}



Future updatePassword(Object useBody, context) async {
  var session = await ReadCache.getString(key: 'session') ?? '';
  if (session != '') {
    final client = http.Client();
    final response = await client.post(
      Uri.parse('$baseUrl/user/update/password'),
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.acceptHeader: 'application/json',
        "Cookie": 'access_token=$session',
        "authorization": authorizationKey,
      },
      body: json.encode(useBody),
    );
    if (response.statusCode == 202) {
      DeleteCache.deleteKey('session');
      Helper.nextScreen(context, Login());
      if (currentBooking.value.isNotEmpty) {
        for (var i = 0; i < currentBooking.value.length; i++) {
          currentBooking.value.removeAt(i);
        }
      }
      if (currentAllBookings.value.isNotEmpty) {
        for (var i = 0; i < currentAllBookings.value.length; i++) {
          currentAllBookings.value.removeAt(i);
        }
      }
      return true;
    }
  }
  return false;
}
*/