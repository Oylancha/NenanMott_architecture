// lib/models/external_word_model.dart

class ExternalWord {
  final String chechen;
  final String? term_latin;
  final String russian;
  final String? english;
  final String? french;
  final String? german;
  final String? turkish;
  final String? arabic;

  ExternalWord({
    required this.chechen,
    this.term_latin,
    required this.russian,
    this.english,
    this.french,
    this.german,
    this.turkish,
    this.arabic,
  });

  String getTerm(bool isCyrillic) {
    if (isCyrillic) {
      return chechen;
    }
    return term_latin ?? chechen;
  }

  factory ExternalWord.fromJson(Map<String, dynamic> json) {
    return ExternalWord(
      chechen: json['term'] ?? '',
      term_latin: json['term_latin'], // <-- THE FIX (was 'term-latin')
      russian: json['translation'] ?? '',
      english: json['english'],
      french: json['french'],
      german: json['german'],
      turkish: json['turkish'],
      arabic: json['arabic'],
    );
  }
}