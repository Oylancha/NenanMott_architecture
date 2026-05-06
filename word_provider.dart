// lib/providers/word_provider.dart

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';
import '../models/word_model.dart';
import '../services/database_helper.dart';
import '../services/srs_service.dart';
import 'package:provider/provider.dart'; 
import 'translation_provider.dart';

class WordProvider extends ChangeNotifier {
  List<Word> _allWords = [];
  List<Word> _currentSessionWords = [];
  int _currentIndex = 0; 
  bool _showTranslation = false;
  bool _isLoading = true;
  AnswerMode _answerMode = AnswerMode.flashcard;
  String _userAnswer = '';
  List<String> _multipleChoiceOptions = [];
  final player = AudioPlayer();
  bool _showAllCategories = true;
  int _wordsMemorizedInSession = 0;
  int _currentStreak = 0;
  int _bestStreak = 0;

  // --- NEW STATE VARIABLES ---
  int _attemptsMade = 0;
  int _hintsUsed = 0;
  static const int maxAttempts = 3;
  static const int maxHints = 3;
  // ---------------------------

  int _sessionTotalCount = 0;
  final SpacedRepetitionService _srsService = SpacedRepetitionService();

  StudyMode _studyMode = StudyMode.none;
  StudyMode get studyMode => _studyMode;

  List<Word> get allWords => _allWords;
  List<Word> get currentSessionWords => _currentSessionWords;
  int get currentIndex => _currentIndex;
  bool get showTranslation => _showTranslation;
  bool get isLoading => _isLoading;
  AnswerMode get answerMode => _answerMode;
  String get userAnswer => _userAnswer;
  List<String> get multipleChoiceOptions => _multipleChoiceOptions;
  bool get showAllCategories => _showAllCategories;
  int get wordsMemorizedInSession => _wordsMemorizedInSession;
  int get currentStreak => _currentStreak;
  int get bestStreak => _bestStreak;

  // --- NEW GETTERS ---
  int get attemptsMade => _attemptsMade;
  int get hintsUsed => _hintsUsed;
  int get remainingAttempts => maxAttempts - _attemptsMade;
  // -------------------

  int _dailyNewWordsLimit = 10;
  int _dailyReviewLimit = 20;
  int _todayNewWordsLearned = 0;
  int _todayWordsReviewed = 0;
  String _lastStudyDate = '';

  int get dailyNewWordsLimit => _dailyNewWordsLimit;
  int get dailyReviewLimit => _dailyReviewLimit;
  int get todayNewWordsLearned => _todayNewWordsLearned;
  int get todayWordsReviewed => _todayWordsReviewed;
  bool get reachedNewWordsLimit => _todayNewWordsLearned >= _dailyNewWordsLimit;
  bool get reachedReviewLimit => _todayWordsReviewed >= _dailyReviewLimit;

  String getCorrectTranslation(Word word, TranslationTarget target) {
    switch (target) {
      case TranslationTarget.english:
        return word.english ?? word.russian;
      case TranslationTarget.french:
        return word.french ?? word.russian;
      case TranslationTarget.german:
        return word.german ?? word.russian;
      case TranslationTarget.turkish:
        return word.turkish ?? word.russian;
      case TranslationTarget.arabic:
        return word.arabic ?? word.russian;
      case TranslationTarget.russian:
      default:
        return word.russian;
    }
  }

  Word? get currentWord {
    if (_currentSessionWords.isEmpty) return null;
    if (_studyMode == StudyMode.browsing) {
      if (_currentIndex >= _currentSessionWords.length) return null;
      return _currentSessionWords[_currentIndex];
    }
    return _currentSessionWords[0];
  }

  // ... (Stats getters remain unchanged: totalInSession, remainingInSession, etc.)
  int get totalInSession => _sessionTotalCount;
  int get remainingInSession => _currentSessionWords.length;

  int get completedInSession {
    if (_studyMode == StudyMode.browsing) return _currentIndex;
    return _sessionTotalCount - _currentSessionWords.length;
  }

  int get totalWordsLearned => _allWords
      .where((w) =>
          (w.state == WordState.reviewing || w.state == WordState.learned) &&
          !w.markedAsKnown)
      .length;

  int get masteredWords => _allWords
      .where((w) => w.state == WordState.learned && !w.markedAsKnown)
      .length;

  int get learningNowCount =>
      _allWords.where((w) => w.state == WordState.learning).length;

  int get alreadyKnownWords =>
      _allWords.where((w) => w.markedAsKnown).length;

  int get reviewedWordsTotal =>
      _allWords.where((w) => w.correctCount > 0).length;

