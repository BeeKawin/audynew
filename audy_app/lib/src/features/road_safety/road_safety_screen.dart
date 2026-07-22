import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../../core/app_routes.dart';
import '../../core/audy_theme.dart';
import '../../core/audy_ui.dart';
import '../../data/models/game_session_model.dart';
import '../../services/bluetooth_service.dart';
import '../../services/sound_service.dart';
import '../../state/audy_controller.dart';
import '../../widgets/game_guide_box.dart';
import '../../widgets/point_celebration_dialog.dart';
import 'road_safety_controller.dart';
import 'road_safety_models.dart';
import 'road_safety_widgets.dart';

class RoadSafetyScreen extends StatefulWidget {
  const RoadSafetyScreen({super.key});

  @override
  State<RoadSafetyScreen> createState() => _RoadSafetyScreenState();
}

class _RoadSafetyScreenState extends State<RoadSafetyScreen> {
  late final RoadSafetyController _controller;
  final FlutterTts _tts = FlutterTts();
  Timer? _crossingTimer;
  bool _showGuide = true;
  bool _hasRecordedCompletion = false;

  @override
  void initState() {
    super.initState();
    _controller = RoadSafetyController()..addListener(_onControllerChanged);
  }

  @override
  void dispose() {
    _crossingTimer?.cancel();
    _controller.removeListener(_onControllerChanged);
    _controller.dispose();
    _tts.stop();
    super.dispose();
  }

  void _onControllerChanged() {
    if (!mounted) return;
    setState(() {});

    if (_controller.isCrossing) {
      _crossingTimer?.cancel();
      _crossingTimer = Timer(const Duration(milliseconds: 1300), () {
        if (!mounted) return;
        _controller.finishCrossing();
      });
    }

    if (_controller.isComplete) {
      unawaited(_recordCompletion());
    }
  }

  Future<void> _speak(String key) async {
    final controller = AudyScope.of(context);
    final text = controller.tr(key);
    if (text.trim().isEmpty) return;

    await _tts.stop();
    await _tts.setLanguage(
      controller.currentLanguage == 'th' ? 'th-TH' : 'en-US',
    );
    await _tts.setPitch(1.12);
    await _tts.setSpeechRate(0.42);
    await _tts.speak(text);
  }

  void _handleAction(RoadSafetyAction action) {
    SoundService.instance.playTap();
    _controller.performAction(action);
    if (!_controller.isComplete) {
      unawaited(_speak(_controller.step.instructionKey));
    }
    if (_controller.feedback.type == RoadSafetyFeedbackType.success) {
      SoundService.instance.playCorrect();
    }
  }

  Future<void> _recordCompletion() async {
    if (_hasRecordedCompletion) return;
    _hasRecordedCompletion = true;
    await _tts.stop();
    SoundService.instance.playGameComplete();
    unawaited(_sendCompletionBleCelebration());

    final appController = AudyScope.of(context);
    final session = _controller.getSessionData();
    final stars = session.stars;
    final pointsEarned = stars * 5;
    final initialPoints = appController.learningPoints;
    final newPoints = initialPoints + pointsEarned;
    final oldLevel = _getLevelFromPoints(initialPoints);
    final newLevel = _getLevelFromPoints(newPoints);
    final isLevelUp = newLevel > oldLevel;

    if (pointsEarned > 0) {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => PointCelebrationDialog(
          points: pointsEarned,
          totalPoints: newPoints,
          currentLevel: newLevel,
          nextLevelThreshold: _getNextLevelThreshold(newLevel),
          nextLevelName: _getLevelName(newLevel + 1),
          isLevelUp: isLevelUp,
          newLevelName: isLevelUp ? _getLevelName(newLevel) : null,
          onClose: () => Navigator.of(dialogContext).pop(),
        ),
      );
      if (!mounted) return;
      await appController.addPoints(pointsEarned);
    }

