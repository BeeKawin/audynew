import 'package:flutter/material.dart';

import '../core/audy_ui.dart';

enum MiniPuzzleGame { pattern, critical, problem }

class MiniPuzzleModulePage extends StatefulWidget {
  const MiniPuzzleModulePage({super.key});

  @override
  State<MiniPuzzleModulePage> createState() => _MiniPuzzleModulePageState();
}

class _MiniPuzzleModulePageState extends State<MiniPuzzleModulePage> {
  static const _patternPool = [
    PatternToken(Icons.circle_rounded, Color(0xFF9EC8F2)),
    PatternToken(Icons.square_rounded, Color(0xFFF6B9D7)),
    PatternToken(Icons.change_history_rounded, Color(0xFFB8E8C4)),
  ];

  static const _criticalPool = [
    CriticalCard('Dog', Icons.pets_rounded, 'Animal'),
    CriticalCard('Cat', Icons.cruelty_free_rounded, 'Animal'),
    CriticalCard('Fish', Icons.set_meal_rounded, 'Animal'),
    CriticalCard('Apple', Icons.apple_rounded, 'Food'),
    CriticalCard('Bread', Icons.breakfast_dining_rounded, 'Food'),
    CriticalCard('Carrot', Icons.eco_rounded, 'Food'),
  ];

  MiniPuzzleGame activeGame = MiniPuzzleGame.pattern;
  bool soundEnabled = true;
  int level = 1;
  int attempts = 0;
  int successes = 0;
  DateTime moduleStartedAt = DateTime.now();

  List<PatternToken> patternSequence = const [];
  List<PatternToken> patternChoices = const [];
  String patternFeedback = 'Watch the pattern, then choose the next one.';

  List<CriticalCard> criticalRound = const [];
  int criticalIndex = 0;
  int criticalAnimalCount = 0;
  int criticalFoodCount = 0;
  String criticalFeedback = 'Sort cards into Animal or Food.';

  List<PuzzlePiece> puzzlePieces = const [];
  int? selectedPieceIndex;
  String problemFeedback = 'Drag pieces into slots. They snap into place.';

  @override
  void initState() {
    super.initState();
    _resetPattern();
    _resetCritical();
    _resetProblem();
  }

