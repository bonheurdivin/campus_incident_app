import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class StorageService {
  static const _cloudName = 'gadcydrh';
  static const _uploadPreset = 'campus_incidents';

  /// Uploads a photo and returns its public https URL.
  Future<String> uploadIncidentPhoto(XFile file) async {
    final uri =
        Uri.parse('https://api.cloudinary.com/v1_1/$_cloudName/image/upload');
    final bytes = await file.readAsBytes();

    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = _uploadPreset
      ..files.add(http.MultipartFile.fromBytes(
        'file',
        bytes,
        filename: file.name.isEmpty ? 'photo.jpg' : file.name,
      ));

    final response = await http.Response.fromStream(await request.send());
    if (response.statusCode != 200) {
      throw Exception('Upload failed (${response.statusCode})');
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return data['secure_url'] as String;
  }
}