import 'dart:async';

import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';

import '../../core/audy_ui.dart';
import '../../services/bluetooth_service.dart';
import '../../services/sound_service.dart';
import '../../state/audy_controller.dart';
import '../../widgets/game_guide_box.dart';
import 'read_pronounce_controller.dart';
import 'read_pronounce_result.dart';
import 'read_pronounce_service.dart';

String _tr(BuildContext context, String key, {Map<String, String>? params}) {
  return AudyScope.of(context).tr(key, params: params);
}

class ReadPronouncePracticeScreen extends StatefulWidget {
  const ReadPronouncePracticeScreen({
    super.key,
    required this.title,
    required this.subtitle,
    required this.module,
  });

  final String title;
  final String subtitle;
  final ReadPronounceModule module;

  @override
  State<ReadPronouncePracticeScreen> createState() =>
      _ReadPronouncePracticeScreenState();
}

class _ReadPronouncePracticeScreenState
    extends State<ReadPronouncePracticeScreen> {
  late final ReadPronounceController _controller;
  late final ReadPronounceService _service;

  StreamSubscription<AudyBleMessage>? _bleMicSub;
  Timer? _recordingTimer;
  bool _isSttListening = false;
  bool _isAdvancingRound = false;
  bool _hasNavigatedToResult = false;
  int _recordingSeconds = 0;
  int _listeningCount = 0;
  String _sttUnavailableMessage = '';
  String _sttDebugStatus = 'idle';
  String _sttDebugText = '';
  String _latestRecognizedText = '';
  bool _isManualStopSubmitting = false;
  bool _hasPendingSpeechSubmission = false;
  bool _discardNextListenResult = false;
  bool _showGuide = true;

  @override
  void initState() {
    super.initState();
    _controller = ReadPronounceController();
    _service = ReadPronounceService();
    _controller.startSession(widget.module);
    _controller.addListener(_onControllerChanged);
    unawaited(_sendGameEnterBleState());
    SoundService.instance.playInstructionReadPronounce();
    _bleMicSub = AudyBluetoothService.instance.incomingMessages.listen(
      _handleBleInput,
    );
  }

  Future<void> _sendGameEnterBleState() async {
    try {
      await AudyBluetoothService.instance.setLed(20);
    } catch (e) {
      debugPrint(
        'ReadPronouncePracticeScreen: Entry LED BLE state skipped - $e',
      );
    }
  }

  void _handleBleInput(AudyBleMessage message) {
    if (!mounted) return;
    if (message.channel != 'nose' || message.value != 1) return;

    unawaited(_handleVoiceButtonTap());
  }

  void _onControllerChanged() {
    if (!mounted) return;
    if (_controller.isSessionComplete && !_hasNavigatedToResult) {
      _hasNavigatedToResult = true;
      final result = _controller.lastSessionResult;
      final title = widget.title;
      Future.microtask(() {
        if (!mounted || result == null) return;
        final controller = AudyScope.of(context);
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => ReadPronounceResultScreen(
              result: result,
              moduleName: controller.tr(title),
              controller: controller,
            ),
          ),
        );
      });
    }
    setState(() {});
  }

  @override
  void dispose() {
    unawaited(_resetGameBleState());
    _bleMicSub?.cancel();
    _recordingTimer?.cancel();
    _controller.removeListener(_onControllerChanged);
    _controller.dispose();
    _service.dispose();
    super.dispose();
  }

  Future<void> _resetGameBleState() async {
    try {
      await AudyBluetoothService.instance.setLed(0);
    } catch (e) {
      debugPrint(
        'ReadPronouncePracticeScreen: Exit LED BLE reset skipped - $e',
      );
    }
  }

  Future<void> _handleVoiceButtonTap() async {
    if (_isAdvancingRound ||
        _controller.isAwaitingNextRound ||
        _controller.isSessionComplete) {
      return;
    }

    if (_isSttListening) {
      await _stopListening();
      return;
    }

    if (_hasPendingSpeechSubmission) {
      SoundService.instance.playTap();
      await _handleListeningResult(_latestRecognizedText);
      return;
    }

    await _startListening();
  }

  Future<void> _handlePromptImageTap() async {
    if (_isAdvancingRound || _controller.isSessionComplete) return;

    final promptText = _controller.currentPrompt?.text.trim();
    if (promptText == null || promptText.isEmpty) return;

    SoundService.instance.playTap();

    if (_isSttListening) {
      await _cancelListeningForPromptAudio();
    }

    if (!mounted) return;
    setState(() {
      _hasPendingSpeechSubmission = false;
      _sttDebugStatus = 'speaking prompt';
      _latestRecognizedText = '';
      _sttDebugText = '';
    });

    await _service.speak(promptText);
  }

  Future<void> _startListening() async {
    final sttAvailable = await _service.ensureSTTAvailable();
    if (!sttAvailable) {
      setState(() {
        _sttUnavailableMessage = _tr(context, 'stt_unavailable');
      });
      return;
    }

    SoundService.instance.playTap();
    _startRecordingTimer();
    setState(() {
      _isSttListening = true;
      _sttUnavailableMessage = '';
      _sttDebugStatus = 'listening';
      _sttDebugText = '';
      _latestRecognizedText = '';
      _hasPendingSpeechSubmission = false;
      _listeningCount++;
    });

    final result = await _service.listen(
      localeId: 'en_US',
      onStatusChanged: (status) {
        if (!mounted) return;
        setState(() => _sttDebugStatus = status);
      },
      onPartialResult: (words) {
        if (!mounted) return;
        setState(() {
          _sttDebugText = words;
          _latestRecognizedText = words;
        });
      },
    );

    if (_discardNextListenResult) {
      _discardNextListenResult = false;
      return;
    }
    if (!mounted || _isManualStopSubmitting) return;
    _stopRecordingTimer();
    final finalText = result?.trim();
    if (finalText != null && finalText.isNotEmpty) {
      _latestRecognizedText = finalText;
      _sttDebugText = finalText;
    }
    final hasRecognizedWords = _latestRecognizedText.trim().isNotEmpty;
    setState(() {
      _isSttListening = false;
      _hasPendingSpeechSubmission = hasRecognizedWords;
      _sttDebugStatus = hasRecognizedWords
          ? 'ready. tap mic again to submit'
          : 'stopped. no speech heard';
    });
  }

  Future<void> _stopListening() async {
    _isManualStopSubmitting = true;
    try {
      SoundService.instance.playTap();
      final result = await _service.stopListening();
      final submittedText = result?.trim().isNotEmpty == true
          ? result!.trim()
          : _latestRecognizedText.trim();
      _stopRecordingTimer();
      if (!mounted) return;
      setState(() {
        _isSttListening = false;
        _hasPendingSpeechSubmission = false;
        _sttDebugStatus = 'manual stop';
        if (submittedText.isNotEmpty) {
          _latestRecognizedText = submittedText;
          _sttDebugText = submittedText;
        }
      });
      await _handleListeningResult(submittedText);
    } finally {
      _isManualStopSubmitting = false;
    }
  }

  Future<void> _cancelListeningForPromptAudio() async {
    _isManualStopSubmitting = true;
    _discardNextListenResult = true;
    try {
      await _service.stopListening();
      _stopRecordingTimer();
      if (!mounted) return;
      setState(() {
        _isSttListening = false;
        _hasPendingSpeechSubmission = false;
        _sttDebugStatus = 'stopped for prompt audio';
        _latestRecognizedText = '';
        _sttDebugText = '';
      });
    } finally {
      _isManualStopSubmitting = false;
    }
  }

  Future<void> _handleListeningResult(String? result) async {
    _stopRecordingTimer();
    if (!mounted) return;

    final submittedText = result?.trim() ?? '';
    setState(() {
      _isSttListening = false;
      _hasPendingSpeechSubmission = false;
      _sttDebugStatus = submittedText.isEmpty ? 'no result' : 'submitted';
      if (submittedText.isNotEmpty) {
        _latestRecognizedText = submittedText;
        _sttDebugText = submittedText;
      }
    });
    final outcome = _controller.submitAttempt(submittedText);
    if (mounted) {
      setState(() => _sttDebugStatus = 'outcome: ${outcome.name}');
    }
    if (outcome == ReadPronounceAttemptOutcome.correct) {
      SoundService.instance.playRoundComplete();
      final isFinalRound =
          _controller.currentPromptIndex + 1 >= _controller.totalPrompts;
      unawaited(_sendCorrectReadSpeakBleSignal(isFinalRound: isFinalRound));
      setState(() => _isAdvancingRound = true);
      await Future.delayed(const Duration(milliseconds: 900));
      if (!mounted) return;
      _controller.advanceAfterCorrect();
      if (mounted) {
        setState(() => _isAdvancingRound = false);
      }
    }
  }

  Future<void> _sendCorrectReadSpeakBleSignal({
    required bool isFinalRound,
  }) async {
    try {
      final bluetooth = AudyBluetoothService.instance;
      if (isFinalRound) {
        await bluetooth.setArms(4);
        await bluetooth.pulseEmotion(2);
        await bluetooth.setLed(11);
      } else {
        await bluetooth.pulseEmotion(1);
      }
    } catch (e) {
      debugPrint(
        'ReadPronouncePracticeScreen: Correct answer BLE signal skipped - $e',
      );
    }
  }

  void _handleSkip() {
    if (_isSttListening || _isAdvancingRound) return;
    SoundService.instance.playTap();
    _controller.skipCurrentPrompt();
  }

  void _startRecordingTimer() {
    _recordingTimer?.cancel();
    _recordingSeconds = 0;
    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() => _recordingSeconds++);
      }
    });
  }

  void _stopRecordingTimer() {
    _recordingTimer?.cancel();
    _recordingTimer = null;
  }

  String _formatRecordingTime() {
    final minutes = _recordingSeconds ~/ 60;
    final seconds = _recordingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  String _localizedFeedback(BuildContext context, String feedback) {
    switch (feedback) {
      case 'Tap the microphone and say it clearly.':
        return _tr(context, 'tap_mic_say_clearly');
      case 'I did not hear it. Try again.':
        return _tr(context, 'did_not_hear');
      case 'Try a shorter answer.':
        return _tr(context, 'try_shorter_answer');
      case 'Correct':
        return _tr(context, 'correct');
      case 'Good try. You can skip this one.':
        return _tr(context, 'can_skip');
      case 'Close. Try saying it again.':
        return _tr(context, 'close_try_again');
      default:
        return feedback;
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final adaptive = _AudyAdaptive(
          width: constraints.maxWidth,
          height: constraints.maxHeight,
        );
        final state = _controller.currentState;
        if (state == null) return const SizedBox.shrink();

        return Scaffold(
          body: AudyBackground(
            child: SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: adaptive.isPhone ? 20 : adaptive.space(28),
                  vertical: adaptive.isPhone ? 20 : adaptive.space(28),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  _TopRow(
                    adaptive: adaptive,
                    label: _tr(context, 'back_home'),
                    onBack: () {
                      SoundService.instance.playTap();
                      Navigator.pop(context);
                    },
                  ),
                  SizedBox(height: adaptive.space(24)),
                  Center(
                    child: Column(
                      children: [
                        Text(
                          _tr(context, widget.title),
                          style: TextStyle(
                            fontSize: adaptive.space(28),
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF243A5A),
                          ),
                        ),
                        SizedBox(height: adaptive.space(8)),
                        Text(
                          _tr(context, widget.subtitle),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: adaptive.space(15),
                            color: const Color(0xFF617691),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: adaptive.space(28)),
                  if (_showGuide) ...[
                    GameGuideBox(
                      message: AudyScope.of(context).tr(
                        'guide_read_pronounce',
                      ),
                      onDismissed: () => setState(() => _showGuide = false),
                    ),
                    SizedBox(height: adaptive.space(18)),
                  ],
                  _ProgressIndicator(
                    adaptive: adaptive,
                    current: state.progressCurrent,
                    total: state.progressTotal,
                  ),
                  SizedBox(height: adaptive.space(24)),
                  _PromptCard(
                    adaptive: adaptive,
                    prompt: state.prompt,
                    imagePath: _controller.getCurrentImagePath(),
                    onImageTap: () => unawaited(_handlePromptImageTap()),
                  ),
                  SizedBox(height: adaptive.space(22)),
                  _RecordingStatus(
                    adaptive: adaptive,
                    isRecording: _isSttListening,
                    label: _isSttListening
                        ? _tr(
                            context,
                            'recording_time',
                            params: {'time': _formatRecordingTime()},
                          )
                        : _hasPendingSpeechSubmission
                            ? _tr(context, 'tap_mic_to_check')
                            : _tr(context, 'ready'),
                  ),
                  // Temporarily hidden; keep the STT debug panel ready for later.
                  // SizedBox(height: adaptive.space(12)),
                  // _SttDebugPanel(
                  //   adaptive: adaptive,
                  //   status: _sttDebugStatus,
                  //   text: _sttDebugText,
                  // ),
                  SizedBox(height: adaptive.space(16)),
                  Center(
                    child: _VoiceButton(
                      adaptive: adaptive,
                      isListening: _isSttListening,
                      isEnabled: !_isAdvancingRound &&
                          !_controller.isAwaitingNextRound,
                      listeningCount: _listeningCount,
                      onTap: _handleVoiceButtonTap,
                    ),
                  ),
                  if (state.isCorrect) ...[
                    SizedBox(height: adaptive.space(18)),
                    Center(child: _CorrectBadge(adaptive: adaptive)),
                  ],
                  if (_controller.shouldShowSkip) ...[
                    SizedBox(height: adaptive.space(18)),
                    _SkipButton(adaptive: adaptive, onPressed: _handleSkip),
                  ],
                  if (_sttUnavailableMessage.isNotEmpty) ...[
                    SizedBox(height: adaptive.space(16)),
                    _SttUnavailableMessage(
                      adaptive: adaptive,
                      message: _sttUnavailableMessage,
                    ),
                  ],
                  SizedBox(height: adaptive.space(18)),
                  _FeedbackCard(
                    adaptive: adaptive,
                    feedback: _localizedFeedback(context, state.feedback),
                    isCorrect: state.isCorrect,
                  ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ProgressIndicator extends StatelessWidget {
  const _ProgressIndicator({
    required this.adaptive,
    required this.current,
    required this.total,
  });

  final _AudyAdaptive adaptive;
  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(adaptive.space(16)),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F8FC),
        borderRadius: BorderRadius.circular(adaptive.space(20)),
        border: Border.all(
          color: const Color(0xFFBDD8F2).withValues(alpha: 0.5),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.star_rounded,
            size: adaptive.space(28),
            color: const Color(0xFFFFD700),
          ),
          SizedBox(width: adaptive.space(12)),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(adaptive.space(8)),
              child: LinearProgressIndicator(
                value: total > 0 ? current / total : 0,
                minHeight: adaptive.space(12),
                backgroundColor: const Color(0xFFE0E8F0),
                valueColor: const AlwaysStoppedAnimation(Color(0xFFFFD700)),
              ),
            ),
          ),
          SizedBox(width: adaptive.space(12)),
          Text(
            '$current / $total',
            style: TextStyle(
              fontSize: adaptive.space(16),
              fontWeight: FontWeight.w700,
              color: const Color(0xFF243A5A),
            ),
          ),
        ],
      ),
    );
  }
}

class _PromptCard extends StatelessWidget {
  const _PromptCard({
    required this.adaptive,
    required this.prompt,
    required this.onImageTap,
    this.imagePath,
  });

  final _AudyAdaptive adaptive;
  final String prompt;
  final VoidCallback onImageTap;
  final String? imagePath;

  @override
  Widget build(BuildContext context) {
    final imageSize = adaptive.isPhone ? 112.0 : adaptive.space(132);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(adaptive.space(28)),
      decoration: BoxDecoration(
        color: const Color(0xFFBDD8F2).withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(adaptive.space(28)),
        border: Border.all(color: const Color(0xFFBDD8F2), width: 3),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF99A9C0).withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onImageTap,
              borderRadius: BorderRadius.circular(adaptive.space(24)),
              child: Padding(
                padding: EdgeInsets.all(adaptive.space(6)),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(adaptive.space(24)),
                  child: imagePath != null
                      ? Image.asset(
                          imagePath!,
                          width: imageSize,
                          height: imageSize,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return _ImageFallback(
                              adaptive: adaptive,
                              size: imageSize,
                            );
                          },
                        )
                      : _ImageFallback(adaptive: adaptive, size: imageSize),
                ),
              ),
            ),
          ),
          SizedBox(height: adaptive.space(18)),
          Text(
            prompt,
            style: TextStyle(
              fontSize: adaptive.space(prompt.length > 12 ? 34 : 48),
              fontWeight: FontWeight.w900,
              color: const Color(0xFF243A5A),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ImageFallback extends StatelessWidget {
  const _ImageFallback({required this.adaptive, required this.size});

  final _AudyAdaptive adaptive;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFF8FBCEC).withValues(alpha: 0.2),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.record_voice_over_rounded,
        size: adaptive.space(54),
        color: const Color(0xFF243A5A),
      ),
    );
  }
}

