import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../../core/app_routes.dart';
import '../../core/audy_theme.dart';
import '../../core/audy_ui.dart';
import '../../data/models/game_session_model.dart';
import '../../services/sound_service.dart';
import '../../state/audy_controller.dart';
import '../../widgets/game_guide_box.dart';
import 'flashcard_card_widget.dart';
import 'flashcard_controller.dart';
import 'flashcard_models.dart';

class FlashcardScreen extends StatefulWidget {
  const FlashcardScreen({super.key});

  @override
  State<FlashcardScreen> createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends State<FlashcardScreen> {
  late final FlashcardController _controller;
  final FlutterTts _tts = FlutterTts();
  Timer? _previewTimer;
  Timer? _feedbackTimer;
  late DateTime _sessionStartedAt;
  bool _hasRecordedCompletion = false;
  bool _showGuide = true;

  @override
  void initState() {
    super.initState();
    _controller = FlashcardController()..addListener(_onControllerChanged);
    _sessionStartedAt = DateTime.now();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final language = AudyScope.of(context).currentLanguage;
      unawaited(_controller.startSession(language));
    });
  }

  @override
  void dispose() {
    _previewTimer?.cancel();
    _feedbackTimer?.cancel();
    _controller.removeListener(_onControllerChanged);
    _controller.dispose();
    _tts.stop();
    super.dispose();
  }

  void _onControllerChanged() {
    if (!mounted) return;
    setState(() {});

    if (_controller.phase == FlashcardGamePhase.previewing) {
      _schedulePreview();
    } else {
      _previewTimer?.cancel();
    }

    if (_controller.phase == FlashcardGamePhase.feedback) {
      _scheduleFeedbackFade();
    }

    if (_controller.phase == FlashcardGamePhase.complete) {
      unawaited(_recordCompletion());
    }
  }

  void _schedulePreview() {
    _previewTimer?.cancel();
    final card = _controller.previewCard;
    if (card == null) return;

    unawaited(_speakCard(card));
    _previewTimer = Timer(const Duration(seconds: 2), () {
      if (!mounted) return;
      _controller.advancePreview();
    });
  }

  void _scheduleFeedbackFade() {
    _feedbackTimer?.cancel();
    _feedbackTimer = Timer(const Duration(seconds: 3), () {
      if (!mounted) return;
      final language = AudyScope.of(context).currentLanguage;
      unawaited(_controller.continueAfterFeedback(language));
    });
  }

  Future<void> _speakCard(FlashcardCard card) async {
    await _speakText(card.ttsText, card.language);
  }

  Future<void> _speakText(String text, String language) async {
    if (text.trim().isEmpty) return;
    if (language == 'th') {
      await AudyScope.of(context).geminiTtsService.speakThai(text);
      return;
    }

    await _tts.stop();
    await _tts.setLanguage('en-US');
    await _tts.setPitch(1.2);
    await _tts.setSpeechRate(0.42);
    await _tts.speak(text);
  }

  Future<void> _handleSubmit() async {
    if (!_controller.canSubmit) return;
    SoundService.instance.playTap();
    final selected = _controller.selectedCards;
    for (final card in selected) {
      await _speakCard(card);
      await Future<void>.delayed(const Duration(milliseconds: 180));
    }
    await _controller.submit();
    if (_controller.lastValidation?.isCorrect == true) {
      SoundService.instance.playCorrect();
    } else {
      SoundService.instance.playWrong();
    }
  }

  Future<void> _recordCompletion() async {
    if (_hasRecordedCompletion) return;
    _hasRecordedCompletion = true;

    final appController = AudyScope.of(context);
    final endedAt = DateTime.now();
    final correctRounds = _controller.correctRounds;
    final totalRounds = _controller.totalRounds;
    final points = correctRounds * 5;

    await appController.trackFlashcardCompleted();
    if (points > 0) {
      await appController.addPoints(points);
    }
    await appController.recordAnalyticsSession(
      GameSessionData.fromTimes(
        gameType: 'flashcard',
        difficulty: '3-5-7',
        correctActions: correctRounds,
        totalActions: totalRounds,
        starsEarned: correctRounds,
        sessionStartedAt: _sessionStartedAt,
        sessionEndedAt: endedAt,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AudyResponsivePage(
      scrollable: false,
      builder: (context, adaptive) {
        return Column(
          children: [
            _Header(
              adaptive: adaptive,
              round: min(
                _controller.currentRoundNumber,
                _controller.totalRounds,
              ),
              totalRounds: _controller.totalRounds,
              guide: _showGuide
                  ? GameGuideBox(
                      message: AudyScope.of(context).tr('guide_flashcard'),
                      onDismissed: () => setState(() => _showGuide = false),
                    )
                  : null,
              onBack: () {
                SoundService.instance.playTap();
                Navigator.pop(context);
              },
            ),
            SizedBox(height: adaptive.space(16)),
            Expanded(child: _buildBody(adaptive)),
          ],
        );
      },
    );
  }

  Widget _buildBody(AudyAdaptive adaptive) {
    switch (_controller.phase) {
      case FlashcardGamePhase.loading:
        return _LoadingState(adaptive: adaptive);
      case FlashcardGamePhase.previewing:
        return _PreviewState(controller: _controller);
      case FlashcardGamePhase.playing:
      case FlashcardGamePhase.validating:
      case FlashcardGamePhase.feedback:
        return _PlayState(
          adaptive: adaptive,
          controller: _controller,
          onCardSelected: _controller.selectCard,
          onPlacedCardTap: _controller.removeSelectedCard,
          onSubmit: _handleSubmit,
        );
      case FlashcardGamePhase.complete:
        return _CompleteState(
          adaptive: adaptive,
          correctRounds: _controller.correctRounds,
          totalRounds: _controller.totalRounds,
          onDone: () {
            final appController = AudyScope.of(context);
            AppRoutes.navigateAfterGameCompletion(context, appController);
          },
        );
      case FlashcardGamePhase.error:
        return _ErrorState(
          adaptive: adaptive,
          onRetry: () {
            final language = AudyScope.of(context).currentLanguage;
            unawaited(_controller.retry(language));
          },
        );
    }
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.adaptive,
    required this.round,
    required this.totalRounds,
    required this.onBack,
    this.guide,
  });

  final AudyAdaptive adaptive;
  final int round;
  final int totalRounds;
  final VoidCallback onBack;
  final Widget? guide;

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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AudyScope.of(context).tr('flashcard_game'),
                style: AudyTypography.headingSmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                AudyScope.of(context).tr(
                  'round_format',
                  params: {
                    'current': round.toString(),
                    'total': totalRounds.toString(),
                  },
                ),
                style: AudyTypography.labelMedium.copyWith(
                  color: AudyColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        if (guide != null)
          SizedBox(
            width: adaptive.isPhone ? adaptive.space(190) : adaptive.space(280),
            child: guide!,
          ),
      ],
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState({required this.adaptive});

  final AudyAdaptive adaptive;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(color: AudyColors.skyBlue),
          SizedBox(height: adaptive.space(18)),
          Text(
            AudyScope.of(context).tr('flashcard_loading'),
            style: AudyTypography.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _PreviewState extends StatelessWidget {
  const _PreviewState({required this.controller});

  final FlashcardController controller;

  @override
  Widget build(BuildContext context) {
    final card = controller.previewCard;
    if (card == null) return const SizedBox.shrink();

    return Center(
      child: AnimatedSwitcher(
        duration: AudyAnimation.slow,
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.96, end: 1).animate(animation),
              child: child,
            ),
          );
        },
        child: FlashcardWordCard(
          key: ValueKey(card.id),
          card: card,
          isPreview: true,
        ),
      ),
    );
  }
}

