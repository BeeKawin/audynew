import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/app_routes.dart';
import '../../core/audy_theme.dart';
import '../../core/audy_ui.dart';
<<<<<<< HEAD
import '../../data/models/game_session_model.dart';
import '../../services/bluetooth_service.dart';
import '../../services/interactive_input_service.dart';
import '../../services/sound_service.dart';
import '../../state/audy_controller.dart';
import '../../widgets/game_guide_box.dart';
import '../../widgets/point_celebration_dialog.dart';
=======
import '../../services/bluetooth_service.dart';
import '../../services/sound_service.dart';
import '../../state/audy_controller.dart';
import '../../widgets/game_guide_box.dart';
>>>>>>> origin/Kongnew
import '../../widgets/robot_panel_layout.dart';
import '../../widgets/virtual_robot_panel.dart';

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

  Timer? _gameLoop;
  Timer? _spawnLoop;
  StreamSubscription<AudyBleMessage>? _bleInputSub;

  double _playerX = 0.25;
  double _targetPlayerX = 0.25;
  int _score = 0;
  int _highScore = 0;
  bool _isGameOver = false;
<<<<<<< HEAD
  bool _hasCompletedSession = false;
=======
>>>>>>> origin/Kongnew
  bool _showGuide = true;
  DateTime _startedAt = DateTime.now();
  Duration _elapsedTime = Duration.zero;
  _StageMetrics? _stageMetrics;

  @override
  void initState() {
    super.initState();
<<<<<<< HEAD
    unawaited(SoundService.instance.playFruitCatchIntro());
    unawaited(_sendGameEnterBleState());
    _startedAt = DateTime.now();
    _loadHighScore();
    _startGame();
    _bleInputSub = InteractiveInputService.instance.incomingMessages.listen(
=======
    _startedAt = DateTime.now();
    _loadHighScore();
    _startGame();
    _bleInputSub = AudyBluetoothService.instance.incomingMessages.listen(
>>>>>>> origin/Kongnew
      _handleBleInput,
    );
  }

<<<<<<< HEAD
  Future<void> _sendGameEnterBleState() async {
    try {
      await AudyBluetoothService.instance.setLed(21);
    } catch (e) {
      debugPrint('FruitCatchingBearScreen: Entry LED BLE state skipped - $e');
    }
  }

  Future<void> _sendCompletionBleCelebration() async {
    try {
      await AudyBluetoothService.instance.celebrateGameCompletion();
    } catch (e) {
      debugPrint('FruitCatchingBearScreen: Completion BLE skipped - $e');
    }
  }

  Future<void> _resetGameBleState() async {
    try {
      await AudyBluetoothService.instance.setLed(0);
    } catch (e) {
      debugPrint('FruitCatchingBearScreen: Exit LED BLE reset skipped - $e');
    }
  }

  void _handleBleInput(AudyBleMessage message) {
    if (!mounted || _isGameOver) return;
    if (ModalRoute.of(context)?.isCurrent != true) return;
=======
  void _handleBleInput(AudyBleMessage message) {
    if (!mounted || _isGameOver) return;
>>>>>>> origin/Kongnew

    if (message.channel == 'ears') {
      if (message.value == 1) {
        _changeLane(0.25);
      } else if (message.value == 2) {
        _changeLane(0.75);
      }
    }
  }

  void _triggerVirtualInput(String channel, int value) {
    _handleBleInput(
      AudyBleMessage(
        channel: channel,
        value: value,
        receivedAt: DateTime.now(),
      ),
    );
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
    final laneX = _random.nextBool() ? 0.25 : 0.75;
    setState(() {
      _items.add(
        _FallingItem(
          assetPath: isBomb
              ? _bombAsset
              : _fruitAssets[_random.nextInt(_fruitAssets.length)],
          type: isBomb ? _FallingItemType.bomb : _FallingItemType.fruit,
          x: laneX,
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
      _playerX = _playerX + (_targetPlayerX - _playerX) * 0.25;

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
<<<<<<< HEAD
    if (_isGameOver) return;
=======
>>>>>>> origin/Kongnew
    _elapsedTime = DateTime.now().difference(_startedAt);
    _isGameOver = true;
    _gameLoop?.cancel();
    _spawnLoop?.cancel();
    SoundService.instance.playGameComplete();
<<<<<<< HEAD
    unawaited(_sendCompletionBleCelebration());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) unawaited(_completeSession());
    });
  }

  Future<void> _completeSession() async {
    if (_hasCompletedSession || !mounted) return;
    _hasCompletedSession = true;

    final controller = AudyScope.of(context);
    final pointsEarned = _score * 5;
    final initialPoints = controller.learningPoints;
    final newPoints = initialPoints + pointsEarned;
    final oldLevel = _getLevelFromPoints(initialPoints);
    final newLevel = _getLevelFromPoints(newPoints);
    final isLevelUp = newLevel > oldLevel;

    if (pointsEarned > 0) {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => PointCelebrationDialog(
          points: pointsEarned,
          totalPoints: newPoints,
          currentLevel: newLevel,
          nextLevelThreshold: _getNextLevelThreshold(newLevel),
          nextLevelName: _getLevelName(newLevel + 1),
          isLevelUp: isLevelUp,
          newLevelName: isLevelUp ? _getLevelName(newLevel) : null,
          onClose: () => Navigator.of(dialogContext).pop(),
        ),
      );
      if (!mounted) return;
      await controller.addPoints(pointsEarned);
    }

    await controller.trackFruitCatchingCompleted();
    await controller.recordAnalyticsSession(
      GameSessionData.fromTimes(
        gameType: 'fruit_catching_bear',
        difficulty: 'standard',
        correctActions: _score,
        totalActions: max(1, _score + 1),
        starsEarned: _score >= 10
            ? 3
            : (_score >= 5 ? 2 : (_score > 0 ? 1 : 0)),
        sessionStartedAt: _startedAt,
        sessionEndedAt: _startedAt.add(_elapsedTime),
      ),
    );
  }

  int _getLevelFromPoints(int points) {
    if (points >= 1000) return 4;
    if (points >= 500) return 3;
    if (points >= 250) return 2;
    if (points >= 100) return 1;
    return 0;
  }

  int _getNextLevelThreshold(int level) {
    const thresholds = [100, 250, 500, 1000, 2000];
    return level >= thresholds.length ? 2000 : thresholds[level];
  }

  String _getLevelName(int level) {
    const names = ['Beginner', 'Learner', 'Explorer', 'Expert', 'Master'];
    return level >= names.length ? 'Master' : names[level];
=======
>>>>>>> origin/Kongnew
  }

  void _changeLane(double laneX) {
    if (_isGameOver) return;
    if (_targetPlayerX != laneX) {
      SoundService.instance.playTap();
      setState(() {
        _targetPlayerX = laneX;
      });
    }
  }

  void _restartGame() {
    SoundService.instance.playTap();
    setState(() {
      _items.clear();
      _playerX = 0.25;
      _targetPlayerX = 0.25;
      _score = 0;
      _isGameOver = false;
<<<<<<< HEAD
      _hasCompletedSession = false;
      _startedAt = DateTime.now();
      _elapsedTime = Duration.zero;
    });
    unawaited(_sendGameEnterBleState());
=======
      _startedAt = DateTime.now();
      _elapsedTime = Duration.zero;
    });
>>>>>>> origin/Kongnew
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
<<<<<<< HEAD
    unawaited(_resetGameBleState());
=======
>>>>>>> origin/Kongnew
    _gameLoop?.cancel();
    _spawnLoop?.cancel();
    _bleInputSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AudyResponsivePage(
      scrollable: false,
      builder: (context, adaptive) {
        return ValueListenableBuilder<bool>(
          valueListenable: AudyBluetoothService.instance.connectionNotifier,
          builder: (context, isConnected, _) {
            return RobotPanelLayout(
              adaptive: adaptive,
              showPanel: !isConnected,
              panelBuilder: (isHorizontal) => VirtualRobotPanel(
                adaptive: adaptive,
                isHorizontal: isHorizontal,
                onEarsLeftTap: () => _triggerVirtualInput('ears', 1),
                onEarsRightTap: () => _triggerVirtualInput('ears', 2),
              ),
              child: Column(
                children: [
                  _TopBar(
                    score: _score,
                    highScore: _highScore,
                    guide: _showGuide
                        ? GameGuideBox(
                            message: _tr(context, 'guide_fruit_catching_bear'),
                            onDismissed: () =>
                                setState(() => _showGuide = false),
                          )
                        : null,
                    onBack: () {
                      SoundService.instance.playTap();
                      Navigator.pop(context);
                    },
                  ),
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
                      onLaneTapped: _changeLane,
                    ),
                  ),
                ],
              ),
            );
          },
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
    required this.onLaneTapped,
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
  final ValueChanged<double> onLaneTapped;

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

        return GestureDetector(
          onTapDown: (details) {
            final tapX = details.localPosition.dx;
            final laneX = tapX < (width / 2) ? 0.25 : 0.75;
            onLaneTapped(laneX);
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AudySpacing.radiusLarge),
            child: Stack(
              children: [
                Positioned.fill(
                  child: Image.asset(backgroundAsset, fit: BoxFit.cover),
                ),
                Positioned.fill(
                  child: ColoredBox(color: Colors.white.withValues(alpha: 0.08)),
                ),
                Positioned.fill(
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border(
                              right: BorderSide(
                                color: Colors.white.withValues(alpha: 0.2),
                                width: 2.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const Expanded(
                        child: SizedBox.shrink(),
                      ),
                    ],
                  ),
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
