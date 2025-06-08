import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

abstract class ImagePickerService {
  Future<XFile?> pickImageFromGallery();
}

class ImagePickerServiceImpl implements ImagePickerService {
  final ImagePicker _picker = ImagePicker();

  @override
  Future<XFile?> pickImageFromGallery() async {
    return await _picker.pickImage(source: ImageSource.gallery);
  }
}

abstract class ApiService {
  Future<Map<String, dynamic>> predictDisease(String imagePath);
}

class ApiServiceImpl implements ApiService {
  final String apiUrl;

  ApiServiceImpl(this.apiUrl);

  @override
  Future<Map<String, dynamic>> predictDisease(String imagePath) async {
    var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
    request.files.add(
      await http.MultipartFile.fromPath('file', imagePath),
    );

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    if (response.statusCode != 200) {
      throw Exception('Server error: ${response.statusCode}');
    }

    return jsonDecode(responseBody);
  }
}