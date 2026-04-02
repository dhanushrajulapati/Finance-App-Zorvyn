class GoalModel {
  final String id;
  final double targetAmount;
  final DateTime month;

  GoalModel({
    required this.id,
    required this.targetAmount,
    required this.month,
  });

  factory GoalModel.fromJson(Map<String, dynamic> json) {
    return GoalModel(
      id: json['id'] as String,
      targetAmount: (json['target_amount'] as num).toDouble(),
      month: DateTime.parse(json['month'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'target_amount': targetAmount,
      'month': month.toIso8601String(),
    };
  }
}
