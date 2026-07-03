import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/app_routes.dart';
import '../../core/audy_theme.dart';
import '../../core/audy_ui.dart';
import '../../services/bluetooth_service.dart';
import '../../services/sound_service.dart';
import '../../state/audy_controller.dart';
import '../../widgets/game_guide_box.dart';

String _tr(BuildContext context, String key, {Map<String, String>? params}) {
  return AudyScope.of(context).tr(key, params: params);
}

class FruitCatchingBearScreen extends StatefulWidget {
  const FruitCatchingBearScreen({super.key});

  @override
  State<FruitCatchingBearScreen> createState() =>
      _FruitCatchingBearScreenState();
}

class _FruitCatchingBearScreenState extends State<FruitCatchingBearScreen> {
  static const String _backgroundAsset =
      'assets/images/games/basket/background.png';
  static const String _playerAsset =
      'assets/images/games/basket/bear_default.png';
  static const List<String> _fruitAssets = [
    'assets/images/games/basket/fruits/4.png',
    'assets/images/games/basket/fruits/5.png',
    'assets/images/games/basket/fruits/6.png',
    'assets/images/games/basket/fruits/7.png',
    'assets/images/games/basket/fruits/8.png',
    'assets/images/games/basket/fruits/9.png',
  ];
  static const String _bombAsset = 'assets/images/games/basket/fruits/bomb.png';
  static const String _highScoreKey = 'fruit_catching_bear_high_score';

  final Random _random = Random();
  final List<_FallingItem> _items = [];

  StreamSubscription<dynamic>? _tiltSubscription;
  StreamSubscription<AudyMpuMotion>? _mpuSubscription;
  Timer? _gameLoop;
  Timer? _spawnLoop;

  double _playerX = 0.5;
  double _tiltX = 0;
  bool _isBluetoothConnected = AudyBluetoothService.instance.isConnected;
  bool _hasMpuMotion = false;
  int _score = 0;
  int _highScore = 0;
  bool _isGameOver = false;
  bool _showGuide = true;
  bool _sensorUnavailable = false;
  DateTime _startedAt = DateTime.now();
  Duration _elapsedTime = Duration.zero;
  _StageMetrics? _stageMetrics;

  @override
  void initState() {
    super.initState();
    _startedAt = DateTime.now();
    AudyBluetoothService.instance.connectionNotifier.addListener(
      _handleBluetoothConnectionChanged,
    );
    unawaited(AudyBluetoothService.instance.setMpuMotionEnabled(true));
    _startMpuListening();
    _loadHighScore();
    _startTiltListening();
    _startGame();
  }

  void _handleBluetoothConnectionChanged() {
    if (!mounted) return;

    setState(() {
      _isBluetoothConnected = AudyBluetoothService.instance.isConnected;
      if (_isBluetoothConnected) {
        _tiltX = 0;
        _hasMpuMotion = false;
        _sensorUnavailable = false;
        unawaited(AudyBluetoothService.instance.setMpuMotionEnabled(true));
      }
    });
  }

  void _startMpuListening() {
    _mpuSubscription = AudyBluetoothService.instance.mpuMotionMessages.listen((
      motion,
    ) {
      if (!mounted) return;

      final rawTilt = motion.ay.clamp(-9.8, 9.8);
      final normalizedTilt = (rawTilt / 9.8) * 10.0;
      final deadZonedTilt = normalizedTilt.abs() < 0.2 ? 0.0 : normalizedTilt;

      setState(() {
        _sensorUnavailable = false;
        _hasMpuMotion = true;
        _tiltX = (_tiltX * 0.72) + (deadZonedTilt * 0.28);
      });
    });
  }

