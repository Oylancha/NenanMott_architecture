// lib/services/tts_service.dart

import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'dart:convert';
import 'dart:typed_data';

class TtsService {
  static const String _serverUrl =
      'https://islamvuso-jilma-mott.hf.space/generate-tts/';

  /// --- NEW FUNCTION ---
  /// Fetches TTS audio as raw bytes without saving.
  Future<Uint8List?> getTtsAudioBytes(String text) async {
    try {
      print('Sending request to TTS server for bytes with text: $text');

      final response = await http.post(
        Uri.parse(_serverUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        // --- 1. MODIFIED: Added 'format': 'mp3' ---
        body: json.encode({'text': text, 'format': 'mp3'}),
      );

      if (response.statusCode == 200) {
        print('Audio bytes received from server.');
        return response.bodyBytes;
      } else {
        print('Server error: ${response.statusCode}');
        print('Response body: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error calling TTS service: $e');
      return null;
    }
  }
  /// --- END OF NEW FUNCTION ---

  Future<String?> getTtsAudio(String text) async {
    try {
      print('Sending request to TTS server with text: $text');

      final response = await http.post(
        Uri.parse(_serverUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        // --- 2. MODIFIED: Added 'format': 'mp3' ---
        body: json.encode({'text': text, 'format': 'mp3'}),
      );

      if (response.statusCode == 200) {
        print('Audio received from server.');

        final tempDir = await getTemporaryDirectory();
        
        // --- 3. MODIFIED: Changed .wav to .mp3 ---
        final fileName = 'tts_${DateTime.now().millisecondsSinceEpoch}.mp3';
        final filePath = '${tempDir.path}/$fileName';
        // --- END OF FIX ---

        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);

        print('Audio file saved to: $filePath');
        return filePath;
      } else {
        print('Server error: ${response.statusCode}');
        print('Response body: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error calling TTS service: $e');
      return null;
    }
  }

  Future<String?> generateAndSaveTtsAudio(
      String text, String filePrefix) async {
    try {
      print('Sending request to TTS server for permanent save: $text');

      final response = await http.post(
        Uri.parse(_serverUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        // --- 4. MODIFIED: Added 'format': 'mp3' ---
        body: json.encode({'text': text, 'format': 'mp3'}),
      );

      if (response.statusCode == 200) {
        print('Audio received from server.');

        // 1. Get Documents Directory (permanent)
        final docDir = await getApplicationDocumentsDirectory();

        // 2. Create the 'sentences_audio' subdirectory
        final audioDir = Directory(p.join(docDir.path, 'sentences_audio'));
        if (!await audioDir.exists()) {
          await audioDir.create(recursive: true);
          print('Created audio directory: ${audioDir.path}');
        }

        // --- 5. MODIFIED: Changed .wav to .mp3 ---
        final fileName = '${filePrefix}_${DateTime.now().millisecondsSinceEpoch}.mp3';
        final filePath = p.join(audioDir.path, fileName);

        // 4. Save the file
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);

        print('Audio file saved permanently to: $filePath');
        return filePath; // Return the full, permanent path
      } else {
        print('Server error: ${response.statusCode}');
        print('Response body: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error calling TTS service: $e');
      return null;
    }
  }
}