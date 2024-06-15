// ignore_for_file: non_constant_identifier_names
import 'package:flutter/cupertino.dart';

ValueNotifier<List<VotationModel>> currentVotations = ValueNotifier(<VotationModel>[]);


class VotationModel {
  late String id = '';
  late String image;
  late String title;
  late String description;
  late List<String> options;
  late DateTime timeStart;
  late DateTime timeEnd;
  late List<VoteModel> votes;
  late String from_id;
  VotationModel();
  VotationModel.fromJSON(Map<String, dynamic> jsonMap) {
    try {
      id = jsonMap['_id'] ?? '';
      
      image = jsonMap['image'] ?? '';
      title = jsonMap['title'] ?? '';
      description = jsonMap['description'] ?? '';
      options = List<String>.from(jsonMap['options'] ?? []);
      List<dynamic> rss = jsonMap['votes'] ?? [];
      votes = [...rss.map((e) => VoteModel.fromJSON(e))];
      timeStart = DateTime.parse(jsonMap['timeStart'] ?? '') ?? DateTime.now();
      timeEnd = DateTime.parse(jsonMap['timeEnd'] ?? '') ?? DateTime.now();
      from_id = jsonMap['from_id'] ?? '';

    } catch (value) {}
  }
}

class VoteModel {
  late String from_id;
  late int value;
  VoteModel();
  VoteModel.fromJSON(Map<String, dynamic> jsonMap) {
    try {

      from_id = jsonMap['from_id'] ?? '';
      value = jsonMap['value'] ?? 0;
      

    } catch (value) {}
  }
}