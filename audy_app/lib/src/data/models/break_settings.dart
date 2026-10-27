class BreakSettings {
  const BreakSettings({
    this.gamesBeforeBreak = 5,
    this.revision = 0,
    this.schemaVersion = 1,
  });
  final int gamesBeforeBreak;
  final int revision;
  final int schemaVersion;
  bool get editable => schemaVersion == 1;
  static bool validThreshold(int value) => value >= 1 && value <= 20;

  factory BreakSettings.fromJson(Map<String, dynamic> json) {
    final threshold = json['games_before_break'];
    if (threshold is! int || !validThreshold(threshold)) {
      throw const FormatException('Invalid break threshold');
    }
    return BreakSettings(
      gamesBeforeBreak: threshold,
      revision: json['revision'] as int? ?? 0,
      schemaVersion: json['schema_version'] as int? ?? 1,
    );
  }
}
