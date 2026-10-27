import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../caretaker_ui.dart';

class FruitPreview extends StatefulWidget {
  const FruitPreview({super.key, required this.values});
  final Map<String, dynamic> values;
  @override
  State<FruitPreview> createState() => _FruitPreviewState();
}

class _FruitItem {
  _FruitItem(this.x, this.asset, this.bomb);
  final double x;
  final String asset;
  final bool bomb;
  double y = -.12;
}

class _FruitPreviewState extends State<FruitPreview>
    with WidgetsBindingObserver {
  final _random = Random();
  final List<_FruitItem> _items = [];
  Timer? _tick;
  Timer? _spawn;
  double _x = .25;
  double _target = .25;
  int _score = 0;
  bool _over = false;
  int _elapsedMs = 0;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _run();
  }

  void _run() {
    _tick = Timer.periodic(const Duration(milliseconds: 16), (_) {
      if (!mounted || _over) return;
      setState(() {
        _elapsedMs += 16;
        _x += (_target - _x) * .25;
        final speed = switch (widget.values['fall_speed']) {
          'slow' => .0032,
          'fast' => .0064,
          _ => .0048,
        };
        for (final item in List<_FruitItem>.from(_items)) {
          item.y += speed;
          if (item.y > .78 && item.y < .94 && (item.x - _x).abs() < .16) {
            _items.remove(item);
            if (item.bomb) {
              _end();
              break;
            } else {
              _score++;
            }
          }
        }
        _items.removeWhere((item) => item.y > 1.02);
        final duration = widget.values['duration_seconds'] as int?;
        if (duration != null && _elapsedMs >= duration * 1000) _end();
      });
    });
    _spawn = Timer.periodic(
      Duration(milliseconds: widget.values['spawn_interval_ms'] as int),
      (_) {
        if (!mounted || _over) return;
        final bomb =
            _score >= (widget.values['bomb_grace_count'] as int) &&
            _random.nextDouble() <
                (widget.values['bomb_probability'] as num).toDouble();
        final fruits = widget.values['fruit_ids'] as List;
        setState(
          () => _items.add(
            _FruitItem(
              _random.nextBool() ? 0.25 : 0.75,
              bomb ? 'bomb' : fruits[_random.nextInt(fruits.length)] as String,
              bomb,
            ),
          ),
        );
      },
    );
  }

  void _end() {
    _over = true;
    _tick?.cancel();
    _spawn?.cancel();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _tick?.cancel();
    _spawn?.cancel();
    if (state == AppLifecycleState.resumed && !_over) _run();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tick?.cancel();
    _spawn?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(
        ct(
          context,
          'Preview score: $_score · ${_elapsedMs ~/ 1000}s',
          'คะแนนทดลอง: $_score · ${_elapsedMs ~/ 1000} วินาที',
        ),
      ),
      if (widget.values['show_guide'] == true)
        Padding(
          padding: const EdgeInsets.all(12),
          child: Text(
            ct(
              context,
              'Tap left or right to catch fruit and avoid bombs.',
              'แตะซ้ายหรือขวาเพื่อรับผลไม้และหลบระเบิด',
            ),
          ),
        ),
      Expanded(
        child: LayoutBuilder(
          builder: (context, size) => GestureDetector(
            onTapDown: _over
                ? null
                : (d) => setState(
                    () => _target = d.localPosition.dx < size.maxWidth / 2
                        ? 0.25
                        : 0.75,
                  ),
            child: ClipRect(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    'assets/images/games/basket/background.png',
                    fit: BoxFit.cover,
                  ),
                  for (final item in _items)
                    Positioned(
                      left: item.x * size.maxWidth - 24,
                      top: item.y * size.maxHeight,
                      child: Image.asset(
                        'assets/images/games/basket/fruits/${item.asset}.png',
                        width: 48,
                        height: 48,
                      ),
                    ),
                  Positioned(
                    left: _x * size.maxWidth - 50,
                    bottom: 8,
                    child: Image.asset(
                      'assets/images/games/basket/bear_default.png',
                      width: 100,
                      height: 100,
                    ),
                  ),
                  if (_over)
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        color: Colors.white,
                        child: Text(
                          ct(
                            context,
                            'Preview complete · $_score fruit',
                            'ทดลองเสร็จ · $_score ผล',
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(16),
        child: OutlinedButton(
          onPressed: () => Navigator.pop(context),
          child: Text(ct(context, 'End preview', 'จบการทดลอง')),
        ),
      ),
    ],
  );
}
