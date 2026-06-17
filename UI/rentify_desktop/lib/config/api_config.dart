import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  static String apiBase = dotenv.env['API_DESKTOP_LOCAL']!;
  //static String apiBase = dotenv.env['API_DESKTOP_DOCKER']!; 
  static  String imagesUsers = "$apiBase/images/users";
  static  String imagesProperties = "$apiBase/images/properties";

  static  Map<String, String> imageFolders = {
    'users': imagesUsers,
    'properties': imagesProperties,
  };
}

