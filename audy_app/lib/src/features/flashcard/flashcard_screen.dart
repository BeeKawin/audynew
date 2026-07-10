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

// ---------------------------------------------------------------------------
// Header
// ---------------------------------------------------------------------------

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
// Play — pure drag-and-drop
// ---------------------------------------------------------------------------

class _PlayState extends StatelessWidget {
  const _PlayState({
    required this.adaptive,
    required this.controller,
    required this.onSubmit,
  });

  final AudyAdaptive adaptive;
  final FlashcardController controller;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final isBusy = controller.phase == FlashcardGamePhase.validating;
    final wordCount = controller.currentRound?.wordCount ?? 3;

    return Column(
      children: [
        // --- Drop zone (selected cards) ---
        _DropZone(
          adaptive: adaptive,
          controller: controller,
          wordCount: wordCount,
        ),
        SizedBox(height: adaptive.space(14)),

        // --- Hand zone (available cards) ---
        Expanded(
          child: _HandZone(
            adaptive: adaptive,
            controller: controller,
          ),
        ),
        SizedBox(height: adaptive.space(14)),

        // Submit button
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

// ---------------------------------------------------------------------------
// Drop Zone — accepts cards from the hand, shows placed cards
// ---------------------------------------------------------------------------

class _DropZone extends StatefulWidget {
  const _DropZone({
    required this.adaptive,
    required this.controller,
    required this.wordCount,
  });

  final AudyAdaptive adaptive;
  final FlashcardController controller;
  final int wordCount;

  @override
  State<_DropZone> createState() => _DropZoneState();
}

class _DropZoneState extends State<_DropZone> {
  int? _hoveredIndex;

  @override
  Widget build(BuildContext context) {
    final selectedCards = widget.controller.selectedCards;
    final wordCount = widget.wordCount;

    // Calculate responsive card dimensions based on wordCount
    final cardWidth = wordCount <= 3 ? 120.0 : (wordCount <= 5 ? 96.0 : 76.0);
    final cardHeight = cardWidth * 1.3;

    final lang = AudyScope.of(context).currentLanguage;
    final placeholderText = lang == 'th' ? 'วางการ์ดที่นี่' : 'Place card here';

    return DragTarget<FlashcardCard>(
      onWillAcceptWithDetails: (details) {
        if (widget.controller.phase != FlashcardGamePhase.playing) return false;
        return true;
      },
      onAcceptWithDetails: (details) {
        setState(() {
          _hoveredIndex = null;
        });
        widget.controller.placeCardAt(details.data, selectedCards.length);
      },
      builder: (context, candidateData, rejectedData) {
        final isHoveringBackground = candidateData.isNotEmpty;
        return AnimatedContainer(
          duration: AudyAnimation.normal,
          width: double.infinity,
          constraints: BoxConstraints(minHeight: cardHeight + widget.adaptive.space(28)),
          padding: EdgeInsets.all(widget.adaptive.space(12)),
          decoration: BoxDecoration(
            color: isHoveringBackground
                ? AudyColors.skyBlue.withValues(alpha: 0.16)
                : AudyColors.skyBlue.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(AudySpacing.radiusLarge),
            border: Border.all(
              color: isHoveringBackground
                  ? AudyColors.skyBlue
                  : AudyColors.skyBlue.withValues(alpha: 0.3),
              width: 2,
            ),
          ),
          child: selectedCards.isEmpty
              ? Center(
                  child: Text(
                    placeholderText,
                    style: AudyTypography.bodyMedium.copyWith(
                      color: AudyColors.textLight,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
              : Wrap(
                  alignment: WrapAlignment.center,
                  spacing: widget.adaptive.space(8),
                  runSpacing: widget.adaptive.space(8),
                  children: List.generate(selectedCards.length, (index) {
                    final card = selectedCards[index];

                    return DragTarget<FlashcardCard>(
                      onWillAcceptWithDetails: (details) {
                        if (widget.controller.phase != FlashcardGamePhase.playing) return false;
                        return true;
                      },
                      onAcceptWithDetails: (details) {
                        setState(() {
                          _hoveredIndex = null;
                        });
                        widget.controller.placeCardAt(details.data, index);
                      },
                      onMove: (details) {
                        if (_hoveredIndex != index) {
                          setState(() {
                            _hoveredIndex = index;
                          });
                        }
                      },
                      onLeave: (data) {
                        if (_hoveredIndex == index) {
                          setState(() {
                            _hoveredIndex = null;
                          });
                        }
                      },
                      builder: (context, candidateData, rejectedData) {
                        final isHoveringSlot = candidateData.isNotEmpty;
                        final isShifted = _hoveredIndex != null && index >= _hoveredIndex!;
                        final spacingFraction = 8.0 / cardWidth;
                        final slideOffset = isShifted ? Offset(1.0 + spacingFraction, 0.0) : Offset.zero;

                        return AnimatedScale(
                          scale: isHoveringSlot ? 1.06 : 1.0,
                          duration: AudyAnimation.quick,
                          curve: Curves.easeOutCubic,
                          child: AnimatedContainer(
                            duration: AudyAnimation.quick,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(AudySpacing.radiusLarge),
                              color: isHoveringSlot
                                  ? AudyColors.skyBlue.withValues(alpha: 0.16)
                                  : Colors.transparent,
                              border: Border.all(
                                color: isHoveringSlot
                                    ? AudyColors.skyBlue
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: AnimatedSlide(
                              offset: slideOffset,
                              duration: AudyAnimation.normal,
                              curve: Curves.easeOutCubic,
                              child: _DraggablePlacedCard(
                                card: card,
                                controller: widget.controller,
                                adaptive: widget.adaptive,
                                width: cardWidth,
                                height: cardHeight,
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }),
                ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Draggable placed card — can be dragged back to the hand zone
// ---------------------------------------------------------------------------

class _DraggablePlacedCard extends StatelessWidget {
  const _DraggablePlacedCard({
    required this.card,
    required this.controller,
    required this.adaptive,
    required this.width,
    required this.height,
  });

  final FlashcardCard card;
  final FlashcardController controller;
  final AudyAdaptive adaptive;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Draggable<FlashcardCard>(
      data: card,
      feedback: Material(
        color: Colors.transparent,
        child: Transform.scale(
          scale: 1.06,
          child: Transform.rotate(
            angle: -0.04,
            child: FlashcardWordCard(
              card: card,
              width: width,
              height: height,
            ),
          ),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.25,
        child: FlashcardWordCard(
          card: card,
          width: width,
          height: height,
        ),
      ),
      child: FlashcardWordCard(
        card: card,
        width: width,
        height: height,
        status: controller.statusForCard(card.id),
        onTap: () {
          controller.removeSelectedCard(card);
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Hand Zone — shows the shuffled deck, accepts cards dragged back from drop zone
// ---------------------------------------------------------------------------

class _HandZone extends StatelessWidget {
  const _HandZone({
    required this.adaptive,
    required this.controller,
  });

  final AudyAdaptive adaptive;
  final FlashcardController controller;

  @override
  Widget build(BuildContext context) {
    final wordCount = controller.currentRound?.wordCount ?? 3;
    final cardWidth = wordCount <= 3 ? 120.0 : (wordCount <= 5 ? 96.0 : 76.0);
    final cardHeight = cardWidth * 1.3;

    return DragTarget<FlashcardCard>(
      onWillAcceptWithDetails: (details) {
        if (controller.phase != FlashcardGamePhase.playing) return false;
        // Only accept cards that ARE in selectedCards (returning them)
        return controller.selectedCards.any((c) => c.id == details.data.id);
      },
      onAcceptWithDetails: (details) {
        controller.removeSelectedCard(details.data);
      },
      builder: (context, candidateData, rejectedData) {
        final isHovering = candidateData.isNotEmpty;
        return AnimatedContainer(
          duration: AudyAnimation.normal,
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AudySpacing.radiusLarge),
            color: isHovering
                ? AudyColors.warning.withValues(alpha: 0.08)
                : Colors.transparent,
          ),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Container(
              constraints: BoxConstraints(
                minHeight: adaptive.space(200),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: adaptive.space(8),
                runSpacing: adaptive.space(8),
                children: controller.handCards.map((card) {
                  return Draggable<FlashcardCard>(
                    data: card,
                    feedback: Material(
                      color: Colors.transparent,
                      child: Transform.scale(
                        scale: 1.06,
                        child: Transform.rotate(
                          angle: 0.04,
                          child: FlashcardWordCard(
                            card: card,
                            width: cardWidth,
                            height: cardHeight,
                          ),
                        ),
                      ),
                    ),
                    childWhenDragging: Opacity(
                      opacity: 0.35,
                      child: FlashcardWordCard(
                        card: card,
                        width: cardWidth,
                        height: cardHeight,
                      ),
                    ),
                    child: FlashcardWordCard(
                      card: card,
                      width: cardWidth,
                      height: cardHeight,
                      onTap: () {
                        controller.selectCard(card);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        );
      },
    );
  }
}

// Empty slot removed

// ---------------------------------------------------------------------------
// Complete
// ---------------------------------------------------------------------------

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
