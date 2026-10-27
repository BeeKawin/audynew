import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../../../flashcard/flashcard_api_service.dart';
import '../../../flashcard/flashcard_controller.dart';
import '../../../flashcard/flashcard_models.dart';
import '../../../../state/audy_controller.dart';
import '../../caretaker_ui.dart';
import '../custom_cards_editor.dart';

class _PreviewApi extends FlashcardApiService {
  _PreviewApi(this.cards);
  final List<Map<String, dynamic>> cards;
  @override
  Future<FlashcardRound> generateRound({
    required String language,
    required int wordCount,
    List<Map<String, dynamic>>? customCards,
  }) => super.generateRound(
    language: language,
    wordCount: wordCount,
    customCards: cards,
  );
  @override
  Future<FlashcardValidation> validateRound({
    required String roundId,
    required String language,
    required List<String> targetCardIds,
    required List<String> selectedCardIds,
    List<Map<String, dynamic>>? customCards,
  }) => super.validateRound(
    roundId: roundId,
    language: language,
    targetCardIds: targetCardIds,
    selectedCardIds: selectedCardIds,
    customCards: cards,
  );
}

class FlashcardPreview extends StatefulWidget {
  const FlashcardPreview({super.key, required this.values});
  final Map<String, dynamic> values;
  @override
  State<FlashcardPreview> createState() => _FlashcardPreviewState();
}

class _FlashcardPreviewState extends State<FlashcardPreview> {
  FlashcardController? _controller;
  final _tts = FlutterTts();
  Timer? _timer;
  String _difficulty = 'easy';
  String? _spoken;
  bool _submitting = false;
  String get _language => widget.values['language'] == 'app'
      ? AudyScope.of(context).currentLanguage
      : widget.values['language'] as String;
  Future<void> _speak(String text) async {
    await _tts.setLanguage(_language == 'th' ? 'th-TH' : 'en-US');
    await _tts.setSpeechRate(0.42);
    await _tts.speak(text);
  }

  void _start() {
    final level = widget.values['difficulty'] == 'child_choice'
        ? _difficulty
        : widget.values['difficulty'] as String;
    final cards = widget.values['use_custom_cards'] == true
        ? (widget.values['custom_cards'] as List)
              .map((c) => Map<String, dynamic>.from(c as Map))
              .toList()
        : <Map<String, dynamic>>[];
    final c = FlashcardController(
      difficulty: FlashcardDifficulty.values.byName(level),
      api: _PreviewApi(cards),
    );
    _controller = c;
    c.addListener(_changed);
    c.startSession(_language);
    setState(() {});
  }