  Future<void> _loadHighScore() async {
    final preferences = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _highScore = max(_highScore, preferences.getInt(_highScoreKey) ?? 0);
    });
  }

  Future<void> _saveHighScore(int highScore) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setInt(_highScoreKey, highScore);
  }

  void _startTiltListening() {
    _tiltSubscription = accelerometerEventStream().listen(
      (event) {
        if (!mounted) return;
        if (_isBluetoothConnected) return;
        final isLandscape =
            MediaQuery.maybeOrientationOf(context) == Orientation.landscape;
        final horizontalTilt = isLandscape ? -event.y : event.x;
        setState(() {
          _sensorUnavailable = false;
          _tiltX = horizontalTilt.clamp(-7.0, 7.0);
        });
      },
      onError: (_) {
        if (!mounted) return;
        setState(() => _sensorUnavailable = true);
      },
      cancelOnError: false,
    );
  }

  void _startGame() {
    _gameLoop?.cancel();
    _spawnLoop?.cancel();

    _gameLoop = Timer.periodic(
      const Duration(milliseconds: 16),
      (_) => _tickGame(),
    );
    _spawnLoop = Timer.periodic(
      const Duration(milliseconds: 900),
      (_) => _spawnItem(),
    );
  }

  void _spawnItem() {
    if (!mounted || _isGameOver) return;

    final isBomb = _score >= 2 && _random.nextDouble() < 0.2;
    setState(() {
      _items.add(
        _FallingItem(
          assetPath: isBomb
              ? _bombAsset
              : _fruitAssets[_random.nextInt(_fruitAssets.length)],
          type: isBomb ? _FallingItemType.bomb : _FallingItemType.fruit,
          x: _random.nextDouble(),
          y: -0.12,
          speed: 0.0048,
          sizeFactor: 0.088 + (_random.nextDouble() * 0.025),
        ),
      );
    });
  }

  void _tickGame() {
    if (!mounted || _isGameOver) return;

    setState(() {
      final tiltVelocity = -_tiltX * 0.0027;
      _playerX = (_playerX + tiltVelocity).clamp(0.08, 0.92);

      for (final item in _items) {
        item.y += item.speed;
      }

      _resolveCatches();
      _removeMisses();
    });
  }

  void _resolveCatches() {
    final metrics = _stageMetrics;
    if (metrics == null) return;

    final playerHitSize = metrics.playerSize * 0.86;
    final playerLeft = (metrics.width * _playerX) - (metrics.playerSize / 2);
    final playerTop = metrics.height - 10 - metrics.playerSize;
    final playerHitLeft =
        playerLeft + ((metrics.playerSize - playerHitSize) / 2);
    final playerHitTop = playerTop + ((metrics.playerSize - playerHitSize) / 2);
    final playerRect = Rect.fromLTWH(
      playerHitLeft.clamp(0.0, max(0.0, metrics.width - playerHitSize)),
      playerHitTop,
      playerHitSize,
      playerHitSize,
    );

    final caught = <_FallingItem>[];
    for (final item in _items) {
      final itemSize = metrics.width * item.sizeFactor;
      final itemLeft = (item.x * metrics.width) - (itemSize / 2);
      final itemTop = item.y * metrics.height;
      final itemRect = Rect.fromLTWH(
        itemLeft.clamp(0.0, max(0.0, metrics.width - itemSize)),
        itemTop,
        itemSize,
        itemSize,
      );

      if (playerRect.overlaps(itemRect)) {
        caught.add(item);
      }
    }

    if (caught.isEmpty) return;

    if (caught.any((item) => item.type == _FallingItemType.bomb)) {
      _items.removeWhere(caught.contains);
      SoundService.instance.playWrong();
      _endGame();
      return;
    }

    final fruitCount = caught
        .where((item) => item.type == _FallingItemType.fruit)
        .length;
    if (fruitCount > 0) {
      _score += fruitCount;
      if (_score > _highScore) {
        _highScore = _score;
        unawaited(_saveHighScore(_highScore));
      }
      SoundService.instance.playCorrect();
    }

    _items.removeWhere(caught.contains);
  }

  void _removeMisses() {
    _items.removeWhere((item) => item.y > 1.02);
  }

  void _endGame() {
    _elapsedTime = DateTime.now().difference(_startedAt);
    _isGameOver = true;
    _gameLoop?.cancel();
    _spawnLoop?.cancel();
    SoundService.instance.playGameComplete();
  }

  void _restartGame() {
    SoundService.instance.playTap();
    setState(() {
      _items.clear();
      _playerX = 0.5;
      _tiltX = 0;
      _hasMpuMotion = false;
      _score = 0;
      _isGameOver = false;
      _sensorUnavailable = false;
      _startedAt = DateTime.now();
      _elapsedTime = Duration.zero;
    });
    _startGame();
  }

  void _updateStageMetrics(_StageMetrics metrics) {
    _stageMetrics = metrics;
  }

  void _finishGame() {
    SoundService.instance.playTap();
    final controller = AudyScope.of(context);
    AppRoutes.navigateAfterGameCompletion(context, controller);
  }

  @override
  void dispose() {
    _tiltSubscription?.cancel();
    _mpuSubscription?.cancel();
    unawaited(AudyBluetoothService.instance.setMpuMotionEnabled(false));
    AudyBluetoothService.instance.connectionNotifier.removeListener(
      _handleBluetoothConnectionChanged,
    );
    _gameLoop?.cancel();
    _spawnLoop?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AudyResponsivePage(
      scrollable: false,
      builder: (context, adaptive) {
        return Column(
          children: [
            _TopBar(
              score: _score,
              highScore: _highScore,
              guide: _showGuide
                  ? GameGuideBox(
                      message: _tr(context, 'guide_fruit_catching_bear'),
                      onDismissed: () => setState(() => _showGuide = false),
                    )
                  : null,
              onBack: () {
                SoundService.instance.playTap();
                Navigator.pop(context);
              },
            ),
            if (_sensorUnavailable) ...[
              SizedBox(height: adaptive.space(12)),
              _SensorMessage(
                adaptive: adaptive,
                message: 'Motion sensor is not ready.',
              ),
            ],
            if (_isBluetoothConnected && !_hasMpuMotion) ...[
              SizedBox(height: adaptive.space(12)),
              _SensorMessage(
                adaptive: adaptive,
                message: 'Waiting for motion sensor.',
              ),
            ],
            SizedBox(height: adaptive.space(12)),
            Expanded(
              child: _GameStage(
                backgroundAsset: _backgroundAsset,
                playerAsset: _playerAsset,
                items: _items,
                playerX: _playerX,
                isGameOver: _isGameOver,
                score: _score,
                highScore: _highScore,
                duration: _isGameOver
                    ? _elapsedTime
                    : DateTime.now().difference(_startedAt),
                onRestart: _restartGame,
                onDone: _finishGame,
                onMetricsChanged: _updateStageMetrics,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.score,
    required this.highScore,
    required this.guide,
    required this.onBack,
  });

  final int score;
  final int highScore;
  final Widget? guide;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: AudySpacing.touchTargetMin,
          height: AudySpacing.touchTargetMin,
          child: IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_rounded),
            color: AudyColors.textPrimary,
          ),
        ),
        if (guide != null) ...[
          const SizedBox(width: 12),
          Expanded(child: guide!),
          const SizedBox(width: 12),
        ] else
          const Spacer(),
        _HudPill(icon: Icons.star_rounded, label: '$score'),
        const SizedBox(width: 12),
        _HudPill(icon: Icons.emoji_events_rounded, label: '$highScore'),
      ],
    );
  }
}

