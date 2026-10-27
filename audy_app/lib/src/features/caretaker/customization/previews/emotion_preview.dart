import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../core/emotion_images.dart';
import '../../caretaker_ui.dart';

class EmotionPreview extends StatefulWidget {
  const EmotionPreview({super.key, required this.values});
  final Map<String, dynamic> values;
  @override
  State<EmotionPreview> createState() => _EmotionPreviewState();
}

class _EmotionPreviewState extends State<EmotionPreview> {
  final _random = Random();
  late List<String> _targets;
  late List<String> _choices;
  late String _image;
  int _round = 0;
  String? _answer;
  bool _selfie = false;
  Timer? _timer;
  String get _target => _targets[_round];
  String _title(String s) => s[0].toUpperCase() + s.substring(1);
  @override
  void initState() {
    super.initState();
    final pool = List<String>.from(widget.values['target_emotions'] as List);
    _targets = [];
    while (_targets.length < (widget.values['round_count'] as int)) {
      final cycle = List<String>.from(pool)..shuffle(_random);
      if (_targets.isNotEmpty && cycle.first == _targets.last) {
        cycle.add(cycle.removeAt(0));
      }
      _targets.addAll(cycle);
    }
    _prepare();
  }

  void _prepare() {
    final others = List<String>.from(widget.values['target_emotions'] as List)
      ..remove(_target)
      ..shuffle(_random);
    final selected = {
      _target,
      ...others.take((widget.values['choice_count'] as int) - 1),
    };
    _choices = [
      'happy',
      'sad',
      'angry',
      'scared',
    ].where(selected.contains).toList();
    _image = widget.values['image_mode'] == 'consistent'
        ? EmotionImages.getDefaultPath(_title(_target))
        : EmotionImages.getRandomPath(_title(_target));
  }

  void _choose(String answer) {
    setState(() => _answer = answer);
    final mode = widget.values['advance_mode'];
    if (mode != 'manual') {
      _timer = Timer(
        Duration(milliseconds: mode == 'automatic_3000ms' ? 3000 : 1500),
        () {
          if (mounted) setState(() => _selfie = true);
        },
      );
    }
  }

  void _next() {
    setState(() {
      _round++;
      _answer = null;
      _selfie = false;
      if (_round < (widget.values['round_count'] as int)) _prepare();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_round >= (widget.values['round_count'] as int)) {
      return Center(
        child: Text(ct(context, 'Preview complete', 'ทดลองเสร็จแล้ว')),
      );
    }
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(
          ct(
            context,
            'Round ${_round + 1}/${widget.values['round_count']}',
            'รอบ ${_round + 1}/${widget.values['round_count']}',
          ),
        ),
        if (widget.values['show_guide'] == true)
          CaretakerNotice(
            ct(
              context,
              'Choose the matching emotion, then see the selfie target. Camera recognition is not tested here.',
              'เลือกอารมณ์ที่ตรงกัน แล้วดูเป้าหมายเซลฟี หน้านี้ไม่ทดสอบกล้องหรือโมเดล',
            ),
          ),
        if (_selfie) ...[
          const Icon(Icons.camera_alt_outlined, size: 80),
          Text(
            ct(
              context,
              'Next: make a ${_title(_target)} face',
              'ขั้นต่อไป: แสดงสีหน้า ${_title(_target)}',
            ),
          ),
          CaretakerNotice(
            ct(
              context,
              'Selfie target preview only. No photo or model result is created.',
              'แสดงเป้าหมายเท่านั้น ไม่ถ่ายภาพหรือสร้างผลตรวจ',
            ),
          ),
          FilledButton(
            onPressed: _next,
            child: Text(ct(context, 'Next preview round', 'รอบทดลองถัดไป')),
          ),
        ] else ...[
          Image.asset(_image, height: 220, fit: BoxFit.contain),
          const SizedBox(height: 16),
          for (final emotion in _choices)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: OutlinedButton(
                onPressed: _answer == null ? () => _choose(emotion) : null,
                child: Text(_title(emotion)),
              ),
            ),
          if (_answer != null)
            Text(
              _answer == _target
                  ? ct(context, 'Well done!', 'เก่งมาก!')
                  : ct(
                      context,
                      'The matching emotion is ${_title(_target)}.',
                      'อารมณ์ที่ตรงคือ ${_title(_target)}',
                    ),
            ),
          if (_answer != null && widget.values['advance_mode'] == 'manual')
            FilledButton(
              onPressed: () => setState(() => _selfie = true),
              child: Text(
                ct(context, 'Continue to selfie target', 'ดูเป้าหมายเซลฟี'),
              ),
            ),
        ],
      ],
    );
  }
}
