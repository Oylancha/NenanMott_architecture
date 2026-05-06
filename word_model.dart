// lib/models/word_model.dart

enum WordState {
  newWord, // Never seen before
  learning, // First learning stage
  reviewing, // In spaced repetition
  learned, // Completed all reviews
}

enum StudyMode { none, learning, reviewing, browsing }

enum AnswerMode { flashcard, typing, multipleChoice }

// Model for Word
class Word {
  final String id;
  String chechen;
  String? term_latin;
  String russian;
  String? english;
  String? french;
  String? german;
  String? turkish;
  String? arabic;
  String category;
  WordState state;
  bool markedAsKnown;
  String? exampleSentence;
  String? exampleTranslation;
  String? audioUrl;
  String? imageUrl;
  String? exampleAudioUrl;
  int reviewLevel;
  DateTime? nextReview;
  int correctCount;
  int incorrectCount;
  bool isLearned = false;
  bool isCustom = false;

  Word({
    required this.id,
    required this.chechen,
    this.term_latin,
    required this.russian,
    this.english,
    this.french,
    this.german,
    this.turkish,
    this.arabic,
    this.category = 'General',
    this.exampleSentence,
    this.exampleTranslation,
    this.audioUrl,
    this.imageUrl,
    this.exampleAudioUrl,
    this.reviewLevel = 0,
    this.nextReview,
    this.correctCount = 0,
    this.incorrectCount = 0,
    this.isLearned = false,
    this.isCustom = false,
    this.state = WordState.newWord,
    this.markedAsKnown = false,
  });

  /// Returns the correct Chechen term based on the alphabet setting.
  /// Falls back to Cyrillic if Latin is null.
  String getTerm(bool isCyrillic) {
    if (isCyrillic) {
      return chechen;
    }
    // Use term_latin, but fallback to cyrillic (chechen) if it's null
    return term_latin ?? chechen;
  }

  /// Factory to create a Word from a JSON (assets) entry.
  factory Word.fromJson(String id, Map<String, dynamic> json) {
    return Word(
      id: id,
      // --- 1. FIX: Read 'chechen' from JSON (matches your file) ---
      chechen: json['chechen'] ?? json['term'] ?? '', 
      term_latin: json['term_latin'],
      russian: json['translation'] ?? '',
      english: json['english'],
      french: json['french'],
      german: json['german'],
      turkish: json['turkish'],
      arabic: json['arabic'],
      category: json['category'] ?? 'General',
      exampleSentence: json['example'],
      exampleTranslation: json['example_translation'],
      audioUrl: json['audio_url'],
      imageUrl: json['image_url'],
      exampleAudioUrl: json['example_audio_url'],
      isCustom: json['is_custom'] ?? false,
    );
  }

  /// Factory to create a Word from a database row.
  factory Word.fromDb(Map<String, dynamic> json) {
    return Word(
      id: json['id'],
      // --- 2. FIX: Read 'term' from DB (matches database schema) ---
      chechen: json['term'], 
      term_latin: json['term_latin'],
      russian: json['russian'],
      english: json['english'],
      french: json['french'],
      german: json['german'],
      turkish: json['turkish'],
      arabic: json['arabic'],
      category: json['category'] ?? 'General',
      exampleSentence: json['exampleSentence'],
      exampleTranslation: json['exampleTranslation'],
      audioUrl: json['audioUrl'],
      imageUrl: json['imageUrl'],
      exampleAudioUrl: json['exampleAudioUrl'],
      isCustom: json['isCustom'] == 1,
      reviewLevel: json['reviewLevel'] ?? 0,
      nextReview: json['nextReview'] != null
          ? DateTime.parse(json['nextReview'])
          : null,
      correctCount: json['correctCount'] ?? 0,
      incorrectCount: json['incorrectCount'] ?? 0,
      isLearned: json['isLearned'] == 1,
      state: WordState.values[json['state'] ?? 0],
      markedAsKnown: json['markedAsKnown'] == 1,
    );
  }

  /// Converts a Word object to a Map for database insertion (full word).
  Map<String, dynamic> toDbMap() {
    return {
      'id': id,
      // --- 3. FIX: Write to 'term' column in DB ---
      'term': chechen, 
      'term_latin': term_latin,
      'russian': russian,
      'english': english,
      'french': french,
      'german': german,
      'turkish': turkish,
      'arabic': arabic,
      'category': category,
      'exampleSentence': exampleSentence,
      'exampleTranslation': exampleTranslation,
      'audioUrl': audioUrl,
      'imageUrl': imageUrl,
      'exampleAudioUrl': exampleAudioUrl,
      'isCustom': isCustom ? 1 : 0,
      'reviewLevel': reviewLevel,
      'nextReview': nextReview?.toIso8601String(),
      'correctCount': correctCount,
      'incorrectCount': incorrectCount,
      'isLearned': isLearned ? 1 : 0,
      'state': state.index,
      'markedAsKnown': markedAsKnown ? 1 : 0,
    };
  }

  /// Converts a Word object to a Map for database update (progress only).
  Map<String, dynamic> toProgressDbMap() {
    return {
      'reviewLevel': reviewLevel,
      'nextReview': nextReview?.toIso8601String(),
      'correctCount': correctCount,
      'incorrectCount': incorrectCount,
      'isLearned': isLearned ? 1 : 0,
      'state': state.index,
      'markedAsKnown': markedAsKnown ? 1 : 0,
    };
  }

  /// Converts a custom Word object back to JSON for saving (if needed).
  Map<String, dynamic> toJson() {
    return {
      // --- 4. FIX: Write 'chechen' to JSON (matches your file format) ---
      'chechen': chechen, 
      'term_latin': term_latin,
      'translation': russian,
      'english': english,
      'french': french,
      'german': german,
      'turkish': turkish,
      'arabic': arabic,
      'category': category,
      'example': exampleSentence,
      'example_translation': exampleTranslation,
      'audio_url': audioUrl,
      'is_custom': isCustom,
      'image_url': imageUrl,
      'example_audio_url': exampleAudioUrl,
    };
  }

  /// Checks if a word is due for review.
  bool needsReview() {
    if (nextReview == null) return false;
    // Check if the review date is today or in the past.
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final reviewDay =
        DateTime(nextReview!.year, nextReview!.month, nextReview!.day);
    return reviewDay.isAtSameMomentAs(today) || reviewDay.isBefore(today);
  }
}