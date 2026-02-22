class ApiConfig {
  static const String apiBase = "http://192.168.1.196:5103";
  static const String imagesUsers = "$apiBase/images/users";
  static const String imagesProperties = "$apiBase/images/properties";

  static const Map<String, String> imageFolders = {
    'users': imagesUsers,
    'properties': imagesProperties,
  };
}