  void _changed() {
    if (!mounted) return;
    setState(() {});
    _timer?.cancel();
    final c = _controller!;
    if (c.phase == FlashcardGamePhase.previewing) {
      final card = c.previewCard;
      final key = '${c.currentRound?.roundId}:${c.previewIndex}';
      if (card != null && _spoken != key) {
        _spoken = key;
        if (widget.values['auto_speak'] == true) {
          unawaited(_speak(card.ttsText));
        }
      }
      final pace = widget.values['preview_pace'];
      if (pace != 'manual') {
        _timer = Timer(
          Duration(seconds: int.parse(pace.toString().split('_').first)),
          c.advancePreview,
        );
      }
    }
    if (c.phase == FlashcardGamePhase.feedback) {
      _timer = Timer(const Duration(milliseconds: 1400), () {
        if (mounted) c.continueAfterFeedback();
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _tts.stop();
    _controller?.removeListener(_changed);
    _controller?.dispose();
    super.dispose();
  }

  Widget _card(FlashcardCard card, {VoidCallback? tap}) => SizedBox(
    width: 150,
    child: Card(
      child: InkWell(
        onTap: tap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CardPicture(card.imageAsset, size: 80),
              Text(card.displayText),
              IconButton(
                tooltip: ct(context, 'Speak', 'อ่านออกเสียง'),
                onPressed: () => _speak(card.ttsText),
                icon: const Icon(Icons.volume_up),
              ),
            ],
          ),
        ),
      ),
    ),
  );
  @override
  Widget build(BuildContext context) {
    final c = _controller;
    if (c == null) {
      return ListView(
        padding: const EdgeInsets.all(24),
        children: [
          if (widget.values['difficulty'] == 'child_choice')
            DropdownButtonFormField<String>(
              initialValue: _difficulty,
              decoration: InputDecoration(
                labelText: ct(context, 'Preview difficulty', 'ระดับทดลอง'),
              ),
              items: [
                for (final level in ['easy', 'medium', 'hard'])
                  DropdownMenuItem(value: level, child: Text(level)),
              ],
              onChanged: (v) => _difficulty = v!,
            ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: _start,
            child: Text(
              ct(context, 'Generate preview sentence', 'สร้างประโยคทดลอง'),
            ),
          ),
          CaretakerNotice(
            ct(
              context,
              'Custom words join the pool; a sentence may use only some of them.',
              'คำที่เพิ่มเป็นส่วนหนึ่งของคลัง แต่ละประโยคอาจเลือกใช้บางคำ',
            ),
          ),
        ],
      );
    }
    if (c.phase == FlashcardGamePhase.loading ||
        c.phase == FlashcardGamePhase.validating) {
      return const Center(child: CircularProgressIndicator());
    }
    if (c.phase == FlashcardGamePhase.error) {
      return Center(
        child: CaretakerNotice(
          ct(
            context,
            'Could not load the sentence. Please retry.',
            'โหลดประโยคไม่ได้ กรุณาลองอีกครั้ง',
          ),
          onRetry: () => c.retry(_language),
        ),
      );
    }
    if (c.phase == FlashcardGamePhase.complete) {
      return Center(
        child: Text(
          ct(context, 'Three-round preview complete.', 'ทดลองครบสามรอบแล้ว'),
        ),
      );
    }
    if (c.phase == FlashcardGamePhase.previewing) {
      final card = c.previewCard;
      return Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (card != null) _card(card),
              if (widget.values['preview_pace'] == 'manual')
                FilledButton(
                  onPressed: c.advancePreview,
                  child: Text(ct(context, 'Next card', 'บัตรถัดไป')),
                ),
            ],
          ),
        ),
      );
    }
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(
          ct(
            context,
            'Round ${c.roundNumber}/3 · Build the sentence',
            'รอบ ${c.roundNumber}/3 · เรียงประโยค',
          ),
        ),
        Text(c.currentRound?.scenario ?? ''),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (var i = 0; i < c.cardCount; i++)
              if (i < c.selectedCards.length)
                _card(
                  c.selectedCards[i],
                  tap: c.phase == FlashcardGamePhase.playing
                      ? () => c.removeSelectedCard(c.selectedCards[i])
                      : null,
                )
              else if (c.hintCardForSlot(i) != null)
                SizedBox(
                  width: 150,
                  child: Column(
                    children: [
                      Opacity(
                        opacity: .45,
                        child: CardPicture(
                          c.hintCardForSlot(i)!.imageAsset,
                          size: 80,
                        ),
                      ),
                      if (c.difficulty.showHintWord)
                        Text(c.hintCardForSlot(i)!.displayText),
                    ],
                  ),
                )
              else
                const SizedBox(
                  width: 150,
                  height: 100,
                  child: Center(child: Icon(Icons.add_box_outlined)),
                ),
          ],
        ),
        const Divider(height: 32),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final card in c.handCards)
              _card(
                card,
                tap: c.phase == FlashcardGamePhase.playing
                    ? () => c.selectCard(card)
                    : null,
              ),
          ],
        ),
        if (c.phase == FlashcardGamePhase.feedback)
          Text(c.lastValidation?.feedback ?? ''),
        FilledButton(
          onPressed: !c.canSubmit || _submitting
              ? null
              : () async {
                  setState(() => _submitting = true);
                  await c.submit();
                  if (mounted) setState(() => _submitting = false);
                },
          child: Text(ct(context, 'Check sentence', 'ตรวจประโยค')),
        ),
      ],
    );
  }
}
