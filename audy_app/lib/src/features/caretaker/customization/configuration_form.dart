import 'package:flutter/material.dart';
import '../../../data/models/game_configuration.dart';
import '../caretaker_ui.dart';

class ConfigurationForm extends StatelessWidget {
  const ConfigurationForm({
    super.key,
    required this.game,
    required this.values,
    required this.onChanged,
  });
  final CaretakerGame game;
  final Map<String, dynamic> values;
  final void Function(String, dynamic) onChanged;
  Widget _select(
    BuildContext context,
    String field,
    String en,
    String th,
    List<dynamic> options, {
    List<String>? labels,
    bool enabled = true,
  }) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 12),
    child: DropdownButtonFormField<dynamic>(
      key: ValueKey('$field-${values[field]}'),
      initialValue: values[field],
      isExpanded: true,
      decoration: InputDecoration(
        labelText: ct(context, en, th),
        border: const OutlineInputBorder(),
      ),
      items: [
        for (var i = 0; i < options.length; i++)
          DropdownMenuItem(
            value: options[i],
            child: Text(labels?[i] ?? _label(context, options[i])),
          ),
      ],
      onChanged: enabled ? (value) => onChanged(field, value) : null,
    ),
  );
  String _label(BuildContext c, dynamic value) {
    const labels = {
      'child_choice': ['Child chooses', 'เด็กเลือกเอง'],
      'easy': ['Easy', 'ง่าย'],
      'medium': ['Medium', 'ปานกลาง'],
      'hard': ['Hard', 'ยาก'],
      'app': ['App language', 'ภาษาของแอป'],
      'manual': ['Manual / Next', 'กดถัดไปเอง'],
      'automatic': ['Automatic', 'อัตโนมัติ'],
      'on_tap': ['On tap', 'เมื่อกด'],
      'text_and_voice': ['Text and voice', 'ข้อความและเสียง'],
      'text_only': ['Text only', 'ข้อความเท่านั้น'],
      'varied': ['Varied', 'เปลี่ยนรูป'],
      'consistent': ['Consistent', 'ใช้รูปเดิม'],
      'slow': ['Slow', 'ช้า'],
      'standard': ['Standard', 'ปกติ'],
      'fast': ['Fast', 'เร็ว'],
      '2_seconds': ['2 seconds', '2 วินาที'],
      '3_seconds': ['3 seconds', '3 วินาที'],
      '5_seconds': ['5 seconds', '5 วินาที'],
      'automatic_900ms': ['Automatic · 0.9 seconds', 'อัตโนมัติ · 0.9 วินาที'],
      'automatic_1800ms': ['Automatic · 1.8 seconds', 'อัตโนมัติ · 1.8 วินาที'],
      'automatic_1500ms': ['Automatic · 1.5 seconds', 'อัตโนมัติ · 1.5 วินาที'],
      'automatic_3000ms': ['Automatic · 3 seconds', 'อัตโนมัติ · 3 วินาที'],
    };
    final pair = labels[value];
    return pair == null ? '$value' : ct(c, pair[0], pair[1]);
  }

  Widget _flag(BuildContext c, String field, String en, String th) =>
      SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(ct(c, en, th)),
        value: values[field] as bool,
        onChanged: (v) => onChanged(field, v),
      );
  Widget _checks(
    BuildContext c,
    String field,
    String en,
    String th,
    Map<String, String> options,
  ) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(ct(c, en, th), style: Theme.of(c).textTheme.titleMedium),
      for (final entry in options.entries)
        CheckboxListTile(
          secondary: field == 'fruit_ids'
              ? Image.asset(
                  'assets/images/games/basket/fruits/${entry.key}.png',
                  width: 48,
                  height: 48,
                )
              : null,
          contentPadding: EdgeInsets.zero,
          title: Text(entry.value),
          value: (values[field] as List).contains(entry.key),
          onChanged: (yes) {
            final list = List<String>.from(values[field] as List);
            if (yes == true) {
              list.add(entry.key);
            } else {
              list.remove(entry.key);
            }
            onChanged(field, list);
          },
        ),
    ],
  );
  @override
  Widget build(BuildContext context) {
    const levels = ['child_choice', 'easy', 'medium', 'hard'];
    final fields = <Widget>[];
    switch (game) {
      case CaretakerGame.socialChat:
        fields.addAll([
          _select(context, 'input_mode', 'Input method', 'วิธีป้อนข้อความ', [
            'text_and_voice',
            'text_only',
          ]),
          _select(context, 'reply_speech', 'Speak replies', 'อ่านคำตอบ', [
            'automatic',
            'on_tap',
          ]),
          _select(
            context,
            'listen_seconds',
            'Listening duration (seconds)',
            'เวลาฟัง (วินาที)',
            [15, 30, 45],
            enabled: values['input_mode'] == 'text_and_voice',
          ),
          _select(
            context,
            'pause_seconds',
            'Silence allowance (seconds)',
            'เวลาหยุดพูด (วินาที)',
            [3, 5, 8],
            enabled: values['input_mode'] == 'text_and_voice',
          ),
          TextFormField(
            key: const ValueKey('starter_phrases'),
            initialValue: (values['starter_phrases'] as List).join('\n'),
            minLines: 3,
            maxLines: 6,
            decoration: InputDecoration(
              labelText: ct(
                context,
                'Conversation starters · one per line',
                'ข้อความเริ่มสนทนา · หนึ่งข้อความต่อบรรทัด',
              ),
              helperText: ct(
                context,
                'Up to 6 phrases, 80 characters each',
                'สูงสุด 6 ข้อความ ข้อละ 80 ตัวอักษร',
              ),
              border: const OutlineInputBorder(),
            ),
            onChanged: (text) => onChanged(
              'starter_phrases',
              text
                  .split('\n')
                  .map((p) => p.trim())
                  .where((p) => p.isNotEmpty)
                  .toList(),
            ),
          ),
        ]);
      case CaretakerGame.flashcard:
        fields.addAll([
          _select(context, 'difficulty', 'Difficulty', 'ระดับความยาก', levels),
          _select(context, 'language', 'Content language', 'ภาษาเนื้อหา', [
            'app',
            'en',
            'th',
          ]),
          _select(
            context,
            'preview_pace',
            'Card preview pace',
            'จังหวะการแสดงบัตร',
            ['2_seconds', '3_seconds', '5_seconds', 'manual'],
          ),
          _flag(context, 'auto_speak', 'Automatic narration', 'อ่านอัตโนมัติ'),
          _flag(
            context,
            'use_custom_cards',
            'Use this child’s custom cards',
            'ใช้บัตรที่ปรับแต่งสำหรับเด็กคนนี้',
          ),
        ]);
      case CaretakerGame.miniPuzzle:
        fields.add(
          _checks(context, 'enabled_types', 'Activities', 'กิจกรรม', {
            'pattern': ct(context, 'Pattern', 'แบบรูป'),
            'oddOneOut': ct(context, 'Odd One Out', 'หาสิ่งที่แตกต่าง'),
            'puzzle': ct(context, 'Visual Match', 'จับคู่ภาพ'),
          }),
        );
        fields.addAll([
          _select(
            context,
            'pattern_difficulty',
            'Pattern difficulty',
            'ระดับแบบรูป',
            levels,
          ),
          _select(
            context,
            'odd_one_out_difficulty',
            'Odd One Out difficulty',
            'ระดับหาสิ่งที่แตกต่าง',
            levels,
          ),
          _select(
            context,
            'puzzle_difficulty',
            'Visual Match difficulty',
            'ระดับจับคู่ภาพ',
            levels,
          ),
          _select(
            context,
            'advance_mode',
            'Successful-round advancement',
            'การไปต่อเมื่อตอบถูก',
            ['automatic_900ms', 'automatic_1800ms', 'manual'],
          ),
          _flag(context, 'show_guide', 'Show instructions', 'แสดงคำแนะนำ'),
        ]);
      case CaretakerGame.emotion:
        fields.addAll([
          _checks(
            context,
            'target_emotions',
            'Emotions to practice',
            'อารมณ์ที่ฝึก',
            {
              'happy': ct(context, 'Happy', 'ดีใจ'),
              'sad': ct(context, 'Sad', 'เศร้า'),
              'angry': ct(context, 'Angry', 'โกรธ'),
              'scared': ct(context, 'Scared', 'กลัว'),
            },
          ),
          _select(
            context,
            'choice_count',
            'Choices per question',
            'ตัวเลือกต่อคำถาม',
            [2, 4],
          ),
          _select(context, 'round_count', 'Combined rounds', 'จำนวนรอบ', [
            1,
            3,
            5,
          ]),
          _select(
            context,
            'image_mode',
            'Face-image variety',
            'ความหลากหลายของรูป',
            ['varied', 'consistent'],
          ),
          _select(
            context,
            'advance_mode',
            'Feedback advancement',
            'จังหวะการไปต่อ',
            ['automatic_1500ms', 'automatic_3000ms', 'manual'],
          ),
          _flag(context, 'show_guide', 'Show instructions', 'แสดงคำแนะนำ'),
        ]);
      case CaretakerGame.fruitCatch:
        fields.addAll([
          _select(context, 'fall_speed', 'Falling speed', 'ความเร็วผลไม้', [
            'slow',
            'standard',
            'fast',
          ]),
          _select(
            context,
            'spawn_interval_ms',
            'Spawn interval (milliseconds)',
            'ระยะห่างการปล่อย (มิลลิวินาที)',
            [900, 1200, 1500],
          ),
          _select(
            context,
            'bomb_probability',
            'Bomb frequency',
            'ความถี่ระเบิด',
            [0, 0.1, 0.2],
            labels: [
              ct(context, 'None', 'ไม่มี'),
              ct(context, 'Fewer · 10%', 'น้อย · 10%'),
              ct(context, 'Standard · 20%', 'ปกติ · 20%'),
            ],
          ),
          _select(
            context,
            'bomb_grace_count',
            'Fruits before bombs',
            'จำนวนผลไม้ก่อนเริ่มระเบิด',
            [2, 5, 10],
            enabled: values['bomb_probability'] != 0,
          ),
          _select(
            context,
            'duration_seconds',
            'Session duration',
            'เวลาเล่น',
            [-1, 30, 60, 120],
            labels: [
              ct(context, 'No limit', 'ไม่จำกัด'),
              '30 s',
              '60 s',
              '120 s',
            ],
          ),
          _checks(context, 'fruit_ids', 'Fruit pictures', 'รูปผลไม้', {
            for (final id in ['4', '5', '6', '7', '8', '9'])
              id: ct(context, 'Fruit $id', 'ผลไม้ $id'),
          }),
          _flag(context, 'show_guide', 'Show instructions', 'แสดงคำแนะนำ'),
        ]);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: fields,
    );
  }
}
