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
  //   var request = http.MultipartRequest('POST', Uri.parse('http://192.168.1.23:5000/predict'));
  //   request.files.add(
  //     await http.MultipartFile.fromPath('file', imagePath),
  //   );
  //
  //   final response = await request.send();
  //   final responseBody = await response.stream.bytesToString();
  //
  //   if (response.statusCode != 200) {
  //     throw Exception('Server error: ${response.statusCode}');
  //   }
  //
  //   return jsonDecode(responseBody);
  // }
}

class ApiServiceImpl implements ApiService {

  ApiServiceImpl();

  @override
  Future<Map<String, dynamic>> predictDisease(String imagePath) async {
    var request = http.MultipartRequest('POST', Uri.parse('http://192.168.1.23:5000/predict'));
    request.files.add(
      await http.MultipartFile.fromPath('file', imagePath),
    );

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    if (response.statusCode != 200) {
      throw Exception('Server error: ${response.statusCode}');
    }
    print("**********************************************************");
    print(responseBody+"888888888888888888885555222456486864");
    print("**********************************************************");
    return jsonDecode(responseBody);
  }
}

