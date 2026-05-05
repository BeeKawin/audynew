import 'package:flutter/material.dart';

import '../../core/app_routes.dart';
import '../../core/audy_theme.dart';
import '../../core/audy_ui.dart';
import '../../data/models/progress_model.dart';
import '../../services/sound_service.dart';
import '../../state/audy_controller.dart';

/// Preferences page for collecting autism-related personalization settings
/// Designed with autism-friendly UX: big icons, minimal text, hard contrast
class PreferencesPage extends StatefulWidget {
  const PreferencesPage({
    super.key,
    this.isOnboarding = false,
  });

  /// If true, this is shown as onboarding after signup
  /// If false, shown as settings from profile tab
  final bool isOnboarding;

  @override
  State<PreferencesPage> createState() => _PreferencesPageState();
}

class _PreferencesPageState extends State<PreferencesPage> {
  int _communicationLevel = 3; // 0-3
  int _sensorySensitivity = 1; // 0-2
  int _learningPace = 1; // 0-2
  final Set<String> _selectedInterests = {};
  bool _isSaving = false;

  final List<_PreferenceOption> _communicationOptions = const [
    _PreferenceOption(
      value: 0,
      label: 'Non-verbal',
      icon: Icons.volume_off_outlined,
      color: Color(0xFFFFA07A),
    ),
    _PreferenceOption(
      value: 1,
      label: 'Single words',
      icon: Icons.chat_bubble_outline,
      color: Color(0xFF98D8C8),
    ),
    _PreferenceOption(
      value: 2,
      label: 'Short phrases',
      icon: Icons.short_text,
      color: Color(0xFFF7DC6F),
    ),
    _PreferenceOption(
      value: 3,
      label: 'Full sentences',
      icon: Icons.record_voice_over_outlined,
      color: Color(0xFFBB8FCE),
    ),
  ];

  final List<_PreferenceOption> _sensitivityOptions = const [
    _PreferenceOption(
      value: 0,
      label: 'Low',
      icon: Icons.volume_down_outlined,
      color: Color(0xFF85C1E2),
    ),
    _PreferenceOption(
      value: 1,
      label: 'Medium',
      icon: Icons.volume_mute_outlined,
      color: Color(0xFFF8C471),
    ),
    _PreferenceOption(
      value: 2,
      label: 'High',
      icon: Icons.hearing_outlined,
      color: Color(0xFFE74C3C),
    ),
  ];

  final List<_PreferenceOption> _paceOptions = const [
    _PreferenceOption(
      value: 0,
      label: 'Slower',
      icon: Icons.snooze_outlined,
      color: Color(0xFF82E0AA),
    ),
    _PreferenceOption(
      value: 1,
      label: 'Standard',
      icon: Icons.timer_outlined,
      color: Color(0xFF85C1E2),
    ),
    _PreferenceOption(
      value: 2,
      label: 'Faster',
      icon: Icons.flash_on_outlined,
      color: Color(0xFFF4D03F),
    ),
  ];

  final List<_InterestOption> _interestOptions = const [
    _InterestOption(
      value: 'animals',
      label: 'Animals',
      icon: Icons.pets_outlined,
      color: Color(0xFF82E0AA),
    ),
    _InterestOption(
      value: 'vehicles',
      label: 'Vehicles',
      icon: Icons.directions_car_outlined,
      color: Color(0xFF85C1E2),
    ),
    _InterestOption(
      value: 'music',
      label: 'Music',
      icon: Icons.music_note_outlined,
      color: Color(0xFFF8B500),
    ),
    _InterestOption(
      value: 'nature',
      label: 'Nature',
      icon: Icons.eco_outlined,
      color: Color(0xFF27AE60),
    ),
    _InterestOption(
      value: 'colors',
      label: 'Colors',
      icon: Icons.palette_outlined,
      color: Color(0xFFE91E63),
    ),
    _InterestOption(
      value: 'numbers',
      label: 'Numbers',
      icon: Icons.calculate_outlined,
      color: Color(0xFF9B59B6),
    ),
  ];

