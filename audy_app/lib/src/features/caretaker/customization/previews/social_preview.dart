import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';
import '../../../../services/speech_service.dart';
import '../../../../state/audy_controller.dart';
import '../../../social_chat/chat_models.dart';
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
  final _messagesByLanguage = <ChatLanguage, List<(bool, String)>>{};
  final _pending = <ChatLanguage>{};
  ChatLanguage? _language;
  int _revision = 0;
  int _micRevision = 0;
  bool _startingMic = false;
  bool _listening = false;
  VoidCallback? _detachMicHandlers;
  String? _error;

  List<(bool, String)> get _messages =>
      _messagesByLanguage.putIfAbsent(_language!, () => []);
  bool get _busy => _pending.contains(_language);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final language = AudyScope.of(context).socialLanguage;
    if (_language == language) return;
    _revision++;
    _language = language;
    _error = null;
    _cancelMic();
    unawaited(_stopVoice());
  }

  void _cancelMic() {
    _micRevision++;
    _detachMicHandlers?.call();
    _detachMicHandlers = null;
    if (_listening || _startingMic) {
      _listening = false;
      unawaited(_speech.cancel().catchError((Object _) {}));
    }
  }

  Future<void> _stopVoice() async {
    try {
      await _tts.stop();
    } catch (_) {
      // The device may not offer speech playback.
    }
  }

  Future<void> _speak(String text) async {
    final revision = _revision;
    try {
      await _tts.setLanguage(_language!.voiceLocale);
      if (mounted && revision == _revision) await _tts.speak(text);
    } catch (_) {
      // The preview still shows the written reply.
    }
  }

  Future<void> _listen() async {
    if (_startingMic) return;
    if (_listening) {
      await _speech.stop();
      if (mounted) setState(() => _listening = false);
      return;
    }

    final language = _language!;
    final revision = _revision;
    final micRevision = ++_micRevision;
    bool isCurrent() =>
        mounted && revision == _revision && micRevision == _micRevision;
    void showError() {
      if (!isCurrent()) return;
      setState(() {
        _listening = false;
        _error = AudyScope.of(context).tr('chat_voice_unavailable');
      });
    }

    _startingMic = true;
    try {
      final available = await _speech.initialize();
      if (!isCurrent()) return;
      if (!available) {
        showError();
        return;
      }
      final locales = await _speech.locales();
      if (!isCurrent()) return;

      _detachMicHandlers?.call();
      _detachMicHandlers = attachChatRecognitionHandlers(
        _speech,
        onStatus: (status) {
          if (isCurrent() &&
              _listening &&
              (status == 'done' || status == 'notListening')) {
            setState(() => _listening = false);
          }
        },
        onError: (_) => showError(),
      );
      setState(() {
        _listening = true;
        _error = null;
      });
      await _speech.listen(
        localeId: language.recognitionLocale(
          locales.map((locale) => locale.localeId),
        ),
        listenFor: Duration(seconds: widget.values['listen_seconds'] as int),
        pauseFor: Duration(seconds: widget.values['pause_seconds'] as int),
        onResult: (result) {
          if (isCurrent()) _text.text = result.recognizedWords;
        },
      );
      if (!isCurrent()) await _speech.cancel();
    } catch (_) {
      showError();
    } finally {
      _startingMic = false;
    }
  }

  Future<void> _send() async {
    if (_busy) return;
    final text = _text.text.trim();
    if (text.isEmpty || text.length > 200) {
      final controller = AudyScope.of(context);
      setState(() {
        _error = controller.tr(text.isEmpty ? 'chat_empty' : 'chat_too_long');
      });
      return;
    }
    final language = _language!;
    final revision = _revision;
    final messages = _messages;
    _cancelMic();
    setState(() {
      _pending.add(language);
      _error = null;
      messages.add((true, text));
      _text.clear();
    });
    try {
      final reply = await _chat.sendMessage(text, language: language);
      if (!mounted) return;
      setState(() => messages.add((false, reply.response)));
      if (revision == _revision &&
          widget.values['reply_speech'] == 'automatic') {
        await _speak(reply.response);
      }
    } catch (_) {
      if (mounted && revision == _revision) {
        final controller = AudyScope.of(context);
        setState(() => _error = controller.tr('chat_offline_reply'));
      }
    } finally {
      if (mounted) setState(() => _pending.remove(language));
    }
  }

  @override
  void dispose() {
    _cancelMic();
    unawaited(_stopVoice());
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
                'Practice an English conversation. Messages stay in this preview.',
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
                labelText: ct(context, 'Message in English', 'ข้อความภาษาไทย'),
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
