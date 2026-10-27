import 'package:flutter/material.dart';

import '../../core/audy_ui.dart';
import '../../state/audy_controller.dart';
import '../../state/app_settings.dart';
import '../caretaker/caretaker_ui.dart';

class AppSettingsPage extends StatefulWidget {
  const AppSettingsPage({super.key, this.legacyTools});
  final Widget? legacyTools;

  @override
  State<AppSettingsPage> createState() => _AppSettingsPageState();
}

class _AppSettingsPageState extends State<AppSettingsPage> {
  bool _saving = false;
  String? _error;

  Future<void> _save(AppSettings value) async {
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await AudyScope.of(context).saveAppSettings(value);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              ct(
                context,
                'Settings saved on this device.',
                'บันทึกการตั้งค่าในอุปกรณ์นี้แล้ว',
              ),
            ),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        setState(
          () => _error = ct(
            context,
            'Could not save settings. Please try again.',
            'บันทึกไม่สำเร็จ กรุณาลองอีกครั้ง',
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = AudyScope.of(context).appSettings;
    return AudyControls(
      child: Scaffold(
        appBar: AppBar(
          title: Text(ct(context, 'App Settings', 'การตั้งค่าแอป')),
        ),
        body: AudyResponsivePage(
          builder: (context, adaptive) => AudyPanel(
            adaptive: adaptive,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  ct(
                    context,
                    'Applies to this device in both modes.',
                    'ใช้กับทั้งสองโหมดในอุปกรณ์นี้',
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  key: ValueKey(settings.language),
                  initialValue: settings.language,
                  decoration: InputDecoration(
                    labelText: ct(context, 'Language', 'ภาษา'),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'en', child: Text('English')),
                    DropdownMenuItem(value: 'th', child: Text('ไทย')),
                  ],
                  onChanged: _saving
                      ? null
                      : (value) => _save(settings.copyWith(language: value)),
                ),
                SwitchListTile(
                  title: Text(ct(context, 'Larger text', 'ตัวอักษรขนาดใหญ่')),
                  subtitle: Text(
                    ct(
                      context,
                      'Respects your device text size.',
                      'ปรับเพิ่มจากขนาดตัวอักษรของอุปกรณ์',
                    ),
                  ),
                  value: settings.largerText,
                  onChanged: _saving
                      ? null
                      : (value) => _save(settings.copyWith(largerText: value)),
                ),
                SwitchListTile(
                  title: Text(
                    ct(context, 'App sound effects', 'เสียงเอฟเฟกต์แอป'),
                  ),
                  subtitle: Text(
                    ct(
                      context,
                      'Game narration and speech have separate controls.',
                      'เสียงอ่านและเสียงพูดในเกมมีการตั้งค่าแยกกัน',
                    ),
                  ),
                  value: settings.soundEffects,
                  onChanged: _saving
                      ? null
                      : (value) =>
                            _save(settings.copyWith(soundEffects: value)),
                ),
                SwitchListTile(
                  title: Text(ct(context, 'Plain background', 'พื้นหลังเรียบ')),
                  subtitle: Text(
                    ct(
                      context,
                      'Hide the decorative app background.',
                      'ซ่อนภาพพื้นหลังของแอป',
                    ),
                  ),
                  value: settings.plainBackground,
                  onChanged: _saving
                      ? null
                      : (value) =>
                            _save(settings.copyWith(plainBackground: value)),
                ),
                if (_saving) const LinearProgressIndicator(),
                if (_error != null) CaretakerNotice(_error!),
                if (widget.legacyTools != null) ...[
                  const Divider(height: 32),
                  widget.legacyTools!,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