  @override
  Widget build(BuildContext context) {
    return AudyResponsivePage(
      builder: (context, adaptive) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _TopControls(
              adaptive: adaptive,
              soundEnabled: soundEnabled,
              onToggleSound: () => setState(() => soundEnabled = !soundEnabled),
              onReplay: _replayActiveGame,
            ),
            SizedBox(height: adaptive.space(16)),
            Text(
              'MiniPuzzle - Cognitive Training',
              style: TextStyle(
                fontSize: adaptive.space(28),
                fontWeight: FontWeight.w800,
                color: const Color(0xFF243A5A),
              ),
            ),
            SizedBox(height: adaptive.space(8)),
            Text(
              'Level $level | Attempts $attempts | Success $successes | Time ${_elapsedTime()}',
              style: TextStyle(
                fontSize: adaptive.space(13),
                color: const Color(0xFF60758F),
              ),
            ),
            SizedBox(height: adaptive.space(10)),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: (successes % 4) / 4,
                minHeight: adaptive.space(12),
                backgroundColor: const Color(0xFFE2E7EE),
                valueColor: const AlwaysStoppedAnimation(Color(0xFF8FCFA9)),
              ),
            ),
            SizedBox(height: adaptive.space(14)),
            Wrap(
              spacing: adaptive.space(10),
              runSpacing: adaptive.space(10),
              children: MiniPuzzleGame.values.map((game) {
                final selected = activeGame == game;
                return ChoiceChip(
                  label: Text(_labelForGame(game)),
                  selected: selected,
                  onSelected: (_) => setState(() => activeGame = game),
                  selectedColor: const Color(0xFFCDE8D7),
                  backgroundColor: const Color(0xFFE9EEF5),
                );
              }).toList(),
            ),
            SizedBox(height: adaptive.space(16)),
            if (activeGame == MiniPuzzleGame.pattern)
              PatternGame(
                adaptive: adaptive,
                sequence: patternSequence,
                choices: patternChoices,
                feedback: patternFeedback,
                onSelect: _onPatternSelect,
              ),
            if (activeGame == MiniPuzzleGame.critical)
              CriticalThinkingGame(
                adaptive: adaptive,
                currentCard: criticalIndex < criticalRound.length
                    ? criticalRound[criticalIndex]
                    : null,
                animalCount: criticalAnimalCount,
                foodCount: criticalFoodCount,
                feedback: criticalFeedback,
                onChooseAnimal: () => _onCriticalChoice('Animal'),
                onChooseFood: () => _onCriticalChoice('Food'),
              ),
            if (activeGame == MiniPuzzleGame.problem)
              ProblemSolvingGame(
                adaptive: adaptive,
                pieces: puzzlePieces,
                selectedPieceIndex: selectedPieceIndex,
                feedback: problemFeedback,
                onSelectPiece: (index) =>
                    setState(() => selectedPieceIndex = index),
                onDropPiece: _onPuzzleDrop,
                onHint: _showProblemHint,
              ),
          ],
        );
      },
    );
  }

  void _replayActiveGame() {
    setState(() {
      if (activeGame == MiniPuzzleGame.pattern) _resetPattern();
      if (activeGame == MiniPuzzleGame.critical) _resetCritical();
      if (activeGame == MiniPuzzleGame.problem) _resetProblem();
    });
  }

  void _onPatternSelect(PatternToken token) {
    final correct = token.icon == _expectedPatternToken().icon;
    setState(() {
      attempts += 1;
      if (correct) {
        successes += 1;
        if (successes % 4 == 0) level += 1;
        patternFeedback = soundEnabled
            ? 'Great job. Correct pattern. Sound on.'
            : 'Great job. Correct pattern.';
      } else {
        patternFeedback = 'Nice try. Hint: repeat the color and shape rhythm.';
      }
    });
    if (correct) {
      Future<void>.delayed(const Duration(milliseconds: 350), () {
        if (!mounted) return;
        setState(_resetPattern);
      });
    }
  }

  void _onCriticalChoice(String category) {
    if (criticalIndex >= criticalRound.length) return;
    final correct = criticalRound[criticalIndex].category == category;
    setState(() {
      attempts += 1;
      if (correct) {
        successes += 1;
        if (successes % 4 == 0) level += 1;
        if (category == 'Animal') criticalAnimalCount += 1;
        if (category == 'Food') criticalFoodCount += 1;
        criticalIndex += 1;
        criticalFeedback = criticalIndex >= criticalRound.length
            ? 'Excellent sorting. Replay for a new round.'
            : 'Correct category. Keep going.';
      } else {
        criticalFeedback = 'Almost there. Think: can we eat it?';
      }
    });
  }

  void _onPuzzleDrop(String pieceId, int slotIndex) {
    final index = puzzlePieces.indexWhere((piece) => piece.id == pieceId);
    if (index == -1) return;
    setState(() {
      attempts += 1;
      final updated = puzzlePieces.toList();
      updated[index] = updated[index].copyWith(currentSlot: slotIndex);
      puzzlePieces = updated;
      selectedPieceIndex = null;
      if (updated[index].targetSlot == slotIndex) {
        successes += 1;
        if (successes % 4 == 0) level += 1;
        problemFeedback = 'Nice fit. Piece snapped into the slot.';
      } else {
        problemFeedback = 'Good effort. Hint: match the shape icon.';
      }
      final solved = puzzlePieces.every(
        (piece) => piece.currentSlot == piece.targetSlot,
      );
      if (solved) {
        problemFeedback = 'Puzzle solved calmly. Replay for another round.';
      }
    });
  }

  void _showProblemHint() {
    final piece = puzzlePieces.firstWhere(
      (item) => item.currentSlot != item.targetSlot,
      orElse: () => puzzlePieces.first,
    );
    setState(() {
      problemFeedback =
          'Hint: place ${piece.label} in slot ${piece.targetSlot + 1}.';
    });
  }

  void _resetPattern() {
    final length = (2 + ((level - 1) % 2)).clamp(2, 3);
    patternSequence = List.generate(length, (i) => _patternPool[i % 3]);
    final expected = _expectedPatternToken();
    patternChoices = [
      expected,
      ..._patternPool.where((p) => p.icon != expected.icon).take(2),
    ].toList()..shuffle();
    patternFeedback = 'Choose the next shape in the sequence.';
  }

  PatternToken _expectedPatternToken() {
    return _patternPool[patternSequence.length % _patternPool.length];
  }

  void _resetCritical() {
    criticalRound = List<CriticalCard>.from(_criticalPool).take(4).toList();
    criticalIndex = 0;
    criticalAnimalCount = 0;
    criticalFoodCount = 0;
    criticalFeedback = 'Sort cards into Animal or Food.';
  }

  void _resetProblem() {
    puzzlePieces = const [
      PuzzlePiece(
        id: 'piece-circle',
        label: 'Blue Circle',
        icon: Icons.circle_rounded,
        color: Color(0xFF9EC8F2),
        targetSlot: 0,
      ),
      PuzzlePiece(
        id: 'piece-square',
        label: 'Pink Square',
        icon: Icons.square_rounded,
        color: Color(0xFFF6B9D7),
        targetSlot: 1,
      ),
      PuzzlePiece(
        id: 'piece-triangle',
        label: 'Green Triangle',
        icon: Icons.change_history_rounded,
        color: Color(0xFFB8E8C4),
        targetSlot: 2,
      ),
    ];
    selectedPieceIndex = null;
    problemFeedback = 'Drag pieces into slots. They snap into place.';
  }

  String _labelForGame(MiniPuzzleGame game) {
    if (game == MiniPuzzleGame.pattern) return 'Pattern';
    if (game == MiniPuzzleGame.critical) return 'Critical';
    return 'Problem';
  }

  String _elapsedTime() {
    final elapsed = DateTime.now().difference(moduleStartedAt);
    final minutes = elapsed.inMinutes.toString().padLeft(2, '0');
    final seconds = (elapsed.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}

class PatternGame extends StatelessWidget {
  const PatternGame({
    super.key,
    required this.adaptive,
    required this.sequence,
    required this.choices,
    required this.feedback,
    required this.onSelect,
  });

  final AudyAdaptive adaptive;
  final List<PatternToken> sequence;
  final List<PatternToken> choices;
  final String feedback;
  final ValueChanged<PatternToken> onSelect;

  @override
  Widget build(BuildContext context) {
    return AudyPanel(
      adaptive: adaptive,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pattern Recognition',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          SizedBox(height: adaptive.space(10)),
          Wrap(
            spacing: adaptive.space(10),
            runSpacing: adaptive.space(10),
            children: sequence
                .map((token) => _PatternChip(adaptive: adaptive, token: token))
                .toList(),
          ),
          SizedBox(height: adaptive.space(12)),
          AudyAdaptiveGrid(
            adaptive: adaptive,
            phoneColumns: 2,
            tabletColumns: 3,
            desktopColumns: 3,
            items: choices
                .map(
                  (token) => InkWell(
                    onTap: () => onSelect(token),
                    borderRadius: BorderRadius.circular(14),
                    child: _PatternChip(adaptive: adaptive, token: token),
                  ),
                )
                .toList(),
          ),
          SizedBox(height: adaptive.space(10)),
          Text(feedback),
        ],
      ),
    );
  }
}

