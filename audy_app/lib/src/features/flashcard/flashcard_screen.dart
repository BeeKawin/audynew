import 'dart:async';
import 'dart:math';
import 'dart:ui';

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
          child: DragTarget<FlashcardCard>(
            onWillAcceptWithDetails: (details) =>
                controller.phase == FlashcardGamePhase.playing &&
                controller.selectedCards.any((c) => c.id == details.data.id),
            onAcceptWithDetails: (details) {
              onPlacedCardTap(details.data);
            },
            builder: (context, candidateData, rejectedData) {
              final isHovering = candidateData.isNotEmpty;
              return AnimatedContainer(
                duration: AudyAnimation.normal,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AudySpacing.radiusLarge),
                  color: isHovering
                      ? AudyColors.warning.withValues(alpha: 0.08)
                      : Colors.transparent,
                ),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      spacing: adaptive.space(12),
                      runSpacing: adaptive.space(12),
                      children: controller.handCards
                          .map(
                            (card) => Draggable<FlashcardCard>(
                              data: card,
                              feedback: Material(
                                color: Colors.transparent,
                                child: Transform.scale(
                                  scale: 1.06,
                                  child: Transform.rotate(
                                    angle: 0.04,
                                    child: FlashcardWordCard(card: card),
                                  ),
                                ),
                              ),
                              childWhenDragging: Opacity(
                                opacity: 0.35,
                                child: FlashcardWordCard(card: card),
                              ),
                              child: FlashcardWordCard(
                                card: card,
                                onTap: isBusy ? null : () => onCardSelected(card),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ),
              );
            },
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

class _SentenceSlots extends StatefulWidget {
  const _SentenceSlots({
    required this.adaptive,
    required this.controller,
    required this.onPlacedCardTap,
  });

  final AudyAdaptive adaptive;
  final FlashcardController controller;
  final ValueChanged<FlashcardCard> onPlacedCardTap;

  @override
  State<_SentenceSlots> createState() => _SentenceSlotsState();
}

class _SentenceSlotsState extends State<_SentenceSlots> {
  int? _hoverIndex;
  FlashcardCard? _draggingCard;

  @override
  Widget build(BuildContext context) {
    final round = widget.controller.currentRound;
    final slotCount = round?.wordCount ?? 3;
    final selectedCards = widget.controller.selectedCards;

    // Compute the preview list based on active drag and hover position
    final List<FlashcardCard> previewList = [];
    final activeCards = List<FlashcardCard>.from(selectedCards);

    if (_draggingCard != null && _hoverIndex != null) {
      final existingIndex = activeCards.indexWhere((c) => c.id == _draggingCard!.id);
      if (existingIndex != -1) {
        activeCards.removeAt(existingIndex);
      }

      var index = _hoverIndex!;
      if (index > activeCards.length) {
        index = activeCards.length;
      }
      activeCards.insert(index, _draggingCard!);
    }

    previewList.addAll(activeCards);

    // Build the grid slots at fixed locations
    final List<Widget> items = List.generate(slotCount, (index) {
      return _buildSlot(index, previewList, _draggingCard);
    });

    return DragTarget<FlashcardCard>(
      onWillAcceptWithDetails: (details) {
        if (widget.controller.phase != FlashcardGamePhase.playing) return false;
        if (_draggingCard == null) {
          setState(() {
            _draggingCard = details.data;
          });
        }
        return true;
      },
      onLeave: (details) {
        setState(() {
          _hoverIndex = null;
          _draggingCard = null;
        });
      },
      onAcceptWithDetails: (details) {
        final index = _hoverIndex ?? selectedCards.length;
        widget.controller.insertCard(details.data, index);
        setState(() {
          _hoverIndex = null;
          _draggingCard = null;
        });
      },
      builder: (context, candidateData, rejectedData) {
        return Container(
          width: double.infinity,
          constraints: BoxConstraints(minHeight: widget.adaptive.space(184)),
          padding: EdgeInsets.all(widget.adaptive.space(14)),
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
            spacing: widget.adaptive.space(10),
            runSpacing: widget.adaptive.space(10),
            children: items,
          ),
        );
      },
    );
  }

  Widget _buildSlot(int index, List<FlashcardCard> previewList, FlashcardCard? draggingCard) {
    return DragTarget<FlashcardCard>(
      onWillAcceptWithDetails: (details) => widget.controller.phase == FlashcardGamePhase.playing,
      onMove: (details) {
        if (_hoverIndex != index) {
          setState(() {
            _hoverIndex = index;
          });
        }
      },
      onAcceptWithDetails: (details) {
        widget.controller.insertCard(details.data, index);
        setState(() {
          _hoverIndex = null;
          _draggingCard = null;
        });
      },
      builder: (context, candidateData, rejectedData) {
        Widget child;
        if (index < previewList.length) {
          final card = previewList[index];
          child = _buildDraggableCard(card, index, draggingCard);
        } else {
          child = _EmptySlot(
            key: ValueKey('empty_$index'),
            adaptive: widget.adaptive,
          );
        }

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          child: child,
        );
      },
    );
  }

  Widget _buildDraggableCard(FlashcardCard card, int index, FlashcardCard? draggingCard) {
    final isCurrentDragging = draggingCard != null && draggingCard.id == card.id;

    Widget childWidget;
    Widget childWhenDraggingWidget;

    if (isCurrentDragging) {
      childWidget = _AnimatedPlaceholder(
        key: ValueKey('placeholder_${card.id}'),
        adaptive: widget.adaptive,
      );
      childWhenDraggingWidget = _AnimatedPlaceholder(
        key: ValueKey('placeholder_dragging_${card.id}'),
        adaptive: widget.adaptive,
      );
    } else {
      childWidget = FlashcardWordCard(
        key: ValueKey('card_${card.id}'),
        card: card,
        status: widget.controller.statusForCard(card.id),
        onTap: widget.controller.phase == FlashcardGamePhase.playing
            ? () => widget.onPlacedCardTap(card)
            : null,
      );
      childWhenDraggingWidget = Opacity(
        opacity: 0.25,
        child: FlashcardWordCard(card: card),
      );
    }

    return Draggable<FlashcardCard>(
      key: ValueKey('draggable_${card.id}'),
      data: card,
      feedback: Material(
        color: Colors.transparent,
        child: Transform.scale(
          scale: 1.06,
          child: Transform.rotate(
            angle: 0.04,
            child: FlashcardWordCard(card: card),
          ),
        ),
      ),
      childWhenDragging: childWhenDraggingWidget,
      onDragStarted: () {
        setState(() {
          _draggingCard = card;
          _hoverIndex = index;
        });
      },
      onDragEnd: (details) {
        setState(() {
          _draggingCard = null;
          _hoverIndex = null;
        });
      },
      child: childWidget,
    );
  }
}

