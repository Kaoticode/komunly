import 'dart:convert';
import 'dart:io';
import 'package:cache_manager/cache_manager.dart';
import 'package:crypto/utils/constants.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
final dio = Dio();
Future<String?> apiCallHook(String uri, Object useBody) async {
  var session = await ReadCache.getString(key: 'session') ?? '';
  final client = http.Client();
  print(useBody);
  final response = await client.post(Uri.parse('$baseUrl/$uri/'),
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        "authorization": 'authKey',
        "Cookie": 'access_token=$session'
      },
      body: json.encode(useBody));
  if (response.statusCode == 202) {
    return response.body;
  }
  return null;
}