    await appController.trackRoadSafetyCompleted();
    await appController.recordAnalyticsSession(
      GameSessionData.fromTimes(
        gameType: 'road_safety',
        difficulty: 'guided',
        correctActions: session.correctActions,
        totalActions: session.totalActions,
        starsEarned: stars,
        sessionStartedAt: session.sessionStartedAt,
        sessionEndedAt: session.sessionEndedAt,
      ),
    );
  }

  Future<void> _sendCompletionBleCelebration() async {
    try {
      await AudyBluetoothService.instance.celebrateGameCompletion();
    } catch (e) {
      debugPrint('RoadSafetyScreen: Completion BLE skipped - $e');
    }
  }

  int _getLevelFromPoints(int points) {
    if (points >= 1000) return 4;
    if (points >= 500) return 3;
    if (points >= 250) return 2;
    if (points >= 100) return 1;
    return 0;
  }

  int _getNextLevelThreshold(int level) {
    const thresholds = [100, 250, 500, 1000, 2000];
    return level >= thresholds.length ? 2000 : thresholds[level];
  }

  String _getLevelName(int level) {
    const names = ['Beginner', 'Learner', 'Explorer', 'Expert', 'Master'];
    return level >= names.length ? 'Master' : names[level];
  }

  @override
  Widget build(BuildContext context) {
    return AudyResponsivePage(
      scrollable: false,
      builder: (context, adaptive) {
        if (_controller.isComplete) {
          return _RoadSafetyComplete(
            adaptive: adaptive,
            stars: _controller.getSessionData().stars,
            onPlayAgain: () {
              _hasRecordedCompletion = false;
              _controller.reset();
            },
            onDone: () {
              final appController = AudyScope.of(context);
              AppRoutes.navigateAfterGameCompletion(context, appController);
            },
          );
        }

        return Column(
          children: [
            _Header(
              adaptive: adaptive,
              showGuide: _showGuide,
              onDismissGuide: () => setState(() => _showGuide = false),
              onBack: () {
                SoundService.instance.playTap();
                Navigator.pop(context);
              },
            ),
            SizedBox(height: adaptive.space(14)),
            RoadSafetyProgress(
              current: _controller.progressCurrent,
              total: RoadSafetyController.totalLearningSteps,
              adaptive: adaptive,
            ),
            SizedBox(height: adaptive.space(14)),
            Text(
              AudyScope.of(context).tr(_controller.step.instructionKey),
              textAlign: TextAlign.center,
              style: AudyTypography.headingMedium,
            ),
            SizedBox(height: adaptive.space(12)),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    RoadScene(controller: _controller, adaptive: adaptive),
                    SizedBox(height: adaptive.space(14)),
                    RoadSafetyFeedbackBanner(
                      feedback: _controller.feedback,
                      adaptive: adaptive,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: adaptive.space(14)),
            RoadSafetyActionPanel(
              controller: _controller,
              adaptive: adaptive,
              onAction: _handleAction,
              onContinue: _controller.completeSession,
            ),
          ],
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.adaptive,
    required this.showGuide,
    required this.onDismissGuide,
    required this.onBack,
  });

  final AudyAdaptive adaptive;
  final bool showGuide;
  final VoidCallback onDismissGuide;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        InkWell(
          onTap: onBack,
          borderRadius: BorderRadius.circular(AudySpacing.radiusMedium),
          child: SizedBox(
            width: adaptive.space(56),
            height: adaptive.space(56),
            child: const Icon(Icons.arrow_back_rounded),
          ),
        ),
        SizedBox(width: adaptive.space(8)),
        Expanded(
          child: Text(
            AudyScope.of(context).tr('road_safety_game'),
            style: AudyTypography.headingSmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (showGuide)
          SizedBox(
            width: adaptive.isPhone ? adaptive.space(184) : adaptive.space(280),
            child: GameGuideBox(
              message: AudyScope.of(context).tr('guide_road_safety'),
              onDismissed: onDismissGuide,
            ),
          ),
      ],
    );
  }
}

class _RoadSafetyComplete extends StatelessWidget {
  const _RoadSafetyComplete({
    required this.adaptive,
    required this.stars,
    required this.onPlayAgain,
    required this.onDone,
  });

  final AudyAdaptive adaptive;
  final int stars;
  final VoidCallback onPlayAgain;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: AudyBackButton(
            label: AudyScope.of(context).tr('back'),
            onPressed: onDone,
          ),
        ),
        const Spacer(),
        Icon(
          Icons.verified_rounded,
          size: adaptive.space(96),
          color: AudyColors.mintGreen,
        ),
        SizedBox(height: adaptive.space(16)),
        Text(
          AudyScope.of(context).tr('road_safety_complete'),
          textAlign: TextAlign.center,
          style: AudyTypography.displayLarge,
        ),
        SizedBox(height: adaptive.space(18)),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (index) {
            return Icon(
              Icons.star_rounded,
              size: adaptive.space(44),
              color: index < stars
                  ? AudyColors.starGold
                  : AudyColors.starSilver,
            );
          }),
        ),
        SizedBox(height: adaptive.space(28)),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: onPlayAgain,
                icon: const Icon(Icons.refresh_rounded),
                label: Text(AudyScope.of(context).tr('try_again')),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AudyColors.backgroundCard,
                  foregroundColor: AudyColors.textPrimary,
                ),
              ),
            ),
            SizedBox(width: adaptive.space(12)),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: onDone,
                icon: const Icon(Icons.check_rounded),
                label: Text(AudyScope.of(context).tr('finish')),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AudyColors.skyBlue,
                  foregroundColor: AudyColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
        const Spacer(),
      ],
    );
  }
}
