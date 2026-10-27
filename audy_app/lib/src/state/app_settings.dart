import 'package:shared_preferences/shared_preferences.dart';

/// Device preferences, independent of accounts and child learning preferences.
class AppSettings {
  const AppSettings({
    this.language = 'en',
    this.largerText = false,
    this.soundEffects = true,
    this.plainBackground = false,
  });

  final String language;
  final bool largerText;
  final bool soundEffects;
  final bool plainBackground;

  AppSettings copyWith({
    String? language,
    bool? largerText,
    bool? soundEffects,
    bool? plainBackground,
  }) => AppSettings(
    language: language ?? this.language,
    largerText: largerText ?? this.largerText,
    soundEffects: soundEffects ?? this.soundEffects,
    plainBackground: plainBackground ?? this.plainBackground,
  );

  static Future<AppSettings> load() async {
    final prefs = await SharedPreferences.getInstance();
    return AppSettings(
      language: prefs.getString('app.language') == 'th' ? 'th' : 'en',
      largerText: prefs.getBool('app.largerText') ?? false,
      soundEffects: prefs.getBool('app.soundEffects') ?? true,
      plainBackground: prefs.getBool('app.plainBackground') ?? false,
    );
  }

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = await Future.wait([
      prefs.setString('app.language', language),
      prefs.setBool('app.largerText', largerText),
      prefs.setBool('app.soundEffects', soundEffects),
      prefs.setBool('app.plainBackground', plainBackground),
    ]);
    if (saved.any((success) => !success)) {
      throw StateError('Settings not saved');
    }
  }
}
