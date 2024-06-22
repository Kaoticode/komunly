import 'dart:convert';
import 'package:komunly/models/user.model.dart';
import 'package:komunly/repository/api.repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
Future<dynamic> createUser(context, username, password, email) async {
    final response = await apiCallHook(context, 'auth/register', {
          'username': username,
          'password': password,
          'email': email
    });
    return response;
}
Future<dynamic> loginUser(context, username, password) async {
    final response = await apiCallHook(context, 'auth/login', {
          'username': username,
          'password': password,
    });
    if (response.statusCode == 201) {
        var jsonResponse = json.decode(response!);
        String accessToken = jsonResponse['access_token'];
        String refreshToken = jsonResponse['refresh_token'];
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String userId = jsonResponse['user_id'];
        await prefs.setString('user_id', userId);
        await prefs.setString('access_token', accessToken);
        await prefs.setString('refresh_token', refreshToken);
        currentUser.value = UserModel.fromJSON(jsonResponse);
    } 
    return response;
}
Future<dynamic> getUserNotifications(context, String uri) async {
  final response = await apiCallHookGet(context, uri);
  return response;
}
Future<dynamic> getUserBalance(context) async {
  final response = await apiCallHookGet(context, '/users/getBalance');
  return response;
}
Future<dynamic> updateUserBalance(context, Object body) async {
  final response = await apiCallHook(context, '/transactions', body);
  return response;
}
Future<dynamic> getUserTransactions(context, String uri) async {
  final response = await apiCallHookGet(context, uri);
  return response;
}