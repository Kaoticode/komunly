import 'dart:convert';
import 'package:komunly/repository/api.repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> verifySession(context) async {
  
  /*if (await getUser()) {
    //Helper.nextScreen(context, home());
  }*/
}
Future<bool> getUser(id) async {
  
    final response = await apiCallHook('auth/login', {
    });
    if (response != null) {
        
        /*await WriteCache.setString(
        key: 'session', value: accessToken);
        currentUser.value = UserModel.fromJSON(json.decode(response)['user']);*/ 
        // NEecesito los cambios de backend para que en el front no exista ni el access ni el refresh token
        return true;
      } else {
        return false;
      }
  
}

Future<dynamic> createUser(username, password, email) async {
  
    final response = await apiCallHook('auth/register', {
          'username': username,
          'password': password,
          'email': email
    });
    if (response != null) {
        
        return response;
      } else {
        return null;
      }
  
}
Future<bool> loginUser(username, password) async {
  
    final response = await apiCallHook('auth/login', {
          'username': username,
          'password': password,
    });
    if (response != null) {
        var jsonResponse = json.decode(response);
        String userId = jsonResponse['user_id'];
        String accessToken = jsonResponse['access_token'];
        String refreshToken = jsonResponse['refresh_token'];
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_id', userId);
        await prefs.setString('access_token', accessToken);
        await prefs.setString('refresh_token', refreshToken);
        return true;
      } else {
        return false;
      }
  
}