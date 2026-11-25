import 'dart:async';

import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../../core/audy_ui.dart';
import '../../services/bluetooth_service.dart';
import '../../services/interactive_input_service.dart';
import '../../services/sound_service.dart';
import '../../services/speech_service.dart';
import '../../state/audy_controller.dart';

class SocialPracticePage extends StatefulWidget {
  const SocialPracticePage({super.key, this.inputService});

  final InteractiveInputService? inputService;

  @override
  State<SocialPracticePage> createState() => _SocialPracticePageState();
}

class _SocialPracticePageState extends State<SocialPracticePage> {
  late final TextEditingController messageController;
  late final ScrollController _scrollController;
  final stt.SpeechToText _speech = stt.SpeechToText();
  AudyController? _controller;
  StreamSubscription<AudyBleMessage>? _bleMicSub;
  bool _startingMic = false;
  VoidCallback? _detachMicHandlers;
  int? _chatRevision;
  int _micRevision = 0;
  bool _isListening = false;
  int _listeningCount = 0; // To trigger AvatarGlow rebuild for each listen
  int _lastMessageCount = 0; // To track new messages for auto-scrolling

  @override
  void initState() {
    super.initState();
    messageController = TextEditingController();
    _scrollController = ScrollController();
    unawaited(_sendGameEnterBleState());
    final inputs = widget.inputService ?? InteractiveInputService.instance;
    _bleMicSub = inputs.incomingMessages.listen(_handleBleInput);
    // Scroll to bottom after initial build
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  Future<void> _sendGameEnterBleState() async {
    try {
      await AudyBluetoothService.instance.setLed(20);
    } catch (e) {
      debugPrint('SocialPracticePage: Entry LED BLE state skipped - $e');
    }
  }

  void _handleBleInput(AudyBleMessage message) {
    if (!mounted) return;
    if (ModalRoute.of(context)?.isCurrent != true) return;
    if (message.channel != 'nose' || message.value != 1) return;

    _listen();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final controller = AudyScope.of(context);
    _controller = controller;
    final revision = controller.chatLanguageRevision;
    if (_chatRevision != null && _chatRevision != revision) {
      _cancelMic();
    }
    _chatRevision = revision;
  }

  void _cancelMic() {
    _micRevision++;
    _detachMicHandlers?.call();
    _detachMicHandlers = null;
    if (_isListening || _startingMic) {
      _isListening = false;
      unawaited(_speech.cancel().catchError((Object _) {}));
    }
  }

  @override
  void dispose() {
    unawaited(_resetGameBleState());
    _bleMicSub?.cancel();
    messageController.dispose();
    _scrollController.dispose();
    _cancelMic();
    unawaited(_controller?.geminiTtsService.stopSpeaking());
    super.dispose();
  }

  Future<void> _resetGameBleState() async {
    try {
      await AudyBluetoothService.instance.setLed(0);
    } catch (e) {
      debugPrint('SocialPracticePage: Exit LED BLE reset skipped - $e');
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _listen() async {
    if (_startingMic) return;
    final controller = AudyScope.of(context);
    final revision = controller.chatLanguageRevision;
    final language = controller.socialLanguage;
    final micRevision = _isListening ? _micRevision : ++_micRevision;
    bool isCurrent() =>
        mounted &&
        revision == controller.chatLanguageRevision &&
        micRevision == _micRevision &&
        ModalRoute.of(context)?.isCurrent == true;

    if (_isListening) {
      SoundService.instance.playTap();
      setState(() => _isListening = false);
      await _speech.stop();
      if (isCurrent()) await _submitMessage(controller);
      return;
    }

    _startingMic = true;
    try {
      final available = await _speech.initialize();
      if (!isCurrent()) return;
      if (!available) {
        _showVoiceUnavailable(controller);
        return;
      }
      final locales = await _speech.locales();
      if (!isCurrent()) return;

      _detachMicHandlers?.call();
      _detachMicHandlers = attachChatRecognitionHandlers(
        _speech,
        onStatus: (status) {
          if (isCurrent() &&
              _isListening &&
              (status == 'notListening' || status == 'done')) {
            setState(() => _isListening = false);
          }
        },
        onError: (_) {
          if (isCurrent()) _showVoiceUnavailable(controller);
        },
      );

      SoundService.instance.playTap();
      setState(() {
        _isListening = true;
        _listeningCount++;
      });
      await _speech.listen(
        localeId: language.recognitionLocale(
          locales.map((locale) => locale.localeId),
        ),
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
        listenOptions: stt.SpeechListenOptions(partialResults: true),
        onResult: (result) {
          if (isCurrent()) messageController.text = result.recognizedWords;
        },
      );
      if (!isCurrent()) await _speech.cancel();
    } catch (_) {
      if (isCurrent()) _showVoiceUnavailable(controller);
    } finally {
      _startingMic = false;
    }
  }

  void _showVoiceUnavailable(AudyController controller) {
    if (_isListening) setState(() => _isListening = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(controller.tr('chat_voice_unavailable'))),
    );
  }

  Future<void> _submitMessage(AudyController controller) async {
    if (controller.isChatLoading) return;
    final text = messageController.text;
    if (!controller.validateSocialMessage(text)) return;

    final revision = controller.chatLanguageRevision;
    _cancelMic();
    messageController.clear();
    final reply = await controller.submitSocialMessage(text);
    if (reply != null &&
        mounted &&
        revision == controller.chatLanguageRevision &&
        ModalRoute.of(context)?.isCurrent == true) {
      await controller.speakSocialResponse(reply);
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = AudyScope.of(context);
    if (controller.socialMessages.length != _lastMessageCount) {
      _lastMessageCount = controller.socialMessages.length;
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    }
    return AudyResponsivePage(
      scrollable: false,
      builder: (context, adaptive) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AudyBackButton(
                        label: controller.tr('back_home'),
                        onPressed: () {
                          SoundService.instance.playTap();
                          Navigator.pop(context);
                        },
                      ),
                      SizedBox(height: adaptive.space(12)),
                      Text(
                        controller.tr('social_practice'),
                        style: TextStyle(
                          fontSize: adaptive.space(24),
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF243A5A),
                        ),
                      ),
                      SizedBox(height: adaptive.space(4)),
                      Text(
                        controller.tr('chat_with_auday'),
                        style: TextStyle(
                          fontSize: adaptive.space(14),
                          color: const Color(0xFF60758F),
                        ),
                      ),
                    ],
                  ),
                ),
                if (!adaptive.isPhone) const AudyMascot(size: 82),
              ],
            ),
            SizedBox(height: adaptive.space(12)),
            Expanded(
              child: AudyPanel(
                adaptive: adaptive,
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(12),
                  itemCount: controller.socialMessages.length,
                  itemBuilder: (context, index) {
                    final message = controller.socialMessages[index];
                    return _ChatBubble(
                      text: message.text,
                      isUser: message.isUser,
                    );
                  },
                ),
              ),
            ),
            SizedBox(height: adaptive.space(10)),
            AudyPanel(
              adaptive: adaptive,
              padding: EdgeInsets.all(adaptive.space(10)),
              child: Row(
                children: [
                  // Microphone
                  AvatarGlow(
                    key: ValueKey('glow_$_listeningCount'),
                    glowColor: const Color(0xFFF8C7DF),
                    animate: _isListening,
                    repeat: true,
                    child: GestureDetector(
                      onTap: _listen,
                      child: CircleAvatar(
                        radius: adaptive.isPhone ? 22 : 26,
                        backgroundColor: const Color(0xFFF8C7DF),
                        child: Icon(
                          _isListening
                              ? Icons.mic_rounded
                              : Icons.mic_none_rounded,
                          color: const Color(0xFF243A5A),
                          size: adaptive.space(20),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: adaptive.space(12)),
                  Expanded(
                    child: TextField(
                      controller: messageController,
                      decoration: InputDecoration(
                        hintText: controller.tr('type_message'),
                        filled: true,
                        fillColor: const Color(0xFFF3F6F9),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(999),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: adaptive.space(16),
                          vertical: adaptive.space(12),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: adaptive.space(12)),
                  // Play the latest reply
                  InkWell(
                    onTap: () {
                      SoundService.instance.playTap();
                      // Get last bot message and speak it
                      final botMessages = controller.socialMessages
                          .where((m) => !m.isUser)
                          .toList();
                      if (botMessages.isNotEmpty) {
                        controller.speakSocialResponse(botMessages.last.text);
                      }
                    },
                    child: CircleAvatar(
                      radius: adaptive.isPhone ? 22 : 26,
                      backgroundColor: const Color(0xFFFFE0B2),
                      child: Icon(
                        Icons.volume_up_rounded,
                        color: const Color(0xFF243A5A),
                        size: adaptive.space(20),
                      ),
                    ),
                  ),
                  SizedBox(width: adaptive.space(12)),
                  // Send button
                  InkWell(
                    onTap: controller.isChatLoading
                        ? null
                        : () async {
                            SoundService.instance.playTap();
                            await _submitMessage(controller);
                          },
                    child: CircleAvatar(
                      radius: adaptive.isPhone ? 22 : 26,
                      backgroundColor: controller.isChatLoading
                          ? const Color(0xFFE1E5EB)
                          : const Color(0xFFC9E8C1),
                      child: controller.isChatLoading
                          ? SizedBox(
                              width: adaptive.space(18),
                              height: adaptive.space(18),
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation(
                                  Color(0xFF243A5A),
                                ),
                              ),
                            )
                          : Icon(
                              Icons.send_outlined,
                              color: const Color(0xFF243A5A),
                              size: adaptive.space(20),
                            ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: adaptive.space(12)),
            Center(
              child: Text(
                controller.isChatLoading
                    ? controller.tr('thinking')
                    : controller.socialFeedback,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: adaptive.space(12),
                  color: const Color(0xFF60758F),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({required this.text, required this.isUser});

  final String text;
  final bool isUser;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        constraints: const BoxConstraints(maxWidth: 320),
        decoration: BoxDecoration(
          color: isUser ? const Color(0xFFBDD8F2) : const Color(0xFFDDD0F4),
          borderRadius: BorderRadius.circular(22),
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 16, color: Color(0xFF243A5A)),
        ),
      ),
    );
  }
}
