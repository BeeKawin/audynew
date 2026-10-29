import 'package:flutter/material.dart';

import '../core/audy_ui.dart';
import '../services/sound_service.dart';
import '../state/audy_controller.dart';

class RewardDraft {
  const RewardDraft({
    required this.prize,
    required this.condition,
    required this.targetCount,
  });

  final String prize;
  final RewardCondition condition;
  final int targetCount;
}

class AddRewardDialog extends StatefulWidget {
  const AddRewardDialog({
    super.key,
    required this.adaptive,
    this.previewOnly = false,
  });

  final AudyAdaptive adaptive;
  final bool previewOnly;

  @override
  State<AddRewardDialog> createState() => _AddRewardDialogState();
}

class _AddRewardDialogState extends State<AddRewardDialog> {
  final _prizeController = TextEditingController();
  RewardCondition _selectedCondition = RewardCondition.emotionClassify;
  int _targetCount = 5;

  @override
  void dispose() {
    _prizeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = AudyScope.of(context);
    final isSocialChat = _selectedCondition == RewardCondition.socialChat;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: EdgeInsets.all(widget.adaptive.space(24)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(widget.adaptive.space(28)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  controller.tr('create_reward'),
                  style: TextStyle(
                    fontSize: widget.adaptive.space(22),
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF243A5A),
                  ),
                ),
              ),
              if (widget.previewOnly) ...[
                SizedBox(height: widget.adaptive.space(16)),
                Text(
                  controller.currentLanguage == 'th'
                      ? 'ตัวอย่างเท่านั้น · ยังไม่บันทึกหรือมอบรางวัลให้เด็ก (TBD)'
                      : 'Preview only · Saving and assigning rewards are TBD.',
                  style: const TextStyle(color: Color(0xFF243A5A)),
                ),
              ],
              SizedBox(height: widget.adaptive.space(24)),
              Text(
                controller.tr('prize_label'),
                style: TextStyle(
                  fontSize: widget.adaptive.space(14),
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF60758F),
                ),
              ),
              SizedBox(height: widget.adaptive.space(8)),
              TextField(
                controller: _prizeController,
                maxLength: 120,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: controller.tr('prize_hint'),
                  hintStyle: const TextStyle(color: Color(0xFFB8BFCA)),
                  filled: true,
                  fillColor: const Color(0xFFF8F9FA),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: widget.adaptive.space(16),
                    vertical: widget.adaptive.space(14),
                  ),
                ),
              ),
              SizedBox(height: widget.adaptive.space(20)),
              Text(
                controller.tr('condition_label'),
                style: TextStyle(
                  fontSize: widget.adaptive.space(14),
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF60758F),
                ),
              ),
              SizedBox(height: widget.adaptive.space(12)),
              Center(
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: widget.adaptive.space(8),
                  runSpacing: widget.adaptive.space(8),
                  children: RewardCondition.values
                      .where((condition) => !condition.isRetired)
                      .where((condition) {
                        return condition != RewardCondition.emotionMimic;
                      })
                      .map((condition) {
                        return _ActivityChoice(
                          condition: condition,
                          selected: _selectedCondition == condition,
                          adaptive: widget.adaptive,
                          label: _conditionLabel(controller, condition),
                          onTap: () {
                            SoundService.instance.playTap();
                            setState(() => _selectedCondition = condition);
                          },
                        );
                      })
                      .toList(),
                ),
              ),
              SizedBox(height: widget.adaptive.space(20)),
              Text(
                controller.tr(isSocialChat ? 'chats_sent' : 'target_label'),
                style: TextStyle(
                  fontSize: widget.adaptive.space(14),
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF60758F),
                ),
              ),
              SizedBox(height: widget.adaptive.space(12)),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _CountButton(
                    icon: Icons.remove,
                    onPressed: _targetCount > 1
                        ? () => setState(() => _targetCount--)
                        : null,
                    adaptive: widget.adaptive,
                  ),
                  SizedBox(width: widget.adaptive.space(16)),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: widget.adaptive.space(24),
                      vertical: widget.adaptive.space(12),
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FA),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$_targetCount',
                      style: TextStyle(
                        fontSize: widget.adaptive.space(24),
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF243A5A),
                      ),
                    ),
                  ),
                  SizedBox(width: widget.adaptive.space(16)),
                  _CountButton(
                    icon: Icons.add,
                    onPressed: _targetCount < 20
                        ? () => setState(() => _targetCount++)
                        : null,
                    adaptive: widget.adaptive,
                  ),
                ],
              ),
              SizedBox(height: widget.adaptive.space(24)),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        SoundService.instance.playTap();
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE2E5EA),
                        foregroundColor: const Color(0xFF60758F),
                        padding: EdgeInsets.symmetric(
                          vertical: widget.adaptive.space(14),
                        ),
                        minimumSize: const Size(48, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      child: Text(controller.tr('cancel')),
                    ),
                  ),
                  SizedBox(width: widget.adaptive.space(12)),
                  Expanded(
                    child: ElevatedButton(
                      onPressed:
                          widget.previewOnly ||
                              _prizeController.text.trim().isEmpty
                          ? null
                          : () {
                              SoundService.instance.playTap();
                              Navigator.pop(
                                context,
                                RewardDraft(
                                  prize: _prizeController.text.trim(),
                                  condition: _selectedCondition,
                                  targetCount: _targetCount,
                                ),
                              );
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF8C7DF),
                        foregroundColor: const Color(0xFF243A5A),
                        disabledBackgroundColor: const Color(0xFFE2E5EA),
                        padding: EdgeInsets.symmetric(
                          vertical: widget.adaptive.space(14),
                        ),
                        minimumSize: const Size(48, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      child: Text(
                        widget.previewOnly
                            ? '${controller.tr('create')} · TBD'
                            : controller.tr('create'),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _conditionLabel(AudyController controller, RewardCondition condition) {
    return switch (condition) {
      RewardCondition.emotionClassify => controller.tr('emotion_classify'),
      RewardCondition.emotionMimic => controller.tr('emotion_mimic'),
      RewardCondition.miniPuzzle => controller.tr('mini_puzzle'),
      RewardCondition.sortingGame => controller.tr('sorting_game'),
      RewardCondition.reactionTime => controller.tr('reaction_time'),
      RewardCondition.reading => controller.tr('reading'),
      RewardCondition.socialChat => controller.tr('social_chat'),
    };
  }
}

class _ActivityChoice extends StatelessWidget {
  const _ActivityChoice({
    required this.condition,
    required this.selected,
    required this.adaptive,
    required this.label,
    required this.onTap,
  });

  final RewardCondition condition;
  final bool selected;
  final AudyAdaptive adaptive;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          constraints: const BoxConstraints(minHeight: 48),
          padding: EdgeInsets.symmetric(horizontal: adaptive.space(12)),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFF8C7DF) : const Color(0xFFF8F9FA),
            borderRadius: BorderRadius.circular(999),
            border: selected
                ? Border.all(color: const Color(0xFF5D6A7E), width: 1.5)
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _conditionIcon(condition),
                size: adaptive.space(18),
                color: const Color(0xFF243A5A),
              ),
              SizedBox(width: adaptive.space(6)),
              Flexible(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: adaptive.space(14),
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF243A5A),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _conditionIcon(RewardCondition condition) {
    return switch (condition) {
      RewardCondition.emotionClassify => Icons.sentiment_satisfied_rounded,
      RewardCondition.emotionMimic => Icons.face_rounded,
      RewardCondition.miniPuzzle => Icons.extension_rounded,
      RewardCondition.sortingGame => Icons.category_rounded,
      RewardCondition.reactionTime => Icons.flash_on_rounded,
      RewardCondition.reading => Icons.menu_book_rounded,
      RewardCondition.socialChat => Icons.chat_bubble_rounded,
    };
  }
}

class _CountButton extends StatelessWidget {
  const _CountButton({
    required this.icon,
    required this.onPressed,
    required this.adaptive,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final AudyAdaptive adaptive;

  @override
  Widget build(BuildContext context) {
    return IconButton.filled(
      onPressed: onPressed,
      icon: Icon(icon),
      iconSize: adaptive.space(20),
      constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
      style: IconButton.styleFrom(
        backgroundColor: const Color(0xFFBDD8F2),
        foregroundColor: const Color(0xFF243A5A),
        disabledBackgroundColor: const Color(0xFFE2E5EA),
      ),
    );
  }
}