  @override
  void initState() {
    super.initState();
    // Load current preferences if editing
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = AudyScope.of(context);
      setState(() {
        _communicationLevel = controller.userPreferences.communicationLevel;
        _sensorySensitivity = controller.userPreferences.sensorySensitivity;
        _learningPace = controller.userPreferences.learningPace;
        _selectedInterests.addAll(controller.userPreferences.interestsList);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return AudyResponsivePage(
      scrollable: true,
      builder: (context, adaptive) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Center(
              child: Column(
                children: [
                  if (!widget.isOnboarding)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: AudyBackButton(
                        label: 'Back',
                        onPressed: () {
                          SoundService.instance.playTap();
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  SizedBox(height: adaptive.space(16)),
                  const AudyMascot(size: 120),
                  SizedBox(height: adaptive.space(20)),
                  Text(
                    widget.isOnboarding
                        ? "Let's Personalize!"
                        : 'Your Preferences',
                    style: AudyTypography.displayMedium.copyWith(
                      color: AudyColors.skyBlue,
                      fontSize: adaptive.space(36),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: adaptive.space(8)),
                  Text(
                    widget.isOnboarding
                        ? 'Help us make AUDY perfect for you!'
                        : 'Customize your experience',
                    style: TextStyle(
                      fontSize: adaptive.space(16),
                      color: AudyColors.textLight,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            SizedBox(height: adaptive.space(32)),

            // Communication Level
            _buildSectionTitle(
              adaptive,
              'How do you communicate?',
              Icons.chat_bubble_outline,
            ),
            SizedBox(height: adaptive.space(16)),
            _buildCommunicationSelector(adaptive),
            SizedBox(height: adaptive.space(28)),

            // Sensory Sensitivity
            _buildSectionTitle(
              adaptive,
              'Sound sensitivity?',
              Icons.hearing_outlined,
            ),
            SizedBox(height: adaptive.space(16)),
            _buildSensitivitySelector(adaptive),
            SizedBox(height: adaptive.space(28)),

            // Learning Pace
            _buildSectionTitle(
              adaptive,
              'Learning pace?',
              Icons.timer_outlined,
            ),
            SizedBox(height: adaptive.space(16)),
            _buildPaceSelector(adaptive),
            SizedBox(height: adaptive.space(28)),

            // Favorite Interests
            _buildSectionTitle(
              adaptive,
              'Favorite things?',
              Icons.favorite_outline,
            ),
            SizedBox(height: adaptive.space(16)),
            _buildInterestsSelector(adaptive),
            SizedBox(height: adaptive.space(36)),

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isSaving ? null : _handleSubmit,
                icon: _isSaving
                    ? SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AudyColors.textOnColor,
                        ),
                      )
                    : Icon(
                        widget.isOnboarding
                            ? Icons.rocket_launch_outlined
                            : Icons.save_outlined,
                        size: 28,
                      ),
                label: Text(
                  _isSaving
                      ? 'Saving...'
                      : (widget.isOnboarding
                          ? 'Start Learning!'
                          : 'Save Changes'),
                  style: TextStyle(
                    fontSize: adaptive.space(18),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AudyColors.mintGreen,
                  foregroundColor: AudyColors.textOnColor,
                  padding: EdgeInsets.symmetric(
                    horizontal: adaptive.space(32),
                    vertical: adaptive.space(18),
                  ),
                  minimumSize: const Size(48, 64),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                  elevation: 4,
                  shadowColor: AudyColors.mintGreen.withValues(alpha: 0.4),
                ),
              ),
            ),
            SizedBox(height: adaptive.space(24)),
          ],
        );
      },
    );
  }

  Widget _buildSectionTitle(AudyAdaptive adaptive, String title, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          size: adaptive.space(28),
          color: AudyColors.textPrimary,
        ),
        SizedBox(width: adaptive.space(12)),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: adaptive.space(20),
              fontWeight: FontWeight.w800,
              color: AudyColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCommunicationSelector(AudyAdaptive adaptive) {
    return Wrap(
      spacing: adaptive.space(12),
      runSpacing: adaptive.space(12),
      children: _communicationOptions.map((option) {
        final isSelected = _communicationLevel == option.value;
        return _CommunicationCard(
          option: option,
          isSelected: isSelected,
          adaptive: adaptive,
          onTap: () {
            SoundService.instance.playTap();
            setState(() => _communicationLevel = option.value);
          },
        );
      }).toList(),
    );
  }

  Widget _buildSensitivitySelector(AudyAdaptive adaptive) {
    return Row(
      children: _sensitivityOptions.map((option) {
        final isSelected = _sensorySensitivity == option.value;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: adaptive.space(6)),
            child: _PillButton(
              option: option,
              isSelected: isSelected,
              adaptive: adaptive,
              onTap: () {
                SoundService.instance.playTap();
                setState(() => _sensorySensitivity = option.value);
              },
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPaceSelector(AudyAdaptive adaptive) {
    return Row(
      children: _paceOptions.map((option) {
        final isSelected = _learningPace == option.value;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: adaptive.space(6)),
            child: _PillButton(
              option: option,
              isSelected: isSelected,
              adaptive: adaptive,
              onTap: () {
                SoundService.instance.playTap();
                setState(() => _learningPace = option.value);
              },
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildInterestsSelector(AudyAdaptive adaptive) {
    return Wrap(
      spacing: adaptive.space(12),
      runSpacing: adaptive.space(12),
      children: _interestOptions.map((option) {
        final isSelected = _selectedInterests.contains(option.value);
        return _InterestCard(
          option: option,
          isSelected: isSelected,
          adaptive: adaptive,
          onTap: () {
            SoundService.instance.playTap();
            setState(() {
              if (isSelected) {
                _selectedInterests.remove(option.value);
              } else {
                _selectedInterests.add(option.value);
              }
            });
          },
        );
      }).toList(),
    );
  }

  Future<void> _handleSubmit() async {
    setState(() => _isSaving = true);

    try {
      final controller = AudyScope.of(context);
      final preferences = UserPreferences(
        communicationLevel: _communicationLevel,
        sensorySensitivity: _sensorySensitivity,
        learningPace: _learningPace,
        favoriteInterests: _selectedInterests.join(','),
      );

      await controller.saveUserPreferences(preferences);

      if (widget.isOnboarding) {
        // Navigate to dashboard after onboarding
        if (mounted) {
          Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
        }
      } else {
        // Go back to profile after saving
        if (mounted) {
          Navigator.pop(context);
        }
      }
    } catch (e) {
      debugPrint('Error saving preferences: $e');
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }
}

class _PreferenceOption {
  final int value;
  final String label;
  final IconData icon;
  final Color color;

  const _PreferenceOption({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });
}

class _InterestOption {
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  const _InterestOption({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });
}

class _CommunicationCard extends StatelessWidget {
  final _PreferenceOption option;
  final bool isSelected;
  final AudyAdaptive adaptive;
  final VoidCallback onTap;

  const _CommunicationCard({
    required this.option,
    required this.isSelected,
    required this.adaptive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: adaptive.isPhone
            ? (adaptive.width - adaptive.space(64)) / 2
            : adaptive.space(140),
        padding: EdgeInsets.all(adaptive.space(16)),
        decoration: BoxDecoration(
          color: isSelected ? option.color : AudyColors.backgroundCard,
          borderRadius: BorderRadius.circular(adaptive.space(20)),
          border: Border.all(
            color: isSelected ? option.color : AudyColors.borderLight,
            width: isSelected ? 3 : 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: option.color.withValues(alpha: 0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : AudyShadows.cardShadow,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: adaptive.space(56),
              height: adaptive.space(56),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.3)
                    : option.color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                option.icon,
                size: adaptive.space(32),
                color: isSelected ? Colors.white : option.color,
              ),
            ),
            SizedBox(height: adaptive.space(12)),
            Text(
              option.label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: adaptive.space(14),
                fontWeight: FontWeight.w700,
                color: isSelected ? Colors.white : AudyColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PillButton extends StatelessWidget {
  final _PreferenceOption option;
  final bool isSelected;
  final AudyAdaptive adaptive;
  final VoidCallback onTap;

  const _PillButton({
    required this.option,
    required this.isSelected,
    required this.adaptive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: adaptive.space(16),
          horizontal: adaptive.space(8),
        ),
        decoration: BoxDecoration(
          color: isSelected ? option.color : AudyColors.backgroundCard,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: isSelected ? option.color : AudyColors.borderLight,
            width: isSelected ? 3 : 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: option.color.withValues(alpha: 0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : AudyShadows.cardShadow,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              option.icon,
              size: adaptive.space(28),
              color: isSelected ? Colors.white : option.color,
            ),
            SizedBox(height: adaptive.space(8)),
            Text(
              option.label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: adaptive.space(13),
                fontWeight: FontWeight.w700,
                color: isSelected ? Colors.white : AudyColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InterestCard extends StatelessWidget {
  final _InterestOption option;
  final bool isSelected;
  final AudyAdaptive adaptive;
  final VoidCallback onTap;

  const _InterestCard({
    required this.option,
    required this.isSelected,
    required this.adaptive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: adaptive.isPhone
            ? (adaptive.width - adaptive.space(80)) / 3
            : adaptive.space(100),
        padding: EdgeInsets.all(adaptive.space(12)),
        decoration: BoxDecoration(
          color: isSelected ? option.color : AudyColors.backgroundCard,
          borderRadius: BorderRadius.circular(adaptive.space(16)),
          border: Border.all(
            color: isSelected ? option.color : AudyColors.borderLight,
            width: isSelected ? 3 : 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: option.color.withValues(alpha: 0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : AudyShadows.cardShadow,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: adaptive.space(44),
              height: adaptive.space(44),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.3)
                    : option.color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                option.icon,
                size: adaptive.space(24),
                color: isSelected ? Colors.white : option.color,
              ),
            ),
            SizedBox(height: adaptive.space(8)),
            Text(
              option.label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: adaptive.space(12),
                fontWeight: FontWeight.w700,
                color: isSelected ? Colors.white : AudyColors.textPrimary,
              ),
            ),
            // Checkmark when selected
            if (isSelected)
              Container(
                margin: EdgeInsets.only(top: adaptive.space(6)),
                width: adaptive.space(20),
                height: adaptive.space(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check,
                  size: adaptive.space(14),
                  color: option.color,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
