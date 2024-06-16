
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as path;


String formatRelativeTime(String dateTimeString) {
  DateTime parsedDateTime = DateTime.parse(dateTimeString);
  DateTime now = DateTime.now();
  Duration difference = now.difference(parsedDateTime).abs();

  if (difference.inDays >= 365) {
    int years = (difference.inDays / 365).floor();
    return years == 1 ? 'hace 1 año' : 'hace $years años';
  } else if (difference.inDays >= 30) {
    int months = (difference.inDays / 30).floor();
    return months == 1 ? 'hace 1 mes' : 'hace $months meses';
  } else if (difference.inDays >= 1) {
    return 'hace ${difference.inDays} días';
  } else if (difference.inHours >= 1) {
    return 'hace ${difference.inHours} horas';
  } else if (difference.inMinutes >= 1) {
    return 'hace ${difference.inMinutes} minutos';
  } else {
    return 'hace unos segundos';
  }
}

Future<bool> checkId(userId) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? myUserId = prefs.getString('user_id');
  return myUserId == userId;
}

Future<bool> checkProfileId(userId) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? myUserId = prefs.getString('user_id');
  if (userId == null || myUserId == userId) {
    return true;
  } else {
    return false;
  }
}

bool checkExt(String filename) {
  List<String> imageExtensions = ["png", "jpg", "jpeg", "gif"];
  List<String> videoExtensions = ["mp4", "avi", "mov", "mkv"];

  String extension = path.extension(filename).toLowerCase().substring(1);
  if (imageExtensions.contains(extension)) {
    return true;
  } else if (videoExtensions.contains(extension)) {
    return false;
  } else {
    return false;
  }
}

bool checkTransference(String type, dynamic sender, String myUserId) {
  /* Si es false, soy el que manda, si es true, el que recibe */
  switch (type) {
    case "CHARGE":
      return false;
    case "DEPOSIT":
      return true;
    case "TRANSFERENCE":
      return sender != myUserId;
    default:
      return true;
  }
}


String checkUsername(String type, String senderUsername, String senderId,
    String receiverUsername, String myUserId) {
  switch (type) {
    case "CHARGE":
      return senderUsername;
    case "DEPOSIT":
      return "Komunly";
    case "TRANSFERENCE":
      return myUserId == senderId ? receiverUsername : senderUsername;
    default:
      return "Usuario no disponible";
  }
}

 
