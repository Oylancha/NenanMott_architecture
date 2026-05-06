// lib/models/pixabay_image.dart

/// A model to represent a single image result from the Pixabay API.
class PixabayImage {
  final int id;
  final String previewURL;
  final String largeImageURL;
  final String tags;

  PixabayImage({
    required this.id,
    required this.previewURL,
    required this.largeImageURL,
    required this.tags,
  });

  /// Factory to create a PixabayImage from a JSON object (a single 'hit').
  factory PixabayImage.fromJson(Map<String, dynamic> json) {
    return PixabayImage(
      id: json['id'] as int,
      previewURL: json['previewURL'] as String,
      largeImageURL: json['largeImageURL'] as String,
      tags: json['tags'] as String,
    );
  }
}