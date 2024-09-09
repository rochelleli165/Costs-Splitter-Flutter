import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'dart:convert';

class ReceiptData {
  ReceiptData(this.items);

  final List<Map<String,String>> items;
}

class ReceiptModel {
    final ImagePicker _picker = ImagePicker(); 
    Future<ReceiptData> pickImage() async {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        File image = File(pickedFile.path);
        return fetchReceipt(image);
        
      }
      return ReceiptData([]);
    }
    Future<ReceiptData> fetchReceipt(File image) async {
      const url = 'http://127.0.0.1:5000/receipt-scan';

      if(!image.existsSync()) {
        print('File does not exist at path: ${image.path}');
        return ReceiptData([]);
      }

      var postUri = Uri.parse(url);
      var request = http.MultipartRequest("POST", postUri);
      request.headers.addAll({
        'Content-Type': 'multipart/form-data',
      });
      final mimeType = lookupMimeType(image.path) ?? 'image/jpg';

      try {
        request.files.add(await http.MultipartFile.fromPath('image', image.path, contentType: MediaType.parse(mimeType)));

        var streamedResponse = await request.send();
        var response = await http.Response.fromStream(streamedResponse);

        print('Response code: ${response.statusCode}');
      
        var result = jsonDecode(response.body);
        
        return ReceiptData(castToListOfMap(result["result"]?["items"])); 

      } catch (e) {
        print('Error occurred: $e');
      }
      return ReceiptData([]);
    } 
}

List<Map<String, String>> castToListOfMap(dynamic items) {
  try {
    if (items is List) {
      return items.map((e) {
        if (e is Map) {
          return Map<String, String>.from(e);
        } else {
          throw Exception('Invalid item type');
        }
      }).toList();
    }
  } catch (e) {
    print('Error casting data: $e');
  }
  return [];
}