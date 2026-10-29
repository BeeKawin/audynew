import 'package:flutter/material.dart';

import '../../core/audy_ui.dart';
import '../../state/audy_controller.dart';
import '../../widgets/add_reward_dialog.dart';
import 'caretaker_ui.dart';

class CaretakerAssignmentsRewardsPage extends StatelessWidget {
  const CaretakerAssignmentsRewardsPage({super.key});

  Future<void> _previewReward(BuildContext context, AudyAdaptive adaptive) {
    return showDialog<void>(
      context: context,
      builder: (_) => CaretakerAccountGuard(
        child: AddRewardDialog(adaptive: adaptive, previewOnly: true),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(ct(context, 'Assignments & Rewards', 'งานและรางวัล')),
    ),
    body: AudyResponsivePage(
      builder: (context, adaptive) =>
          AudyPanel(adaptive: adaptive, child: _content(context, adaptive)),
    ),
  );

  Widget _content(BuildContext context, AudyAdaptive adaptive) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text(
        ct(context, 'Assignments · TBD', 'งานที่มอบหมาย · TBD'),
        style: Theme.of(context).textTheme.titleLarge,
      ),
      const SizedBox(height: 8),
      Text(
        ct(
          context,
          'Assignments will be connected in a future update.',
          'จะเชื่อมต่อการมอบหมายงานในการอัปเดตภายหลัง',
        ),
      ),
      const Divider(height: 48),
      Text(
        AudyScope.of(context).tr('rewards'),
        style: Theme.of(context).textTheme.titleLarge,
      ),
      const SizedBox(height: 8),
      Text(
        ct(
          context,
          'Preview reward setup. Saving rewards and assigning them to children are TBD.',
          'ทดลองตั้งค่ารางวัล การบันทึกและมอบรางวัลให้เด็กจะเชื่อมต่อภายหลัง (TBD)',
        ),
      ),
      const SizedBox(height: 24),
      ElevatedButton.icon(
        onPressed: () => _previewReward(context, adaptive),
        icon: const Icon(Icons.add_rounded),
        label: Text(AudyScope.of(context).tr('add_rewards')),
      ),
    ],
  );
}
