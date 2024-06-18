import 'dart:convert';
import 'dart:io';
import 'package:cache_manager/cache_manager.dart';
import 'package:komunly/constants/constants.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'package:komunly/pages/user/login_page.dart';
import 'package:komunly/utils/helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

final dio = Dio();

Future<dynamic> refreshTokens() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    String? refreshToken = prefs.getString('refresh_token');
    String apiUrl = "$API_URL/auth/refreshTokens";

    try {
      var response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({"refreshToken": refreshToken}),
      );

      if (response.statusCode == 201) {
        var jsonResponse = json.decode(response.body);
        String accessToken = jsonResponse['access_token'];
        await prefs.setString('access_token', accessToken);
        return true;
      } else if (response.statusCode != 201) {
        await prefs.remove('access_token');
        await prefs.remove('refresh_token');
        await prefs.remove('user_id');
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
}
Future<String?> apiCallHook(String uri, Object useBody) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? accessToken = prefs.getString('access_token');
  final client = http.Client();
  final response = await client.post(Uri.parse('$API_URL/$uri/'),
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
      },
      body: json.encode(useBody));
  if (response.statusCode == 401 || response.statusCode == 400) {
    if(await refreshTokens() == false){
      return null;
    }
  }
  if (response.statusCode == 202) {
    return response.body;
  }
  return null;
}

Future<String?> apiCallHookGet(String uri) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? accessToken = prefs.getString('access_token');
  final client = http.Client();
  final response = await client.get(Uri.parse('$API_URL/$uri/'),
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
    });
  if (response.statusCode == 401 || response.statusCode == 400) {
    if(await refreshTokens() == false){
      return null;
    }
  }
  if (response.statusCode == 202) {
    return response.body;
  }
  return null;
}