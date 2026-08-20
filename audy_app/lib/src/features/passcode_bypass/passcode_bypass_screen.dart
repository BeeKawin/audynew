import 'dart:async';
import 'dart:math' show sin, pi;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/app_routes.dart';
import '../../core/audy_theme.dart';
import '../../services/sound_service.dart';
import '../../state/audy_controller.dart';

/// Parent/teacher override screen for the Meltdown and EmotionDown
/// restriction screens.
///
/// The passcode is hardcoded for this phase; a future phase should move it
/// to a per-family/teacher setting stored server-side.
class PasscodeBypassScreen extends StatefulWidget {
  const PasscodeBypassScreen({super.key});

  static const int codeLength = 6;
  static const String _validCode = '528546';

  @override
  State<PasscodeBypassScreen> createState() => _PasscodeBypassScreenState();
}

class _PasscodeBypassScreenState extends State<PasscodeBypassScreen>
    with SingleTickerProviderStateMixin {
  String _entered = '';
  bool _isError = false;

  late final AnimationController _shakeController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 400),
  );

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  void _onDigit(String digit) {
    if (_entered.length >= PasscodeBypassScreen.codeLength) return;
    HapticFeedback.selectionClick();
    SoundService.instance.playTap();
    setState(() {
      _isError = false;
      _entered += digit;
    });

    if (_entered.length == PasscodeBypassScreen.codeLength) {
      _checkCode();
    }
  }

  void _onBackspace() {
    if (_entered.isEmpty) return;
    HapticFeedback.selectionClick();
    SoundService.instance.playTap();
    setState(() {
      _isError = false;
      _entered = _entered.substring(0, _entered.length - 1);
    });
  }

  Future<void> _checkCode() async {
    if (_entered == PasscodeBypassScreen._validCode) {
      HapticFeedback.mediumImpact();
      SoundService.instance.playCorrect();
      await _onSuccess();
      return;
    }

    HapticFeedback.heavyImpact();
    SoundService.instance.playWrong();
    setState(() => _isError = true);
    unawaited(_shakeController.forward(from: 0));

    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    setState(() => _entered = '');
  }

  Future<void> _onSuccess() async {
    final controller = AudyScope.of(context);

    // Belt-and-braces: the EmotionDown screen underneath this one is
    // replaced-away rather than popped, so it never gets a chance to stop
    // its own ambient loop. Stop it here so unlocking never leaves it
    // playing under the games screen.
    SoundService.instance.stopBGM();

    try {
      await controller.resetMeltdownState();
    } catch (e) {
      debugPrint('Reset meltdown state error: $e');
    }

    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(AppRoutes.games);
  }

  @override
  Widget build(BuildContext context) {
    final isThai = AudyScope.of(context).currentLanguage == 'th';

    return Scaffold(
      backgroundColor: AudyColors.backgroundPrimary,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(isThai),
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.shield_moon_rounded,
                        size: AudySpacing.iconXLarge,
                        color: AudyColors.skyBlue,
                      ),
                      const SizedBox(height: AudySpacing.elementGap),
                      Text(
                        isThai ? 'สำหรับผู้ปกครอง/ครู' : 'For parents & teachers',
                        style: AudyTypography.headingSmall,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AudySpacing.smallGap),
                      Text(
                        isThai
                            ? 'กรอกรหัสผ่าน 6 หลักเพื่อปลดล็อก'
                            : 'Enter the 6-digit passcode to unlock',
                        style: AudyTypography.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AudySpacing.sectionGap),
                      _buildDots(),
                      if (_isError) ...[
                        const SizedBox(height: AudySpacing.smallGap),
                        Text(
                          isThai ? 'รหัสไม่ถูกต้อง ลองอีกครั้ง' : 'Incorrect passcode, try again',
                          style: AudyTypography.bodyMedium.copyWith(
                            color: AudyColors.error,
                          ),
                        ),
                      ],
                      const SizedBox(height: AudySpacing.sectionGap),
                      _buildKeypad(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isThai) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AudySpacing.screenPadding,
        vertical: AudySpacing.smallGap,
      ),
      child: Row(
        children: [
          InkWell(
            onTap: () => Navigator.of(context).maybePop(),
            borderRadius: BorderRadius.circular(AudySpacing.radiusMedium),
            child: const Padding(
              padding: EdgeInsets.all(12),
              child: Icon(Icons.arrow_back_rounded),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            isThai ? 'ปลดล็อกด้วยรหัสผ่าน' : 'Passcode unlock',
            style: AudyTypography.headingSmall,
          ),
        ],
      ),
    );
  }

  Widget _buildDots() {
    return AnimatedBuilder(
      animation: _shakeController,
      builder: (context, child) {
        final t = _shakeController.value;
        final dx = (1 - t) * 10.0 * sin(t * pi * 6);
        return Transform.translate(offset: Offset(dx, 0), child: child);
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(PasscodeBypassScreen.codeLength, (index) {
          final filled = index < _entered.length;
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 6),
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _isError
                  ? AudyColors.error
                  : (filled ? AudyColors.skyBlue : Colors.transparent),
              border: Border.all(
                color: _isError ? AudyColors.error : AudyColors.skyBlue,
                width: 2,
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildKeypad() {
    const layout = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['', '0', 'back'],
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: layout.map((row) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: row.map((key) {
              if (key.isEmpty) {
                return const SizedBox(width: 76, height: 76);
              }
              if (key == 'back') {
                return _KeypadButton(
                  onTap: _onBackspace,
                  child: const Icon(Icons.backspace_outlined, size: 26),
                );
              }
              return _KeypadButton(
                onTap: () => _onDigit(key),
                child: Text(
                  key,
                  style: AudyTypography.headingMedium.copyWith(fontSize: 28),
                ),
              );
            }).toList(),
          ),
        );
      }).toList(),
    );
  }
}

class _KeypadButton extends StatelessWidget {
  const _KeypadButton({required this.onTap, required this.child});

  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Material(
        color: AudyColors.backgroundSoft.withValues(alpha: 0.5),
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: SizedBox(
            width: 76,
            height: 76,
            child: Center(child: child),
          ),
        ),
      ),
    );
  }
}
