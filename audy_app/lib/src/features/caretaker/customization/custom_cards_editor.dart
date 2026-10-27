import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/audy_theme.dart';
import '../../../data/repositories/caretaker_repository.dart';
import '../../../state/audy_controller.dart';
import '../caretaker_ui.dart';

String? normalizeCardImage(Uint8List bytes) {
  final decoded = img.decodeImage(bytes);
  if (decoded == null) return null;
  final oriented = img.bakeOrientation(decoded);
  final resized = img.copyResize(
    oriented,
    width: oriented.width >= oriented.height ? min(400, oriented.width) : null,
    height: oriented.height > oriented.width ? min(400, oriented.height) : null,
  );
  final data = img.encodeJpg(resized, quality: 70);
  if (data.length > 131072) return null;
  return 'data:image/jpeg;base64,${base64Encode(data)}';
}

class CustomCardsEditor extends StatefulWidget {
  const CustomCardsEditor({
    super.key,
    required this.cards,
    required this.onChanged,
    required this.onPendingChanged,
  });
  final List<dynamic> cards;
  final ValueChanged<List<dynamic>> onChanged;
  final ValueChanged<bool> onPendingChanged;
  @override
  State<CustomCardsEditor> createState() => _CustomCardsEditorState();
}

class _CustomCardsEditorState extends State<CustomCardsEditor> {
  final _word = TextEditingController();
  String _category = 'noun';
  String? _image;
  String? _editingId;
  String? _message;
  bool _error = false;
  bool _busy = false;

  static const _types = [
    ('pronoun', 'Pronouns', 'สรรพนาม', AudyColors.skyBlue),
    ('noun', 'Noun', 'คำนาม', AudyColors.mintGreen),
    ('verb', 'Actions', 'การกระทำ', Colors.orange),
    ('adjective', 'Feeling', 'ความรู้สึก', AudyColors.blushPink),
    ('adverb', 'Adverbs', 'คำวิเศษณ์', AudyColors.softLavender),
  ];

  void _pending() => widget.onPendingChanged(
    _word.text.isNotEmpty ||
        _image != null ||
        _category != 'noun' ||
        _editingId != null ||
        _busy,
  );

  @override
  void dispose() {
    _word.dispose();
    super.dispose();
  }

  void _clear() {
    _word.clear();
    _category = 'noun';
    _image = null;
    _editingId = null;
  }

