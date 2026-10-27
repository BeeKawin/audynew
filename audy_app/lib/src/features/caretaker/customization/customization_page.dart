import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../data/models/game_configuration.dart';
import '../../../data/repositories/caretaker_repository.dart';
import '../../../data/repositories/break_settings_repository.dart';
import '../../../state/caretaker_controller.dart';
import '../../parent/child_profile_selector.dart';
import '../caretaker_ui.dart';
import 'game_editor.dart';
import 'break_settings_editor.dart';

class CustomizationPage extends StatefulWidget {
  const CustomizationPage({super.key, required this.controller});
  final CaretakerController controller;
  @override
  State<CustomizationPage> createState() => _CustomizationPageState();
}

class _CustomizationPageState extends State<CustomizationPage> {
  final _repository = GameConfigurationRepository(Supabase.instance.client);
  Set<String> _saved = {};
  String? _error;
  bool _loading = true;
  int _request = 0;
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_changed);
    _load();
  }

  String? _child;
  void _changed() {
    if (_child != widget.controller.selectedId) _load();
  }

  Future<void> _load() async {
    _child = widget.controller.selectedId;
    final request = ++_request;
    setState(() {
      _loading = true;
      _error = null;
      _saved = {};
    });
    try {
      final saved = _child == null
          ? <String>{}
          : await _repository.summaries(_child!);
      if (mounted && request == _request) setState(() => _saved = saved);
    } catch (e) {
      if (mounted && request == _request) {
        setState(() => _error = caretakerError(e));
      }
    } finally {
      if (mounted && request == _request) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_changed);
    _request++;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => CaretakerAccountGuard(
    child: Scaffold(
      appBar: AppBar(title: Text(ct(context, 'Customization', 'ปรับแต่งเกม'))),
      body: ListenableBuilder(
        listenable: widget.controller,
        builder: (context, _) => CaretakerPageBody(
          children: [
            ChildProfileSelector(
              children: widget.controller.children,
              selectedChildId: widget.controller.selectedId,
              onSelected: widget.controller.select,
              label: ct(context, 'Selected child', 'เด็กที่เลือก'),
              emptyMessage: ct(
                context,
                'Choose a child in your care list first.',
                'เลือกเด็กในความดูแลก่อน',
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              minVerticalPadding: 16,
              leading: const Icon(Icons.self_improvement_rounded),
              title: Text(
                ct(
                  context,
                  'Break / Meltdown Protection',
                  'การพัก / ป้องกันภาวะล้นเกิน',
                ),
              ),
              subtitle: Text(
                ct(
                  context,
                  'Set the number of games before a break. Applies to Student play.',
                  'กำหนดจำนวนเกมก่อนพัก ใช้กับการเล่นของเด็ก',
                ),
              ),
              trailing: const Icon(Icons.chevron_right),
              enabled:
                  widget.controller.selected != null &&
                  !widget.controller.loading &&
                  widget.controller.error == null,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => BreakSettingsEditor(
                    child: widget.controller.selected!,
                    repository: BreakSettingsRepository(
                      Supabase.instance.client,
                    ),
                  ),
                ),
              ),
            ),
            const Divider(height: 32),
            Text(
              ct(context, 'Game previews', 'การทดลองเกม'),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            CaretakerNotice(
              ct(
                context,
                'Saved settings are for Caretaker previews. Student gameplay is unchanged in this phase.',
                'การตั้งค่าใช้ในการทดลองของผู้ดูแล เกมของเด็กยังใช้การตั้งค่าเดิมในระยะนี้',
              ),
            ),
            if (_loading) const LinearProgressIndicator(),
            if (_error != null) CaretakerNotice(_error!, onRetry: _load),
            for (final game in CaretakerGame.values)
              ListTile(
                minVerticalPadding: 16,
                leading: const Icon(Icons.sports_esports_outlined),
                title: Text(game.title),
                subtitle: Text(
                  _loading || _error != null
                      ? ct(
                          context,
                          'Settings not loaded',
                          'ยังไม่ได้โหลดการตั้งค่า',
                        )
                      : ct(
                          context,
                          _saved.contains(game.key)
                              ? 'Customized'
                              : 'Default settings',
                          _saved.contains(game.key)
                              ? 'ปรับแต่งแล้ว'
                              : 'ค่าเริ่มต้น',
                        ),
                ),
                trailing: const Icon(Icons.chevron_right),
                enabled:
                    widget.controller.selected != null &&
                    !_loading &&
                    _error == null,
                onTap: () async {
                  final child = widget.controller.selected!;
                  await Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => GameEditor(
                        child: child,
                        game: game,
                        repository: _repository,
                      ),
                    ),
                  );
                  if (mounted) _load();
                },
              ),
          ],
        ),
      ),
    ),
  );
}
