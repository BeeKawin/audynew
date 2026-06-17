import 'package:flutter/material.dart';

import '../../core/audy_theme.dart';
import '../../core/audy_ui.dart';

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({
    super.key,
    this.title = 'กำลังเตรียม...',
    this.subtitle = 'กรุณารอสักครู่',
    this.mascotAsset = 'assets/mascot/Neutral.png',
  });

  final String title;
  final String subtitle;
  final String mascotAsset;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AudyColors.backgroundPrimary,
      body: AudyBackground(
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(AudySpacing.screenPadding),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    mascotAsset,
                    width: 140,
                    height: 140,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          color: AudyColors.skyBlue.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.sentiment_satisfied_rounded,
                          size: 80,
                          color: AudyColors.skyBlue,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: AudySpacing.sectionGap),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: AudyTypography.headingLarge,
                  ),
                  const SizedBox(height: AudySpacing.smallGap),
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: AudyTypography.bodyMedium.copyWith(
                      color: AudyColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AudySpacing.sectionGap),
                  CircularProgressIndicator(
                    color: AudyColors.skyBlue,
                    backgroundColor: AudyColors.borderLight,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
