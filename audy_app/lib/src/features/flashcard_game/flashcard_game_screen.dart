import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/app_routes.dart';
import '../../core/audy_theme.dart';
import '../../core/audy_ui.dart';
import '../../services/sound_service.dart';
import '../../state/audy_controller.dart';
import '../../widgets/game_guide_box.dart';
import '../read_pronounce/read_pronounce_service.dart';
import 'flashcard_api_service.dart';
import 'flashcard_models.dart';

String _tr(BuildContext context, String key, {Map<String, String>? params}) {
  return AudyScope.of(context).tr(key, params: params);
}

class FlashcardGameScreen extends StatefulWidget {
  const FlashcardGameScreen({super.key, required this.difficulty});

  final FlashcardDifficulty difficulty;

  @override
  State<FlashcardGameScreen> createState() => _FlashcardGameScreenState();
}

class _FlashcardGameScreenState extends State<FlashcardGameScreen> {
  final FlashcardApiService _api = FlashcardApiService();
  final ReadPronounceService _speech = ReadPronounceService();
  final Stopwatch _sessionClock = Stopwatch();

  FlashcardSession? _session;
  List<FlashcardWord> _handCards = [];
  final List<FlashcardWord> _sentenceCards = [];
  Map<String, FlashcardValidationStatus> _feedback = {};
  Timer? _introTimer;
  Timer? _glowTimer;
  int _introIndex = 0;
  bool _isLoading = true;
  bool _isIntro = true;
  bool _isSubmitting = false;
  bool _showGuide = true;
  bool _completionRecorded = false;
  String? _errorKey;
  String? _message;
  String? _selectedSentenceCardId;

  @override
  void initState() {
    super.initState();
    _startSession();
  }

  @override
  void dispose() {
    _introTimer?.cancel();
    _glowTimer?.cancel();
    _speech.dispose();
    super.dispose();
  }

