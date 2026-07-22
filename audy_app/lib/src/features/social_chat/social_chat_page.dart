import 'dart:async';

import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../../core/audy_ui.dart';
import '../../services/bluetooth_service.dart';
import '../../services/interactive_input_service.dart';
import '../../services/sound_service.dart';
import '../../state/audy_controller.dart';

class SocialPracticePage extends StatefulWidget {
  const SocialPracticePage({super.key});

  @override
  State<SocialPracticePage> createState() => _SocialPracticePageState();
}

class _SocialPracticePageState extends State<SocialPracticePage> {
  late final TextEditingController messageController;
  late final ScrollController _scrollController;
  final stt.SpeechToText _speech = stt.SpeechToText();
  StreamSubscription<AudyBleMessage>? _bleMicSub;
  bool _speechInitialized = false;
  bool _isListening = false;
  int _listeningCount = 0; // To trigger AvatarGlow rebuild for each listen
  int _lastMessageCount = 0; // To track new messages for auto-scrolling

  @override
  void initState() {
    super.initState();
    unawaited(SoundService.instance.playSocialChatIntro());
    messageController = TextEditingController();
    _scrollController = ScrollController();
    unawaited(_sendGameEnterBleState());
    _bleMicSub = InteractiveInputService.instance.incomingMessages.listen(
      _handleBleInput,
    );
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
  void dispose() {
    unawaited(_resetGameBleState());
    _bleMicSub?.cancel();
    messageController.dispose();
    _scrollController.dispose();
    _speech.stop();
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

  void _listen() async {
    final controller = AudyScope.of(context);

    if (!_isListening) {
      // Initialize STT on first use
      if (!_speechInitialized) {
        _speechInitialized = await _speech.initialize(
          onStatus: (status) {
            if (status == 'notListening' || status == 'done') {
              if (mounted && _isListening) {
                setState(() => _isListening = false);
              }
            }
          },
          onError: (error) {
            if (mounted) {
              setState(() => _isListening = false);
            }
          },
        );
      }
      if (_speechInitialized) {
        SoundService.instance.playTap();
        setState(() {
          _isListening = true;
          _listeningCount++;
        });
        _speech.listen(
          localeId: 'th_TH',
          listenFor: const Duration(seconds: 30),
          pauseFor: const Duration(seconds: 3),
          listenOptions: stt.SpeechListenOptions(partialResults: true),
          onResult: (result) {
            if (mounted) {
              setState(() {
                messageController.text = result.recognizedWords;
              });
            }
          },
        );
      }
    } else {
      // User taps mic again to stop listening and submit recognized speech.
      SoundService.instance.playTap();
      setState(() => _isListening = false);
      await _speech.stop();
      await _submitMessage(controller);
    }
  }

  Future<void> _submitMessage(AudyController controller) async {
    if (controller.isChatLoading) return;

    final text = messageController.text;
    if (controller.validateThaiChatMessage(text) != null) return;

    final previousMessageCount = controller.thaiSocialMessages.length;

    messageController.clear();
    await controller.submitThaiSocialMessage(text);

    final newBotMessages = controller.thaiSocialMessages
        .skip(previousMessageCount)
        .where((message) => !message.isUser);
    if (newBotMessages.isNotEmpty) {
      await controller.speakThaiResponse(newBotMessages.last.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = AudyScope.of(context);
    if (controller.thaiSocialMessages.length != _lastMessageCount) {
      _lastMessageCount = controller.thaiSocialMessages.length;
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
                  itemCount: controller.thaiSocialMessages.length,
                  itemBuilder: (context, index) {
                    final message = controller.thaiSocialMessages[index];
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
                  // Mic button for Thai speech input
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
                  // Speaker button (TTS for Thai)
                  InkWell(
                    onTap: () {
                      SoundService.instance.playTap();
                      // Get last bot message and speak it
                      final botMessages = controller.thaiSocialMessages
                          .where((m) => !m.isUser)
                          .toList();
                      if (botMessages.isNotEmpty) {
                        controller.speakThaiResponse(botMessages.last.text);
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
                    : controller.socialFeedback ==
                          'Start a conversation with a short message.'
                    ? controller.tr('start_conversation')
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
