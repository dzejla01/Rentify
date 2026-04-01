import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  static String apiBase = dotenv.env['API_MOBILE_LOCAL']!;
  //static String apiBase = dotenv.env['API_MOBILE_DOCKER']!; -> Postava za docker
  static String imagesUsers = "$apiBase/images/users";
  static String imagesProperties = "$apiBase/images/properties";

  static Map<String, String> imageFolders = {
    'users': imagesUsers,
    'properties': imagesProperties,
  };
}

