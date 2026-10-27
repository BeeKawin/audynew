class ChildProgressSnapshot {
  const ChildProgressSnapshot({
    this.stats,
    this.sessions = const [],
    this.assignments = const [],
  });
  final Map<String, dynamic>? stats;
  final List<Map<String, dynamic>> sessions;
  final List<Map<String, dynamic>> assignments;

  factory ChildProgressSnapshot.fromJson(Map<String, dynamic> json) =>
      ChildProgressSnapshot(
        stats: json['stats'] == null
            ? null
            : Map<String, dynamic>.from(json['stats'] as Map),
        sessions: (json['sessions'] as List)
            .map((row) => Map<String, dynamic>.from(row as Map))
            .toList(),
        assignments: (json['assignments'] as List)
            .map((row) => Map<String, dynamic>.from(row as Map))
            .toList(),
      );
}
