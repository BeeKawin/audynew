import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';
import '../../../social_chat/chat_service.dart';
import '../../caretaker_ui.dart';

class SocialPreview extends StatefulWidget {
  const SocialPreview({super.key, required this.values});
  final Map<String, dynamic> values;
  @override
  State<SocialPreview> createState() => _SocialPreviewState();
}

class _SocialPreviewState extends State<SocialPreview> {
  final _chat = ChatService();
  final _speech = SpeechToText();
  final _tts = FlutterTts();
  final _text = TextEditingController();
  final List<(bool, String)> _messages = [];
  bool _busy = false;
  bool _listening = false;
  String? _error;
  Future<void> _speak(String text) async {
    await _tts.setLanguage('th-TH');
    await _tts.speak(text);
  }

  Future<void> _listen() async {
    if (_listening) {
      await _speech.stop();
      if (mounted) setState(() => _listening = false);
      return;
    }
    try {
      final available = await _speech.initialize(
        onStatus: (s) {
          if (mounted && (s == 'done' || s == 'notListening')) {
            setState(() => _listening = false);
          }
        },
        onError: (_) {
          if (mounted) {
            setState(() {
              _listening = false;
              _error = ct(
                context,
                'Microphone unavailable. You can type instead.',
                'ใช้ไมโครโฟนไม่ได้ สามารถพิมพ์แทนได้',
              );
            });
          }
        },
      );
      if (!mounted) return;
      if (!available) {
        setState(
          () => _error = ct(
            context,
            'Microphone unavailable. You can type instead.',
            'ใช้ไมโครโฟนไม่ได้ สามารถพิมพ์แทนได้',
          ),
        );
        return;
      }
      setState(() => _listening = true);
      await _speech.listen(
        localeId: 'th_TH',
        listenFor: Duration(seconds: widget.values['listen_seconds'] as int),
        pauseFor: Duration(seconds: widget.values['pause_seconds'] as int),
        onResult: (r) {
          if (mounted) _text.text = r.recognizedWords;
        },
      );
    } catch (_) {
      if (mounted) {
        setState(
          () => _error = ct(
            context,
            'Please type your message instead.',
            'กรุณาพิมพ์ข้อความแทน',
          ),
        );
      }
    }
  }

  Future<void> _send() async {
    final text = _text.text.trim();
    if (text.isEmpty || text.length > 200) {
      setState(
        () => _error = ct(
          context,
          'Enter 1–200 characters.',
          'กรอกข้อความ 1–200 ตัวอักษร',
        ),
      );
      return;
    }
    await _speech.stop();
    if (!mounted) return;
    setState(() {
      _busy = true;
      _listening = false;
      _error = null;
      _messages.add((true, text));
      _text.clear();
    });
    try {
      final reply = await _chat
          .sendMessage(text)
          .timeout(const Duration(seconds: 30));
      if (!mounted) return;
      setState(() => _messages.add((false, reply.response)));
      if (widget.values['reply_speech'] == 'automatic') {
        await _speak(reply.response);
      }
    } catch (_) {
      if (mounted) {
        setState(
          () => _error = ct(
            context,
            'Could not get a reply. Type or send again to retry.',
            'รับคำตอบไม่ได้ ลองส่งข้อความอีกครั้ง',
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  void dispose() {
    if (_speech.isListening) _speech.cancel();
    _tts.stop();
    _text.dispose();
    _chat.clearSession();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Expanded(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            CaretakerNotice(
              ct(
                context,
                'Practice a Thai conversation. Messages stay in this preview.',
                'ทดลองสนทนาภาษาไทย ข้อความอยู่เฉพาะการทดลองนี้',
              ),
            ),
            for (final message in _messages)
              ListTile(
                title: Text(message.$2),
                leading: Icon(
                  message.$1 ? Icons.person : Icons.chat_bubble_outline,
                ),
                trailing: message.$1
                    ? null
                    : IconButton(
                        onPressed: () => _speak(message.$2),
                        tooltip: ct(context, 'Speak', 'อ่านออกเสียง'),
                        icon: const Icon(Icons.volume_up),
                      ),
              ),
            for (final phrase in widget.values['starter_phrases'] as List)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: OutlinedButton(
                  onPressed: () => _text.text = phrase as String,
                  child: Text(phrase),
                ),
              ),
            if (_error != null) CaretakerNotice(_error!),
          ],
        ),
      ),
      if (_busy) const LinearProgressIndicator(),
      Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _text,
              maxLength: 200,
              enabled: !_busy,
              decoration: InputDecoration(
                labelText: ct(context, 'Message in Thai', 'ข้อความภาษาไทย'),
                border: const OutlineInputBorder(),
              ),
            ),
            Row(
              children: [
                if (widget.values['input_mode'] == 'text_and_voice')
                  IconButton(
                    onPressed: _busy ? null : _listen,
                    tooltip: ct(context, 'Microphone', 'ไมโครโฟน'),
                    icon: Icon(_listening ? Icons.stop : Icons.mic),
                  ),
                Expanded(
                  child: FilledButton(
                    onPressed: _busy ? null : _send,
                    child: Text(ct(context, 'Send', 'ส่ง')),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ],
  );
}