class _HudPill extends StatelessWidget {
  const _HudPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 48, minWidth: 88),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AudyColors.backgroundCard.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(AudySpacing.radiusMedium),
        border: Border.all(color: AudyColors.borderLight, width: 2),
        boxShadow: AudyShadows.cardShadow,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AudyColors.starGold, size: 28),
          const SizedBox(width: 8),
          Text(label, style: AudyTypography.headingSmall),
        ],
      ),
    );
  }
}

class _SensorMessage extends StatelessWidget {
  const _SensorMessage({required this.adaptive, required this.message});

  final AudyAdaptive adaptive;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(adaptive.space(14)),
      decoration: BoxDecoration(
        color: AudyColors.warning.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(AudySpacing.radiusMedium),
        border: Border.all(color: AudyColors.warning, width: 2),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_rounded, color: AudyColors.textPrimary),
          SizedBox(width: adaptive.space(10)),
          Expanded(
            child: Text(
              message,
              style: AudyTypography.bodySmall.copyWith(
                color: AudyColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GameStage extends StatelessWidget {
  const _GameStage({
    required this.backgroundAsset,
    required this.playerAsset,
    required this.items,
    required this.playerX,
    required this.isGameOver,
    required this.score,
    required this.highScore,
    required this.duration,
    required this.onRestart,
    required this.onDone,
    required this.onMetricsChanged,
  });

  final String backgroundAsset;
  final String playerAsset;
  final List<_FallingItem> items;
  final double playerX;
  final bool isGameOver;
  final int score;
  final int highScore;
  final Duration duration;
  final VoidCallback onRestart;
  final VoidCallback onDone;
  final ValueChanged<_StageMetrics> onMetricsChanged;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;
        final playerSize = min(width * 0.34, 160.0);
        final playerLeft = (playerX * width) - (playerSize / 2);
        onMetricsChanged(
          _StageMetrics(width: width, height: height, playerSize: playerSize),
        );

        return ClipRRect(
          borderRadius: BorderRadius.circular(AudySpacing.radiusLarge),
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.asset(backgroundAsset, fit: BoxFit.cover),
              ),
              Positioned.fill(
                child: ColoredBox(color: Colors.white.withValues(alpha: 0.08)),
              ),
              for (final item in items)
                _FallingItemSprite(
                  item: item,
                  stageWidth: width,
                  stageHeight: height,
                ),
              Positioned(
                left: playerLeft.clamp(0.0, max(0.0, width - playerSize)),
                bottom: 10,
                child: Image.asset(
                  playerAsset,
                  width: playerSize,
                  height: playerSize,
                  fit: BoxFit.contain,
                ),
              ),
              if (isGameOver)
                _GameOverOverlay(
                  score: score,
                  highScore: highScore,
                  duration: duration,
                  onRestart: onRestart,
                  onDone: onDone,
                ),
            ],
          ),
        );
      },
    );
  }
}

