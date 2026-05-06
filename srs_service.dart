import '../models/word_model.dart';

/// Service for Spaced Repetition System (SRS) logic.
///
/// This class encapsulates the logic for updating a word's review state
/// based on user performance.
class SpacedRepetitionService {
  // Defines the intervals (in days) for each review level.
  // Example:
  // Level 0 -> 1 day
  // Level 1 -> 3 days
  // Level 2 -> 7 days
  // Level 3 -> 14 days
  // ...and so on.
  static const List<int> _reviewIntervals = [
    1, // Level 0 -> 1
    3, // Level 1 -> 3
    7, // Level 2 -> 7
    14, // Level 3 -> 14
    30, // Level 4 -> 30
    60, // Level 5 -> 60
    120, // Level 6 -> 120
  ];

  /// The maximum review level.
  static final int _maxLevel = _reviewIntervals.length - 1;

  /// Call when a user gets a word correct during a REVIEW session.
  ///
  /// This promotes the word to the next review level.
  void markCorrect(Word word) {
    word.correctCount++;

    if (word.reviewLevel < _maxLevel) {
      word.reviewLevel++;
    }

    // Set next review date
    final daysToAdd = _reviewIntervals[word.reviewLevel];
    word.nextReview = _addDaysToToday(daysToAdd);

    // Check if word is now "learned"
    if (word.reviewLevel == _maxLevel) {
      word.state = WordState.learned;
      word.isLearned = true;
    }
  }

  /// Call when a user gets a word incorrect during a REVIEW session.
  ///
  /// This demotes the word by two levels (minimum of 0).
  void markIncorrect(Word word) {
    word.incorrectCount++;

    if (word.reviewLevel > 0) {
      // Demote by 2 levels, but not below 0
      word.reviewLevel = (word.reviewLevel - 2).clamp(0, _maxLevel);
    }

    // Set next review date to tomorrow
    word.nextReview = _addDaysToToday(1);
    word.state = WordState.reviewing; // Ensure it stays in review
    word.isLearned = false;
  }

  /// Call when a user learns a word for the first time in a LEARNING session.
  ///
  /// This graduates the word from "learning" to "reviewing".
  void markAsMemorized(Word word) {
    word.correctCount++;
    word.state = WordState.reviewing; // Graduate to review
    word.reviewLevel = 0; // Start at the first level
    word.nextReview = _addDaysToToday(_reviewIntervals[0]); // Set for tomorrow
  }

  /// Call when a user fails to learn a word in a LEARNING session.
  ///
  /// The word remains in the "learning" state.
  void needsMorePractice(Word word) {
    word.incorrectCount++;
    word.state = WordState.learning; // Keep in learning
    word.nextReview = null; // No review date until memorized
  }

  /// Helper to get a future date, ignoring time.
  DateTime _addDaysToToday(int days) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return today.add(Duration(days: days));
  }
}