  Map<DateTime, int> getWordsLearnedByDay(int days) {
    final Map<DateTime, int> stats = {};
    final now = DateTime.now();
    for (int i = 0; i < days; i++) {
      final day =
          DateTime(now.year, now.month, now.day).subtract(Duration(days: i));
      stats[day] = 0;
    }
    return stats;
  }

  Set<String> _selectedCategories = {};
  Set<String> get selectedCategories => _selectedCategories;

  List<String> get allCategories {
    final categories = _allWords.map((w) => w.category).toSet().toList();
    categories.sort();
    return categories;
  }

  // ... (Category methods toggleCategory, selectAllCategories, clearAllCategories, _matchesSelectedCategories remain unchanged)
  void toggleCategory(String category) {
    _showAllCategories = false;
    if (_selectedCategories.contains(category)) {
      _selectedCategories.remove(category);
    } else {
      _selectedCategories.add(category);
    }
    if (_selectedCategories.length == allCategories.length) {
      _showAllCategories = true;
      _selectedCategories.clear();
    }
    saveSelectedCategories();
    notifyListeners();
  }

  void selectAllCategories() {
    _showAllCategories = true;
    _selectedCategories.clear();
    saveSelectedCategories();
    notifyListeners();
  }

  void clearAllCategories() {
    _showAllCategories = false;
    _selectedCategories.clear();
    saveSelectedCategories();
    notifyListeners();
  }

  bool _matchesSelectedCategories(Word word) {
    if (_showAllCategories) return true;
    if (_selectedCategories.isEmpty) return false;
    return _selectedCategories.contains(word.category);
  }

  // ... (Streak and Progress methods updateStreak, loadDailyProgress, saveSelectedCategories, saveDailyProgress, setDailyLimits, increment... remain unchanged)
  Future<void> updateStreak() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toString().split(' ')[0];
    final lastActiveDate = prefs.getString('last_active_date') ?? '';

