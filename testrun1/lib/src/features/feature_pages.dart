import 'package:flutter/material.dart';

import '../core/app_routes.dart';
import '../core/audy_ui.dart';

class GamesHubPage extends StatelessWidget {
  const GamesHubPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cards = [
      _RouteCard(
        'Emotion Game',
        'Name the feeling',
        Icons.sentiment_satisfied_alt_rounded,
        const Color(0xFFF8C7DF),
        AppRoutes.emotionGame,
      ),
      _RouteCard(
        'Eye Contact',
        'Focus training',
        Icons.remove_red_eye_outlined,
        const Color(0xFFBDD8F2),
        AppRoutes.eyeContact,
      ),
      _RouteCard(
        'Color Sorting',
        'Match by color',
        Icons.palette_outlined,
        const Color(0xFFFFF3A6),
        AppRoutes.colorSorting,
      ),
      _RouteCard(
        'Reaction Time',
        'Tap quickly',
        Icons.bolt_rounded,
        const Color(0xFFFFDAC7),
        AppRoutes.reactionTime,
      ),
    ];

    return AudyFeaturePage(
      title: 'Games',
      subtitle: 'Play and learn with fun activities!',
      leadingLabel: 'Back to Home',
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
                  onTap: () => Navigator.pushNamed(context, card.route),
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class ReadPronouncePage extends StatelessWidget {
  const ReadPronouncePage({super.key});

  @override
  Widget build(BuildContext context) {
    final cards = [
      _RouteCard(
        'Letters',
        'A B C sounds',
        Icons.text_fields_rounded,
        const Color(0xFFBDD8F2),
        AppRoutes.letters,
      ),
      _RouteCard(
        'Words',
        'Simple vocabulary',
        Icons.menu_book_rounded,
        const Color(0xFFF8C7DF),
        AppRoutes.words,
      ),
      _RouteCard(
        'Sentences',
        'Short phrases',
        Icons.chat_bubble_outline_rounded,
        const Color(0xFFC9E8C1),
        AppRoutes.sentences,
      ),
    ];

    return AudyFeaturePage(
      title: 'Read & Pronounce',
      subtitle: 'Choose your learning level.',
      leadingLabel: 'Back to Home',
      mascot: const AudyMascot(size: 126),
      childBuilder: (context, adaptive) {
        return AudyAdaptiveGrid(
          adaptive: adaptive,
          phoneColumns: 1,
          tabletColumns: 3,
          desktopColumns: 3,
          items: cards
              .map(
                (card) => AudyActionCard(
                  title: card.title,
                  subtitle: card.subtitle,
                  icon: card.icon,
                  color: card.color,
                  adaptive: adaptive,
                  onTap: () => Navigator.pushNamed(context, card.route),
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class ReadingPracticePage extends StatelessWidget {
  const ReadingPracticePage({
    super.key,
    required this.title,
    required this.subtitle,
    required this.prompt,
    required this.progressLabel,
    required this.illustrationIcon,
  });

  final String title;
  final String subtitle;
  final String prompt;
  final String progressLabel;
  final IconData illustrationIcon;

  @override
  Widget build(BuildContext context) {
    return AudyResponsivePage(
      builder: (context, adaptive) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _TopRow(
              adaptive: adaptive,
              leadingLabel: 'Back',
              trailingText: progressLabel,
            ),
            SizedBox(height: adaptive.space(18)),
            Center(
              child: AudyBadgeIcon(
                icon: illustrationIcon,
                size: adaptive.isPhone ? 88 : 106,
                background: const Color(0xFFFFE5A8),
                foreground: const Color(0xFFF28C28),
              ),
            ),
            SizedBox(height: adaptive.space(16)),
            Center(
              child: Column(
                children: [
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: adaptive.space(26),
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF243A5A),
                    ),
                  ),
                  SizedBox(height: adaptive.space(8)),
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: adaptive.space(15),
                      color: const Color(0xFF617691),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: adaptive.space(24)),
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 620),
                child: AudyPanel(
                  adaptive: adaptive,
                  child: Column(
                    children: [
                      Text(
                        prompt,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: adaptive.space(prompt.length > 8 ? 32 : 44),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: adaptive.space(18)),
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: adaptive.space(14),
                        runSpacing: adaptive.space(14),
                        children: [
                          AudyPillButton(
                            label: 'Listen',
                            icon: Icons.volume_up_outlined,
                            color: const Color(0xFFBDD8F2),
                            adaptive: adaptive,
                            onPressed: () {},
                          ),
                          AudyPillButton(
                            label: 'Say It!',
                            icon: Icons.mic_none_rounded,
                            color: const Color(0xFFC9E8C1),
                            adaptive: adaptive,
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class EmotionGamePage extends StatelessWidget {
  const EmotionGamePage({super.key});

  @override
  Widget build(BuildContext context) {
    const choices = ['Happy', 'Sad', 'Angry', 'Surprised', 'Scared'];
    const colors = [
      Color(0xFFFFF2A8),
      Color(0xFFBDD8F2),
      Color(0xFFFFDAC7),
      Color(0xFFF8C7DF),
      Color(0xFFDDD0F4),
    ];

    return AudyResponsivePage(
      builder: (context, adaptive) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _TopRow(
              adaptive: adaptive,
              leadingLabel: 'Back',
              trailingText: 'Score: 0 / 1',
            ),
            SizedBox(height: adaptive.space(24)),
            Center(
              child: Text(
                'What emotion is this?',
                style: TextStyle(
                  fontSize: adaptive.space(28),
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF243A5A),
                ),
              ),
            ),
            SizedBox(height: adaptive.space(18)),
            Center(
              child: AudyBadgeIcon(
                icon: Icons.sentiment_satisfied_alt_rounded,
                size: adaptive.isPhone ? 110 : 132,
                background: const Color(0xFFFFE4A6),
                foreground: const Color(0xFFF59A23),
              ),
            ),
            SizedBox(height: adaptive.space(18)),
            Center(
              child: AudyPillButton(
                label: 'Hear the word',
                icon: Icons.volume_up_outlined,
                color: const Color(0xFFBDD8F2),
                adaptive: adaptive,
                onPressed: () {},
              ),
            ),
            SizedBox(height: adaptive.space(24)),
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: AudyAdaptiveGrid(
                  adaptive: adaptive,
                  phoneColumns: 1,
                  tabletColumns: 2,
                  desktopColumns: 3,
                  items: List.generate(
                    choices.length,
                    (index) => AudyAnswerCard(
                      label: choices[index],
                      color: colors[index],
                      adaptive: adaptive,
                      onTap: () {},
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class EyeContactPage extends StatelessWidget {
  const EyeContactPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AudyResponsivePage(
      builder: (context, adaptive) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _TopRow(adaptive: adaptive, leadingLabel: 'Back to Home'),
            SizedBox(height: adaptive.space(20)),
            Center(
              child: Column(
                children: [
                  Text(
                    'Eye Contact Training',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: adaptive.space(28),
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF243A5A),
                    ),
                  ),
                  SizedBox(height: adaptive.space(8)),
                  Text(
                    'Look at the cat icon. Keep looking as long as you can.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: adaptive.space(15),
                      color: const Color(0xFF5F7390),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: adaptive.space(24)),
            Center(
              child: Container(
                width: adaptive.isPhone ? 220 : 280,
                height: adaptive.isPhone ? 220 : 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFFFB45E), width: 5),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFD287).withValues(alpha: 0.28),
                      blurRadius: 28,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: const Center(child: AudyMascot(size: 120)),
              ),
            ),
            SizedBox(height: adaptive.space(24)),
            Center(
              child: Text(
                '2.9s',
                style: TextStyle(
                  fontSize: adaptive.space(44),
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF243A5A),
                ),
              ),
            ),
            SizedBox(height: adaptive.space(20)),
            Center(
              child: AudyPillButton(
                label: 'Stop',
                color: const Color(0xFFBDD8F2),
                adaptive: adaptive,
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        );
      },
    );
  }
}

class ColorSortingPage extends StatelessWidget {
  const ColorSortingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final baskets = [
      _BasketData('Red', const Color(0xFFFF8D91)),
      _BasketData('Blue', const Color(0xFF8FBCEC)),
      _BasketData('Yellow', const Color(0xFFFFF68C)),
      _BasketData('Green', const Color(0xFF90F48A)),
    ];

    return AudyResponsivePage(
      builder: (context, adaptive) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _TopRow(
              adaptive: adaptive,
              leadingLabel: 'Back to Home',
              trailing: AudyPillButton(
                label: 'Hint',
                icon: Icons.lightbulb_outline_rounded,
                color: const Color(0xFFFFF2A8),
                adaptive: adaptive,
                onPressed: () {},
              ),
            ),
            SizedBox(height: adaptive.space(24)),
            Center(
              child: Column(
                children: [
                  Text(
                    'Color Sorting',
                    style: TextStyle(
                      fontSize: adaptive.space(28),
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF243A5A),
                    ),
                  ),
                  SizedBox(height: adaptive.space(8)),
                  Text(
                    'Tap a shape, then tap the matching color basket.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: adaptive.space(15),
                      color: const Color(0xFF617691),
                    ),
                  ),
                  SizedBox(height: adaptive.space(12)),
                  RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: adaptive.space(15),
                        color: const Color(0xFF617691),
                      ),
                      children: const [
                        TextSpan(text: 'Selected: '),
                        TextSpan(
                          text: 'Green',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF243A5A),
                          ),
                        ),
                        TextSpan(text: ' (circle)'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: adaptive.space(22)),
            AudyPanel(
              adaptive: adaptive,
              child: Column(
                children: [
                  Text(
                    'Tap from here:',
                    style: TextStyle(
                      fontSize: adaptive.space(18),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: adaptive.space(18)),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: adaptive.space(18),
                    runSpacing: adaptive.space(18),
                    children: const [
                      _ShapeChip(
                        shape: BoxShape.circle,
                        color: Color(0xFFFF8D91),
                      ),
                      _ShapeChip(
                        shape: BoxShape.rectangle,
                        color: Color(0xFF8FBCEC),
                      ),
                      _ShapeChip(
                        shape: BoxShape.circle,
                        color: Color(0xFF90F48A),
                        selected: true,
                      ),
                      _ShapeChip(
                        shape: BoxShape.rectangle,
                        color: Color(0xFFFF8D91),
                      ),
                      _TriangleChip(color: Color(0xFF8FBCEC)),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: adaptive.space(22)),
            AudyAdaptiveGrid(
              adaptive: adaptive,
              phoneColumns: 2,
              tabletColumns: 2,
              desktopColumns: 4,
              items: baskets
                  .map(
                    (basket) => _ColorBasketCard(
                      label: basket.label,
                      color: basket.color,
                      adaptive: adaptive,
                    ),
                  )
                  .toList(),
            ),
          ],
        );
      },
    );
  }
}

class ReactionTimePage extends StatelessWidget {
  const ReactionTimePage({super.key});

  @override
  Widget build(BuildContext context) {
    return AudyResponsivePage(
      builder: (context, adaptive) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _TopRow(
              adaptive: adaptive,
              leadingLabel: 'Back to Home',
              trailingText: 'Round: 3 / 10',
            ),
            SizedBox(height: adaptive.space(24)),
            Center(
              child: Column(
                children: [
                  Text(
                    'Reaction Time',
                    style: TextStyle(
                      fontSize: adaptive.space(28),
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF243A5A),
                    ),
                  ),
                  SizedBox(height: adaptive.space(8)),
                  Text(
                    'Tap the symbols as quickly as you can.',
                    style: TextStyle(
                      fontSize: adaptive.space(15),
                      color: const Color(0xFF617691),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: adaptive.space(20)),
            AudyPanel(
              adaptive: adaptive,
              padding: EdgeInsets.symmetric(
                horizontal: adaptive.space(22),
                vertical: adaptive.space(16),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Score: 2',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: adaptive.space(18),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Misses: 1',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: adaptive.space(18),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: adaptive.space(20)),
            Container(
              width: double.infinity,
              constraints: BoxConstraints(
                minHeight: adaptive.isPhone ? 260 : 420,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4FF),
                borderRadius: BorderRadius.circular(adaptive.space(28)),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF99A9C0).withValues(alpha: 0.15),
                    blurRadius: 22,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  Icons.auto_awesome_rounded,
                  size: adaptive.isPhone ? 56 : 76,
                  color: const Color(0xFFFFB14F),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class SocialPracticePage extends StatelessWidget {
  const SocialPracticePage({super.key});

  @override
  Widget build(BuildContext context) {
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
                        label: 'Back to Home',
                        onPressed: () => Navigator.pop(context),
                      ),
                      SizedBox(height: adaptive.space(28)),
                      Text(
                        'Social Practice',
                        style: TextStyle(
                          fontSize: adaptive.space(28),
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF243A5A),
                        ),
                      ),
                      SizedBox(height: adaptive.space(8)),
                      Text(
                        'Let\'s have a friendly conversation.',
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
              padding: EdgeInsets.symmetric(
                horizontal: adaptive.space(18),
                vertical: adaptive.space(16),
              ),
              child: Row(
                children: [
                  Text(
                    'Confidence:',
                    style: TextStyle(
                      fontSize: adaptive.space(16),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(width: adaptive.space(12)),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        value: 0.20,
                        minHeight: adaptive.space(12),
                        backgroundColor: const Color(0xFFE1E5EB),
                        valueColor: const AlwaysStoppedAnimation(
                          Color(0xFF69E0A0),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: adaptive.space(12)),
                  Text(
                    '20%',
                    style: TextStyle(
                      fontSize: adaptive.space(16),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: adaptive.space(20)),
            AudyPanel(
              adaptive: adaptive,
              child: SizedBox(
                height: adaptive.isPhone ? 320 : 420,
                child: ListView(
                  children: const [
                    _ChatBubble(
                      text: 'Hi! I\'m your friendly chat buddy!',
                      isUser: false,
                    ),
                    _ChatBubble(text: 'What did you eat today?', isUser: false),
                    _ChatBubble(text: 'Pizza!', isUser: true),
                    _ChatBubble(text: 'Sounds delicious!', isUser: false),
                    _ChatBubble(
                      text: 'What do you like to play?',
                      isUser: false,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: adaptive.space(18)),
            AudyPanel(
              adaptive: adaptive,
              padding: EdgeInsets.all(adaptive.space(14)),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: adaptive.isPhone ? 22 : 26,
                    backgroundColor: const Color(0xFFF8C7DF),
                    child: Icon(
                      Icons.mic_none_rounded,
                      color: const Color(0xFF243A5A),
                      size: adaptive.space(20),
                    ),
                  ),
                  SizedBox(width: adaptive.space(12)),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: adaptive.space(18),
                        vertical: adaptive.space(16),
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F6F9),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        'Type your message...',
                        style: TextStyle(
                          fontSize: adaptive.space(15),
                          color: const Color(0xFF7E8EA3),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: adaptive.space(12)),
                  CircleAvatar(
                    radius: adaptive.isPhone ? 22 : 26,
                    backgroundColor: const Color(0xFFC9E8C1),
                    child: Icon(
                      Icons.send_outlined,
                      color: const Color(0xFF243A5A),
                      size: adaptive.space(20),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _TopRow extends StatelessWidget {
  const _TopRow({
    required this.adaptive,
    required this.leadingLabel,
    this.trailingText,
    this.trailing,
  });

  final AudyAdaptive adaptive;
  final String leadingLabel;
  final String? trailingText;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: AudyBackButton(
            label: leadingLabel,
            onPressed: () => Navigator.pop(context),
          ),
        ),
        if (trailing != null) trailing!,
        if (trailing == null && trailingText != null)
          Text(
            trailingText!,
            style: TextStyle(
              fontSize: adaptive.space(16),
              fontWeight: FontWeight.w700,
            ),
          ),
      ],
    );
  }
}

class _ShapeChip extends StatelessWidget {
  const _ShapeChip({
    required this.shape,
    required this.color,
    this.selected = false,
  });

  final BoxShape shape;
  final Color color;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final content = Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: color,
        shape: shape,
        borderRadius: shape == BoxShape.rectangle
            ? BorderRadius.circular(10)
            : null,
      ),
    );

    if (!selected) return content;

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFB1C9F5), width: 3),
      ),
      child: content,
    );
  }
}

class _TriangleChip extends StatelessWidget {
  const _TriangleChip({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 56,
      height: 56,
      child: CustomPaint(painter: _TrianglePainter(color)),
    );
  }
}

class _TrianglePainter extends CustomPainter {
  const _TrianglePainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _TrianglePainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

class _ColorBasketCard extends StatelessWidget {
  const _ColorBasketCard({
    required this.label,
    required this.color,
    required this.adaptive,
  });

  final String label;
  final Color color;
  final AudyAdaptive adaptive;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: adaptive.isPhone ? 150 : 200,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(adaptive.space(24)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFA5B4C7).withValues(alpha: 0.20),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: TextStyle(
          fontSize: adaptive.space(18),
          fontWeight: FontWeight.w800,
          color: const Color(0xFF243A5A),
        ),
      ),
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
  final String subtitle;
  final IconData icon;
  final Color color;
  final String route;
}

class _BasketData {
  const _BasketData(this.label, this.color);

  final String label;
  final Color color;
}
