import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/app_routes.dart';
import '../../core/audy_theme.dart';
import '../../core/audy_ui.dart';
import '../../data/models/game_session_model.dart';
import '../../services/bluetooth_service.dart';
import '../../services/sound_service.dart';
import '../../state/audy_controller.dart';
import '../../widgets/game_guide_box.dart';
import 'sorting_game_models.dart';
import 'sort_game_engine.dart';
import 'sort_levels.dart';
import 'sort_game_widgets.dart';
import 'sort_game_result_screen.dart';

// Helper function to get localized string
String _tr(BuildContext context, String key, {Map<String, String>? params}) {
  return AudyScope.of(context).tr(key, params: params);
}

class SortGameScreen extends StatefulWidget {
  const SortGameScreen({super.key, required this.level});

  final SortGameLevel level;

  @override
  State<SortGameScreen> createState() => _SortGameScreenState();
}

class _SortGameScreenState extends State<SortGameScreen> {
  late SortGameEngine _engine;
  String? _selectedItemId;
  bool _sessionRecorded = false;
  bool _sessionBleSignalSent = false;
  bool _unlockRecorded = false;
  bool _showGuide = true;

  @override
  void initState() {
    super.initState();
    _engine = SortGameEngine();
    _engine.startSession(widget.level);
    SoundService.instance.playInstructionSortingGame();
  }

