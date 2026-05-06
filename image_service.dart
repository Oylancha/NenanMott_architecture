// lib/services/image_service.dart

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../models/pixabay_image.dart';

class ImageService {
  static const String _apiKey = '';
  static const String _baseUrl = 'https://pixabay.com/api/';

  /// Searches for images on Pixabay.
  Future<List<PixabayImage>> searchImages(String query) async {
    final uri = Uri.parse(_baseUrl).replace(queryParameters: {
      'key': _apiKey,
      'q': query,
      'image_type': 'photo',
      'per_page': '50', // Get 50 results
    });

    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final hits = data['hits'] as List;
        return hits.map((hit) => PixabayImage.fromJson(hit)).toList();
      } else {
        print('Pixabay error: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error searching images: $e');
      return [];
    }
  }

  /// Downloads an image from a URL and saves it to the app's documents directory.
  Future<String?> downloadAndSaveImage(String url, String filePrefix) async {
    try {
      // 1. Download the image
      final response = await http.get(Uri.parse(url));
      if (response.statusCode != 200) {
        print('Failed to download image.');
        return null;
      }

      // 2. Get Documents Directory
      final docDir = await getApplicationDocumentsDirectory();

      // 3. Create the 'images' subdirectory
      final imagesDir = Directory(p.join(docDir.path, 'images'));
      if (!await imagesDir.exists()) {
        await imagesDir.create(recursive: true);
        print('Created images directory: ${imagesDir.path}');
      }

      // 4. Create a unique filename
      final fileExtension = p.extension(url).split('?').first; // e.g., .jpg
      final fileName =
          '${filePrefix}_${DateTime.now().millisecondsSinceEpoch}$fileExtension';
      final filePath = p.join(imagesDir.path, fileName);

      // 5. Save the file
      final file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);

      print('Image file saved permanently to: $filePath');
      return filePath; // Return the full, permanent path
    } catch (e) {
      print('Error downloading image: $e');
      return null;
    }
  }
}