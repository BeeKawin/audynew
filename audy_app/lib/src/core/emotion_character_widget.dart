import 'package:flutter/material.dart';

class EmotionCharacterWidget extends StatelessWidget {
  const EmotionCharacterWidget({
    super.key,
    required this.emotion,
    this.size = 160,
  });

  final String emotion;
  final double size;

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
      case 'Proud':
        return Icons.emoji_events_rounded;
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
      case 'Proud':
        return const Color(0xFFE7D8FA);
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
      case 'Proud':
        return const Color(0xFFB388FF);
      default:
        return const Color(0xFF69B85A);
    }
  }

  @override
  Widget build(BuildContext context) {
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
