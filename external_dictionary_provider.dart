// lib/providers/external_dictionary_provider.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/external_word_model.dart';

class ExternalDictionaryProvider extends ChangeNotifier {
  List<ExternalWord> _allWords = [];
  bool _isLoading = true;

  // 1. ADD EMPTY CONSTRUCTOR
  ExternalDictionaryProvider();

  bool get isLoading => _isLoading;
  int get wordCount => _allWords.length;

  Future<void> loadWords() async {
    _isLoading = true;
    notifyListeners();

    try {
      final String jsonString =
          await rootBundle.loadString('assets/external_dictionary.json');
      final List<dynamic> jsonList = json.decode(jsonString);

      _allWords =
          jsonList.map((json) => ExternalWord.fromJson(json)).toList();

      _allWords.sort((a, b) =>
          a.chechen.toLowerCase().compareTo(b.chechen.toLowerCase()));

      print('Loaded ${_allWords.length} words from external dictionary.');
    } catch (e) {
      print('Error loading external dictionary: $e');
      _allWords = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  // 2. UPDATE SEARCH FILTER
  List<ExternalWord> getFilteredWords(String query) {
    if (query.isEmpty) {
      return _allWords;
    }
    final lowerQuery = query.toLowerCase();
    return _allWords.where((word) {
      return word.getTerm(true).toLowerCase().contains(lowerQuery) || // Cyrillic
          word.getTerm(false).toLowerCase().contains(lowerQuery) || // Latin
          word.russian.toLowerCase().contains(lowerQuery) ||
          (word.english ?? '').toLowerCase().contains(lowerQuery) ||
          (word.french ?? '').toLowerCase().contains(lowerQuery) ||
          (word.german ?? '').toLowerCase().contains(lowerQuery) ||
          (word.turkish ?? '').toLowerCase().contains(lowerQuery) || // <-- ADD
          (word.arabic ?? '').toLowerCase().contains(lowerQuery);   // <-- ADD
    }).toList();
  }
}