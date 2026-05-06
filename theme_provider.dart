import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_themes.dart'; // We will create this in Step 2

class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'theme_is_dark';
  bool _isDarkMode = true; // Default to your current dark theme
  late SharedPreferences _prefs;

  bool get isDarkMode => _isDarkMode;
  ThemeData get themeData =>
      _isDarkMode ? AppThemes.darkTheme : AppThemes.lightTheme;

  ThemeProvider() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    _prefs = await SharedPreferences.getInstance();
    _isDarkMode = _prefs.getBool(_themeKey) ?? true; // Default to dark
    notifyListeners();
  }

  Future<void> toggleTheme(bool isDark) async {
    _isDarkMode = isDark;
    await _prefs.setBool(_themeKey, _isDarkMode);
    notifyListeners();
  }
}