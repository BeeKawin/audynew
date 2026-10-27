import 'package:flutter/material.dart';

import '../../core/audy_ui.dart';
import '../../data/models/child_progress_snapshot.dart';
import '../../data/repositories/caretaker_repository.dart';
import '../../services/auth_service.dart';
import '../../state/audy_controller.dart';
import '../../state/caretaker_controller.dart';
import '../parent/child_profile_selector.dart';
import '../parent/parent_child_analytics.dart';
import '../parent/parent_child_progress_page.dart';
import 'caretaker_ui.dart';

class CaretakerChildProgress extends StatefulWidget {
  const CaretakerChildProgress({super.key, required this.controller});
  final CaretakerController controller;
  @override
  State<CaretakerChildProgress> createState() => _CaretakerChildProgressState();
}

class _CaretakerChildProgressState extends State<CaretakerChildProgress> {
  int _tab = 0;
  @override
  Widget build(BuildContext context) {
    final c = widget.controller;
    return AudyResponsivePage(
      builder: (context, adaptive) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            ct(context, 'Child Progress', 'ความก้าวหน้าของเด็ก'),
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 24),
          ChildProfileSelector(
            children: c.children,
            selectedChildId: c.selectedId,
            isLoading: c.loading,
            errorMessage: c.error,
            onRetry: c.load,
            onSelected: c.select,
            label: ct(context, 'Selected child', 'เด็กที่เลือก'),
            emptyMessage: ct(
              context,
              'Choose children in Profile → Manage Children.',
              'เลือกเด็กที่ โปรไฟล์ → จัดการเด็ก',
            ),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              ProgressTabButton(
                label: ct(
                  context,
                  'Level, Points & History',
                  'ระดับ คะแนน และประวัติ',
                ),
                icon: Icons.query_stats_rounded,
                selected: _tab == 0,
                color: const Color(0xFFBDD8F2),
                onTap: () => setState(() => _tab = 0),
              ),
              ProgressTabButton(
                label: ct(context, 'Analysis', 'การวิเคราะห์'),
                icon: Icons.bar_chart_rounded,
                selected: _tab == 1,
                color: const Color(0xFFE7D8FA),
                onTap: () => setState(() => _tab = 1),
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (!c.loading && c.error == null && c.selected != null)
            ChildProgressDetails(
              key: ValueKey(c.selectedId),
              child: c.selected!,
              repository: c.repository,
              adaptive: adaptive,
              analysis: _tab == 1,
            ),
        ],
      ),
    );
  }
}

class ChildProgressDetails extends StatefulWidget {
  const ChildProgressDetails({
    super.key,
    required this.child,
    required this.repository,
    required this.adaptive,
    required this.analysis,
  });
  final UserProfile child;
  final CaretakerRepository repository;
  final AudyAdaptive adaptive;
  final bool analysis;
  @override
  State<ChildProgressDetails> createState() => _ChildProgressDetailsState();
}

class _ChildProgressDetailsState extends State<ChildProgressDetails> {
  ChildProgressSnapshot? _data;
  String? _error;
  bool _loading = true;
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await widget.repository.progress(widget.child.id);
      if (mounted) setState(() => _data = data);
    } catch (error) {
      if (mounted) setState(() => _error = caretakerError(error));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) return CaretakerNotice(_error!, onRetry: _load);
    final data = _data!;
    if (widget.analysis) {
      return ParentChildAnalytics(
        key: ValueKey(data),
        child: widget.child,
        adaptive: widget.adaptive,
        snapshot: data,
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ChildLevelProgress(
          key: ValueKey(data),
          child: widget.child,
          adaptive: widget.adaptive,
          snapshot: data,
        ),
        const SizedBox(height: 24),
        AudyPanel(
          adaptive: widget.adaptive,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                ct(
                  context,
                  'Recorded Game History',
                  'ประวัติการเล่นที่บันทึกไว้',
                ),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                ct(
                  context,
                  'Latest 200 recorded sessions. Totals use the existing game counter.',
                  'แสดงการเล่นที่บันทึกล่าสุด 200 ครั้ง ยอดรวมใช้ตัวนับเดิมของแอป',
                ),
              ),
              const SizedBox(height: 8),
              Text(
                ct(
                  context,
                  'Last active: ${_date(data.stats?['last_played_at'])}',
                  'ใช้งานล่าสุด: ${_date(data.stats?['last_played_at'])}',
                ),
              ),
              const Divider(height: 24),
              if (data.sessions.isEmpty)
                Text(
                  ct(
                    context,
                    'No recorded games yet.',
                    'ยังไม่มีประวัติการเล่น',
                  ),
                ),
              for (final session in data.sessions)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.sports_esports_outlined),
                  title: Text(
                    '${_gameTitle(session['game_type'])} · ${_difficulty(session['difficulty'])}',
                  ),
                  subtitle: Text(
                    '${_date(session['session_ended_at'])}\n'
                    '${ct(context, 'Accuracy', 'ความแม่นยำ')}: ${session['accuracy_percent']}% · '
                    '${session['duration_seconds']} ${ct(context, 'seconds', 'วินาที')}',
                  ),
                  isThreeLine: true,
                ),
            ],
          ),
        ),
      ],
    );
  }

  String _date(dynamic raw) {
    final date = raw is String ? DateTime.tryParse(raw)?.toLocal() : null;
    return date == null
        ? ct(context, 'Never', 'ยังไม่มี')
        : '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _gameTitle(dynamic value) {
    const keys = {
      'emotion_classify': 'emotion_classify',
      'emotion_mimic': 'emotion_mimic',
      'minipuzzle': 'mini_puzzle',
      'sorting': 'sorting_game',
      'reaction_time': 'reaction_time',
      'flashcard': 'flashcard_game',
      'fruit_catching_bear': 'fruit_catching_bear',
      'reading': 'read_speak',
      'social_chat': 'social_chat',
    };
    final key = keys[value];
    return key == null
        ? ct(context, 'Game', 'เกม')
        : AudyScope.of(context).tr(key);
  }

  String _difficulty(dynamic value) =>
      ['easy', 'medium', 'hard'].contains(value)
      ? AudyScope.of(context).tr(value as String)
      : ct(context, 'Standard', 'มาตรฐาน');
}
