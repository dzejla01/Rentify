import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:rentify_desktop/config/api_config.dart';
import 'package:rentify_desktop/helper/http_helper.dart';

class ImageAppProvider {
  ImageAppProvider._();

  static Future<String> upload({
    required File file,
    required String folder,
    int? ownerUserId,
    int? propertyId,
  }) async {
    final uri = Uri.parse('${ApiConfig.apiBase}/api/images/upload').replace(
      queryParameters: {
        'folder': folder,
        if (ownerUserId != null) 'ownerUserId': ownerUserId.toString(),
        if (propertyId != null) 'propertyId': propertyId.toString(),
      },
    );

    final request = http.MultipartRequest('POST', uri);
    request.headers.addAll(
      HttpHelper.getHeaders()..remove('Content-Type'),
    );

    request.files.add(
      await http.MultipartFile.fromPath(
        'file',
        file.path,
        filename: p.basename(file.path),
      ),
    );

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    HttpHelper.checkResponse(response);

    
    final json = jsonDecode(response.body);
    return json['fileName']; 
  }

  static Future<void> delete({
    required String folder,
    required String fileName,
    int? ownerUserId,
    int? propertyId,
  }) async {
    final uri = Uri.parse('${ApiConfig.apiBase}/api/images').replace(
      queryParameters: {
        'folder': folder,
        'fileName': fileName,
        if (ownerUserId != null) 'ownerUserId': ownerUserId.toString(),
        if (propertyId != null) 'propertyId': propertyId.toString(),
      },
    );

    final res = await http.delete(
      uri,
      headers: HttpHelper.getHeaders(),
    );

    HttpHelper.checkResponse(res);
  }
}