class _AnimatedPlaceholder extends StatefulWidget {
  const _AnimatedPlaceholder({super.key, required this.adaptive});

  final AudyAdaptive adaptive;

  @override
  State<_AnimatedPlaceholder> createState() => _AnimatedPlaceholderState();
}

class _AnimatedPlaceholderState extends State<_AnimatedPlaceholder> {
  double _width = 0.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _width = 132.0;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      width: _width,
      height: 172,
      child: _width > 10
          ? Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              child: CustomPaint(
                painter: _DashedRectPainter(
                  color: AudyColors.skyBlue.withValues(alpha: 0.5),
                  strokeWidth: 3,
                  gap: 6,
                  dash: 10,
                  radius: AudySpacing.radiusLarge,
                ),
                child: Container(
                  color: AudyColors.skyBlue.withValues(alpha: 0.08),
                  child: Center(
                    child: Icon(
                      Icons.arrow_downward_rounded,
                      size: widget.adaptive.space(38),
                      color: AudyColors.skyBlue.withValues(alpha: 0.6),
                    ),
                  ),
                ),
              ),
            )
          : const SizedBox.shrink(),
    );
  }
}

class _DashedRectPainter extends CustomPainter {
  const _DashedRectPainter({
    required this.color,
    required this.strokeWidth,
    required this.gap,
    required this.dash,
    required this.radius,
  });

  final Color color;
  final double strokeWidth;
  final double gap;
  final double dash;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final RRect rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        strokeWidth / 2,
        strokeWidth / 2,
        size.width - strokeWidth,
        size.height - strokeWidth,
      ),
      Radius.circular(radius),
    );

    final Path path = Path()..addRRect(rrect);
    final Path dashedPath = Path();

    double distance = 0.0;
    for (final PathMetric measurePath in path.computeMetrics()) {
      while (distance < measurePath.length) {
        dashedPath.addPath(
          measurePath.extractPath(distance, distance + dash),
          Offset.zero,
        );
        distance += dash + gap;
      }
    }
    canvas.drawPath(dashedPath, paint);
  }

  @override
  bool shouldRepaint(covariant _DashedRectPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.gap != gap ||
        oldDelegate.dash != dash ||
        oldDelegate.radius != radius;
  }
}

class _EmptySlot extends StatelessWidget {
  const _EmptySlot({super.key, required this.adaptive});

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
