import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/audy_ui.dart';
import '../../../minipuzzle_game/minipuzzle_controller.dart';
import '../../../minipuzzle_game/minipuzzle_models.dart';
import '../../../minipuzzle_game/games/pattern_game_widget.dart';
import '../../../minipuzzle_game/games/odd_one_out_game_widget.dart';
import '../../../minipuzzle_game/games/puzzle_game_widget.dart';
import '../../caretaker_ui.dart';

class MiniPuzzlePreview extends StatefulWidget {
  const MiniPuzzlePreview({super.key, required this.values});
  final Map<String, dynamic> values;
  @override
  State<MiniPuzzlePreview> createState() => _MiniPuzzlePreviewState();
}

class _MiniPuzzlePreviewState extends State<MiniPuzzlePreview> {
  final _controller = MiniPuzzleController();
  Timer? _timer;
  int? _scheduled;
  bool _started = false;
  bool _complete = false;
  late String _type = (widget.values['enabled_types'] as List).first as String;
  String _difficulty = 'easy';
  void _start() {
    final field = switch (_type) {
      'pattern' => 'pattern_difficulty',
      'oddOneOut' => 'odd_one_out_difficulty',
      _ => 'puzzle_difficulty',
    };
    final level = widget.values[field] == 'child_choice'
        ? _difficulty
        : widget.values[field] as String;
    _controller.startGame(
      MiniPuzzleType.values.byName(_type),
      MiniPuzzleDifficulty.values.byName(level),
    );
    setState(() => _started = true);
  }

  @override
  void initState() {
    super.initState();
    _controller.addListener(_changed);
  }

  void _changed() {
    if (!mounted) return;
    setState(() {});
    if (!_controller.roundComplete || _scheduled == _controller.currentRound) {
      return;
    }
    _scheduled = _controller.currentRound;
    final mode = widget.values['advance_mode'];
    if (mode != 'manual') {
      _timer = Timer(
        Duration(milliseconds: mode == 'automatic_1800ms' ? 1800 : 900),
        _next,
      );
    }
  }

  void _next() {
    if (!mounted) return;
    if (_controller.currentRound >= 3) {
      setState(() => _complete = true);
    } else {
      _controller.nextRound();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.removeListener(_changed);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_started) {
      return ListView(
        padding: const EdgeInsets.all(24),
        children: [
          DropdownButtonFormField<String>(
            initialValue: _type,
            decoration: InputDecoration(
              labelText: ct(context, 'Activity', 'กิจกรรม'),
            ),
            items: [
              for (final type in widget.values['enabled_types'] as List)
                DropdownMenuItem(value: type as String, child: Text(type)),
            ],
            onChanged: (v) => setState(() => _type = v!),
          ),
          DropdownButtonFormField<String>(
            initialValue: _difficulty,
            decoration: InputDecoration(
              labelText: ct(
                context,
                'Preview level when child chooses',
                'ระดับทดลองเมื่อเด็กเลือกเอง',
              ),
            ),
            items: [
              for (final level in ['easy', 'medium', 'hard'])
                DropdownMenuItem(value: level, child: Text(level)),
            ],
            onChanged: (v) => _difficulty = v!,
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _start,
            child: Text(ct(context, 'Start preview', 'เริ่มทดลอง')),
          ),
        ],
      );
    }
    if (_complete) {
      return Center(
        child: Text(
          ct(
            context,
            'Preview complete · ${_controller.totalCorrect}/3',
            'ทดลองเสร็จ · ${_controller.totalCorrect}/3',
          ),
        ),
      );
    }
    final size = MediaQuery.sizeOf(context);
    final adaptive = AudyAdaptive(width: size.width, height: size.height);
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        if (widget.values['show_guide'] == true)
          CaretakerNotice(
            ct(
              context,
              'Choose the next pattern, the different item, or match each piece to its slot.',
              'เลือกแบบรูปถัดไป สิ่งที่แตกต่าง หรือจับคู่ชิ้นส่วน',
            ),
          ),
        Text(
          ct(
            context,
            'Round ${_controller.currentRound}/3',
            'รอบ ${_controller.currentRound}/3',
          ),
        ),
        switch (_type) {
          'pattern' => PatternGameWidget(
            controller: _controller,
            adaptive: adaptive,
            gameColor: Colors.blue,
          ),
          'oddOneOut' => OddOneOutGameWidget(
            controller: _controller,
            adaptive: adaptive,
            gameColor: Colors.pink,
          ),
          _ => PuzzleGameWidget(
            controller: _controller,
            adaptive: adaptive,
            gameColor: Colors.green,
          ),
        },
        if (_controller.showingFeedback)
          Text(
            _controller.isCorrect
                ? ct(context, 'Well done!', 'เก่งมาก!')
                : ct(context, 'Try again', 'ลองอีกครั้ง'),
          ),
        if (_controller.roundComplete &&
            widget.values['advance_mode'] == 'manual')
          FilledButton(
            onPressed: _next,
            child: Text(ct(context, 'Next', 'ถัดไป')),
          ),
      ],
    );
  }
}