class _RecordingStatus extends StatelessWidget {
  const _RecordingStatus({
    required this.adaptive,
    required this.isRecording,
    required this.label,
  });

  final _AudyAdaptive adaptive;
  final bool isRecording;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(minHeight: 48),
        padding: EdgeInsets.symmetric(
          horizontal: adaptive.space(18),
          vertical: adaptive.space(10),
        ),
        decoration: BoxDecoration(
          color: isRecording
              ? const Color(0xFFF8C7DF).withValues(alpha: 0.45)
              : const Color(0xFFF5F8FC),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: isRecording
                ? const Color(0xFFF29AC5)
                : const Color(0xFFBDD8F2),
            width: 2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isRecording ? Icons.fiber_manual_record : Icons.mic_none_rounded,
              size: adaptive.space(18),
              color: isRecording
                  ? const Color(0xFFC6427A)
                  : const Color(0xFF617691),
            ),
            SizedBox(width: adaptive.space(8)),
            Text(
              label,
              style: TextStyle(
                fontSize: adaptive.space(15),
                fontWeight: FontWeight.w800,
                color: isRecording
                    ? const Color(0xFFC6427A)
                    : const Color(0xFF617691),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SttDebugPanel extends StatelessWidget {
  const _SttDebugPanel({
    required this.adaptive,
    required this.status,
    required this.text,
  });

  final _AudyAdaptive adaptive;
  final String status;
  final String text;

  @override
  Widget build(BuildContext context) {
    final heardText = text.trim().isEmpty ? '(nothing yet)' : text.trim();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(adaptive.space(12)),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(adaptive.space(14)),
        border: Border.all(color: const Color(0xFFFFD54F), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'STT status: $status',
            style: TextStyle(
              fontSize: adaptive.space(13),
              fontWeight: FontWeight.w800,
              color: const Color(0xFF6D4C00),
            ),
          ),
          SizedBox(height: adaptive.space(6)),
          Text(
            'Heard: $heardText',
            style: TextStyle(
              fontSize: adaptive.space(14),
              fontWeight: FontWeight.w700,
              color: const Color(0xFF243A5A),
            ),
          ),
        ],
      ),
    );
  }
}

