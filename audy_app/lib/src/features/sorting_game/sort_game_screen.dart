import 'package:flutter/material.dart';

import '../../core/audy_theme.dart';
import 'sorting_game_models.dart';
import 'sort_game_engine.dart';
import 'sort_game_widgets.dart';
import 'sort_game_result_screen.dart';

class SortGameScreen extends StatefulWidget {
  const SortGameScreen({super.key, required this.level});

  final SortGameLevel level;

  @override
  State<SortGameScreen> createState() => _SortGameScreenState();
}

class _SortGameScreenState extends State<SortGameScreen> {
  late SortGameEngine _engine;
  String? _selectedItemId;

  static const double _maxWidth = 420.0;

  double _sp(double width) => width.clamp(0.0, _maxWidth);

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

        final screenHeight = MediaQuery.of(context).size.height;
        final screenWidth = MediaQuery.of(context).size.width;
        final effectiveWidth = _sp(screenWidth);

        return Scaffold(
          backgroundColor: AudyColors.backgroundPrimary,
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: _maxWidth),
                child: Padding(
                  padding: EdgeInsets.all(effectiveWidth * 0.04),
                  child: ListView(
                    children: [
                      _buildHeader(effectiveWidth),
                      SizedBox(height: screenHeight * 0.015),
                      _buildInstruction(),
                      SizedBox(height: screenHeight * 0.015),
                      SortGameProgress(
                        currentRound: _engine.currentRoundNumber,
                        totalRounds: _engine.totalRounds,
                        remainingItems: _engine.remainingItems.length,
                      ),
                      SizedBox(height: screenHeight * 0.015),
                      SizedBox(
                        height: (screenHeight * 0.6).clamp(300.0, 500.0),
                        child: Stack(
                          children: [
                            Column(
                              children: [
                                Expanded(
                                  flex: _engine.remainingItems.length > 5
                                      ? 3
                                      : 2,
                                  child: _buildItemsGrid(effectiveWidth),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: effectiveWidth * 0.05),
                                  child: Divider(
                                    color: AudyColors.borderLight,
                                    thickness: 2,
                                    height: 1,
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: _buildCategoriesWrap(effectiveWidth),
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
                                    message: _engine.feedbackMessage,
                                    isCorrect: _engine.isCorrect,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(double effectiveWidth) {
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: effectiveWidth * 0.02,
      runSpacing: effectiveWidth * 0.01,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              onTap: () {
                final sessionData = _engine.getSessionData();
                Navigator.pop(context, sessionData.toJson());
              },
              borderRadius: BorderRadius.circular(AudySpacing.radiusMedium),
              child: SizedBox(
                width: effectiveWidth * 0.12,
                height: effectiveWidth * 0.12,
                child: const Icon(
                  Icons.arrow_back_rounded,
                  size: AudySpacing.iconMedium,
                ),
              ),
            ),
            SizedBox(width: effectiveWidth * 0.02),
            Icon(
              widget.level.theme.icon,
              size: effectiveWidth * 0.08,
              color: widget.level.theme.primaryColor,
            ),
            SizedBox(width: effectiveWidth * 0.02),
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: effectiveWidth * 0.35),
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
            starsEarned: _engine.totalStars,
            maxStars: widget.level.totalRounds * 3,
            starSize: effectiveWidth * 0.06,
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

  Widget _buildItemsGrid(double effectiveWidth) {
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
      mainAxisSpacing: effectiveWidth * 0.03,
      crossAxisSpacing: effectiveWidth * 0.03,
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
            setState(() {
              _selectedItemId = item.id;
            });
          },
        );
      }).toList(),
    );
  }

  Widget _buildCategoriesWrap(double effectiveWidth) {
    final categories = _engine.currentCategories;

    return Wrap(
      alignment: WrapAlignment.center,
      runAlignment: WrapAlignment.center,
      spacing: effectiveWidth * 0.03,
      runSpacing: effectiveWidth * 0.02,
      children: categories.map((category) {
        return SizedBox(
          width:
              (effectiveWidth - effectiveWidth * 0.08 - effectiveWidth * 0.06) /
              (categories.length <= 2 ? categories.length : 3),
          child: SortCategoryTarget(
            category: category,
            itemCount: 0,
            isHighlighted: _selectedItemId != null,
            onTap: () {
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
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final effectiveWidth = _sp(screenWidth);

    return Scaffold(
      backgroundColor: AudyColors.backgroundPrimary,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: _maxWidth),
            child: Padding(
              padding: EdgeInsets.all(effectiveWidth * 0.04),
              child: Column(
                children: [
                  Row(
                    children: [
                      InkWell(
                        onTap: () {
                          final sessionData = _engine.getSessionData();
                          Navigator.pop(context, sessionData.toJson());
                        },
                        borderRadius: BorderRadius.circular(
                          AudySpacing.radiusMedium,
                        ),
                        child: SizedBox(
                          width: effectiveWidth * 0.12,
                          height: effectiveWidth * 0.12,
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
                        SizedBox(height: screenHeight * 0.04),
                        Icon(
                          Icons.celebration_rounded,
                          size: (screenHeight * 0.1).clamp(60.0, 80.0),
                          color: AudyColors.mintGreen,
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        Text(
                          _engine.feedbackMessage,
                          style: AudyTypography.displayLarge,
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: screenHeight * 0.03),
                        StarRewardDisplay(
                          starsEarned: stars,
                          maxStars: 3,
                          starSize: effectiveWidth * 0.1,
                        ),
                        SizedBox(height: screenHeight * 0.03),
                        Container(
                          padding: EdgeInsets.all(effectiveWidth * 0.05),
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
                                'Round ${_engine.currentRoundNumber} Complete',
                                style: AudyTypography.headingMedium,
                              ),
                              SizedBox(height: screenHeight * 0.01),
                              Text(
                                'Correct: ${_engine.totalCorrect} | Try again: ${_engine.totalIncorrect}',
                                style: AudyTypography.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.03),
                        ElevatedButton(
                          onPressed: () {
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
                            minimumSize: Size(
                              double.infinity,
                              (screenHeight * 0.07).clamp(50.0, 68.0),
                            ),
                          ),
                          child: Text(
                            _engine.sessionComplete
                                ? 'See Results'
                                : 'Next Round',
                            style: AudyTypography.buttonText,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.03),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
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
