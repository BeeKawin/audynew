import 'dart:async';
import 'dart:math' as math;

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
  const FlashcardScreen({super.key, required this.difficulty});

  final FlashcardDifficulty difficulty;

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
  String? _spokenRoundId;

  @override
  void initState() {
    super.initState();
    _controller = FlashcardController(difficulty: widget.difficulty)
      ..addListener(_onControllerChanged);
    _sessionStartedAt = DateTime.now();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final scope = AudyScope.of(context);
      final language = scope.currentLanguage;
      final teacherId = scope.currentUser?.teacherId;
      unawaited(_controller.startSession(language, teacherId: teacherId));
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

    if (_controller.phase == FlashcardGamePhase.playing) {
      final round = _controller.currentRound;
      if (round != null && _spokenRoundId != round.roundId) {
        _spokenRoundId = round.roundId;
        unawaited(_speakText(round.scenario, round.language));
      }
    }

    if (_controller.phase == FlashcardGamePhase.feedback) {
      _scheduleFeedbackResolve();
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

  void _scheduleFeedbackResolve() {
    _feedbackTimer?.cancel();
    // Hold the coloured feedback briefly, then lock correct cards and gently
    // return the wrong ones to the hand for another try.
    _feedbackTimer = Timer(const Duration(milliseconds: 1400), () {
      if (!mounted) return;
      unawaited(_controller.continueAfterFeedback());
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
    // Gentle, non-punishing feedback: celebrate a full sentence, otherwise a
    // soft "try again" rather than a harsh buzzer.
    if (_controller.lastValidation?.isCorrect == true) {
      SoundService.instance.playCorrect();
    } else {
      SoundService.instance.playTryAgain();
    }
  }

  Future<void> _recordCompletion() async {
    if (_hasRecordedCompletion) return;
    _hasRecordedCompletion = true;

    final appController = AudyScope.of(context);
    final endedAt = DateTime.now();
    final correct = _controller.sessionCorrectCount;
    final total = _controller.sessionTotalCards;
    final mistakes = _controller.sessionMistakes;
    final points = (correct * 5 - mistakes).clamp(0, correct * 5);
    final stars = mistakes == 0
        ? 3
        : (mistakes <= total ? 2 : 1);

    await appController.trackFlashcardCompleted();
    if (points > 0) {
      await appController.addPoints(points);
    }
    await appController.recordAnalyticsSession(
      GameSessionData.fromTimes(
        gameType: 'flashcard',
        difficulty: widget.difficulty.name,
        correctActions: correct,
        totalActions: total + mistakes,
        starsEarned: stars,
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
              roundNumber: _controller.roundNumber,
              totalRounds: FlashcardController.totalRounds,
              lockedCount: _controller.lockedCount,
              totalCards: _controller.totalCards,
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
          onSubmit: _handleSubmit,
          onSpeakScenario: () {
            final scenario = _controller.currentRound?.scenario ?? '';
            final lang = _controller.currentRound?.language ?? 'en';
            unawaited(_speakText(scenario, lang));
          },
        );
      case FlashcardGamePhase.complete:
        return _CompleteState(
          adaptive: adaptive,
          correctCount: _controller.sessionCorrectCount,
          totalCards: _controller.sessionTotalCards,
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

// ---------------------------------------------------------------------------
// Header
// ---------------------------------------------------------------------------

class _Header extends StatelessWidget {
  const _Header({
    required this.adaptive,
    required this.roundNumber,
    required this.totalRounds,
    required this.lockedCount,
    required this.totalCards,
    required this.onBack,
    this.guide,
  });

  final AudyAdaptive adaptive;
  final int roundNumber;
  final int totalRounds;
  final int lockedCount;
  final int totalCards;
  final VoidCallback onBack;
  final Widget? guide;

  @override
  Widget build(BuildContext context) {
    final isThai = AudyScope.of(context).currentLanguage == 'th';
    final progress = isThai
        ? 'รอบ $roundNumber/$totalRounds  •  ถูกแล้ว $lockedCount/$totalCards'
        : 'Round $roundNumber/$totalRounds  •  Placed $lockedCount/$totalCards';

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
                progress,
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

// ---------------------------------------------------------------------------
// Loading
// ---------------------------------------------------------------------------

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

// ---------------------------------------------------------------------------
// Preview
// ---------------------------------------------------------------------------

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

// ---------------------------------------------------------------------------
// Play — tap to move cards between deck and hand
// ---------------------------------------------------------------------------

class _PlayState extends StatelessWidget {
  const _PlayState({
    required this.adaptive,
    required this.controller,
    required this.onSubmit,
    this.onSpeakScenario,
  });

  final AudyAdaptive adaptive;
  final FlashcardController controller;
  final VoidCallback onSubmit;
  final VoidCallback? onSpeakScenario;

  @override
  Widget build(BuildContext context) {
    final isBusy = controller.phase == FlashcardGamePhase.validating;
    final isThai = AudyScope.of(context).currentLanguage == 'th';
    final scenario = controller.currentRound?.scenario ?? '';

    return Column(
      children: [
        if (scenario.isNotEmpty) ...[
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              vertical: adaptive.space(12),
              horizontal: adaptive.space(16),
            ),
            decoration: BoxDecoration(
              color: AudyColors.backgroundSoft,
              borderRadius: BorderRadius.circular(AudySpacing.radiusLarge),
              boxShadow: AudyShadows.cardShadow,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    scenario,
                    style: AudyTypography.headingSmall,
                  ),
                ),
                if (onSpeakScenario != null) ...[
                  SizedBox(width: adaptive.space(12)),
                  IconButton(
                    onPressed: onSpeakScenario,
                    icon: const Icon(
                      Icons.volume_up_rounded,
                      color: AudyColors.textPrimary,
                      size: 32,
                    ),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(height: adaptive.space(14)),
        ],
        // Deck — fixed slots the player fills to build the sentence.
        _DeckZone(adaptive: adaptive, controller: controller),
        SizedBox(height: adaptive.space(14)),

        // Hand — the remaining shuffled cards to choose from.
        Expanded(
          child: _HandZone(adaptive: adaptive, controller: controller),
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
                  ? (isThai ? 'กำลังตรวจ' : 'Checking')
                  : (isThai ? 'ตรวจคำตอบ' : 'Check'),
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

// ---------------------------------------------------------------------------
// Deck — fixed slots, tap a placed (unlocked) card to return it to the hand
// ---------------------------------------------------------------------------

class _DeckZone extends StatelessWidget {
  const _DeckZone({required this.adaptive, required this.controller});

  final AudyAdaptive adaptive;
  final FlashcardController controller;

  @override
  Widget build(BuildContext context) {
    final count = controller.cardCount;
    final cardWidth = count <= 3 ? 108.0 : 88.0;
    final cardHeight = cardWidth * 1.3;
    final selected = controller.selectedCards;

    return _ShakeOnChange(
      trigger: controller.mistakes,
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(minHeight: cardHeight + adaptive.space(24)),
        padding: EdgeInsets.all(adaptive.space(12)),
        decoration: BoxDecoration(
          color: AudyColors.skyBlue.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(AudySpacing.radiusLarge),
          border: Border.all(
            color: AudyColors.skyBlue.withValues(alpha: 0.3),
            width: 2,
          ),
        ),
        child: Wrap(
          alignment: WrapAlignment.center,
          spacing: adaptive.space(8),
          runSpacing: adaptive.space(8),
          children: List.generate(count, (index) {
            final card = index < selected.length ? selected[index] : null;
            return _DeckSlot(
              index: index,
              card: card,
              controller: controller,
              width: cardWidth,
              height: cardHeight,
            );
          }),
        ),
      ),
    );
  }
}

class _DeckSlot extends StatelessWidget {
  const _DeckSlot({
    required this.index,
    required this.card,
    required this.controller,
    required this.width,
    required this.height,
  });

  final int index;
  final FlashcardCard? card;
  final FlashcardController controller;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final placed = card;
    if (placed != null) {
      final locked = controller.isLocked(placed.id);
      return FlashcardWordCard(
        key: ValueKey('slot_${index}_${placed.id}'),
        card: placed,
        width: width,
        height: height,
        status: controller.statusForCard(placed.id),
        onTap: locked ? null : () => controller.removeSelectedCard(placed),
      );
    }

    // Empty slot: ghost hint (match-to-sample) or a plain placeholder.
    final hint = controller.hintCardForSlot(index);
    if (hint != null) {
      return _GhostHintSlot(
        card: hint,
        width: width,
        height: height,
        showWord: controller.difficulty.showHintWord,
      );
    }

    return _EmptySlot(width: width, height: height);
  }
}

/// A faded target card shown in an empty deck slot so the player can match the
/// picture on a hand card to the picture in the slot.
class _GhostHintSlot extends StatelessWidget {
  const _GhostHintSlot({
    required this.card,
    required this.width,
    required this.height,
    required this.showWord,
  });

  final FlashcardCard card;
  final double width;
  final double height;
  final bool showWord;

  @override
  Widget build(BuildContext context) {
    final emoji = card.imageAsset.startsWith('emoji:')
        ? card.imageAsset.substring(6)
        : null;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AudyColors.skyBlue.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(AudySpacing.radiusLarge),
        border: Border.all(
          color: AudyColors.skyBlue.withValues(alpha: 0.35),
          width: 2,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (emoji != null)
              Opacity(
                opacity: 0.5,
                child: Text(emoji, style: TextStyle(fontSize: width * 0.4)),
              )
            else
              Icon(
                Icons.help_outline_rounded,
                size: width * 0.36,
                color: AudyColors.skyBlue.withValues(alpha: 0.5),
              ),
            if (showWord) ...[
              SizedBox(height: width * 0.05),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: width * 0.08),
                child: Text(
                  card.displayText,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: width * 0.13,
                    fontWeight: FontWeight.w700,
                    color: AudyColors.textLight,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _EmptySlot extends StatelessWidget {
  const _EmptySlot({required this.width, required this.height});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AudyColors.backgroundSoft.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(AudySpacing.radiusLarge),
        border: Border.all(
          color: AudyColors.borderLight,
          width: 2,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Hand — remaining cards; tap one to place it in the next open slot
// ---------------------------------------------------------------------------

class _HandZone extends StatelessWidget {
  const _HandZone({required this.adaptive, required this.controller});

  final AudyAdaptive adaptive;
  final FlashcardController controller;

  @override
  Widget build(BuildContext context) {
    final count = controller.cardCount;
    final cardWidth = count <= 3 ? 108.0 : 88.0;
    final cardHeight = cardWidth * 1.3;
    final canPlace = !controller.isDeckFull;

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Container(
        constraints: BoxConstraints(minHeight: adaptive.space(200)),
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Wrap(
          alignment: WrapAlignment.center,
          spacing: adaptive.space(8),
          runSpacing: adaptive.space(8),
          children: controller.handCards.map((card) {
            return AnimatedEntrance(
              key: ValueKey('hand_${card.id}'),
              child: FlashcardWordCard(
                card: card,
                width: cardWidth,
                height: cardHeight,
                onTap: canPlace ? () => controller.selectCard(card) : null,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Complete
// ---------------------------------------------------------------------------

class _CompleteState extends StatelessWidget {
  const _CompleteState({
    required this.adaptive,
    required this.correctCount,
    required this.totalCards,
    required this.onDone,
  });

  final AudyAdaptive adaptive;
  final int correctCount;
  final int totalCards;
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
            '$correctCount / $totalCards',
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

// ---------------------------------------------------------------------------
// Error
// ---------------------------------------------------------------------------

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

// ---------------------------------------------------------------------------
// Animated Entrance
// ---------------------------------------------------------------------------

class AnimatedEntrance extends StatelessWidget {
  const AnimatedEntrance({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: AudyAnimation.normal,
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.84 + 0.16 * value,
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

// ---------------------------------------------------------------------------
// Gentle shake — a soft horizontal nudge when [trigger] changes (a wrong card
// bounced back). Skipped entirely when the platform disables animations.
// ---------------------------------------------------------------------------

class _ShakeOnChange extends StatefulWidget {
  const _ShakeOnChange({required this.trigger, required this.child});

  final int trigger;
  final Widget child;

  @override
  State<_ShakeOnChange> createState() => _ShakeOnChangeState();
}

class _ShakeOnChangeState extends State<_ShakeOnChange>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 320),
  );

  @override
  void didUpdateWidget(_ShakeOnChange oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.trigger != oldWidget.trigger && widget.trigger > 0) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).disableAnimations) return widget.child;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // Two soft cycles, decaying — a nudge, not a jolt.
        final t = _controller.value;
        final dx = (1 - t) * 6.0 * math.sin(t * math.pi * 4);
        return Transform.translate(offset: Offset(dx, 0), child: child);
      },
      child: widget.child,
    );
  }
}
