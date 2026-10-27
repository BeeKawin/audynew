class ChildRewardData {
  const ChildRewardData({
    required this.id,
    required this.childId,
    required this.createdBy,
    required this.prize,
    required this.conditionType,
    required this.targetCount,
    required this.currentProgress,
    required this.isCompleted,
    required this.isClaimed,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String childId;
  final String createdBy;
  final String prize;
  final String conditionType;
  final int targetCount;
  final int currentProgress;
  final bool isCompleted;
  final bool isClaimed;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory ChildRewardData.fromJson(Map<String, dynamic> json) {
    return ChildRewardData(
      id: json['id'] as String,
      childId: json['child_id'] as String,
      createdBy: json['created_by'] as String,
      prize: json['prize'] as String,
      conditionType: json['condition_type'] as String,
      targetCount: json['target_count'] as int,
      currentProgress: json['current_progress'] as int? ?? 0,
      isCompleted: json['is_completed'] as bool? ?? false,
      isClaimed: json['is_claimed'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  ChildRewardData copyWith({
    int? currentProgress,
    bool? isCompleted,
    bool? isClaimed,
    DateTime? updatedAt,
  }) {
    return ChildRewardData(
      id: id,
      childId: childId,
      createdBy: createdBy,
      prize: prize,
      conditionType: conditionType,
      targetCount: targetCount,
      currentProgress: currentProgress ?? this.currentProgress,
      isCompleted: isCompleted ?? this.isCompleted,
      isClaimed: isClaimed ?? this.isClaimed,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  double get progressRatio {
    if (targetCount <= 0) return 0;
    return (currentProgress / targetCount).clamp(0, 1);
  }
}
