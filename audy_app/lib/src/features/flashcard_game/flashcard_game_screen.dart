import 'package:flutter/material.dart';

import '../../core/app_routes.dart';
import '../../core/audy_theme.dart';
import '../../core/audy_ui.dart';
import '../../data/models/game_session_model.dart';
import '../../services/game_tts_service.dart';
import '../../services/sound_service.dart';
import '../../state/audy_controller.dart';
import '../../widgets/game_guide_box.dart';
import '../sorting_game/sort_game_widgets.dart'
    show ABAGameFeedbackOverlay, StarRewardDisplay;
import 'flashcard_engine.dart';
import 'flashcard_models.dart';
import 'flashcard_result_screen.dart';
import 'flashcard_widgets.dart';

String _tr(BuildContext context, String key, {Map<String, String>? params}) {
  return AudyScope.of(context).tr(key, params: params);
}

class FlashCardGameScreen extends StatefulWidget {
  const FlashCardGameScreen({super.key, required this.level});

  final FlashLevel level;

  @override
  State<FlashCardGameScreen> createState() => _FlashCardGameScreenState();
}

class _FlashCardGameScreenState extends State<FlashCardGameScreen> {
  late final FlashCardEngine _engine;
  final GameTtsService _tts = GameTtsService();
  bool _showGuide = true;
  bool _sessionRecorded = false;
  bool _started = false;
  bool _handCollapsed = false;

  // Sequential deal-in state.
  int _animatedRound = -1;
  int _dealtCount = 0;
  bool _dealing = false;

  // Per-slot feedback glow during left→right submit evaluation.
  List<CardGlow> _glow = const [];
  bool _runningFeedback = false;

  @override
  void initState() {
    super.initState();
    _engine = FlashCardEngine(languageProvider: _lang);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Start once the InheritedWidget (AudyScope) is available so the engine's
    // languageProvider can read the current language.
    if (!_started) {
      _started = true;
      _engine.startSession(widget.level);
    }
  }

  @override
  void dispose() {
    _tts.dispose();
    _engine.dispose();
    super.dispose();
  }

  String _lang() => mounted ? AudyScope.of(context).currentLanguage : 'en';

  /// Deal cards one at a time, speaking each word before the next appears.
  void _maybeStartDeal() {
    if (_engine.sessionComplete || _engine.loading || _dealing) return;
    if (_engine.hand.isEmpty) return;
    if (_engine.roundIndex == _animatedRound) return;
    _animatedRound = _engine.roundIndex;
    WidgetsBinding.instance.addPostFrameCallback((_) => _runDealSequence());
  }

  Future<void> _runDealSequence() async {
    if (!mounted) return;
    final hand = _engine.hand;
    final reduce = MediaQuery.of(context).disableAnimations;
    setState(() {
      _dealing = true;
      _dealtCount = reduce ? hand.length : 0;
      _glow = const [];
    });
    if (reduce) {
      if (mounted) setState(() => _dealing = false);
      return;
    }
    final lang = _lang();
    final thai = lang == 'th';
    for (var i = 0; i < hand.length; i++) {
      if (!mounted || _engine.roundIndex != _animatedRound) return;
      setState(() => _dealtCount = i + 1);
      await _tts.speak(hand[i].display(lang), thai: thai);
    }
    if (mounted) setState(() => _dealing = false);
  }

