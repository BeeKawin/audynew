import 'package:flutter/material.dart';

import 'read_pronounce_controller.dart';
import 'read_pronounce_service.dart';
import 'read_pronounce_result.dart';

class ReadPronouncePracticeScreen extends StatefulWidget {
  const ReadPronouncePracticeScreen({
    super.key,
    required this.title,
    required this.subtitle,
    required this.module,
    required this.illustrationIcon,
  });

  final String title;
  final String subtitle;
  final ReadPronounceModule module;
  final IconData illustrationIcon;

  @override
  State<ReadPronouncePracticeScreen> createState() =>
      _ReadPronouncePracticeScreenState();
}

class _ReadPronouncePracticeScreenState
    extends State<ReadPronouncePracticeScreen>
    with TickerProviderStateMixin {
  late final ReadPronounceController _controller;
  late final ReadPronounceService _service;
  final TextEditingController _textController = TextEditingController();

  bool _isTtsPlaying = false;
  bool _isSttListening = false;
  String _sttUnavailableMessage = '';

  late AnimationController _pulseController;
  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _controller = ReadPronounceController();
    _service = ReadPronounceService();
    _controller.startSession(widget.module);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _controller.addListener(_onControllerChanged);
  }

  void _onControllerChanged() {
    if (!mounted) return;
    if (_controller.isSessionComplete) {
      final result = _controller.lastSessionResult;
      final title = widget.title;
      Future.microtask(() {
        if (!mounted || result == null) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) =>
                ReadPronounceResultScreen(result: result, moduleName: title),
          ),
        );
      });
    }
    setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _controller.dispose();
    _textController.dispose();
    _pulseController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  Future<void> _handleListen() async {
    final state = _controller.currentState;
    if (state == null) return;

    setState(() => _isTtsPlaying = true);

    await _service.speak(state.prompt);

    if (mounted) {
      setState(() => _isTtsPlaying = false);
    }
  }

  Future<void> _handleSayIt() async {
    if (!_service.isSTTAvailable) {
      setState(() {
        _sttUnavailableMessage =
            'This feature is not available on your device.';
      });
      return;
    }

    setState(() {
      _isSttListening = true;
      _sttUnavailableMessage = '';
    });

    final result = await _service.listen();

    if (mounted) {
      setState(() => _isSttListening = false);

      if (result != null && result.trim().isNotEmpty) {
        _textController.text = result;
        _handleAttempt(result);
      }
    }
  }

  void _handleAttempt(String text) {
    _controller.submitAttempt(text);
    _textController.clear();
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
          body: SafeArea(
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
                    label: 'Back to Home',
                    onBack: () => Navigator.pop(context),
                  ),
                  SizedBox(height: adaptive.space(24)),
                  Center(
                    child: Column(
                      children: [
                        Text(
                          widget.title,
                          style: TextStyle(
                            fontSize: adaptive.space(28),
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF243A5A),
                          ),
                        ),
                        SizedBox(height: adaptive.space(8)),
                        Text(
                          widget.subtitle,
                          style: TextStyle(
                            fontSize: adaptive.space(15),
                            color: const Color(0xFF617691),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: adaptive.space(28)),
                  _ProgressIndicator(
                    adaptive: adaptive,
                    current: state.progressCurrent,
                    total: state.progressTotal,
                  ),
                  SizedBox(height: adaptive.space(28)),
                  _PromptCard(
                    adaptive: adaptive,
                    prompt: state.prompt,
                    illustrationIcon: widget.illustrationIcon,
                  ),
                  SizedBox(height: adaptive.space(24)),
                  Row(
                    children: [
                      Expanded(
                        child: _ListenButton(
                          adaptive: adaptive,
                          isPlaying: _isTtsPlaying,
                          onPressed: _handleListen,
                        ),
                      ),
                      SizedBox(width: adaptive.space(16)),
                      Expanded(
                        child: _SayItButton(
                          adaptive: adaptive,
                          onPressed: _handleSayIt,
                          isListening: _isSttListening,
                          isAvailable: _service.isSTTAvailable,
                        ),
                      ),
                    ],
                  ),
                  if (_sttUnavailableMessage.isNotEmpty) ...[
                    SizedBox(height: adaptive.space(16)),
                    _SttUnavailableMessage(
                      adaptive: adaptive,
                      message: _sttUnavailableMessage,
                    ),
                  ],
                  SizedBox(height: adaptive.space(20)),
                  _ManualInput(
                    adaptive: adaptive,
                    controller: _textController,
                    onAttempt: _handleAttempt,
                  ),
                  SizedBox(height: adaptive.space(16)),
                  _FeedbackCard(adaptive: adaptive, feedback: state.feedback),
                ],
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
    required this.illustrationIcon,
  });

  final _AudyAdaptive adaptive;
  final String prompt;
  final IconData illustrationIcon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(adaptive.space(32)),
      decoration: BoxDecoration(
        color: const Color(0xFFBDD8F2).withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(adaptive.space(32)),
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
          Container(
            width: adaptive.space(100),
            height: adaptive.space(100),
            decoration: BoxDecoration(
              color: const Color(0xFF8FBCEC).withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              illustrationIcon,
              size: adaptive.space(52),
              color: const Color(0xFF243A5A),
            ),
          ),
          SizedBox(height: adaptive.space(20)),
          Text(
            prompt,
            style: TextStyle(
              fontSize: adaptive.space(48),
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

class _ListenButton extends StatelessWidget {
  const _ListenButton({
    required this.adaptive,
    required this.isPlaying,
    required this.onPressed,
  });

  final _AudyAdaptive adaptive;
  final bool isPlaying;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isPlaying ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF8FBCEC),
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(vertical: adaptive.space(18)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(adaptive.space(16)),
        ),
        elevation: 4,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isPlaying ? Icons.volume_off_rounded : Icons.volume_up_rounded,
            size: adaptive.space(24),
          ),
          SizedBox(width: adaptive.space(8)),
          Text(
            isPlaying ? 'Playing...' : 'Listen',
            style: TextStyle(
              fontSize: adaptive.space(18),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _SayItButton extends StatefulWidget {
  const _SayItButton({
    required this.adaptive,
    required this.onPressed,
    required this.isListening,
    required this.isAvailable,
  });

  final _AudyAdaptive adaptive;
  final VoidCallback onPressed;
  final bool isListening;
  final bool isAvailable;

  @override
  State<_SayItButton> createState() => _SayItButtonState();
}

class _SayItButtonState extends State<_SayItButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(_SayItButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isListening && !oldWidget.isListening) {
      _pulseController.repeat(reverse: true);
    } else if (!widget.isListening && oldWidget.isListening) {
      _pulseController.stop();
      _pulseController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: widget.isAvailable ? widget.onPressed : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: widget.isAvailable
            ? const Color(0xFF69E0A0)
            : const Color(0xFFB0BEC5),
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(vertical: widget.adaptive.space(18)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(widget.adaptive.space(16)),
        ),
        elevation: 4,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (widget.isListening)
            ScaleTransition(
              scale: _pulseAnimation,
              child: Icon(Icons.mic_rounded, size: widget.adaptive.space(24)),
            )
          else
            Icon(Icons.mic_none_rounded, size: widget.adaptive.space(24)),
          SizedBox(width: widget.adaptive.space(8)),
          Text(
            widget.isListening ? 'Listening...' : 'Say It!',
            style: TextStyle(
              fontSize: widget.adaptive.space(18),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
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

class _ManualInput extends StatelessWidget {
  const _ManualInput({
    required this.adaptive,
    required this.controller,
    required this.onAttempt,
  });

  final _AudyAdaptive adaptive;
  final TextEditingController controller;
  final ValueSetter<String> onAttempt;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(adaptive.space(16)),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F8FC),
        borderRadius: BorderRadius.circular(adaptive.space(16)),
        border: Border.all(
          color: const Color(0xFFBDD8F2).withValues(alpha: 0.5),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Or type your answer:',
            style: TextStyle(
              fontSize: adaptive.space(14),
              color: const Color(0xFF617691),
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: adaptive.space(12)),
          TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: 'Type here...',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(adaptive.space(12)),
                borderSide: BorderSide(
                  color: const Color(0xFFBDD8F2),
                  width: 2,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(adaptive.space(12)),
                borderSide: BorderSide(
                  color: const Color(0xFFBDD8F2),
                  width: 2,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(adaptive.space(12)),
                borderSide: const BorderSide(
                  color: Color(0xFF8FBCEC),
                  width: 2,
                ),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: adaptive.space(16),
                vertical: adaptive.space(14),
              ),
            ),
            style: TextStyle(
              fontSize: adaptive.space(18),
              fontWeight: FontWeight.w600,
              color: const Color(0xFF243A5A),
            ),
          ),
          SizedBox(height: adaptive.space(12)),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (controller.text.trim().isNotEmpty) {
                  onAttempt(controller.text.trim());
                  controller.clear();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFBDD8F2),
                foregroundColor: const Color(0xFF243A5A),
                padding: EdgeInsets.symmetric(vertical: adaptive.space(14)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(adaptive.space(12)),
                ),
                elevation: 2,
              ),
              child: Text(
                'Submit',
                style: TextStyle(
                  fontSize: adaptive.space(16),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeedbackCard extends StatelessWidget {
  const _FeedbackCard({required this.adaptive, required this.feedback});

  final _AudyAdaptive adaptive;
  final String feedback;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(adaptive.space(16)),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(adaptive.space(16)),
        border: Border.all(color: const Color(0xFF69E0A0), width: 2),
      ),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_rounded,
            size: adaptive.space(24),
            color: const Color(0xFF4CAF50),
          ),
          SizedBox(width: adaptive.space(12)),
          Expanded(
            child: Text(
              feedback,
              style: TextStyle(
                fontSize: adaptive.space(15),
                color: const Color(0xFF2E7D32),
                fontWeight: FontWeight.w600,
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
