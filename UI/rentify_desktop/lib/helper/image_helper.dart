import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:rentify_desktop/config/api_config.dart';
class ImageHelper {

  static final ImagePicker _picker = ImagePicker();

  /// Otvara image picker i vraća File ili null
  static Future<File?> openImagePicker({
    ImageSource source = ImageSource.gallery,
    int imageQuality = 85,
  }) async {
    final XFile? picked = await _picker.pickImage(
      source: source,
      imageQuality: imageQuality,
    );

    if (picked == null) return null;

    return File(picked.path);
  }

  static String httpCheck(String imagePath) {
    if (imagePath.isEmpty) {
      return '${ApiConfig.imagesUsers}/default.png';
    }

    if (imagePath.startsWith('http')) {
      return imagePath;
    }

    return '${ApiConfig.imagesUsers}/$imagePath';
  }

  static bool isHttp(String imagePath) {
    
    if (imagePath.startsWith('http')) {
      return true;
    }

    return false;
  }
}
