import 'package:komunly/repository/api.repository.dart';
Future<dynamic> getPosts(limit, page, endpoint) async {
  
    String apiUrl = "${endpoint}?limit=$limit&page=$page";
    final response = await apiCallHookGet(apiUrl);
    if (response != null) {
        
        /*await WriteCache.setString(
        key: 'session', value: accessToken);
        currentUser.value = UserModel.fromJSON(json.decode(response)['user']);*/ 
        // NEecesito los cambios de backend para que en el front no exista ni el access ni el refresh token
        return response;
      } else {
        return null;
      }
}