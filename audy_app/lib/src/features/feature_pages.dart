import 'package:flutter/material.dart';

import '../core/app_routes.dart';
import '../core/audy_ui.dart';
import '../services/sound_service.dart';
import '../state/audy_controller.dart';

class GamesHubPage extends StatelessWidget {
  const GamesHubPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = AudyScope.of(context);

    final cards = [
      _RouteCard(
        controller.tr('emotion_classify'),
        null,
        Icons.face_rounded,
        const Color(0xFFF8C7DF),
        AppRoutes.emotionClassify,
      ),
      _RouteCard(
        controller.tr('emotion_mimic'),
        null,
        Icons.camera_alt_rounded,
        const Color(0xFFDDD0F4),
        AppRoutes.emotionMimic,
      ),
      _RouteCard(
        controller.tr('mini_puzzle'),
        null,
        Icons.extension_rounded,
        const Color(0xFFBDD8F2),
        AppRoutes.miniPuzzle,
      ),
      _RouteCard(
        controller.tr('sorting_game'),
        null,
        Icons.sort_rounded,
        const Color(0xFFFFF3A6),
        AppRoutes.sortingGame,
      ),
      _RouteCard(
        controller.tr('reaction_time'),
        null,
        Icons.bolt_rounded,
        const Color(0xFFFFDAC7),
        AppRoutes.reactionTime,
      ),
    ];

    return AudyFeaturePage(
      title: controller.tr('games'),
      subtitle: controller.tr('play_and_learn'),
      leadingLabel: controller.tr('back_home'),
      mascot: const AudyMascot(size: 132),
      childBuilder: (context, adaptive) {
        return AudyAdaptiveGrid(
          adaptive: adaptive,
          phoneColumns: 1,
          tabletColumns: 2,
          desktopColumns: 2,
          items: cards
              .map(
                (card) => AudyActionCard(
                  title: card.title,
                  subtitle: card.subtitle,
                  icon: card.icon,
                  color: card.color,
                  adaptive: adaptive,
                  onTap: () {
                    SoundService.instance.playTap();
                    Navigator.pushNamed(context, card.route);
                  },
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class SocialPracticePage extends StatefulWidget {
  const SocialPracticePage({super.key});

  @override
  State<SocialPracticePage> createState() => _SocialPracticePageState();
}

class _SocialPracticePageState extends State<SocialPracticePage> {
  late final TextEditingController messageController;
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    messageController = TextEditingController();
    _scrollController = ScrollController();
    // Scroll to bottom after initial build
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  @override
  void dispose() {
    messageController.dispose();
    _scrollController.dispose();
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    final controller = AudyScope.of(context);
    // Auto-scroll when messages change
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

    return AudyResponsivePage(
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
                      SizedBox(height: adaptive.space(28)),
                      Text(
                        controller.tr('social_practice'),
                        style: TextStyle(
                          fontSize: adaptive.space(28),
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF243A5A),
                        ),
                      ),
                      SizedBox(height: adaptive.space(8)),
                      Text(
                        controller.tr('chat_with_auday'),
                        style: TextStyle(
                          fontSize: adaptive.space(16),
                          color: const Color(0xFF60758F),
                        ),
                      ),
                    ],
                  ),
                ),
                if (!adaptive.isPhone) const AudyMascot(size: 110),
              ],
            ),
            SizedBox(height: adaptive.space(20)),
            AudyPanel(
              adaptive: adaptive,
              child: SizedBox(
                height: adaptive.isPhone ? 360 : 460,
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
            SizedBox(height: adaptive.space(18)),
            AudyPanel(
              adaptive: adaptive,
              padding: EdgeInsets.all(adaptive.space(14)),
              child: Row(
                children: [
                  // Microphone button (STT for Thai)
                  InkWell(
                    onTap: () async {
                      SoundService.instance.playTap();
                      final text = await controller.listenThaiSpeech();
                      if (text != null && text.isNotEmpty) {
                        messageController.text = text;
                      }
                    },
                    child: CircleAvatar(
                      radius: adaptive.isPhone ? 22 : 26,
                      backgroundColor: const Color(0xFFF8C7DF),
                      child: Icon(
                        Icons.mic_none_rounded,
                        color: const Color(0xFF243A5A),
                        size: adaptive.space(20),
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
                          horizontal: adaptive.space(18),
                          vertical: adaptive.space(16),
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
                            final text = messageController.text;
                            if (controller.validateThaiChatMessage(text) ==
                                null) {
                              messageController.clear();
                              await controller.submitThaiSocialMessage(text);
                            }
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
                  fontSize: adaptive.space(13),
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

class _RouteCard {
  const _RouteCard(
    this.title,
    this.subtitle,
    this.icon,
    this.color,
    this.route,
  );

  final String title;
  final String? subtitle;
  final IconData icon;
  final Color color;
  final String route;
}