    if (lastActiveDate != today) {
      final yesterday =
          DateTime.now().subtract(Duration(days: 1)).toString().split(' ')[0];

      if (lastActiveDate == yesterday) {
        _currentStreak++;
        await prefs.setInt('current_streak', _currentStreak);
        if (_currentStreak > _bestStreak) {
          _bestStreak = _currentStreak;
          await prefs.setInt('best_streak', _bestStreak);
        }
      } else if (lastActiveDate.isNotEmpty) {
        _currentStreak = 1;
        await prefs.setInt('current_streak', 1);
      } else {
        _currentStreak = 1;
        _bestStreak = 1;
        await prefs.setInt('current_streak', 1);
        await prefs.setInt('best_streak', 1);
      }
      await prefs.setString('last_active_date', today);
    }
    notifyListeners();
  }

  Future<void> loadDailyProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toString().split(' ')[0];

    _lastStudyDate = prefs.getString('last_study_date') ?? '';
    _dailyNewWordsLimit = prefs.getInt('daily_new_words_limit') ?? 10;
    _dailyReviewLimit = prefs.getInt('daily_review_limit') ?? 20;
    _currentStreak = prefs.getInt('current_streak') ?? 0;
    _bestStreak = prefs.getInt('best_streak') ?? 0;
    _showAllCategories = prefs.getBool('show_all_categories') ?? true;
    final categoriesJson = prefs.getStringList('selected_categories');
    _selectedCategories = categoriesJson?.toSet() ?? {};

    if (_lastStudyDate != today) {
      _todayNewWordsLearned = 0;
      _todayWordsReviewed = 0;
      _lastStudyDate = today;
      await prefs.setString('last_study_date', today);
      await prefs.setInt('today_new_words', 0);
      await prefs.setInt('today_reviewed', 0);
    } else {
      _todayNewWordsLearned = prefs.getInt('today_new_words') ?? 0;
      _todayWordsReviewed = prefs.getInt('today_reviewed') ?? 0;
    }
    notifyListeners();
  }

  Future<void> saveSelectedCategories() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('show_all_categories', _showAllCategories);
    await prefs.setStringList(
        'selected_categories', _selectedCategories.toList());
  }

  Future<void> saveDailyProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('today_new_words', _todayNewWordsLearned);
    await prefs.setInt('today_reviewed', _todayWordsReviewed);
  }

  Future<void> setDailyLimits(int newWordsLimit, int reviewLimit) async {
    _dailyNewWordsLimit = newWordsLimit;
    _dailyReviewLimit = reviewLimit;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('daily_new_words_limit', newWordsLimit);
    await prefs.setInt('daily_review_limit', reviewLimit);
    notifyListeners();
  }

  void incrementNewWordsLearned() {
    _todayNewWordsLearned++;
    saveDailyProgress();
    notifyListeners();
  }

  void incrementWordsReviewed() {
    _todayWordsReviewed++;
    saveDailyProgress();
    notifyListeners();
  }

  Future<void> loadWords() async {
    _isLoading = true;
    notifyListeners();

    try {
      await DatabaseHelper.instance.migrateData(rootBundle);
      _allWords = await DatabaseHelper.instance.readAllWords();
      print('Loaded ${_allWords.length} words from sqflite database.');

      await loadDailyProgress();
      await updateStreak();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('Error loading words: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  // ... (CRUD methods addWord, editWord, deleteWord, saveProgress, resetWordProgress remain unchanged)
  Future<void> addWord(String chechen, String russian,
      {String? term_latin,
      String? category,
      String? example,
      String? exampleTranslation,
      String? audioUrl,
      String? exampleAudioUrl,
      String? imageUrl,
      String? english,
      String? french,
      String? german,
      String? turkish,
      String? arabic}) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final newWord = Word(
      id: id,
      chechen: chechen,
      term_latin: term_latin,
      russian: russian,
      english: english,
      french: french,
      german: german,
      turkish: turkish,
      arabic: arabic,
      category: category ?? 'General',
      exampleSentence: example,
      exampleTranslation: exampleTranslation,
      audioUrl: audioUrl,
      exampleAudioUrl: exampleAudioUrl,
      imageUrl: imageUrl,
      isCustom: true,
    );
    await DatabaseHelper.instance.create(newWord);
    _allWords.add(newWord);
    notifyListeners();
  }

  Future<void> editWord(String id, String chechen, String russian,
      {String? term_latin,
      String? example,
      String? exampleTranslation,
      String? audioUrl,
      String? exampleAudioUrl,
      String? imageUrl,
      String? english,
      String? french,
      String? german,
      String? turkish,
      String? arabic}) async {
    final wordIndex = _allWords.indexWhere((w) => w.id == id);
    if (wordIndex != -1) {
      final word = _allWords[wordIndex];
      word.chechen = chechen;
      word.term_latin = term_latin;
      word.russian = russian;
      word.english = english;
      word.french = french;
      word.german = german;
      word.turkish = turkish;
      word.arabic = arabic;
      word.exampleSentence = example;
      word.exampleTranslation = exampleTranslation;
      word.audioUrl = audioUrl;
      word.exampleAudioUrl = exampleAudioUrl;
      word.imageUrl = imageUrl;

      await DatabaseHelper.instance.update(word);
      notifyListeners();
    }
  }

  Future<void> deleteWord(String id) async {
    await DatabaseHelper.instance.delete(id);
    _allWords.removeWhere((w) => w.id == id);
    notifyListeners();
  }

  Future<void> saveProgress() async {
    if (currentWord == null) return;
    await DatabaseHelper.instance.updateProgress(currentWord!);
  }
  
  Future<void> resetWordProgress(Word word) async {
    word.reviewLevel = 0;
    word.correctCount = 0;
    word.incorrectCount = 0;
    word.isLearned = false;
    word.nextReview = null;
    word.state = WordState.newWord;
    word.markedAsKnown = false;

    await DatabaseHelper.instance.updateProgress(word);
    notifyListeners();
  }

  Future<void> playAudio(String? audioUrl) async {
    if (audioUrl == null || audioUrl.isEmpty) {
      print('❌ Audio URL is null or empty.');
      return;
    }
    try {
      await player.stop();
      if (audioUrl.startsWith('http')) {
        await player.play(UrlSource(audioUrl));
      } else if (audioUrl.startsWith('assets/')) {
        final assetPath = audioUrl.replaceFirst('assets/', '');
        await player.play(AssetSource(assetPath));
      } else if (audioUrl.startsWith('/')) {
        await player.play(DeviceFileSource(audioUrl));
      } else {
        await player.play(AssetSource(audioUrl));
      }
    } catch (e) {
      print('❌ Error playing audio: $e');
    }
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  // --- HELPER FOR RESETTING INTERACTION STATE ---
  void _resetInteractionState() {
    _userAnswer = '';
    _showTranslation = false;
    _multipleChoiceOptions = [];
    // Reset counters
    _attemptsMade = 0;
    _hintsUsed = 0;
  }
  // ---------------------------------------------

  // --- NEW METHODS FOR HINTS AND ATTEMPTS ---
  void incrementAttempts() {
    if (_attemptsMade < maxAttempts) {
      _attemptsMade++;
      notifyListeners();
    }
  }

  void useHint(TranslationTarget target) {
    if (currentWord == null) return;
    if (_hintsUsed >= maxHints) return;

    final correct = getCorrectTranslation(currentWord!, target);
    if (correct.isEmpty) return;

    String currentInput = _userAnswer.trim();
    String newAnswer = '';

    // 1. Calculate how much of the current input is correct (prefix)
    int i = 0;
    while (i < currentInput.length && 
           i < correct.length && 
           currentInput[i].toLowerCase() == correct[i].toLowerCase()) {
      newAnswer += correct[i]; // Preserve the correct casing
      i++;
    }

    // 2. Append the next character from the correct answer
    if (i < correct.length) {
      newAnswer += correct[i];
    }

    _userAnswer = newAnswer;
    _hintsUsed++;
    notifyListeners();
  }
  // -------------------------------------------

  void startLearningNewWords() {
    final remaining = _dailyNewWordsLimit - _todayNewWordsLearned;
    if (remaining <= 0) return;

    _studyMode = StudyMode.learning;
    _wordsMemorizedInSession = 0;

    var eligibleWords = _allWords
        .where((word) =>
            ((word.state == WordState.newWord && !word.markedAsKnown) ||
                word.state == WordState.learning) &&
            _matchesSelectedCategories(word))
        .toList();

    eligibleWords.shuffle(Random());
    _currentSessionWords = eligibleWords.take(remaining).toList();

    _sessionTotalCount = _currentSessionWords.length;
    _currentIndex = 0;

    _answerMode = AnswerMode.flashcard;
    _resetInteractionState(); // <-- RESET HERE
    notifyListeners();
  }

  void startReviewingWords() {
    final remaining = _dailyReviewLimit - _todayWordsReviewed;
    if (remaining <= 0) return;

    _studyMode = StudyMode.reviewing;
    _wordsMemorizedInSession = 0;

    var eligibleWords = _allWords
        .where((word) =>
            word.state == WordState.reviewing &&
            word.needsReview() &&
            _matchesSelectedCategories(word))
        .toList();

    eligibleWords.shuffle(Random());
    _currentSessionWords = eligibleWords.take(remaining).toList();

    _sessionTotalCount = _currentSessionWords.length;
    _currentIndex = 0;

    _answerMode = AnswerMode.flashcard;
    _resetInteractionState(); // <-- RESET HERE
    notifyListeners();
  }

  void startBrowsing() {
    _studyMode = StudyMode.browsing;
    _currentSessionWords =
        _allWords.where(_matchesSelectedCategories).toList();
    _currentSessionWords.sort((a, b) =>
        a.chechen.toLowerCase().compareTo(b.chechen.toLowerCase()));

    _sessionTotalCount = _currentSessionWords.length;
    _currentIndex = 0;

    _answerMode = AnswerMode.flashcard;
    _resetInteractionState(); // <-- RESET HERE
    notifyListeners();
  }

  void setAnswerMode(AnswerMode mode, TranslationTarget target) {
    _answerMode = mode;
    _resetInteractionState(); // <-- RESET HERE
    if (mode == AnswerMode.multipleChoice && currentWord != null) {
      _generateMultipleChoiceOptions(target);
    }
    notifyListeners();
  }

  void _generateMultipleChoiceOptions(TranslationTarget target) {
    if (currentWord == null) return;
    final correctAnswer = getCorrectTranslation(currentWord!, target);
    final otherWords = _allWords
        .where((w) => w.id != currentWord!.id)
        .toList()
      ..shuffle();
    _multipleChoiceOptions = [
      correctAnswer,
      ...otherWords.take(3).map((w) => getCorrectTranslation(w, target)),
    ]..shuffle();
  }

  void toggleTranslation() {
    _showTranslation = !_showTranslation;
    notifyListeners();
  }

  void setUserAnswer(String answer) {
    _userAnswer = answer;
    notifyListeners();
  }

  bool checkAnswer(String answer, TranslationTarget target) {
    if (currentWord == null) return false;
    final correctTranslation = getCorrectTranslation(currentWord!, target);
    return answer.trim().toLowerCase() == correctTranslation.toLowerCase();
  }

  Future<void> submitAnswer(String answer, TranslationTarget target) async {
    if (currentWord == null) return;

    if (_studyMode == StudyMode.learning) {
      if (checkAnswer(answer, target)) {
        await markAsMemorized();
      } else {
        await needsMorePractice(target);
      }
    } else {
      if (checkAnswer(answer, target)) {
        await markWordCorrect();
      } else {
        await markWordIncorrect(target);
      }
    }
  }

  Future<void> markAsAlreadyKnown() async {
    if (currentWord == null) return;
    currentWord!.markedAsKnown = true;
    currentWord!.state = WordState.learned;
    await saveProgress();
    moveToNextWord(TranslationTarget.russian);
  }

  Future<void> startLearning() async {
    if (currentWord == null) return;
    currentWord!.state = WordState.learning;
    await saveProgress();

    _requeueCurrentWord(TranslationTarget.russian);
  }

  Future<void> markAsMemorized() async {
    if (currentWord == null) return;
    _srsService.markAsMemorized(currentWord!);

    await saveProgress();
    incrementNewWordsLearned();
    _wordsMemorizedInSession++;
    moveToNextWord(TranslationTarget.russian);
  }

  Future<void> needsMorePractice(TranslationTarget target) async {
    if (currentWord == null) return;
    _srsService.needsMorePractice(currentWord!);

    await saveProgress();
    _requeueCurrentWord(target);
  }

  Future<void> markWordCorrect() async {
    if (currentWord == null) return;
    _srsService.markCorrect(currentWord!);

    await saveProgress();
    incrementWordsReviewed();
    _wordsMemorizedInSession++;
    moveToNextWord(TranslationTarget.russian);
  }

  Future<void> markWordIncorrect(TranslationTarget target) async {
    if (currentWord == null) return;
    _srsService.markIncorrect(currentWord!);

    await saveProgress();
    _requeueCurrentWord(target);
  }

  void requeueCurrentWordLater(TranslationTarget target) {
    if (currentWord == null) return;
    _requeueCurrentWord(target);
  }

  void _requeueCurrentWord(TranslationTarget target) {
    _resetInteractionState(); // <-- RESET HERE

    if (_currentSessionWords.isNotEmpty) {
      final wordToReDrill = _currentSessionWords.removeAt(0);
      int newIndex = (3).clamp(0, _currentSessionWords.length);
      _currentSessionWords.insert(newIndex, wordToReDrill);
    }

    if (_currentSessionWords.isEmpty) {
      _currentIndex = 0;
      _studyMode = StudyMode.none;
    } else if (_answerMode == AnswerMode.multipleChoice) {
      _generateMultipleChoiceOptions(target);
    }

    notifyListeners();
  }

  void previousWord(TranslationTarget target) {
    if (_studyMode != StudyMode.browsing) return;

    _resetInteractionState(); // <-- RESET HERE
    
    if (_currentIndex > 0) {
      _currentIndex--;
    } else {
      _currentIndex = _currentSessionWords.length - 1;
    }
    if (_answerMode == AnswerMode.multipleChoice) {
      _generateMultipleChoiceOptions(target);
    }
    notifyListeners();
  }

  void moveToNextWord(TranslationTarget target) {
    _resetInteractionState(); // <-- RESET HERE

    if (_studyMode == StudyMode.browsing) {
      if (_currentIndex < _currentSessionWords.length - 1) {
        _currentIndex++;
      } else {
        _currentIndex = 0;
      }
      if (_answerMode == AnswerMode.multipleChoice) {
        _generateMultipleChoiceOptions(target);
      }
    } else {
      if (_currentSessionWords.isNotEmpty) {
        _currentSessionWords.removeAt(0);
      }
      if (_currentSessionWords.isEmpty) {
        _currentIndex = 0;
        _studyMode = StudyMode.none;
      } else if (_answerMode == AnswerMode.multipleChoice) {
        _generateMultipleChoiceOptions(target);
      }
    }
    notifyListeners();
  }

  void reset() {
    _currentSessionWords = [];
    _currentIndex = 0;
    _sessionTotalCount = 0;
    _studyMode = StudyMode.none;
    _answerMode = AnswerMode.flashcard;
    _resetInteractionState(); // <-- RESET HERE
    notifyListeners();
  }

  Future<void> resetAllProgress() async {
    _isLoading = true;
    notifyListeners();
    try {
      await DatabaseHelper.instance.resetProgress(rootBundle);
      await loadWords();
    } catch (e) {
      print('Failed to reset progress: $e');
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // ... (Counts getters remain unchanged)
  int get newWordsCount => _allWords
      .where((w) =>
          ((w.state == WordState.newWord && !w.markedAsKnown) ||
              w.state == WordState.learning) &&
          _matchesSelectedCategories(w))
      .length;

  int get reviewWordsCount => _allWords
      .where((w) =>
          w.state == WordState.reviewing &&
          w.needsReview() &&
          _matchesSelectedCategories(w))
      .length;

  int get browsableWordsCount =>
      _allWords.where(_matchesSelectedCategories).length;

  int get vocabularyCount => _allWords.length;
  int get learnedCount => _allWords.where((w) => w.isLearned).length;
}