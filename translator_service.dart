import 'dart:convert';
import 'package:http/http.dart' as http;

class TranslatorService {
  // 1. We removed the plain-text _apiKey
  // 2. Paste the "Obfuscated Key" from Step 1 here
  static const String _encryptedKey = 'WV9jYjAtQjRCMWpJSjRWMzdUdzc3VEl2UENKUTF5c0pEeVNheklB';

  // 3. This 'late final' variable will call _revealKey() the first time
  //    _apiKey is accessed, and then cache the result.
  static late final String _apiKey = _revealKey();

  // 4. This function reverses the process from Step 1
  static String _revealKey() {
    try {
      final decodedKey = utf8.decode(base64.decode(_encryptedKey));
      final realKey = decodedKey.split('').reversed.join('');
      return realKey;
    } catch (e) {
      print('Error decoding API key: $e');
      return 'DECODING_ERROR'; // Fail safe
    }
  }
  
  static const String _baseUrl =
      'https://translation.googleapis.com/language/translate/v2';

  /// Translates text from source language to target language
  ///
  /// [text] - The text to translate
  /// [targetLanguage] - Target language code (e.g., 'ce' for Chechen, 'ru' for Russian)
  /// [sourceLanguage] - Source language code (optional, auto-detect if null)
  Future<TranslationResult> translate({
    required String text,
    required String targetLanguage,
    String? sourceLanguage,
  }) async {
    // API Key Check
    if (_apiKey == 'YOUR_GOOGLE_TRANSLATE_API_KEY') {
      return TranslationResult(
        translatedText: '',
        sourceLanguage: sourceLanguage ?? 'unknown',
        targetLanguage: targetLanguage,
        isSuccess: false,
        errorMessage:
            'Please add your Google Translate API key to translator_service.dart (line 12)',
      );
    }

    try {
      final uri = Uri.parse(_baseUrl).replace(queryParameters: {
        'key': _apiKey,
        'q': text,
        'target': targetLanguage,
        if (sourceLanguage != null) 'source': sourceLanguage,
      });

      final response = await http.post(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final translatedText =
            data['data']['translations'][0]['translatedText'] as String;
        final detectedLanguage =
            data['data']['translations'][0]['detectedSourceLanguage'] as String?;

        return TranslationResult(
          translatedText: translatedText,
          sourceLanguage: sourceLanguage ?? detectedLanguage ?? 'unknown',
          targetLanguage: targetLanguage,
          isSuccess: true,
        );
      } else {
        // Handle specific API errors
        final data = json.decode(response.body);
        String message = 'Translation failed: ${response.statusCode}';
        if (data['error'] != null && data['error']['message'] != null) {
          message = 'Error: ${data['error']['message']}';
        }
        return TranslationResult(
          translatedText: '',
          sourceLanguage: sourceLanguage ?? 'unknown',
          targetLanguage: targetLanguage,
          isSuccess: false,
          errorMessage: message,
        );
      }
    } catch (e) {
      return TranslationResult(
        translatedText: '',
        sourceLanguage: sourceLanguage ?? 'unknown',
        targetLanguage: targetLanguage,
        isSuccess: false,
        errorMessage: 'Error: $e',
      );
    }
  }

  /// Gets a list of supported languages
  Future<List<LanguageInfo>> getSupportedLanguages() async {
    // API Key Check
    if (_apiKey == 'YOUR_GOOGLE_TRANSLATE_API_KEY') {
      return _getDefaultLanguages();
    }

    try {
      final uri = Uri.parse('$_baseUrl/languages').replace(queryParameters: {
        'key': _apiKey,
        'target': 'en', // Get language names in English
      });

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final languages = data['data']['languages'] as List;

        return languages
            .map((lang) => LanguageInfo(
                  code: lang['language'] as String,
                  name: lang['name'] as String,
                ))
            .toList();
      }
    } catch (e) {
      print('Error fetching languages: $e');
    }

    // Return default languages if API call fails
    return _getDefaultLanguages();
  }

  List<LanguageInfo> _getDefaultLanguages() {
    return [
      LanguageInfo(code: 'ce', name: 'Chechen'),
      LanguageInfo(code: 'ru', name: 'Russian'),
      LanguageInfo(code: 'en', name: 'English'),
      LanguageInfo(code: 'ar', name: 'Arabic'),
      LanguageInfo(code: 'tr', name: 'Turkish'),
    ];
  }
}

class TranslationResult {
  final String translatedText;
  final String sourceLanguage;
  final String targetLanguage;
  final bool isSuccess;
  final String? errorMessage;

  TranslationResult({
    required this.translatedText,
    required this.sourceLanguage,
    required this.targetLanguage,
    required this.isSuccess,
    this.errorMessage,
  });
}

class LanguageInfo {
  final String code;
  final String name;

  LanguageInfo({
    required this.code,
    required this.name,
  });
}
