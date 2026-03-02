class ApiConfig {
  static const String apiBase = "http://localhost:5002";
  static const String imagesUsers = "$apiBase/images/users";
  static const String imagesProperties = "$apiBase/images/properties";

  static const Map<String, String> imageFolders = {
    'users': imagesUsers,
    'properties': imagesProperties,
  };
}

