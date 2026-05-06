import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  static const String _langKey = 'ui_language_code';
  Locale _locale = const Locale('ru'); // Default to Russian
  late SharedPreferences _prefs;

  LocaleProvider() {
    _loadLocale();
  }

  Locale get locale => _locale;

  // Helper for your new settings page dropdown
  String get currentLanguageName {
    switch (_locale.languageCode) {
      case 'en':
        return 'English';
      case 'ru':
      default:
        return 'Русский';
    }
  }

  Future<void> _loadLocale() async {
    _prefs = await SharedPreferences.getInstance();
    String langCode = _prefs.getString(_langKey) ?? 'ru';
    _locale = Locale(langCode);
    notifyListeners();
  }

  Future<void> setLocale(Locale newLocale) async {
    if (newLocale.languageCode == _locale.languageCode) return;
    
    _locale = newLocale;
    await _prefs.setString(_langKey, _locale.languageCode);
    notifyListeners();
  }
}
