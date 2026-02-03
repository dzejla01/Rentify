import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:rentify_desktop/config/api_config.dart';

class ImageAppProvider {
  ImageAppProvider._();

  static Future<String> upload({
    required File file,
    required String folder, 
  }) async {
    final uri = Uri.parse(
      '${ApiConfig.apiBase}/api/images/upload?folder=$folder',
    );

    final request = http.MultipartRequest('POST', uri);

    request.files.add(
      await http.MultipartFile.fromPath(
        'file',
        file.path,
        filename: p.basename(file.path),
      ),
    );

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode != 200) {
      throw Exception('Upload slike nije uspio');
    }

    
    final json = jsonDecode(response.body);
    return json['fileName']; 
  }

  static Future<void> delete({
    required String folder,
    required String fileName,
  }) async {
    final uri = Uri.parse(
      '${ApiConfig.apiBase}/api/images'
      '?folder=$folder&fileName=$fileName',
    );

    final res = await http.delete(uri);

    if (res.statusCode != 200 && res.statusCode != 404) {
      throw Exception('Brisanje slike nije uspjelo');
    }
  }
}
