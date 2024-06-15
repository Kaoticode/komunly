import 'dart:convert';
import 'dart:io';
// ignore: depend_on_referenced_packages
import 'package:crypto/models/entities.model.dart';
import 'package:crypto/models/user.model.dart';
import 'package:crypto/repository/api.repository.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'package:cache_manager/cache_manager.dart';

Future<bool> getEntitie(String id) async {
  var session = await ReadCache.getString(key: 'session') ?? '';
  if (session != '') {
    final response = await apiCallHook('entities/get', {'id': id});
    if (response != null) {
      if (json.decode(response) == null) {
        return false;
      } else {
        
      }
      return true;
    }
  }
  return false;
}

Future<bool> getMyEntities(List<String> entities) async {
  var session = await ReadCache.getString(key: 'session') ?? '';
  if (session != '') {
    final response = await apiCallHook('entities/getmyentities', {'entities': entities});
    if (response != null) {
      if (json.decode(response) == null) {
        return false;
      } else {
        List<dynamic> entitiesCast = json.decode(response)['entities'] ?? [];
        List<EntitieModel> dynamicEntities = [];
        if(entitiesCast.isNotEmpty){
          for(var i = 0; i<entitiesCast.length; i++){
            dynamicEntities.add(EntitieModel.fromJSON(entitiesCast[i]));
          }
          currentEntities.value = dynamicEntities.map((e) => e).toList();
        }
        
      }
      return true;
    }
  }
  return false;
}