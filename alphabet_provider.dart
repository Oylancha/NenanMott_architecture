// lib/providers/alphabet_provider.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AlphabetProvider extends ChangeNotifier {
  static const String _alphabetKey = 'alphabet_is_cyrillic';
  bool _isCyrillic = true; // Default to Cyrillic
  late SharedPreferences _prefs;
  bool _isLoaded = false;

  AlphabetProvider() {
    _loadAlphabet();
  }

  bool get isCyrillic => _isCyrillic;
  bool get isLoaded => _isLoaded;

  Future<void> _loadAlphabet() async {
    _prefs = await SharedPreferences.getInstance();
    _isCyrillic = _prefs.getBool(_alphabetKey) ?? true; // Default to true
    _isLoaded = true;
    notifyListeners();
  }

  Future<void> setAlphabet(bool isCyrillic) async {
    if (_isCyrillic == isCyrillic) return; // No change

    _isCyrillic = isCyrillic;
    await _prefs.setBool(_alphabetKey, _isCyrillic);
    notifyListeners();
  }
}