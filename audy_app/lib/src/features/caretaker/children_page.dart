import 'package:flutter/material.dart';

import '../../data/repositories/caretaker_repository.dart';
import '../../state/caretaker_controller.dart';
import 'caretaker_ui.dart';

class ChildrenPage extends StatefulWidget {
  const ChildrenPage({super.key, required this.controller});
  final CaretakerController controller;
  @override
  State<ChildrenPage> createState() => ChildrenPageState();
}

class ChildrenPageState extends State<ChildrenPage> {
  final _count = TextEditingController();
  final _email = TextEditingController();
  Set<String> _ids = {};
  int? _revision;
  bool _busy = false;
  String? _error;
  CaretakerRoster? _baseline;
  bool get _dirty =>
      _baseline != null &&
      (_count.text != '${_baseline!.plannedCount}' ||
          _ids.length != _baseline!.children.where((c) => c.inCare).length ||
          _baseline!.children.any(
            (c) => c.inCare != _ids.contains(c.profile.id),
          ));
  @override
  void didUpdateWidget(covariant ChildrenPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    _initialize();
  }

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  void _initialize() {
    final roster = widget.controller.roster;
    if (roster == null || _baseline != null) return;
    _baseline = roster;
    _revision = roster.revision;
    _count.text = '${roster.plannedCount}';
    _ids = roster.children
        .where((c) => c.inCare)
        .map((c) => c.profile.id)
        .toSet();
  }

  @override
  void dispose() {
    _count.dispose();
    _email.dispose();
    super.dispose();
  }

  Future<bool> leave() async =>
      !_busy && (!_dirty || await confirmLeave(context, _save));
  Future<bool> _save() async {
    final count = int.tryParse(_count.text);
    if (count == null ||
        count < 0 ||
        count > 2147483647 ||
        count < _ids.length) {
      setState(
        () => _error = ct(
          context,
          'Choose a whole number at least ${_ids.length}.',
          'เลือกจำนวนเต็มอย่างน้อย ${_ids.length}',
        ),
      );
      return false;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await widget.controller.repository.save(count, _ids, _revision!);
      await widget.controller.load();
      if (!mounted) return false;
      _baseline = null;
      _initialize();
      setState(
        () => _error = ct(context, 'Care list saved.', 'บันทึกรายชื่อแล้ว'),
      );
      return true;
    } catch (e) {
      if (mounted) setState(() => _error = caretakerError(e));
      return false;
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _link() async {
    if (_dirty && !await leave()) return;
    if (!mounted) return;
    if (!_email.text.trim().contains('@')) {
      setState(
        () => _error = ct(
          context,
          'Enter the child account email.',
          'กรอกอีเมลบัญชีเด็ก',
        ),
      );
      return;
    }
    setState(() => _busy = true);
    try {
      await widget.controller.repository.link(_email.text);
      await widget.controller.load();
      if (!mounted) return;
      if (widget.controller.error != null) {
        setState(() => _error = widget.controller.error);
        return;
      }
      _baseline = null;
      _initialize();
      _email.clear();
      setState(
        () => _error = ct(
          context,
          'Account linked. Select this child and save your care list.',
          'เชื่อมบัญชีแล้ว เลือกเด็กและบันทึกรายชื่อ',
        ),
      );
    } catch (e) {
      if (mounted) setState(() => _error = caretakerError(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    _initialize();
    final c = widget.controller;
    return PopScope(
      canPop: !_dirty && !_busy,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop && await leave() && context.mounted) Navigator.pop(context);
      },
      child: CaretakerPageBody(
        children: [
          Text(
            ct(context, 'Children in my care', 'เด็กในความดูแล'),
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          if (c.loading) const LinearProgressIndicator(),
          if (c.error != null) CaretakerNotice(c.error!, onRetry: c.load),
          if (_baseline != null) ...[
            const SizedBox(height: 20),
            TextField(
              controller: _count,
              enabled: !_busy,
              keyboardType: TextInputType.number,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                prefixIcon: IconButton(
                  tooltip: ct(context, 'Fewer children', 'ลดจำนวนเด็ก'),
                  onPressed: _busy
                      ? null
                      : () => setState(() {
                          final value = int.tryParse(_count.text) ?? 0;
                          if (value > 0) _count.text = '${value - 1}';
                        }),
                  icon: const Icon(Icons.remove),
                ),
                suffixIcon: IconButton(
                  tooltip: ct(context, 'More children', 'เพิ่มจำนวนเด็ก'),
                  onPressed: _busy
                      ? null
                      : () => setState(() {
                          final value = int.tryParse(_count.text) ?? 0;
                          if (value < 2147483647) _count.text = '${value + 1}';
                        }),
                  icon: const Icon(Icons.add),
                ),
                helperMaxLines: 3,
                labelText: ct(
                  context,
                  'How many children will you care for?',
                  'คุณจะดูแลเด็กกี่คน?',
                ),
                helperText: ct(
                  context,
                  '${_ids.length} real profiles selected. Extra places do not create accounts.',
                  'เลือก ${_ids.length} บัญชี จำนวนที่เพิ่มไม่สร้างบัญชีใหม่',
                ),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            for (final child in c.roster!.children)
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(child.profile.name),
                subtitle: Text(
                  ct(
                    context,
                    'Age ${child.profile.age}',
                    'อายุ ${child.profile.age} ปี',
                  ),
                ),
                value: _ids.contains(child.profile.id),
                onChanged: _busy
                    ? null
                    : (selected) => setState(() {
                        if (selected == true) {
                          _ids.add(child.profile.id);
                        } else {
                          _ids.remove(child.profile.id);
                        }
                      }),
              ),
            if (c.roster!.children.isEmpty)
              Text(
                ct(
                  context,
                  'Link an existing Child account below.',
                  'เชื่อมบัญชีเด็กที่มีอยู่ด้านล่าง',
                ),
              ),
            if (_error != null) CaretakerNotice(_error!),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _busy ? null : _save,
              child: Text(ct(context, 'Save care list', 'บันทึกรายชื่อ')),
            ),
            TextButton(
              onPressed: _busy
                  ? null
                  : () async {
                      await c.load();
                      if (mounted) {
                        setState(() {
                          _baseline = null;
                          _initialize();
                        });
                      }
                    },
              child: Text(
                ct(
                  context,
                  'Reload saved care list',
                  'โหลดรายชื่อที่บันทึกใหม่',
                ),
              ),
            ),
            const Divider(height: 40),
            Text(
              ct(context, 'Link existing child', 'เชื่อมบัญชีเด็กที่มีอยู่'),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _email,
              enabled: !_busy,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: ct(context, 'Child account email', 'อีเมลบัญชีเด็ก'),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _busy ? null : _link,
              icon: const Icon(Icons.link),
              label: Text(ct(context, 'Link account', 'เชื่อมบัญชี')),
            ),
          ],
        ],
      ),
    );
  }
}
