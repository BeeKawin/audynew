import 'dart:math';

/// Maps emotions to real human image assets for the emotion guessing game.
/// Supports 5 emotions with 3 variants each for variety.
class EmotionImages {
  const EmotionImages._();

  /// Available emotion images by emotion name
  static const Map<String, List<String>> _assets = {
    'Happy': ['happy1.jpg', 'happy2.jpg', 'happy3.jpg'],
    'Sad': ['sad1.jpg', 'sad2.jpg', 'sad3.jpg'],
    'Angry': ['angry1.jpg', 'angry2.jpg', 'angry3.jpg'],
    'Scared': ['scared1.jpg', 'scared2.jpg', 'scared3.jpg'],
    'Surprised': ['surprised1.jpg', 'surprised2.jpg', 'surprised3.jpg'],
    'Disgust': [],
  };

  /// Base path for emotion images
  static const String _basePath = 'assets/images';

  /// Returns a random image path for the given emotion.
  /// Returns empty string if emotion has no images.
  static String getRandomPath(String emotion) {
    final images = _assets[emotion];
    if (images == null || images.isEmpty) return '';

    final random = Random();
    final index = random.nextInt(images.length);
    return '$_basePath/${images[index]}';
  }

  /// Returns true if the emotion has human images available
  static bool hasImages(String emotion) {
    final images = _assets[emotion];
    return images != null && images.isNotEmpty;
  }

  /// Gets all available image paths for an emotion
  static List<String> getAllPaths(String emotion) {
    final images = _assets[emotion];
    if (images == null || images.isEmpty) return [];
    return images.map((img) => '$_basePath/$img').toList();
  }
}
