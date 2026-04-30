import 'package:flutter/material.dart';

import '../../core/audy_theme.dart';
import '../../core/audy_ui.dart';
import '../../services/sound_service.dart';
import '../../state/audy_controller.dart';
import 'sorting_game_models.dart';
import 'sort_game_engine.dart';
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

  @override
  void initState() {
    super.initState();
    _engine = SortGameEngine();
    _engine.startSession(widget.level);
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

    final crossCount = items.length <= 3 ? items.length : 3;

    return GridView.count(
      crossAxisCount: crossCount,
      mainAxisSpacing: adaptive.space(12),
      crossAxisSpacing: adaptive.space(12),
      childAspectRatio: 1.0,
      children: items.map((item) {
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
      }).toList(),
    );
  }

  Widget _buildCategoriesWrap(AudyAdaptive adaptive) {
    final categories = _engine.currentCategories;

    return Wrap(
      alignment: WrapAlignment.center,
      runAlignment: WrapAlignment.center,
      spacing: adaptive.space(12),
      runSpacing: adaptive.space(8),
      children: categories.map((category) {
        return SizedBox(
          width:
              (adaptive.contentMaxWidth -
                  adaptive.space(40) -
                  adaptive.space(24)) /
              (categories.length <= 2 ? categories.length : 3),
          child: SortCategoryTarget(
            category: category,
            itemCount: 0,
            isHighlighted: _selectedItemId != null,
            onTap: () {
              SoundService.instance.playTap();
              if (_selectedItemId != null && !_engine.showingFeedback) {
                _engine.handleSortAttempt(_selectedItemId!, category.id);
                setState(() {
                  _selectedItemId = null;
                });
              }
            },
          ),
        );
      }).toList(),
    );
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
                    onPressed: () {
                      SoundService.instance.playTap();
                      _engine.advanceToNextRound();
                    },
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

    return SortGameResultScreen(
      sessionData: sessionData,
      theme: widget.level.theme,
      levelName: widget.level.name,
      onPlayAgain: () {
        _engine.reset();
        _engine.startSession(widget.level);
        setState(() {
          _selectedItemId = null;
        });
      },
      onDone: () {
        Navigator.pop(context, {
          'stars': sessionData.totalStars,
          'data': sessionData.toJson(),
        });
      },
    );
  }
}