class CriticalThinkingGame extends StatelessWidget {
  const CriticalThinkingGame({
    super.key,
    required this.adaptive,
    required this.currentCard,
    required this.animalCount,
    required this.foodCount,
    required this.feedback,
    required this.onChooseAnimal,
    required this.onChooseFood,
  });

  final AudyAdaptive adaptive;
  final CriticalCard? currentCard;
  final int animalCount;
  final int foodCount;
  final String feedback;
  final VoidCallback onChooseAnimal;
  final VoidCallback onChooseFood;

  @override
  Widget build(BuildContext context) {
    return AudyPanel(
      adaptive: adaptive,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Critical Thinking',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          SizedBox(height: adaptive.space(10)),
          if (currentCard != null)
            Center(
              child: Icon(
                currentCard!.icon,
                size: adaptive.space(54),
                color: const Color(0xFF4A6181),
              ),
            ),
          SizedBox(height: adaptive.space(10)),
          Row(
            children: [
              Expanded(
                child: AudyPillButton(
                  label: 'Animal ($animalCount)',
                  color: const Color(0xFFB8E8C4),
                  adaptive: adaptive,
                  onPressed: onChooseAnimal,
                ),
              ),
              SizedBox(width: adaptive.space(10)),
              Expanded(
                child: AudyPillButton(
                  label: 'Food ($foodCount)',
                  color: const Color(0xFFF8EAA0),
                  adaptive: adaptive,
                  onPressed: onChooseFood,
                ),
              ),
            ],
          ),
          SizedBox(height: adaptive.space(10)),
          Text(feedback),
        ],
      ),
    );
  }
}

class ProblemSolvingGame extends StatelessWidget {
  const ProblemSolvingGame({
    super.key,
    required this.adaptive,
    required this.pieces,
    required this.selectedPieceIndex,
    required this.feedback,
    required this.onSelectPiece,
    required this.onDropPiece,
    required this.onHint,
  });

  final AudyAdaptive adaptive;
  final List<PuzzlePiece> pieces;
  final int? selectedPieceIndex;
  final String feedback;
  final ValueChanged<int> onSelectPiece;
  final void Function(String pieceId, int slotIndex) onDropPiece;
  final VoidCallback onHint;