  Future<void> _edit(Map<String, dynamic> card) async {
    final pending =
        _word.text.isNotEmpty ||
        _image != null ||
        _category != 'noun' ||
        _editingId != null;
    if (pending) {
      final discard = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            ct(
              context,
              'Replace unfinished card?',
              'แทนที่บัตรที่ยังไม่เสร็จหรือไม่?',
            ),
          ),
          content: Text(
            ct(
              context,
              'The text and picture in the form have not been added.',
              'ข้อความและรูปในแบบฟอร์มยังไม่ได้เพิ่มลงในคลัง',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(ct(context, 'Keep editing', 'แก้ไขต่อ')),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(ct(context, 'Replace', 'แทนที่')),
            ),
          ],
        ),
      );
      if (discard != true || !mounted) return;
    }
    setState(() {
      _word.text = card['word'] as String;
      _category = card['category'] as String? ?? 'noun';
      _image = card['image_url'] as String?;
      _editingId = card['id'] as String?;
      _message = null;
    });
    _pending();
    if (mounted) {
      await Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 200),
      );
    }
  }

  Future<void> _pickImage() async {
    setState(() => _busy = true);
    _pending();
    try {
      final file = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 400,
        maxHeight: 400,
        imageQuality: 70,
      );
      if (file == null) return;
      final image = await compute(normalizeCardImage, await file.readAsBytes());
      if (!mounted) return;
      setState(() {
        if (image != null) _image = image;
        _error = image == null;
        _message = image == null
            ? ct(
                context,
                'Could not use this picture. Choose a smaller JPEG or PNG.',
                'ใช้รูปนี้ไม่ได้ กรุณาเลือกรูป JPEG หรือ PNG ที่เล็กลง',
              )
            : null;
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          _error = true;
          _message = ct(
            context,
            'Could not open the picture. Please try again.',
            'เปิดรูปไม่ได้ กรุณาลองอีกครั้ง',
          );
        });
      }
    } finally {
      if (mounted) {
        setState(() => _busy = false);
        _pending();
      }
    }
  }

  void _addCard() {
    final word = _word.text.trim();
    String? error;
    if (word.isEmpty || word.length > 40) {
      error = ct(
        context,
        'Please enter a word (1–40 characters).',
        'กรุณากรอกคำ 1–40 ตัวอักษร',
      );
    } else if (widget.cards.any(
      (card) =>
          card['id'] != _editingId &&
          card['category'] == _category &&
          card['word'].toString().trim().toLowerCase() == word.toLowerCase(),
    )) {
      error = ct(
        context,
        'This word and word type are already in the library.',
        'มีคำและประเภทคำนี้ในคลังแล้ว',
      );
    } else if (_editingId == null && widget.cards.length >= 20) {
      error = ct(
        context,
        'Use up to 20 custom cards for each child.',
        'ใช้บัตรคำได้สูงสุด 20 ใบต่อเด็กหนึ่งคน',
      );
    }
    if (error != null) {
      setState(() {
        _error = true;
        _message = error;
      });
      return;
    }
    final card = {
      'id':
          _editingId ??
          List.generate(
            16,
            (_) =>
                Random.secure().nextInt(256).toRadixString(16).padLeft(2, '0'),
          ).join(),
      'word': word,
      'category': _category,
      'image_url': _image,
    };
    final updated = List<dynamic>.from(widget.cards);
    final index = updated.indexWhere((card) => card['id'] == _editingId);
    if (index < 0) {
      updated.add(card);
    } else {
      updated[index] = card;
    }
    widget.onChanged(updated);
    setState(() {
      _clear();
      _error = false;
      _message = ct(
        context,
        'Added "$word" to this draft. Use Save settings to keep it.',
        'เพิ่ม "$word" ในฉบับแก้ไขแล้ว กดบันทึกการตั้งค่าเพื่อจัดเก็บ',
      );
    });
    _pending();
  }

  Future<void> _import() async {
    final ownerId = AudyScope.of(context).currentUser?.id;
    setState(() => _busy = true);
    _pending();
    try {
      final words = await CaretakerRepository(
        Supabase.instance.client,
      ).legacyWords();
      if (!mounted || AudyScope.of(context).currentUser?.id != ownerId) return;
      final index = await showDialog<int>(
        context: context,
        builder: (context) => SimpleDialog(
          title: Text(ct(context, 'Import a legacy card', 'นำเข้าบัตรเดิม')),
          children: [
            if (words.isEmpty)
              Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  ct(context, 'No legacy cards found.', 'ไม่พบบัตรเดิม'),
                ),
              ),
            for (var i = 0; i < words.length; i++)
              SimpleDialogOption(
                onPressed: () => Navigator.pop(context, i),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    '${words[i].word} · ${words[i].category ?? 'noun'}',
                  ),
                ),
              ),
          ],
        ),
      );
      if (index != null &&
          mounted &&
          AudyScope.of(context).currentUser?.id == ownerId) {
        final word = words[index];
        await _edit({
          'word': word.word,
          'category': word.category ?? 'noun',
          'image_url': word.imageUrl,
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _error = true;
          _message = caretakerError(error);
        });
      }
    } finally {
      if (mounted) {
        setState(() => _busy = false);
        _pending();
      }
    }
  }

  InputDecoration _decoration(String label, IconData icon, {String? hint}) =>
      InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: AudyColors.backgroundSoft.withValues(alpha: .1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AudySpacing.radiusMedium),
        ),
      );

  Widget _library() => LayoutBuilder(
    builder: (context, constraints) => Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        for (final entry in widget.cards)
          _cardChip(
            Map<String, dynamic>.from(entry as Map),
            constraints.maxWidth,
          ),
      ],
    ),
  );

  Widget _cardChip(Map<String, dynamic> card, double width) {
    final type = _types.firstWhere((type) => type.$1 == card['category']);
    return InputChip(
      avatar: card['image_url'] == null
          ? null
          : ClipOval(
              child: CardPicture(card['image_url'] as String?, size: 24),
            ),
      label: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: 48,
          maxWidth: max(48, min(260, width - 112)),
        ),
        child: Wrap(
          spacing: 6,
          runSpacing: 4,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              card['word'] as String,
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: type.$4,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                ct(context, type.$2, type.$3),
                style: const TextStyle(
                  color: AudyColors.textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
      tooltip: ct(context, 'Edit card', 'แก้ไขบัตร'),
      materialTapTargetSize: MaterialTapTargetSize.padded,
      avatarBoxConstraints: const BoxConstraints.tightFor(
        width: 24,
        height: 24,
      ),
      deleteIconBoxConstraints: const BoxConstraints.tightFor(
        width: 48,
        height: 48,
      ),
      onPressed: _busy ? null : () => _edit(card),
      onDeleted: _busy
          ? null
          : () {
              widget.onChanged(
                List<dynamic>.from(widget.cards)
                  ..removeWhere((entry) => entry['id'] == card['id']),
              );
              if (_editingId == card['id']) {
                setState(_clear);
                _pending();
              }
            },
      deleteButtonTooltipMessage: ct(context, 'Remove card', 'ลบบัตร'),
      backgroundColor: AudyColors.backgroundSoft.withValues(alpha: .15),
      side: const BorderSide(color: AudyColors.borderLight, width: 1.2),
    );
  }

  @override
  Widget build(BuildContext context) => Card(
    color: Colors.white,
    surfaceTintColor: Colors.transparent,
    elevation: 4,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AudySpacing.radiusLarge),
    ),
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            ct(
              context,
              'Flashcard Custom Cards',
              'บัตรคำ Flashcard ที่ปรับแต่ง',
            ),
            style: AudyTypography.headingSmall.copyWith(fontSize: 18),
          ),
          const SizedBox(height: 6),
          Text(
            ct(
              context,
              'Add custom cards with a word, its type, and an image for this child’s Flashcard sentence preview.',
              'เพิ่มคำ ประเภทคำ และรูปภาพสำหรับทดลองเกมเรียงประโยคของเด็กคนนี้',
            ),
            style: const TextStyle(
              fontSize: 13,
              color: AudyColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            key: const ValueKey('legacy-card-word'),
            controller: _word,
            maxLength: 40,
            decoration: _decoration(
              ct(context, 'Word / Text', 'คำ / ข้อความ'),
              Icons.label_outline_rounded,
              hint: ct(
                context,
                'Enter card text (e.g. Sleep)',
                'กรอกคำบนบัตร เช่น นอน',
              ),
            ),
            onChanged: (_) => _pending(),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            key: ValueKey('legacy-type-$_category'),
            initialValue: _category,
            isExpanded: true,
            decoration: _decoration(
              ct(context, 'Word Type', 'ประเภทคำ'),
              Icons.category_outlined,
            ),
            items: [
              for (final type in _types)
                DropdownMenuItem(
                  value: type.$1,
                  child: Text(ct(context, type.$2, type.$3)),
                ),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() => _category = value);
                _pending();
              }
            },
          ),
          if (['adjective', 'adverb'].contains(_category))
            CaretakerNotice(
              ct(
                context,
                'Stored in the word bank. The current sentence generator does not select this type yet.',
                'บันทึกในคลังคำได้ แต่ตัวสร้างประโยคปัจจุบันยังไม่เลือกประเภทนี้',
              ),
            ),
          if (_category == 'verb')
            CaretakerNotice(
              ct(
                context,
                'The existing generator pairs actions with food objects. Test the sentence before saving.',
                'ตัวสร้างประโยคเดิมจับคู่การกระทำกับอาหาร ควรทดลองก่อนบันทึก',
              ),
            ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: _busy ? null : _pickImage,
                icon: const Icon(Icons.image_outlined),
                label: Text(ct(context, 'Add Card Image', 'เพิ่มรูปบัตร')),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AudyColors.backgroundSoft,
                  foregroundColor: AudyColors.textPrimary,
                  minimumSize: const Size(140, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      AudySpacing.radiusMedium,
                    ),
                  ),
                ),
              ),
              if (_image != null) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CardPicture(_image, size: 48),
                ),
                IconButton(
                  onPressed: _busy
                      ? null
                      : () {
                          setState(() => _image = null);
                          _pending();
                        },
                  tooltip: ct(context, 'Remove picture', 'ลบรูป'),
                  constraints: const BoxConstraints(
                    minWidth: 48,
                    minHeight: 48,
                  ),
                  icon: const Icon(
                    Icons.delete_outline,
                    color: AudyColors.error,
                  ),
                ),
              ],
            ],
          ),
          if (_busy) const LinearProgressIndicator(),
          if (_message != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: (_error ? AudyColors.error : AudyColors.success)
                      .withValues(alpha: .1),
                  borderRadius: BorderRadius.circular(AudySpacing.radiusMedium),
                  border: Border.all(
                    color: (_error ? AudyColors.error : AudyColors.success)
                        .withValues(alpha: .3),
                  ),
                ),
                child: Text(
                  _message!,
                  style: TextStyle(
                    color: _error ? AudyColors.error : AudyColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed:
                _busy || (widget.cards.length >= 20 && _editingId == null)
                ? null
                : _addCard,
            style: ElevatedButton.styleFrom(
              backgroundColor: AudyColors.skyBlue,
              foregroundColor: AudyColors.textOnColor,
              minimumSize: const Size(48, 56),
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AudySpacing.radiusMedium),
              ),
            ),
            child: Text(
              _editingId == null
                  ? ct(
                      context,
                      'Add Custom Flashcard Card',
                      'เพิ่มบัตรคำ Flashcard',
                    )
                  : ct(
                      context,
                      'Update Flashcard Card',
                      'อัปเดตบัตรคำ Flashcard',
                    ),
              textAlign: TextAlign.center,
            ),
          ),
          TextButton(
            onPressed: _busy
                ? null
                : () {
                    setState(() {
                      _clear();
                      _message = null;
                    });
                    _pending();
                  },
            child: Text(ct(context, 'Clear card form', 'ล้างแบบฟอร์มบัตร')),
          ),
          if (widget.cards.isNotEmpty) ...[
            const Divider(color: AudyColors.borderLight, height: 32),
            Text(
              ct(context, 'Custom Flashcards Added:', 'บัตรคำที่เพิ่มแล้ว:'),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: AudyColors.textSecondary,
              ),
            ),
            const SizedBox(height: 10),
            _library(),
          ],
          if (AudyScope.of(context).currentUser?.role == 'teacher')
            TextButton.icon(
              onPressed: _busy || widget.cards.length >= 20 ? null : _import,
              icon: const Icon(Icons.download),
              label: Text(
                ct(
                  context,
                  'Import from my legacy word bank',
                  'นำเข้าจากคลังบัตรคำเดิม',
                ),
              ),
            ),
        ],
      ),
    ),
  );
}

class CardPicture extends StatelessWidget {
  const CardPicture(this.source, {super.key, this.size = 100});
  final String? source;
  final double size;
  @override
  Widget build(BuildContext context) {
    Widget fallback() => Icon(Icons.style_outlined, size: size / 2);
    final value = source;
    if (value == null || value.isEmpty) {
      return SizedBox(width: size, height: size, child: fallback());
    }
    if (value.startsWith('emoji:')) {
      return SizedBox(
        width: size,
        height: size,
        child: Center(
          child: Text(
            value.substring(6),
            style: TextStyle(fontSize: size * .5),
          ),
        ),
      );
    }
    if (value.startsWith('data:image/')) {
      try {
        return Image.memory(
          base64Decode(value.split(',').last),
          width: size,
          height: size,
          cacheWidth: 400,
          fit: BoxFit.contain,
          errorBuilder: (_, e, s) => fallback(),
        );
      } catch (_) {
        return fallback();
      }
    }
    if (value.startsWith('assets/')) {
      return Image.asset(
        value,
        width: size,
        height: size,
        fit: BoxFit.contain,
        errorBuilder: (_, e, s) => fallback(),
      );
    }
    return fallback();
  }
}
