import 'package:flutter/material.dart';
import '../../../data/models/game_configuration.dart';
import '../../../core/audy_ui.dart';
import '../caretaker_ui.dart';
import 'previews/emotion_preview.dart';
import 'previews/flashcard_preview.dart';
import 'previews/fruit_preview.dart';
import 'previews/minipuzzle_preview.dart';
import 'previews/social_preview.dart';

/// No repository or child ID enters this subtree: previews cannot save progress.
class GamePreview extends StatelessWidget {
  const GamePreview({super.key, required this.config, required this.childName});
  final GameConfiguration config;
  final String childName;
  @override
  Widget build(BuildContext context) => CaretakerAccountGuard(
    child: Scaffold(
      appBar: AppBar(
        title: Text(ct(context, 'Preview · $childName', 'ทดลอง · $childName')),
      ),
      body: AudyResponsivePage(
        scrollable: false,
        builder: (context, adaptive) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                ct(
                  context,
                  'Preview only · no points, rewards, analytics or robot commands',
                  'ทดลองเท่านั้น · ไม่บันทึกคะแนน รางวัล การวิเคราะห์ หรือส่งคำสั่งหุ่นยนต์',
                ),
              ),
            ),
            Expanded(
              child: switch (config.game) {
                CaretakerGame.socialChat => SocialPreview(
                  values: config.toJson(),
                ),
                CaretakerGame.flashcard => FlashcardPreview(
                  values: config.toJson(),
                ),
                CaretakerGame.miniPuzzle => MiniPuzzlePreview(
                  values: config.toJson(),
                ),
                CaretakerGame.emotion => EmotionPreview(
                  values: config.toJson(),
                ),
                CaretakerGame.fruitCatch => FruitPreview(
                  values: config.toJson(),
                ),
              },
            ),
          ],
        ),
      ),
    ),
  );
}