  @override
  Widget build(BuildContext context) {
    return AudyPanel(
      adaptive: adaptive,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Problem Solving',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          SizedBox(height: adaptive.space(10)),
          Row(
            children: List.generate(3, (slot) {
              PuzzlePiece? piece;
              for (final item in pieces) {
                if (item.currentSlot == slot) {
                  piece = item;
                  break;
                }
              }
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: adaptive.space(4)),
                  child: DragTarget<String>(
                    onAcceptWithDetails: (details) =>
                        onDropPiece(details.data, slot),
                    builder: (context, candidateData, rejectedData) =>
                        Container(
                          height: adaptive.isPhone ? 96 : 118,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0F4FA),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: const Color(0xFFD3DBE7),
                              width: 2,
                            ),
                          ),
                          child: piece == null
                              ? const Icon(
                                  Icons.add_rounded,
                                  color: Color(0xFFA0AFC4),
                                )
                              : Icon(
                                  piece.icon,
                                  color: piece.color,
                                  size: adaptive.space(38),
                                ),
                        ),
                  ),
                ),
              );
            }),
          ),
          SizedBox(height: adaptive.space(12)),
          Wrap(
            spacing: adaptive.space(8),
            runSpacing: adaptive.space(8),
            children: List.generate(pieces.length, (index) {
              final piece = pieces[index];
              return Draggable<String>(
                data: piece.id,
                feedback: Icon(
                  piece.icon,
                  color: piece.color,
                  size: adaptive.space(34),
                ),
                childWhenDragging: Opacity(
                  opacity: 0.4,
                  child: Icon(
                    piece.icon,
                    color: piece.color,
                    size: adaptive.space(32),
                  ),
                ),
                child: InkWell(
                  onTap: () => onSelectPiece(index),
                  child: Container(
                    padding: EdgeInsets.all(adaptive.space(10)),
                    decoration: BoxDecoration(
                      color: piece.color.withValues(alpha: 0.24),
                      borderRadius: BorderRadius.circular(12),
                      border: selectedPieceIndex == index
                          ? Border.all(color: const Color(0xFF94ACD0), width: 2)
                          : null,
                    ),
                    child: Icon(
                      piece.icon,
                      color: piece.color,
                      size: adaptive.space(30),
                    ),
                  ),
                ),
              );
            }),
          ),
          SizedBox(height: adaptive.space(10)),
          AudyPillButton(
            label: 'Hint',
            icon: Icons.lightbulb_outline_rounded,
            color: const Color(0xFFFFF2A8),
            adaptive: adaptive,
            onPressed: onHint,
          ),
          SizedBox(height: adaptive.space(10)),
          Text(feedback),
        ],
      ),
    );
  }
}

class _TopControls extends StatelessWidget {
  const _TopControls({
    required this.adaptive,
    required this.soundEnabled,
    required this.onToggleSound,
    required this.onReplay,
  });

  final AudyAdaptive adaptive;
  final bool soundEnabled;
  final VoidCallback onToggleSound;
  final VoidCallback onReplay;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AudyBackButton(
          label: 'Back to Home',
          onPressed: () => Navigator.pop(context),
        ),
        const Spacer(),
        IconButton(
          onPressed: onToggleSound,
          style: IconButton.styleFrom(backgroundColor: const Color(0xFFE6F1FC)),
          icon: Icon(
            soundEnabled ? Icons.volume_up_rounded : Icons.volume_off_rounded,
            color: const Color(0xFF284464),
          ),
        ),
        SizedBox(width: adaptive.space(8)),
        IconButton(
          onPressed: onReplay,
          style: IconButton.styleFrom(backgroundColor: const Color(0xFFFFF2A8)),
          icon: const Icon(Icons.replay_rounded, color: Color(0xFF284464)),
        ),
      ],
    );
  }
}

class _PatternChip extends StatelessWidget {
  const _PatternChip({required this.adaptive, required this.token});

  final AudyAdaptive adaptive;
  final PatternToken token;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: adaptive.isPhone ? 72 : 90,
      height: adaptive.isPhone ? 72 : 90,
      decoration: BoxDecoration(
        color: token.color.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(token.icon, color: token.color, size: adaptive.space(34)),
    );
  }
}

class PatternToken {
  const PatternToken(this.icon, this.color);
  final IconData icon;
  final Color color;
}

class CriticalCard {
  const CriticalCard(this.label, this.icon, this.category);
  final String label;
  final IconData icon;
  final String category;
}

class PuzzlePiece {
  const PuzzlePiece({
    required this.id,
    required this.label,
    required this.icon,
    required this.color,
    required this.targetSlot,
    this.currentSlot,
  });

  final String id;
  final String label;
  final IconData icon;
  final Color color;
  final int targetSlot;
  final int? currentSlot;

  PuzzlePiece copyWith({int? currentSlot}) {
    return PuzzlePiece(
      id: id,
      label: label,
      icon: icon,
      color: color,
      targetSlot: targetSlot,
      currentSlot: currentSlot,
    );
  }
}