  @override
  void dispose() {
    _engine.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _engine,
      builder: (context, _) {
        if (_engine.sessionComplete) {
          return _buildResultScreen();
        }

        if (_engine.roundComplete) {
          return _buildRoundCompleteOverlay();
        }

        return AudyResponsivePage(
          scrollable: false,
          builder: (context, adaptive) {
            return Column(
              children: [
                _buildHeader(adaptive),
                SizedBox(height: adaptive.space(12)),
                if (_showGuide) ...[
                  GameGuideBox(
                    message: _tr(context, 'guide_sorting_game'),
                    onDismissed: () => setState(() => _showGuide = false),
                  ),
                  SizedBox(height: adaptive.space(12)),
                ],
                _buildInstruction(),
                SizedBox(height: adaptive.space(12)),
                SortGameProgress(
                  currentRound: _engine.currentRoundNumber,
                  totalRounds: _engine.totalRounds,
                  remainingItems: _engine.remainingItems.length,
                ),
                SizedBox(height: adaptive.space(12)),
                Expanded(
                  child: Stack(
                    children: [
                      Column(
                        children: [
                          Expanded(
                            flex: _engine.remainingItems.length > 5 ? 3 : 2,
                            child: _buildItemsGrid(adaptive),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: adaptive.space(20),
                            ),
                            child: Divider(
                              color: AudyColors.borderLight,
                              thickness: 2,
                              height: 1,
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: SingleChildScrollView(
                              child: _buildCategoriesWrap(adaptive),
                            ),
                          ),
                        ],
                      ),
                      if (_engine.showingFeedback)
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: ABAGameFeedbackOverlay(
                              message: _tr(context, _engine.feedbackMessageKey),
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

  Widget _buildHeader(AudyAdaptive adaptive) {
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: adaptive.space(8),
      runSpacing: adaptive.space(4),
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              onTap: () {
                SoundService.instance.playTap();
                final sessionData = _engine.getSessionData();
                Navigator.pop(context, sessionData.toJson());
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
              widget.level.theme.icon,
              size: adaptive.space(32),
              color: widget.level.theme.primaryColor,
            ),
            SizedBox(width: adaptive.space(8)),
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: adaptive.space(140)),
              child: Text(
                widget.level.name,
                style: AudyTypography.headingSmall,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
        Flexible(
          child: StarRewardDisplay(
            starsEarned: _engine.liveProgressStars,
            maxStars: _engine.totalItemsInLevel,
            starSize: adaptive.space(24),
          ),
        ),
      ],
    );
  }

  Widget _buildInstruction() {
    return Center(
      child: Text(
        widget.level.theme.instructionText,
        style: AudyTypography.bodyMedium,
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildItemsGrid(AudyAdaptive adaptive) {
    final items = _engine.remainingItems;
    if (items.isEmpty) {
      return const Center(
        child: Icon(
          Icons.check_circle_rounded,
          size: 80,
          color: AudyColors.mintGreen,
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final spacing = adaptive.space(12);
        final crossCount = _itemGridColumns(
          adaptive: adaptive,
          itemCount: items.length,
          maxWidth: constraints.maxWidth,
        );
        final maxCardSize = _itemCardMaxSize(adaptive);
        final gridWidth = _stableGridWidth(
          availableWidth: constraints.maxWidth,
          columns: crossCount,
          spacing: spacing,
          maxCardSize: maxCardSize,
        );

        return Center(
          child: SizedBox(
            width: gridWidth,
            child: GridView.builder(
              padding: EdgeInsets.zero,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossCount,
                mainAxisSpacing: spacing,
                crossAxisSpacing: spacing,
                childAspectRatio: 1.0,
              ),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                final isSelected = _selectedItemId == item.id;
                final isHinted = _engine.hintItemId == item.id;

                return SortItemCard(
                  item: item,
                  isSelected: isSelected,
                  isHinted: isHinted,
                  isDisabled: _engine.showingFeedback,
                  onTap: () {
                    SoundService.instance.playTap();
                    setState(() {
                      _selectedItemId = item.id;
                    });
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  Future<void> _sendCorrectSortBleSignal() async {
    try {
      await AudyBluetoothService.instance.pulseEmotion(1);
    } catch (e) {
      debugPrint('SortGameScreen: Correct sort BLE signal skipped - $e');
    }
  }

  Future<void> _sendSessionCompleteBleSignal() async {
    if (_sessionBleSignalSent) return;
    _sessionBleSignalSent = true;

    try {
      final bluetooth = AudyBluetoothService.instance;
      await bluetooth.setArms(4);
      await bluetooth.pulseEmotion(2);
    } catch (e) {
      debugPrint('SortGameScreen: Session complete BLE signal skipped - $e');
    }
  }

  void _handleCategoryTap(String categoryId) {
    SoundService.instance.playTap();
    if (_selectedItemId == null || _engine.showingFeedback) return;

    final previousCorrectCount = _engine.totalCorrect;
    _engine.handleSortAttempt(_selectedItemId!, categoryId);

    setState(() {
      _selectedItemId = null;
    });

    if (_engine.totalCorrect > previousCorrectCount) {
      unawaited(_sendCorrectSortBleSignal());
    }
  }

  void _handleRoundContinue() {
    SoundService.instance.playTap();
    _engine.advanceToNextRound();

    if (_engine.sessionComplete) {
      unawaited(_sendSessionCompleteBleSignal());
    }
  }

  Widget _buildCategoriesWrap(AudyAdaptive adaptive) {
    final categories = _engine.currentCategories;

    return LayoutBuilder(
      builder: (context, constraints) {
        final spacing = adaptive.space(12);
        final columns = _categoryColumns(
          adaptive: adaptive,
          categoryCount: categories.length,
          maxWidth: constraints.maxWidth,
        );
        final cardWidth = _categoryCardWidth(
          availableWidth: constraints.maxWidth,
          columns: columns,
          spacing: spacing,
          adaptive: adaptive,
        );
        final cardHeight = _categoryCardHeight(adaptive);

        return Wrap(
          alignment: WrapAlignment.center,
          runAlignment: WrapAlignment.center,
          spacing: spacing,
          runSpacing: adaptive.space(8),
          children: categories.map((category) {
            return SizedBox(
              width: cardWidth,
              height: cardHeight,
              child: SortCategoryTarget(
                category: category,
                itemCount: 0,
                isHighlighted: _selectedItemId != null,
                onTap: () => _handleCategoryTap(category.id),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  int _itemGridColumns({
    required AudyAdaptive adaptive,
    required int itemCount,
    required double maxWidth,
  }) {
    if (itemCount <= 1) return 1;
    if (adaptive.isPhone && maxWidth < 360) return 2;
    if (adaptive.isPhone && itemCount <= 2) return itemCount;
    return itemCount < 3 ? itemCount : 3;
  }

  double _itemCardMaxSize(AudyAdaptive adaptive) {
    if (adaptive.isDesktop) return 156;
    if (adaptive.isTablet) return 148;
    return 128;
  }

  double _stableGridWidth({
    required double availableWidth,
    required int columns,
    required double spacing,
    required double maxCardSize,
  }) {
    final preferredWidth = (columns * maxCardSize) + ((columns - 1) * spacing);
    return preferredWidth < availableWidth ? preferredWidth : availableWidth;
  }

  int _categoryColumns({
    required AudyAdaptive adaptive,
    required int categoryCount,
    required double maxWidth,
  }) {
    if (categoryCount <= 1) return 1;
    if (adaptive.isPhone && maxWidth < 360) return 2;
    if (categoryCount <= 2) return categoryCount;
    return adaptive.isPhone ? 2 : 3;
  }

  double _categoryCardWidth({
    required double availableWidth,
    required int columns,
    required double spacing,
    required AudyAdaptive adaptive,
  }) {
    var maxWidth = 156.0;
    if (adaptive.isTablet) maxWidth = 176.0;
    if (adaptive.isDesktop) maxWidth = 188.0;

    final availableCardWidth =
        (availableWidth - (spacing * (columns - 1))) / columns;
    return availableCardWidth < maxWidth ? availableCardWidth : maxWidth;
  }

  double _categoryCardHeight(AudyAdaptive adaptive) {
    if (adaptive.isDesktop) return 128;
    if (adaptive.isTablet) return 120;
    return 108;
  }

  Widget _buildRoundCompleteOverlay() {
    final stars = _engine.currentRoundStars;

    return AudyResponsivePage(
      scrollable: false,
      builder: (context, adaptive) {
        return Column(
          children: [
            Row(
              children: [
                InkWell(
                  onTap: () {
                    SoundService.instance.playTap();
                    final sessionData = _engine.getSessionData();
                    Navigator.pop(context, sessionData.toJson());
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
              ],
            ),
            Expanded(
              child: ListView(
                children: [
                  SizedBox(height: adaptive.space(32)),
                  Icon(
                    Icons.celebration_rounded,
                    size: adaptive.space(80),
                    color: AudyColors.mintGreen,
                  ),
                  SizedBox(height: adaptive.space(16)),
                  Text(
                    _tr(context, _engine.feedbackMessageKey),
                    style: AudyTypography.displayLarge,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: adaptive.space(24)),
                  StarRewardDisplay(
                    starsEarned: stars,
                    maxStars: _engine.totalItemsInCurrentRound,
                    starSize: adaptive.space(40),
                  ),
                  SizedBox(height: adaptive.space(24)),
                  Container(
                    padding: EdgeInsets.all(adaptive.space(20)),
                    decoration: BoxDecoration(
                      color: AudyColors.backgroundCard,
                      borderRadius: BorderRadius.circular(
                        AudySpacing.radiusXLarge,
                      ),
                      boxShadow: AudyShadows.cardShadow,
                    ),
                    child: Column(
                      children: [
                        Text(
                          _tr(
                            context,
                            'round_complete',
                            params: {
                              'round': _engine.currentRoundNumber.toString(),
                            },
                          ),
                          style: AudyTypography.headingMedium,
                        ),
                        SizedBox(height: adaptive.space(8)),
                        Text(
                          '${_tr(context, 'correct_count', params: {'correct': _engine.totalCorrect.toString()})} | ${_tr(context, 'try_again_count', params: {'count': _engine.totalIncorrect.toString()})}',
                          style: AudyTypography.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: adaptive.space(24)),
                  ElevatedButton(
                    onPressed: _handleRoundContinue,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AudyColors.skyBlue,
                      foregroundColor: AudyColors.textOnColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AudySpacing.radiusXLarge,
                        ),
                      ),
                      elevation: 4,
                      minimumSize: Size(double.infinity, adaptive.space(56)),
                    ),
                    child: Text(
                      _engine.sessionComplete
                          ? _tr(context, 'see_results')
                          : _tr(context, 'next_round'),
                      style: AudyTypography.buttonText,
                    ),
                  ),
                  SizedBox(height: adaptive.space(24)),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildResultScreen() {
    final sessionData = _engine.getSessionData();

    if (!_unlockRecorded) {
      _unlockRecorded = true;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;
        final controller = AudyScope.of(context);
        await controller.unlockSortingLevelAfterCompletion(
          levelId: widget.level.id,
          completedLevelIndex: SortLevelDefinitions.indexForLevelId(
            widget.level.id,
          ),
          starsEarned: sessionData.totalStars,
          starsRequired: widget.level.starsRequired,
        );
      });
    }

    // Record the session to analytics database (guard against duplicate calls)
    if (!_sessionRecorded) {
      _sessionRecorded = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final controller = AudyScope.of(context);
        final gameSession = GameSessionData.fromTimes(
          gameType: 'sorting',
          levelId: sessionData.levelId,
          difficulty: sessionData.difficulty,
          correctActions: sessionData.correctActions,
          totalActions: sessionData.totalActions,
          starsEarned: sessionData.totalStars,
          sessionStartedAt: sessionData.sessionStartedAt,
          sessionEndedAt: sessionData.sessionEndedAt,
        );
        controller.recordAnalyticsSession(gameSession);
      });
    }

    return SortGameResultScreen(
      sessionData: sessionData,
      theme: widget.level.theme,
      levelName: widget.level.name,
      onPlayAgain: () {
        _engine.reset();
        _engine.startSession(widget.level);
        setState(() {
          _selectedItemId = null;
          _sessionRecorded = false;
          _sessionBleSignalSent = false;
          _unlockRecorded = false;
        });
      },
      onDone: () {
        final controller = AudyScope.of(context);
        AppRoutes.navigateAfterGameCompletion(context, controller);
      },
    );
  }
}
