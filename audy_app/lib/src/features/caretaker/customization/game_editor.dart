import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../data/models/game_configuration.dart';
import '../../../data/repositories/caretaker_repository.dart';
import '../../../services/auth_service.dart';
import '../../../state/audy_controller.dart';
import '../caretaker_ui.dart';
import 'configuration_form.dart';
import 'custom_cards_editor.dart';
import 'game_preview.dart';

class GameEditor extends StatefulWidget {
  const GameEditor({
    super.key,
    required this.child,
    required this.game,
    required this.repository,
  });
  final UserProfile child;
  final CaretakerGame game;
  final GameConfigurationRepository repository;
  @override
  State<GameEditor> createState() => _GameEditorState();
}

class _GameEditorState extends State<GameEditor> {
  SavedGameConfiguration? _saved;
  Map<String, dynamic>? _draft;
  String? _error;
  bool _busy = false;
  bool _uncertain = false;
  bool _conflict = false;
  int _formRevision = 0;
  int _cardsRevision = 0;
  bool _pendingCard = false;
  String? _ownerId;
  bool _started = false;
  bool get _sessionActive =>
      mounted && AudyScope.of(context).currentUser?.id == _ownerId;
  bool get _dirty =>
      _pendingCard ||
      (_draft != null &&
          jsonEncode(_draft) != jsonEncode(_saved!.config.toJson()));
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_started) {
      _started = true;
      _ownerId = AudyScope.of(context).currentUser?.id;
      _load();
    }
  }

  Future<void> _load() async {
    setState(() => _busy = true);
    try {
      final saved = await widget.repository.load(widget.child.id, widget.game);
      if (_sessionActive) {
        setState(() {
          _saved = saved;
          _draft = saved.config.toJson();
          _error = saved.editable
              ? null
              : ct(
                  context,
                  'Update the app to edit these settings.',
                  'อัปเดตแอปเพื่อแก้ไขการตั้งค่านี้',
                );
          _uncertain = false;
          _conflict = false;
          _formRevision++;
          _cardsRevision++;
          _pendingCard = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _error = caretakerError(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<bool> _save() async {
    if (!_cardReady()) return false;
    final config = GameConfiguration(widget.game, _draft!);
    final errors = config.validate();
    if (errors.isNotEmpty) {
      setState(() => _error = errors.join('\n'));
      return false;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final saved = await widget.repository.save(
        widget.child.id,
        config,
        _saved!.revision,
      );
      if (!mounted || !_sessionActive) return false;
      setState(() {
        _saved = saved;
        _draft = saved.config.toJson();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            ct(
              context,
              'Saved for ${widget.child.name}. Student gameplay is unchanged.',
              'บันทึกสำหรับ ${widget.child.name} แล้ว เกมของเด็กยังใช้ค่าเดิม',
            ),
          ),
        ),
      );
      return true;
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = caretakerError(e);
          _conflict =
              e.toString().contains('40001') ||
              e.toString().contains('revision');
          _uncertain = !_conflict;
        });
      }
      return false;
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  bool _cardReady() {
    if (!_pendingCard) return true;
    setState(
      () => _error = ct(
        context,
        'Add or update your unfinished card, or clear the card form, before saving or previewing.',
        'กรุณาเพิ่มหรืออัปเดตบัตรที่ยังไม่เสร็จ หรือล้างแบบฟอร์ม ก่อนบันทึกหรือทดลอง',
      ),
    );
    return false;
  }

  Future<void> _back() async {
    if (_busy) return;
    if (!_dirty ||
        await confirmLeave(
          context,
          () => _uncertain || _conflict ? Future.value(false) : _save(),
        )) {
      if (mounted) Navigator.pop(context);
    }
  }

  void _change(String field, dynamic value) => setState(() {
    _draft![field] = field == 'duration_seconds' && value == -1 ? null : value;
    _error = null;
  });
  Future<void> _reload() async {
    if (_dirty &&
        !await confirmLeave(
          context,
          () => _uncertain || _conflict ? Future.value(false) : _save(),
        )) {
      return;
    }
    if (mounted) await _load();
  }

  @override
  Widget build(BuildContext context) {
    final editable = _saved?.editable == true;
    return CaretakerAccountGuard(
      child: PopScope(
        canPop: !_dirty && !_busy,
        onPopInvokedWithResult: (p, r) {
          if (!p) _back();
        },
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              onPressed: _back,
              icon: const Icon(Icons.arrow_back),
              tooltip: ct(context, 'Back', 'กลับ'),
            ),
            title: Text('${widget.child.name} · ${widget.game.title}'),
          ),
          body: CaretakerPageBody(
            children: [
              CaretakerNotice(
                ct(
                  context,
                  'Caretaker preview settings. Student games keep their current behavior.',
                  'ตั้งค่าสำหรับการทดลองของผู้ดูแล เกมของเด็กยังใช้พฤติกรรมเดิม',
                ),
              ),
              if (_busy) const LinearProgressIndicator(),
              if (_error != null)
                CaretakerNotice(_error!, onRetry: _busy ? null : _reload),
              if (_draft != null && editable)
                IgnorePointer(
                  ignoring: _busy || !editable,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (widget.game == CaretakerGame.flashcard) ...[
                        CustomCardsEditor(
                          key: ValueKey('${widget.child.id}-$_cardsRevision'),
                          cards: _draft!['custom_cards'] as List,
                          onChanged: (cards) => _change('custom_cards', cards),
                          onPendingChanged: (pending) => setState(() {
                            _pendingCard = pending;
                            _error = null;
                          }),
                        ),
                        const SizedBox(height: 24),
                      ],
                      ConfigurationForm(
                        key: ValueKey(_formRevision),
                        game: widget.game,
                        values: {
                          ..._draft!,
                          if (widget.game == CaretakerGame.fruitCatch &&
                              _draft!['duration_seconds'] == null)
                            'duration_seconds': -1,
                        },
                        onChanged: _change,
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 24),
              if (editable) ...[
                FilledButton.icon(
                  onPressed: _busy || _uncertain || _conflict ? null : _save,
                  icon: const Icon(Icons.save_outlined),
                  label: Text(ct(context, 'Save settings', 'บันทึกการตั้งค่า')),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: _busy
                      ? null
                      : () {
                          if (!_cardReady()) return;
                          final config = GameConfiguration(
                            widget.game,
                            _draft!,
                          );
                          final errors = config.validate();
                          if (errors.isNotEmpty) {
                            setState(() => _error = errors.join('\n'));
                            return;
                          }
                          Navigator.push(
                            context,
                            MaterialPageRoute<void>(
                              builder: (_) => GamePreview(
                                config: config,
                                childName: widget.child.name,
                              ),
                            ),
                          );
                        },
                  icon: const Icon(Icons.play_arrow),
                  label: Text(ct(context, 'Preview draft', 'ทดลองการตั้งค่า')),
                ),
                TextButton(
                  onPressed: _busy
                      ? null
                      : () => setState(() {
                          final cards = _draft!['custom_cards'];
                          _draft = GameConfiguration.defaults(
                            widget.game,
                          ).toJson();
                          if (cards != null) _draft!['custom_cards'] = cards;
                          _formRevision++;
                        }),
                  child: Text(
                    ct(context, 'Restore defaults', 'คืนค่าเริ่มต้น'),
                  ),
                ),
                if (_conflict || _uncertain)
                  TextButton(
                    onPressed: _busy
                        ? null
                        : () async {
                            // Reload first after an uncertain write; never replay a possibly committed save.
                            final keep = Map<String, dynamic>.from(_draft!);
                            await _load();
                            if (mounted && _saved != null && !_busy) {
                              setState(() => _draft = keep);
                            }
                          },
                    child: Text(
                      ct(
                        context,
                        'Reload saved revision and keep my draft',
                        'โหลดรุ่นล่าสุดและเก็บฉบับแก้ไขของฉัน',
                      ),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
