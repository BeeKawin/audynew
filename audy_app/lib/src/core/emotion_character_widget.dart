import 'package:flutter/material.dart';

import 'emotion_images.dart';

/// Widget that displays emotion representation.
/// Can show either a human image (for guessing game) or icon (for mimic/result screens).
class EmotionCharacterWidget extends StatelessWidget {
  const EmotionCharacterWidget({
    super.key,
    required this.emotion,
    this.size = 160,
    this.useHumanImage = false,
  });

  final String emotion;
  final double size;

  /// If true, shows human face image (for guessing game).
  /// If false, shows icon (for selfie/result screens).
  final bool useHumanImage;

  IconData get _icon {
    switch (emotion) {
      case 'Happy':
        return Icons.sentiment_very_satisfied_rounded;
      case 'Sad':
        return Icons.sentiment_dissatisfied_rounded;
      case 'Angry':
        return Icons.sentiment_very_dissatisfied_rounded;
      case 'Surprised':
        return Icons.auto_awesome_rounded;
      case 'Scared':
        return Icons.psychology_rounded;
      case 'Calm':
        return Icons.sentiment_neutral_rounded;
      default:
        return Icons.sentiment_neutral_rounded;
    }
  }

  Color get _bgColor {
    switch (emotion) {
      case 'Happy':
        return const Color(0xFFFFF2A8);
      case 'Sad':
        return const Color(0xFFBDD8F2);
      case 'Angry':
        return const Color(0xFFFFDAC7);
      case 'Surprised':
        return const Color(0xFFF8C7DF);
      case 'Scared':
        return const Color(0xFFDDD0F4);
      case 'Calm':
        return const Color(0xFFC9E8C1);
      default:
        return const Color(0xFFC9E8C1);
    }
  }

  Color get _fgColor {
    switch (emotion) {
      case 'Happy':
        return const Color(0xFFFFB800);
      case 'Sad':
        return const Color(0xFF5B9BD5);
      case 'Angry':
        return const Color(0xFFFF6B6B);
      case 'Surprised':
        return const Color(0xFFE87EA8);
      case 'Scared':
        return const Color(0xFF9B8FD4);
      case 'Calm':
        return const Color(0xFF69B85A);
      default:
        return const Color(0xFF69B85A);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show human image if requested and available
    if (useHumanImage && EmotionImages.hasImages(emotion)) {
      final imagePath = EmotionImages.getRandomPath(emotion);
      if (imagePath.isNotEmpty) {
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: _bgColor,
            borderRadius: BorderRadius.circular(size * 0.25),
            boxShadow: [
              BoxShadow(
                color: _fgColor.withValues(alpha: 0.20),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(size * 0.25),
            child: Image.asset(
              imagePath,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                // Fallback to icon if image fails to load
                return _buildIconWidget();
              },
            ),
          ),
        );
      }
    }

    // Default: show icon
    return _buildIconWidget();
  }

  Widget _buildIconWidget() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: _bgColor,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: _fgColor.withValues(alpha: 0.20),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Icon(_icon, size: size * 0.55, color: _fgColor),
    );
  }
}