  /// Submit → validate → play left→right speak + glow, then advance/retry.
  Future<void> _onSubmit() async {
    if (_runningFeedback || !_engine.canSubmit) return;
    _runningFeedback = true;
    SoundService.instance.playTap();

    await _engine.submit();
    if (!mounted) {
      _runningFeedback = false;
      return;
    }

    final reduce = MediaQuery.of(context).disableAnimations;
    final lang = _lang();
    final thai = lang == 'th';
    final n = _engine.slots.length;
    final errs = _engine.errorIndices.toSet();
    final correct = _engine.isCorrect;
    setState(() => _glow = List<CardGlow>.filled(n, CardGlow.none));

    for (var i = 0; i < n; i++) {
      if (!mounted) {
        _runningFeedback = false;
        return;
      }
      // Only the incorrect card(s) glow red; correct cards stay neutral.
      final wrong = !correct && errs.contains(i);
      setState(() => _glow[i] = wrong ? CardGlow.wrong : CardGlow.none);
      await _tts.speak(_engine.slots[i]?.display(lang) ?? '', thai: thai);
      if (!reduce) {
        await Future.delayed(const Duration(milliseconds: 260));
      }
    }

    await Future.delayed(const Duration(milliseconds: 350));
    if (!mounted) {
      _runningFeedback = false;
      return;
    }
    setState(() => _glow = const []);
    _engine.completeFeedback();
    _runningFeedback = false;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _engine,
      builder: (context, _) {
        if (_engine.sessionComplete) return _buildResult();

        _maybeStartDeal();

        return AudyResponsivePage(
          scrollable: false,
          builder: (context, adaptive) {
            return Column(
              children: [
                _buildHeader(adaptive),
                SizedBox(height: adaptive.space(10)),
                if (_showGuide) ...[
                  GameGuideBox(
                    message: _tr(context, 'flashcard_guide'),
                    onDismissed: () => setState(() => _showGuide = false),
                  ),
                  SizedBox(height: adaptive.space(10)),
                ],
                _buildProgress(adaptive),
                SizedBox(height: adaptive.space(10)),
                Expanded(
                  child: Stack(
                    children: [
                      adaptive.isPhone
                          ? _buildPortrait(adaptive)
                          : _buildLandscape(adaptive),
                      if (_engine.loading)
                        const Positioned.fill(
                          child: Center(child: CircularProgressIndicator()),
                        ),
                      if (_engine.hasVerdict)
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: adaptive.space(8),
                          child: Center(
                            child: ABAGameFeedbackOverlay(
                              message: _tr(context, _engine.feedbackKey),
                              isCorrect: _engine.isCorrect,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ─── Header ───
  Widget _buildHeader(AudyAdaptive adaptive) {
    return Row(
      children: [
        InkWell(
          onTap: () {
            SoundService.instance.playTap();
            Navigator.pop(context);
          },
          borderRadius: BorderRadius.circular(AudySpacing.radiusMedium),
          child: SizedBox(
            width: adaptive.space(48),
            height: adaptive.space(48),
            child: const Icon(Icons.arrow_back_rounded, size: AudySpacing.iconMedium),
          ),
        ),
        SizedBox(width: adaptive.space(8)),
        Icon(
          Icons.style_rounded,
          size: adaptive.space(30),
          color: widget.level.primaryColor,
        ),
        SizedBox(width: adaptive.space(8)),
        Expanded(
          child: Text(
            _tr(context, 'flashcard_game'),
            style: AudyTypography.headingSmall,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
        ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: adaptive.isPhone ? adaptive.space(150) : adaptive.space(260),
          ),
          child: StarRewardDisplay(
            starsEarned: _engine.totalStars,
            maxStars: _engine.maxStars,
            starSize: adaptive.space(22),
          ),
        ),
      ],
    );
  }

  Widget _buildProgress(AudyAdaptive adaptive) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          _tr(context, 'round_format', params: {
            'current': _engine.roundNumber.toString(),
            'total': _engine.totalRounds.toString(),
          }),
          style: AudyTypography.labelLarge,
        ),
        Flexible(
          child: Text(
            _tr(context, widget.level.instructionKey),
            style: AudyTypography.bodySmall,
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
    );
  }

  // ─── Card sizing ───
  double _cardW(AudyAdaptive adaptive) =>
      adaptive.isPhone ? adaptive.space(78) : adaptive.space(96);
  double _cardH(AudyAdaptive adaptive) =>
      adaptive.isPhone ? adaptive.space(112) : adaptive.space(136);

  // ─── Landscape: rail + controls centered, hand bottom (bounded) ───
  Widget _buildLandscape(AudyAdaptive adaptive) {
    return Column(
      children: [
        Expanded(
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildSentenceRail(adaptive),
                  SizedBox(height: adaptive.space(16)),
                  _buildControls(adaptive),
                ],
              ),
            ),
          ),
        ),
        Flexible(child: _buildHand(adaptive)),
      ],
    );
  }

  // ─── Portrait: rail, controls, hand bottom (bounded) ───
  Widget _buildPortrait(AudyAdaptive adaptive) {
    return Column(
      children: [
        Expanded(
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildSentenceRail(adaptive),
                  SizedBox(height: adaptive.space(16)),
                  _buildControls(adaptive),
                ],
              ),
            ),
          ),
        ),
        Flexible(child: _buildHand(adaptive)),
      ],
    );
  }

  Widget _buildSentenceRail(AudyAdaptive adaptive) {
    final w = _cardW(adaptive);
    final h = _cardH(adaptive);
    final gap = adaptive.space(8);

    final slots = List.generate(_engine.slots.length, (i) {
      final hintPos =
          i < _engine.hintPattern.length ? _engine.hintPattern[i] : null;
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: gap / 2),
        child: SentenceSlot(
          index: i,
          card: _engine.slots[i],
          width: w,
          height: h,
          hint: _engine.hint,
          hintPos: hintPos,
          enabled: !_engine.showingFeedback,
          glow: i < _glow.length ? _glow[i] : CardGlow.none,
          onDropFromHand: (cardId) {
            SoundService.instance.playTap();
            _engine.placeFromHand(cardId, i);
          },
          onDropFromSlot: (from) {
            SoundService.instance.playTap();
            _engine.moveBetweenSlots(from, i);
          },
          onTapCard: () {
            SoundService.instance.playTap();
            _engine.returnToHand(i);
          },
        ),
      );
    });

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(mainAxisSize: MainAxisSize.min, children: slots),
    );
  }

  // ─── Clear Answer + Submit ───
  Widget _buildControls(AudyAdaptive adaptive) {
    final canClear =
        _engine.hasPlacedCards && !_engine.showingFeedback && !_dealing;
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          height: adaptive.space(56),
          child: OutlinedButton.icon(
            onPressed: canClear
                ? () {
                    SoundService.instance.playTap();
                    _engine.clearAllSlots();
                  }
                : null,
            icon: Icon(Icons.refresh_rounded, size: adaptive.space(22)),
            label: Text(
              _tr(context, 'flashcard_clear_answer'),
              style: AudyTypography.buttonText,
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: AudyColors.textPrimary,
              side: const BorderSide(color: AudyColors.borderLight, width: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AudySpacing.radiusXLarge),
              ),
            ),
          ),
        ),
        SizedBox(width: adaptive.space(12)),
        SizedBox(
          width: adaptive.space(180),
          height: adaptive.space(56),
          child: ElevatedButton.icon(
            onPressed: _engine.canSubmit ? _onSubmit : null,
            icon: Icon(Icons.check_rounded, size: adaptive.space(24)),
            label:
                Text(_tr(context, 'submit'), style: AudyTypography.buttonText),
            style: ElevatedButton.styleFrom(
              backgroundColor: AudyColors.mintGreen,
              foregroundColor: AudyColors.textOnColor,
              disabledBackgroundColor: AudyColors.borderLight,
              disabledForegroundColor: AudyColors.textLight,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AudySpacing.radiusXLarge),
              ),
              elevation: _engine.canSubmit ? 4 : 0,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHand(AudyAdaptive adaptive) {
    final scale = _handCollapsed ? 0.66 : 1.0;
    final w = _cardW(adaptive) * scale;
    final h = _cardH(adaptive) * scale;
    // During dealing, reveal only the cards dealt so far.
    final cards =
        _dealing ? _engine.hand.take(_dealtCount).toList() : _engine.hand;
    // Interaction is locked while dealing or showing feedback.
    final interactive = !_dealing && !_engine.showingFeedback;

    return DragTarget<FlashDragData>(
      onAcceptWithDetails: (details) {
        final data = details.data;
        if (interactive && data.fromSlot != null) {
          SoundService.instance.playTap();
          _engine.returnToHand(data.fromSlot!);
        }
      },
      builder: (context, candidate, rejected) {
        final hovering = candidate.isNotEmpty;
        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(adaptive.space(10)),
          decoration: BoxDecoration(
            color: hovering
                ? AudyColors.skyBlue.withValues(alpha: 0.12)
                : AudyColors.backgroundSoft.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(AudySpacing.radiusLarge),
            border: Border.all(
              color: hovering ? AudyColors.skyBlue : AudyColors.borderLight,
              width: 2,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHandHeader(adaptive),
              SizedBox(height: adaptive.space(6)),
              Flexible(
                child: AnimatedSize(
                  duration: AudyAnimation.normal,
                  curve: Curves.easeOut,
                  child: _engine.hand.isEmpty
                      ? Padding(
                          padding: EdgeInsets.all(adaptive.space(12)),
                          child: Text(
                            _tr(context, 'flashcard_hand_empty'),
                            style: AudyTypography.bodySmall,
                          ),
                        )
                      : _buildHandCards(adaptive, cards, w, h, interactive),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHandHeader(AudyAdaptive adaptive) {
    return Row(
      children: [
        Icon(
          Icons.style_outlined,
          size: adaptive.space(18),
          color: AudyColors.textLight,
        ),
        SizedBox(width: adaptive.space(6)),
        Expanded(
          child: Text(
            _tr(context, 'flashcard_your_cards'),
            style: AudyTypography.labelLarge,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        IconButton(
          visualDensity: VisualDensity.compact,
          tooltip: _tr(
            context,
            _handCollapsed ? 'flashcard_expand' : 'flashcard_collapse',
          ),
          icon: Icon(
            _handCollapsed
                ? Icons.unfold_more_rounded
                : Icons.unfold_less_rounded,
            size: adaptive.space(22),
          ),
          onPressed: () {
            SoundService.instance.playTap();
            setState(() => _handCollapsed = !_handCollapsed);
          },
        ),
      ],
    );
  }

  Widget _buildHandCards(
    AudyAdaptive adaptive,
    List<FlashCard> cards,
    double w,
    double h,
    bool interactive,
  ) {
    Widget tile(FlashCard card) => _DealEntrance(
          key: ValueKey(card.id),
          child: FlashCardTile(
            card: card,
            width: w,
            height: h,
            enabled: interactive,
          ),
        );

    if (_handCollapsed) {
      // Compact single-row "deck" view.
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final card in cards)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: adaptive.space(4)),
                child: tile(card),
              ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: adaptive.space(8),
        runSpacing: adaptive.space(8),
        children: [for (final card in cards) tile(card)],
      ),
    );
  }

  // ─── Result ───
  Widget _buildResult() {
    final session = _engine.getSessionData();

    if (!_sessionRecorded) {
      _sessionRecorded = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final controller = AudyScope.of(context);
        controller.recordAnalyticsSession(
          GameSessionData.fromTimes(
            gameType: 'flashcard',
            levelId: session.levelId,
            difficulty: session.difficulty,
            correctActions: session.correctSubmits,
            totalActions: session.totalActions,
            starsEarned: session.totalStars,
            sessionStartedAt: session.sessionStartedAt,
            sessionEndedAt: session.sessionEndedAt,
          ),
        );
        controller.trackFlashcardCompleted();
      });
    }

    return FlashCardResultScreen(
      sessionData: session,
      primaryColor: widget.level.primaryColor,
      levelName: _tr(context, widget.level.difficulty.name),
      onPlayAgain: () {
        setState(() => _sessionRecorded = false);
        _engine.startSession(widget.level);
      },
      onDone: () {
        final controller = AudyScope.of(context);
        AppRoutes.navigateAfterGameCompletion(context, controller);
      },
    );
  }
}

/// Plays a one-shot fly-in + flip for a freshly dealt card. Keyed by card id so
/// each card animates once on mount; honors reduced motion.
class _DealEntrance extends StatelessWidget {
  const _DealEntrance({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).disableAnimations) return child;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 360),
      curve: Curves.easeOutCubic,
      builder: (context, t, child) {
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, (1 - t) * 24),
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.0012)
                ..rotateY((1 - t) * 1.1)
                ..scaleByDouble(0.85 + 0.15 * t, 0.85 + 0.15 * t, 1, 1),
              child: child,
            ),
          ),
        );
      },
      child: child,
    );
  }
}