class _VoiceButton extends StatelessWidget {
  const _VoiceButton({
    required this.adaptive,
    required this.isListening,
    required this.isEnabled,
    required this.listeningCount,
    required this.onTap,
  });

  final _AudyAdaptive adaptive;
  final bool isListening;
  final bool isEnabled;
  final int listeningCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final radius = adaptive.isPhone ? 62.0 : adaptive.space(72);

    return AvatarGlow(
      key: ValueKey('read_pronounce_glow_$listeningCount'),
      glowColor: const Color(0xFFF8C7DF),
      animate: isListening,
      repeat: true,
      child: GestureDetector(
        onTap: isEnabled ? onTap : null,
        child: CircleAvatar(
          radius: radius,
          backgroundColor: isEnabled || isListening
              ? const Color(0xFFF8C7DF)
              : const Color(0xFFD7DEE8),
          child: Icon(
            isListening ? Icons.mic_rounded : Icons.mic_none_rounded,
            color: const Color(0xFF243A5A),
            size: adaptive.space(54),
          ),
        ),
      ),
    );
  }
}

class _CorrectBadge extends StatelessWidget {
  const _CorrectBadge({required this.adaptive});

  final _AudyAdaptive adaptive;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 48),
      padding: EdgeInsets.symmetric(
        horizontal: adaptive.space(20),
        vertical: adaptive.space(10),
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFF69E0A0), width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.check_circle_rounded,
            color: const Color(0xFF2E7D32),
            size: adaptive.space(24),
          ),
          SizedBox(width: adaptive.space(8)),
          Text(
            _tr(context, 'correct'),
            style: TextStyle(
              color: const Color(0xFF2E7D32),
              fontSize: adaptive.space(18),
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _SkipButton extends StatelessWidget {
  const _SkipButton({required this.adaptive, required this.onPressed});

  final _AudyAdaptive adaptive;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(Icons.skip_next_rounded, size: adaptive.space(24)),
        label: Text(
          _tr(context, 'skip'),
          style: TextStyle(
            fontSize: adaptive.space(17),
            fontWeight: FontWeight.w800,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFFE0B2),
          foregroundColor: const Color(0xFF6D4C00),
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(adaptive.space(16)),
          ),
          elevation: 2,
        ),
      ),
    );
  }
}