class _FallingItemSprite extends StatelessWidget {
  const _FallingItemSprite({
    required this.item,
    required this.stageWidth,
    required this.stageHeight,
  });

  final _FallingItem item;
  final double stageWidth;
  final double stageHeight;

  @override
  Widget build(BuildContext context) {
    final size = stageWidth * item.sizeFactor;
    final left = (item.x * stageWidth) - (size / 2);
    final top = item.y * stageHeight;

    return Positioned(
      left: left.clamp(0.0, max(0.0, stageWidth - size)),
      top: top,
      child: Image.asset(
        item.assetPath,
        width: size,
        height: size,
        fit: BoxFit.contain,
      ),
    );
  }
}

class _GameOverOverlay extends StatelessWidget {
  const _GameOverOverlay({
    required this.score,
    required this.highScore,
    required this.duration,
    required this.onRestart,
    required this.onDone,
  });

  final int score;
  final int highScore;
  final Duration duration;
  final VoidCallback onRestart;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final seconds = max(1, duration.inSeconds);

    return Positioned.fill(
      child: ColoredBox(
        color: Colors.white.withValues(alpha: 0.9),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AudySpacing.cardPadding),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.celebration_rounded,
                  size: 72,
                  color: AudyColors.mintGreen,
                ),
                const SizedBox(height: 16),
                Text('All done', style: AudyTypography.headingLarge),
                const SizedBox(height: 8),
                Text(
                  'Score $score - Best $highScore - ${seconds}s',
                  style: AudyTypography.headingSmall.copyWith(
                    color: AudyColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 28),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: onRestart,
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('Again'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AudyColors.skyBlue,
                          foregroundColor: AudyColors.textOnColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: onDone,
                        icon: const Icon(Icons.check_rounded),
                        label: const Text('Done'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AudyColors.mintGreen,
                          foregroundColor: AudyColors.textOnColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

enum _FallingItemType { fruit, bomb }

class _StageMetrics {
  const _StageMetrics({
    required this.width,
    required this.height,
    required this.playerSize,
  });

  final double width;
  final double height;
  final double playerSize;
}

class _FallingItem {
  _FallingItem({
    required this.assetPath,
    required this.type,
    required this.x,
    required this.y,
    required this.speed,
    required this.sizeFactor,
  });

  final String assetPath;
  final _FallingItemType type;
  final double x;
  double y;
  final double speed;
  final double sizeFactor;
}
