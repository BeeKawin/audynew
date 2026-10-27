import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/break_settings.dart';

class BreakSettingsRepository {
  BreakSettingsRepository(this.client);
  final SupabaseClient client;

  Future<BreakSettings> load(String childId) async {
    final row = await client
        .from('child_break_settings')
        .select()
        .eq('child_id', childId)
        .maybeSingle();
    return row == null ? const BreakSettings() : BreakSettings.fromJson(row);
  }

  Future<BreakSettings> loadForStudent() async => BreakSettings.fromJson(
    Map<String, dynamic>.from(await client.rpc('student_break_settings')),
  );

  Future<BreakSettings> save(
    String childId,
    int threshold,
    int revision,
  ) async {
    if (!BreakSettings.validThreshold(threshold)) {
      throw const FormatException('Use 1 to 20 games');
    }
    return BreakSettings.fromJson(
      Map<String, dynamic>.from(
        await client.rpc(
          'caretaker_save_break_settings',
          params: {
            'target_child': childId,
            'game_threshold': threshold,
            'expected_revision': revision,
          },
        ),
      ),
    );
  }
}
