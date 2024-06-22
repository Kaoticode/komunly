import 'package:komunly/repository/api.repository.dart';
Future<dynamic> getPosts(context, String endpoint) async {
  final response = await apiCallHookGet(context, endpoint);
  return response;
}


Future<dynamic> getMessagesChat(context) async {
  final response = await apiCallHookGet(context, 'messages/chat');
  return response;
}

Future<dynamic> getMessagesChatEndpoint(context, limit, page, endpoint) async {
  String apiUrl = "${endpoint}?page=$page&limit=$limit";
  final response = await apiCallHookGet(context, apiUrl);
  return response;
}


Future<dynamic> sendMessageChat(context, Object body) async {
  final response = await apiCallHook(context, 'messages/', body);
  return response;
}
Future<dynamic> followUserChat(context, Object body) async {
  final response = await apiCallHook(context, 'follows/', body);
  return response;
}
Future<dynamic> sendFollowRequestChat(context, Object body) async {
  final response = await apiCallHook(context, 'follows/request/', body);
  return response;
}

Future<dynamic> blockUser(context, Object body) async {
  final response = await apiCallHook(context, 'blocks/', body);
  return response;
}

Future<dynamic> createEvent(context, Object body) async {
  final response = await apiCallHook(context, 'events/', body);
  return response;
}
Future<dynamic> userStorieViewed(context, String uri, Object body) async {
  final response = await apiCallHook(context, uri, body);
  return response;
}


Future<dynamic> resStorie(context, Object body) async {
  final response = await apiCallHook(context, 'messages/', body);
  return response;
}

