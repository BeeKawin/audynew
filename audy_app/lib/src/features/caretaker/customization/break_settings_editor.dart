import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../data/models/break_settings.dart';
import '../../../data/repositories/break_settings_repository.dart';
import '../../../data/repositories/caretaker_repository.dart';
import '../../../services/auth_service.dart';
import '../caretaker_ui.dart';

class BreakSettingsEditor extends StatefulWidget {
  const BreakSettingsEditor({
    super.key,
    required this.child,
    required this.repository,
  });
  final UserProfile child;
  final BreakSettingsRepository repository;
  @override
  State<BreakSettingsEditor> createState() => _BreakSettingsEditorState();
}

class _BreakSettingsEditorState extends State<BreakSettingsEditor> {
  final _threshold = TextEditingController();
  BreakSettings? _saved;
  bool _busy = true;
  bool _blocked = false;
  String? _error;
  int _previewCount = 0;
  bool get _dirty =>
      _saved != null && _threshold.text != '${_saved!.gamesBeforeBreak}';
  int? get _value => int.tryParse(_threshold.text);
  bool get _valid => _value != null && BreakSettings.validThreshold(_value!);

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _threshold.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final settings = await widget.repository.load(widget.child.id);
      if (!mounted) return;
      setState(() {
        _saved = settings;
        _threshold.text = '${settings.gamesBeforeBreak}';
        _blocked = false;
        _previewCount = 0;
      });
    } catch (error) {
      if (mounted) setState(() => _error = caretakerError(error));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<bool> _save() async {
    if (_busy || !_valid || _blocked || _saved?.editable != true) return false;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final saved = await widget.repository.save(
        widget.child.id,
        _value!,
        _saved!.revision,
      );
      if (!mounted) return false;
      setState(() {
        _saved = saved;
        _threshold.text = '${saved.gamesBeforeBreak}';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            ct(
              context,
              'Break threshold saved for ${widget.child.name}.',
              'บันทึกจำนวนเกมก่อนพักสำหรับ ${widget.child.name} แล้ว',
            ),
          ),
        ),
      );
      return true;
    } catch (error) {
      if (mounted) {
        setState(() {
          _error = caretakerError(error);
          // A timeout can also mean the write committed: reload before retrying.
          _blocked = error is! FormatException;
          if (error is PostgrestException && error.code == '22023') {
            _blocked = false;
          }
        });
      }
      return false;
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _back() async {
    if (_busy) return;
    if (!_dirty || await confirmLeave(context, _save)) {
      if (mounted) Navigator.pop(context);
    }
  }

  Future<void> _reload() async {
    if (_dirty && !await confirmLeave(context, _save)) return;
    if (mounted) await _load();
  }

  void _step(int amount) => setState(() {
    _threshold.text = '${((_value ?? 5) + amount).clamp(1, 20)}';
  });

  @override
  Widget build(BuildContext context) => CaretakerAccountGuard(
    child: PopScope(
      canPop: !_dirty && !_busy,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _back();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: _back,
            icon: const Icon(Icons.arrow_back),
          ),
          title: Text(
            ct(
              context,
              '${widget.child.name} · Break Protection',
              '${widget.child.name} · การพัก',
            ),
          ),
        ),
        body: CaretakerPageBody(
          children: [
            Text(
              ct(context, 'Games before a break', 'จำนวนเกมก่อนพัก'),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Text(
              ct(
                context,
                'This setting applies to Student play at the next game-entry or completion check. The break lasts 5 minutes.',
                'การตั้งค่านี้ใช้กับเด็กเมื่อตรวจสอบก่อนเข้าเกมหรือหลังจบเกมครั้งถัดไป โดยพักครั้งละ 5 นาที',
              ),
            ),
            const SizedBox(height: 24),
            if (_busy) const LinearProgressIndicator(),
            if (_error != null)
              CaretakerNotice(_error!, onRetry: _busy ? null : _reload),
            if (_saved != null && !_saved!.editable)
              Text(
                ct(
                  context,
                  'Update the app to edit these settings.',
                  'อัปเดตแอปเพื่อแก้ไขการตั้งค่านี้',
                ),
              ),
            if (_saved?.editable == true) ...[
              TextField(
                controller: _threshold,
                enabled: !_busy,
                keyboardType: TextInputType.number,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  labelText: ct(context, 'Games (1–20)', 'จำนวนเกม (1–20)'),
                  errorText: _valid
                      ? null
                      : ct(
                          context,
                          'Enter a whole number from 1 to 20.',
                          'กรอกจำนวนเต็มตั้งแต่ 1 ถึง 20',
                        ),
                  prefixIcon: IconButton(
                    onPressed: _busy || _value == 1 ? null : () => _step(-1),
                    tooltip: ct(context, 'Fewer games', 'ลดจำนวนเกม'),
                    icon: const Icon(Icons.remove),
                  ),
                  suffixIcon: IconButton(
                    onPressed: _busy || _value == 20 ? null : () => _step(1),
                    tooltip: ct(context, 'More games', 'เพิ่มจำนวนเกม'),
                    icon: const Icon(Icons.add),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: !_busy && _valid && !_blocked ? _save : null,
                icon: const Icon(Icons.save_outlined),
                label: Text(ct(context, 'Save threshold', 'บันทึกจำนวนเกม')),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: _busy
                    ? null
                    : () => setState(() => _threshold.text = '5'),
                child: Text(
                  ct(
                    context,
                    'Restore default (5 games)',
                    'คืนค่าเริ่มต้น (5 เกม)',
                  ),
                ),
              ),
              const Divider(height: 40),
              Text(
                ct(context, 'Test the threshold', 'ทดลองจำนวนเกมก่อนพัก'),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              Text(
                ct(
                  context,
                  'Simulated games: $_previewCount / ${_value ?? '—'}',
                  'จำนวนเกมจำลอง: $_previewCount / ${_value ?? '—'}',
                ),
              ),
              Text(
                _valid && _previewCount >= _value!
                    ? ct(context, 'A break would start now.', 'ถึงเวลาพักแล้ว')
                    : ct(
                        context,
                        'Ready to continue playing.',
                        'ยังเล่นต่อได้',
                      ),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: _busy || !_valid
                    ? null
                    : () => setState(() => _previewCount++),
                child: Text(
                  ct(
                    context,
                    'Simulate one completed game',
                    'จำลองการเล่นจบหนึ่งเกม',
                  ),
                ),
              ),
              TextButton(
                onPressed: _busy
                    ? null
                    : () => setState(() => _previewCount = 0),
                child: Text(ct(context, 'Reset test', 'เริ่มทดลองใหม่')),
              ),
            ],
          ],
        ),
      ),
    ),
  );
}