class _PlayState extends StatelessWidget {
  const _PlayState({
    required this.adaptive,
    required this.controller,
    required this.onCardSelected,
    required this.onPlacedCardTap,
    required this.onSubmit,
  });

  final AudyAdaptive adaptive;
  final FlashcardController controller;
  final ValueChanged<FlashcardCard> onCardSelected;
  final ValueChanged<FlashcardCard> onPlacedCardTap;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final isBusy = controller.phase == FlashcardGamePhase.validating;
    return Column(
      children: [
        _SentenceSlots(
          adaptive: adaptive,
          controller: controller,
          onPlacedCardTap: onPlacedCardTap,
        ),
        SizedBox(height: adaptive.space(18)),
        Expanded(
          child: SingleChildScrollView(
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: adaptive.space(12),
              runSpacing: adaptive.space(12),
              children: controller.handCards
                  .map(
                    (card) => FlashcardWordCard(
                      card: card,
                      onTap: isBusy ? null : () => onCardSelected(card),
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
        SizedBox(height: adaptive.space(14)),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: controller.canSubmit && !isBusy ? onSubmit : null,
            icon: Icon(
              isBusy ? Icons.hourglass_empty_rounded : Icons.check_rounded,
              size: adaptive.space(28),
            ),
            label: Text(
              isBusy
                  ? AudyScope.of(context).tr('checking')
                  : AudyScope.of(context).tr('submit'),
              style: AudyTypography.buttonText,
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AudyColors.skyBlue,
              foregroundColor: AudyColors.textOnColor,
              minimumSize: Size.fromHeight(adaptive.space(62)),
            ),
          ),
        ),
      ],
    );
  }
}

class _SentenceSlots extends StatelessWidget {
  const _SentenceSlots({
    required this.adaptive,
    required this.controller,
    required this.onPlacedCardTap,
  });

