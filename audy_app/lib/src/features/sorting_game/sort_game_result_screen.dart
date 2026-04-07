import 'package:flutter/material.dart';

import '../../core/audy_theme.dart';
import 'sorting_game_models.dart';
import 'sort_game_widgets.dart';

class _Responsive {
  static const double maxWidth = 420.0;
  static double sp(double width) => width.clamp(0.0, maxWidth);
}

class SortGameResultScreen extends StatelessWidget {
  const SortGameResultScreen({
    super.key,
    required this.sessionData,
    required this.theme,
    required this.levelName,
    required this.onPlayAgain,
    required this.onDone,
  });

  final SortGameSessionData sessionData;
  final SortTheme theme;
  final String levelName;
  final VoidCallback onPlayAgain;
  final VoidCallback onDone;

  int get accuracyPercent {
    if (sessionData.totalActions == 0) return 0;
    return ((sessionData.correctActions / sessionData.totalActions) * 100)
        .round();
  }

  int get totalStarsEarned => sessionData.totalStars;
  int get maxStars => sessionData.roundResults.length * 3;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final effectiveWidth = _Responsive.sp(screenWidth);

    return Scaffold(
      backgroundColor: AudyColors.backgroundPrimary,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: _Responsive.maxWidth),
            child: Padding(
              padding: EdgeInsets.all(effectiveWidth * 0.04),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      InkWell(
                        onTap: onDone,
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
                  SizedBox(height: (screenHeight * 0.03).clamp(10.0, 30.0)),
                  Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.celebration_rounded,
                          size: (screenHeight * 0.1).clamp(50.0, 80.0),
                          color: theme.primaryColor,
                        ),
                        SizedBox(
                          height: (screenHeight * 0.015).clamp(5.0, 15.0),
                        ),
                        Text(
                          'Wonderful!',
                          style: AudyTypography.displayLarge,
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(
                          height: (screenHeight * 0.005).clamp(2.0, 8.0),
                        ),
                        Text(
                          '$levelName Complete',
                          style: AudyTypography.bodyLarge,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: (screenHeight * 0.03).clamp(10.0, 30.0)),
                  Expanded(
                    child: ListView(
                      children: [
                        _buildStarsCard(effectiveWidth),
                        SizedBox(
                          height: (screenHeight * 0.015).clamp(5.0, 15.0),
                        ),
                        _buildSummaryCard(effectiveWidth),
                        SizedBox(
                          height: (screenHeight * 0.015).clamp(5.0, 15.0),
                        ),
                        _buildRoundBreakdownCard(effectiveWidth),
                        SizedBox(
                          height: (screenHeight * 0.015).clamp(5.0, 15.0),
                        ),
                        _buildAdaptiveInsightCard(effectiveWidth),
                      ],
                    ),
                  ),
                  SizedBox(height: (screenHeight * 0.015).clamp(5.0, 15.0)),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: effectiveWidth * 0.03,
                    runSpacing: effectiveWidth * 0.02,
                    children: [
                      SizedBox(
                        width: effectiveWidth * 0.42,
                        child: ElevatedButton(
                          onPressed: onPlayAgain,
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
                            'Play Again',
                            style: AudyTypography.buttonText,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: effectiveWidth * 0.42,
                        child: ElevatedButton(
                          onPressed: onDone,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AudyColors.mintGreen,
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
                          child: Text('Done', style: AudyTypography.buttonText),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: (screenHeight * 0.03).clamp(10.0, 30.0)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStarsCard(double effectiveWidth) {
    return Container(
      padding: EdgeInsets.all(effectiveWidth * 0.05),
      decoration: BoxDecoration(
        color: AudyColors.backgroundCard,
        borderRadius: BorderRadius.circular(AudySpacing.radiusXLarge),
        boxShadow: AudyShadows.cardShadow,
      ),
      child: Column(
        children: [
          Text(
            'Your Score',
            style: AudyTypography.headingSmall,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: effectiveWidth * 0.03),
          StarRewardDisplay(
            starsEarned: totalStarsEarned,
            maxStars: maxStars,
            starSize: (effectiveWidth * 0.12).clamp(30.0, 56.0),
          ),
          SizedBox(height: effectiveWidth * 0.02),
          Text(
            '$totalStarsEarned / $maxStars stars',
            style: AudyTypography.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(double effectiveWidth) {
    return Container(
      padding: EdgeInsets.all(effectiveWidth * 0.05),
      decoration: BoxDecoration(
        color: AudyColors.backgroundCard,
        borderRadius: BorderRadius.circular(AudySpacing.radiusXLarge),
        boxShadow: AudyShadows.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Summary', style: AudyTypography.headingSmall),
          SizedBox(height: effectiveWidth * 0.03),
          _SummaryRow(
            label: 'Accuracy',
            value: '$accuracyPercent%',
            color: accuracyPercent >= 80
                ? AudyColors.mintGreen
                : accuracyPercent >= 60
                ? AudyColors.skyBlue
                : AudyColors.warning,
          ),
          SizedBox(height: effectiveWidth * 0.015),
          _SummaryRow(
            label: 'Correct',
            value: '${sessionData.correctActions}',
            color: AudyColors.mintGreen,
          ),
          SizedBox(height: effectiveWidth * 0.015),
          _SummaryRow(
            label: 'Try Again',
            value: '${sessionData.incorrectActions}',
            color: AudyColors.warning,
          ),
          SizedBox(height: effectiveWidth * 0.015),
          _SummaryRow(
            label: 'Hints Used',
            value: '${sessionData.hintsUsed}',
            color: AudyColors.warning,
          ),
        ],
      ),
    );
  }

  Widget _buildRoundBreakdownCard(double effectiveWidth) {
    return Container(
      padding: EdgeInsets.all(effectiveWidth * 0.05),
      decoration: BoxDecoration(
        color: AudyColors.backgroundCard,
        borderRadius: BorderRadius.circular(AudySpacing.radiusXLarge),
        boxShadow: AudyShadows.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Round Breakdown', style: AudyTypography.headingSmall),
          SizedBox(height: effectiveWidth * 0.03),
          ...sessionData.roundResults.map((round) {
            final roundAccuracy = round.correctCount + round.incorrectCount > 0
                ? ((round.correctCount /
                              (round.correctCount + round.incorrectCount)) *
                          100)
                      .round()
                : 0;

            return Padding(
              padding: EdgeInsets.only(bottom: effectiveWidth * 0.02),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    runAlignment: WrapAlignment.center,
                    spacing: effectiveWidth * 0.02,
                    runSpacing: effectiveWidth * 0.01,
                    children: [
                      Text(
                        'Round ${round.roundIndex + 1}',
                        style: AudyTypography.labelMedium,
                      ),
                      Wrap(
                        alignment: WrapAlignment.end,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: effectiveWidth * 0.02,
                        runSpacing: effectiveWidth * 0.01,
                        children: [
                          Text(
                            '${round.correctCount}/${round.correctCount + round.incorrectCount}',
                            style: AudyTypography.bodyMedium,
                          ),
                          Text(
                            '$roundAccuracy%',
                            style: TextStyle(
                              fontSize: (effectiveWidth * 0.04).clamp(
                                12.0,
                                16.0,
                              ),
                              fontWeight: FontWeight.w700,
                              color: roundAccuracy >= 80
                                  ? AudyColors.mintGreen
                                  : AudyColors.warning,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: effectiveWidth * 0.01),
                  Wrap(
                    spacing: 2,
                    children: List.generate(3, (i) {
                      return Icon(
                        Icons.star_rounded,
                        size: (effectiveWidth * 0.05).clamp(14.0, 20.0),
                        color: i < round.starsEarned
                            ? AudyColors.starGold
                            : AudyColors.starSilver,
                      );
                    }),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildAdaptiveInsightCard(double effectiveWidth) {
    String insight;
    IconData insightIcon;
    Color insightColor;

    if (accuracyPercent >= 90) {
      insight = 'You are ready for harder levels!';
      insightIcon = Icons.trending_up_rounded;
      insightColor = AudyColors.mintGreen;
    } else if (accuracyPercent >= 60) {
      insight = 'Good progress! Keep practicing!';
      insightIcon = Icons.thumb_up_rounded;
      insightColor = AudyColors.skyBlue;
    } else {
      insight = 'Try the easier levels to build confidence!';
      insightIcon = Icons.lightbulb_rounded;
      insightColor = AudyColors.warning;
    }

    return Container(
      padding: EdgeInsets.all(effectiveWidth * 0.05),
      decoration: BoxDecoration(
        color: insightColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AudySpacing.radiusXLarge),
        border: Border.all(
          color: insightColor.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Wrap(
        alignment: WrapAlignment.start,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: effectiveWidth * 0.02,
        children: [
          Icon(
            insightIcon,
            size: (effectiveWidth * 0.08).clamp(24.0, 48.0),
            color: insightColor,
          ),
          Flexible(
            child: Text(
              insight,
              style: TextStyle(
                fontSize: (effectiveWidth * 0.04).clamp(14.0, 18.0),
                fontWeight: FontWeight.w600,
                color: insightColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final effectiveWidth = _Responsive.sp(screenWidth);

    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      runAlignment: WrapAlignment.center,
      spacing: effectiveWidth * 0.02,
      runSpacing: effectiveWidth * 0.01,
      children: [
        Text(label, style: AudyTypography.bodyMedium),
        Text(
          value,
          style: TextStyle(
            fontSize: (effectiveWidth * 0.045).clamp(14.0, 18.0),
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }
}
