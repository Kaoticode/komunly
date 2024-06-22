import 'dart:convert';
import 'dart:io';
import 'package:komunly/constants/constants.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'package:komunly/pages/user/login_page.dart';
import 'package:komunly/utils/helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

final dio = Dio();

Future<dynamic> refreshTokens(context) async {
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
        Helper.nextScreen(context, LoginPage());
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
}
Future<dynamic> apiCallHook(dynamic context, String uri, Object useBody) async {
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
  if(uri != 'auth/login'){
    if (response.statusCode == 401 || response.statusCode == 400) {
      if(await refreshTokens(context) == false){
        return false;
      }
    }
  }
  return response;
}

Future<dynamic> apiCallHookGet(dynamic context, String uri) async {
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
    if(await refreshTokens(context) == false){
      return false;
    }
  }
  return response;
}