  final AudyAdaptive adaptive;
  final FlashcardController controller;
  final ValueChanged<FlashcardCard> onPlacedCardTap;

  @override
  Widget build(BuildContext context) {
    final round = controller.currentRound;
    final slotCount = round?.wordCount ?? 3;

    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: adaptive.space(184)),
      padding: EdgeInsets.all(adaptive.space(14)),
      decoration: BoxDecoration(
        color: AudyColors.skyBlue.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AudySpacing.radiusLarge),
        border: Border.all(
          color: AudyColors.skyBlue.withValues(alpha: 0.35),
          width: 2,
        ),
      ),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: adaptive.space(10),
        runSpacing: adaptive.space(10),
        children: List.generate(slotCount, (index) {
          if (index < controller.selectedCards.length) {
            final card = controller.selectedCards[index];
            return FlashcardWordCard(
              card: card,
              status: controller.statusForCard(card.id),
              onTap: controller.phase == FlashcardGamePhase.playing
                  ? () => onPlacedCardTap(card)
                  : null,
            );
          }
          return _EmptySlot(adaptive: adaptive);
        }),
      ),
    );
  }
}

class _EmptySlot extends StatelessWidget {
  const _EmptySlot({required this.adaptive});

  final AudyAdaptive adaptive;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 132,
      height: 172,
      decoration: BoxDecoration(
        color: AudyColors.backgroundCard.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(AudySpacing.radiusLarge),
        border: Border.all(
          color: AudyColors.borderLight,
          width: 3,
          strokeAlign: BorderSide.strokeAlignInside,
        ),
      ),
      child: Center(
        child: Icon(
          Icons.add_rounded,
          size: adaptive.space(38),
          color: AudyColors.textLight,
        ),
      ),
    );
  }
}

class _CompleteState extends StatelessWidget {
  const _CompleteState({
    required this.adaptive,
    required this.correctRounds,
    required this.totalRounds,
    required this.onDone,
  });

  final AudyAdaptive adaptive;
  final int correctRounds;
  final int totalRounds;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.celebration_rounded,
            size: adaptive.space(88),
            color: AudyColors.mintGreen,
          ),
          SizedBox(height: adaptive.space(18)),
          Text(
            AudyScope.of(context).tr('flashcard_complete'),
            style: AudyTypography.displayLarge,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: adaptive.space(12)),
          Text(
            '$correctRounds / $totalRounds',
            style: AudyTypography.headingMedium,
          ),
          SizedBox(height: adaptive.space(26)),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onDone,
              style: ElevatedButton.styleFrom(
                backgroundColor: AudyColors.skyBlue,
                foregroundColor: AudyColors.textOnColor,
                minimumSize: Size.fromHeight(adaptive.space(62)),
              ),
              child: Text(
                AudyScope.of(context).tr('finish'),
                style: AudyTypography.buttonText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.adaptive, required this.onRetry});

  final AudyAdaptive adaptive;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.info_rounded,
            size: adaptive.space(76),
            color: AudyColors.warning,
          ),
          SizedBox(height: adaptive.space(16)),
          Text(
            AudyScope.of(context).tr('flashcard_error'),
            style: AudyTypography.headingSmall,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: adaptive.space(24)),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: Text(AudyScope.of(context).tr('try_again')),
          ),
        ],
      ),
    );
  }
}
