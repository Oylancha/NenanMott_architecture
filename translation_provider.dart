// lib/providers/translation_provider.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 1. ADD NEW LANGUAGES TO THE ENUM
enum TranslationTarget { russian, english, french, german, turkish, arabic }

class TranslationProvider extends ChangeNotifier {
  static const String _langKey = 'translation_target';
  TranslationTarget _target = TranslationTarget.russian;
  late SharedPreferences _prefs;

  TranslationProvider() {
    _loadLanguage();
  }

  TranslationTarget get currentTarget => _target;
  
  // 2. UPDATE THE HELPER
  String get currentTargetName {
    switch (_target) {
      case TranslationTarget.english:
        return 'English';
      case TranslationTarget.french:
        return 'Français';
      case TranslationTarget.german:
        return 'Deutsch';
      case TranslationTarget.turkish:
        return 'Türkçe'; // <-- ADD
      case TranslationTarget.arabic:
        return 'العربية'; // <-- ADD
      case TranslationTarget.russian:
      default:
        return 'Русский';
    }
  }

  Future<void> _loadLanguage() async {
    _prefs = await SharedPreferences.getInstance();
    int targetIndex = _prefs.getInt(_langKey) ?? 0;
    // Ensure index is valid, otherwise default to 0 (Russian)
    if (targetIndex >= 0 && targetIndex < TranslationTarget.values.length) {
      _target = TranslationTarget.values[targetIndex];
    } else {
      _target = TranslationTarget.russian;
    }
    notifyListeners();
  }

  Future<void> setLanguage(TranslationTarget newTarget) async {
    _target = newTarget;
    await _prefs.setInt(_langKey, _target.index);
    notifyListeners();
  }
}