  Future<void> _startSession() async {
    setState(() {
      _isLoading = true;
      _isIntro = true;
      _isSubmitting = false;
      _errorKey = null;
      _message = null;
      _feedback = {};
      _handCards = [];
      _sentenceCards.clear();
      _introIndex = 0;
      _completionRecorded = false;
      _selectedSentenceCardId = null;
    });

    try {
      final language = AudyScope.of(context).currentLanguage;
      final session = await _api.createSession(
        language: language == 'th' ? 'th' : 'en',
        difficulty: widget.difficulty,
      );
      if (!mounted) return;

      setState(() {
        _session = session;
        _isLoading = false;
      });
      _sessionClock
        ..reset()
        ..start();
      unawaited(_presentNextIntroCard());
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorKey = 'flashcard_load_error';
      });
    }
  }

  Future<void> _presentNextIntroCard() async {
    final session = _session;
    if (!mounted || session == null) return;

    if (_introIndex >= session.handCards.length) {
      setState(() => _isIntro = false);
      return;
    }

    final card = session.handCards[_introIndex];
    final language = session.language == 'th' ? 'th-TH' : 'en-US';
    unawaited(
      _speech.speak(card.labelFor(session.language), language: language),
    );

    _introTimer?.cancel();
    _introTimer = Timer(const Duration(seconds: 4), _placeIntroCard);
  }

  void _placeIntroCard() {
    final session = _session;
    if (!mounted ||
        session == null ||
        _introIndex >= session.handCards.length) {
      return;
    }

    _speech.stopSpeaking();
    setState(() {
      _handCards.add(session.handCards[_introIndex]);
      _introIndex += 1;
    });
    unawaited(_presentNextIntroCard());
  }

  void _handleIntroTap() {
    SoundService.instance.playTap();
    _introTimer?.cancel();
    _placeIntroCard();
  }

  void _moveToSentence(FlashcardWord card) {
    if (_isSubmitting) return;
    SoundService.instance.playTap();
    setState(() {
      _handCards.removeWhere((item) => item.id == card.id);
      _sentenceCards.add(card);
      _feedback = {};
      _message = null;
    });
  }

  void _handleSentenceCardTap(FlashcardWord card) {
    if (_isSubmitting) return;
    SoundService.instance.playTap();
    setState(() {
      if (_selectedSentenceCardId == null) {
        _selectedSentenceCardId = card.id;
        return;
      }

      if (_selectedSentenceCardId == card.id) {
        _sentenceCards.removeWhere((item) => item.id == card.id);
        _handCards.add(card);
      } else {
        final firstIndex = _sentenceCards.indexWhere(
          (item) => item.id == _selectedSentenceCardId,
        );
        final secondIndex = _sentenceCards.indexWhere(
          (item) => item.id == card.id,
        );
        if (firstIndex != -1 && secondIndex != -1) {
          final first = _sentenceCards[firstIndex];
          _sentenceCards[firstIndex] = _sentenceCards[secondIndex];
          _sentenceCards[secondIndex] = first;
        }
      }

      _selectedSentenceCardId = null;
      _feedback = {};
      _message = null;
    });
  }

  Future<void> _submit() async {
    final session = _session;
    if (session == null || _sentenceCards.isEmpty || _isSubmitting) return;

    setState(() => _isSubmitting = true);
    SoundService.instance.playTap();
    await _speakSentenceCards();

    try {
      final result = await _api.validate(
        language: session.language,
        difficulty: widget.difficulty,
        submittedCardIds: _sentenceCards.map((card) => card.id).toList(),
        availableCardIds: session.handCards.map((card) => card.id).toList(),
        targetCardIds: session.targetCardIds,
      );
      if (!mounted) return;

      setState(() {
        _feedback = {
          for (final item in result.feedback) item.cardId: item.status,
        };
        _message = result.isValid
            ? _tr(context, 'flashcard_good_sentence')
            : _tr(context, 'flashcard_try_change');
      });

      if (result.isValid && !_completionRecorded) {
        _completionRecorded = true;
        _sessionClock.stop();
        await AudyScope.of(context).trackReadingCompleted();
      }

      _glowTimer?.cancel();
      _glowTimer = Timer(const Duration(seconds: 3), () {
        if (!mounted) return;
        setState(() => _feedback = {});
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _message = _tr(context, 'flashcard_check_error'));
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _speakSentenceCards() async {
    final session = _session;
    if (session == null) return;

    final language = session.language == 'th' ? 'th-TH' : 'en-US';
    final text = _sentenceCards
        .map((card) => card.labelFor(session.language))
        .join(' ');
    await _speech.speak(text, language: language);
  }

  void _finishGame() {
    final controller = AudyScope.of(context);
    AppRoutes.navigateAfterGameCompletion(context, controller);
  }

  @override
  Widget build(BuildContext context) {
    return AudyResponsivePage(
      scrollable: false,
      builder: (context, adaptive) {
        if (_isLoading) {
          return _buildLoading(adaptive);
        }

        if (_errorKey != null) {
          return _buildError(adaptive);
        }

        if (_isIntro) {
          return _buildIntro(adaptive);
        }

        return _buildPlay(adaptive);
      },
    );
  }

  Widget _buildLoading(AudyAdaptive adaptive) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(color: AudyColors.skyBlue),
          SizedBox(height: adaptive.space(18)),
          Text(
            _tr(context, 'flashcard_loading'),
            style: AudyTypography.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildError(AudyAdaptive adaptive) {
    return Column(
      children: [
        _Header(
          adaptive: adaptive,
          difficulty: widget.difficulty,
          showGuide: false,
          onGuideDismissed: () {},
        ),
        const Spacer(),
        Icon(
          Icons.cloud_off_rounded,
          size: adaptive.space(80),
          color: AudyColors.warning,
        ),
        SizedBox(height: adaptive.space(16)),
        Text(
          _tr(context, _errorKey!),
          style: AudyTypography.headingSmall,
          textAlign: TextAlign.center,
        ),
        SizedBox(height: adaptive.space(24)),
        ElevatedButton.icon(
          onPressed: _startSession,
          icon: const Icon(Icons.refresh_rounded),
          label: Text(_tr(context, 'try_again')),
          style: ElevatedButton.styleFrom(
            backgroundColor: AudyColors.skyBlue,
            foregroundColor: AudyColors.textOnColor,
            minimumSize: Size(double.infinity, adaptive.space(56)),
          ),
        ),
        const Spacer(),
      ],
    );
  }

  Widget _buildIntro(AudyAdaptive adaptive) {
    final session = _session!;
    final card = session.handCards[_introIndex];

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _handleIntroTap,
      child: Column(
        children: [
          _Header(
            adaptive: adaptive,
            difficulty: widget.difficulty,
            showGuide: _showGuide,
            onGuideDismissed: () => setState(() => _showGuide = false),
          ),
          const Spacer(),
          Text(
            _tr(context, 'flashcard_listen'),
            style: AudyTypography.bodyLarge,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: adaptive.space(20)),
          SizedBox(
            width: adaptive.isPhone ? double.infinity : adaptive.space(360),
            height: adaptive.space(190),
            child: _WordCard(
              adaptive: adaptive,
              card: card,
              language: session.language,
              isSelected: false,
              status: null,
              onTap: _handleIntroTap,
            ),
          ),
          SizedBox(height: adaptive.space(18)),
          Text(
            _tr(
              context,
              'flashcard_card_count',
              params: {
                'current': (_introIndex + 1).toString(),
                'total': session.handCards.length.toString(),
              },
            ),
            style: AudyTypography.bodySmall,
            textAlign: TextAlign.center,
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildPlay(AudyAdaptive adaptive) {
    final session = _session!;
    final selectedCount = _sentenceCards.length;
    final isComplete = _completionRecorded;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Header(
          adaptive: adaptive,
          difficulty: widget.difficulty,
          showGuide: _showGuide,
          onGuideDismissed: () => setState(() => _showGuide = false),
        ),
        SizedBox(height: adaptive.space(12)),
        Center(
          child: Text(
            _tr(context, 'flashcard_build_sentence'),
            style: AudyTypography.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ),
        SizedBox(height: adaptive.space(14)),
        Container(
          width: double.infinity,
          constraints: BoxConstraints(minHeight: adaptive.space(132)),
          padding: EdgeInsets.all(adaptive.space(14)),
          decoration: BoxDecoration(
            color: AudyColors.backgroundCard,
            borderRadius: BorderRadius.circular(AudySpacing.radiusLarge),
            border: Border.all(color: AudyColors.skyBlue, width: 2),
            boxShadow: AudyShadows.cardShadow,
          ),
          child: _sentenceCards.isEmpty
              ? Center(
                  child: Text(
                    _tr(context, 'flashcard_tap_cards'),
                    style: AudyTypography.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                )
              : Wrap(
                  alignment: WrapAlignment.center,
                  spacing: adaptive.space(10),
                  runSpacing: adaptive.space(10),
                  children: _sentenceCards.map((card) {
                    return SizedBox(
                      width: _playCardWidth(adaptive),
                      height: adaptive.space(96),
                      child: _WordCard(
                        adaptive: adaptive,
                        card: card,
                        language: session.language,
                        isSelected: _selectedSentenceCardId == card.id,
                        status: _feedback[card.id],
                        onTap: () => _handleSentenceCardTap(card),
                      ),
                    );
                  }).toList(),
                ),
        ),
        SizedBox(height: adaptive.space(14)),
        if (_message != null)
          Center(
            child: Text(
              _message!,
              style: AudyTypography.headingSmall,
              textAlign: TextAlign.center,
            ),
          ),
        const Spacer(),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: adaptive.space(10),
          runSpacing: adaptive.space(10),
          children: _handCards.map((card) {
            return SizedBox(
              width: _playCardWidth(adaptive),
              height: adaptive.space(96),
              child: _WordCard(
                adaptive: adaptive,
                card: card,
                language: session.language,
                isSelected: false,
                status: null,
                onTap: () => _moveToSentence(card),
              ),
            );
          }).toList(),
        ),
        SizedBox(height: adaptive.space(16)),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: selectedCount == 0 || _isSubmitting ? null : _submit,
                icon: Icon(
                  _isSubmitting
                      ? Icons.hourglass_empty_rounded
                      : Icons.check_rounded,
                ),
                label: Text(
                  _isSubmitting
                      ? _tr(context, 'flashcard_checking')
                      : _tr(context, 'flashcard_submit'),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AudyColors.skyBlue,
                  foregroundColor: AudyColors.textOnColor,
                  disabledBackgroundColor: AudyColors.borderLight,
                  minimumSize: Size(double.infinity, adaptive.space(56)),
                ),
              ),
            ),
            if (isComplete) ...[
              SizedBox(width: adaptive.space(10)),
              SizedBox(
                width: adaptive.space(64),
                height: adaptive.space(56),
                child: IconButton.filled(
                  onPressed: _finishGame,
                  icon: const Icon(Icons.done_rounded),
                  style: IconButton.styleFrom(
                    backgroundColor: AudyColors.mintGreen,
                    foregroundColor: AudyColors.textPrimary,
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  double _playCardWidth(AudyAdaptive adaptive) {
    if (adaptive.isPhone) return adaptive.space(102);
    if (adaptive.isTablet) return adaptive.space(126);
    return adaptive.space(140);
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.adaptive,
    required this.difficulty,
    required this.showGuide,
    required this.onGuideDismissed,
  });

  final AudyAdaptive adaptive;
  final FlashcardDifficulty difficulty;
  final bool showGuide;
  final VoidCallback onGuideDismissed;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: adaptive.space(8),
      runSpacing: adaptive.space(8),
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
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
                child: const Icon(
                  Icons.arrow_back_rounded,
                  size: AudySpacing.iconMedium,
                ),
              ),
            ),
            SizedBox(width: adaptive.space(8)),
            Icon(
              Icons.style_rounded,
              color: AudyColors.activityReading,
              size: adaptive.space(32),
            ),
            SizedBox(width: adaptive.space(8)),
            Text(
              _tr(context, difficulty.apiValue),
              style: AudyTypography.headingSmall,
            ),
          ],
        ),
        if (showGuide)
          SizedBox(
            width: adaptive.space(280),
            child: GameGuideBox(
              message: _tr(context, 'guide_flashcard_game'),
              onDismissed: onGuideDismissed,
            ),
          ),
      ],
    );
  }
}

class _WordCard extends StatelessWidget {
  const _WordCard({
    required this.adaptive,
    required this.card,
    required this.language,
    required this.isSelected,
    required this.status,
    required this.onTap,
  });

  final AudyAdaptive adaptive;
  final FlashcardWord card;
  final String language;
  final bool isSelected;
  final FlashcardValidationStatus? status;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final glowColor = switch (status) {
      FlashcardValidationStatus.correct => AudyColors.success,
      FlashcardValidationStatus.swap ||
      FlashcardValidationStatus.remove => AudyColors.error,
      null => Colors.transparent,
    };

    return AnimatedContainer(
      duration: AudyAnimation.normal,
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AudySpacing.radiusLarge),
        boxShadow: status == null
            ? AudyShadows.cardShadow
            : [
                BoxShadow(
                  color: glowColor.withValues(alpha: 0.42),
                  blurRadius: 24,
                  spreadRadius: 3,
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AudySpacing.radiusLarge),
          child: Ink(
            decoration: BoxDecoration(
              color: AudyColors.backgroundCard,
              borderRadius: BorderRadius.circular(AudySpacing.radiusLarge),
              border: Border.all(
                color: isSelected ? AudyColors.skyBlue : _categoryColor(card),
                width: isSelected ? 4 : 2,
              ),
            ),
            child: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: adaptive.space(8)),
                child: Text(
                  card.labelFor(language),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AudyTypography.headingSmall.copyWith(
                    fontSize: adaptive.space(20),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _categoryColor(FlashcardWord card) {
    return switch (card.category) {
      FlashcardCategory.noun => AudyColors.skyBlue,
      FlashcardCategory.pronoun => AudyColors.softLavender,
      FlashcardCategory.verb => AudyColors.mintGreen,
      FlashcardCategory.adverb => AudyColors.warning,
      FlashcardCategory.adjective => AudyColors.blushPink,
    };
  }
}