class _SttUnavailableMessage extends StatelessWidget {
  const _SttUnavailableMessage({required this.adaptive, required this.message});

  final _AudyAdaptive adaptive;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(adaptive.space(16)),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(adaptive.space(16)),
        border: Border.all(color: const Color(0xFFFFB74D), width: 2),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: adaptive.space(24),
            color: const Color(0xFFFF9800),
          ),
          SizedBox(width: adaptive.space(12)),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: adaptive.space(14),
                color: const Color(0xFFE65100),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeedbackCard extends StatelessWidget {
  const _FeedbackCard({
    required this.adaptive,
    required this.feedback,
    required this.isCorrect,
  });

  final _AudyAdaptive adaptive;
  final String feedback;
  final bool isCorrect;

  @override
  Widget build(BuildContext context) {
    final color = isCorrect ? const Color(0xFF69E0A0) : const Color(0xFFBDD8F2);
    final icon = isCorrect
        ? Icons.check_circle_rounded
        : Icons.tips_and_updates_rounded;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(adaptive.space(16)),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(adaptive.space(16)),
        border: Border.all(color: color, width: 2),
      ),
      child: Row(
        children: [
          Icon(icon, size: adaptive.space(24), color: const Color(0xFF243A5A)),
          SizedBox(width: adaptive.space(12)),
          Expanded(
            child: Text(
              feedback,
              style: TextStyle(
                fontSize: adaptive.space(15),
                color: const Color(0xFF243A5A),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TopRow extends StatelessWidget {
  const _TopRow({
    required this.adaptive,
    required this.label,
    required this.onBack,
  });

  final _AudyAdaptive adaptive;
  final String label;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onBack,
      child: Container(
        constraints: const BoxConstraints(minHeight: 48),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.arrow_back_rounded,
              size: adaptive.space(22),
              color: const Color(0xFF617691),
            ),
            SizedBox(width: adaptive.space(8)),
            Text(
              label,
              style: TextStyle(
                fontSize: adaptive.space(15),
                fontWeight: FontWeight.w600,
                color: const Color(0xFF617691),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AudyAdaptive {
  const _AudyAdaptive({required this.width, required this.height});

  final double width;
  final double height;

  bool get isPhone => width < 600;
  bool get isTablet => width >= 600 && width < 1024;
  bool get isDesktop => width >= 1024;

  double get scale => (width / 390).clamp(0.92, 1.35);
  double space(double value) => value * scale;
}
