class TriggerEvent {
  TriggerEvent({
    required this.id,
    required this.triggerType,
    required this.value,
    required this.createdAt,
    required this.isConfirmed,
  });

  final String id;
  final String triggerType;
  final String value;
  final DateTime createdAt;
  final bool isConfirmed;

  TriggerEvent copyWith({
    String? id,
    String? triggerType,
    String? value,
    DateTime? createdAt,
    bool? isConfirmed,
  }) {
    return TriggerEvent(
      id: id ?? this.id,
      triggerType: triggerType ?? this.triggerType,
      value: value ?? this.value,
      createdAt: createdAt ?? this.createdAt,
      isConfirmed: isConfirmed ?? this.isConfirmed,
    );
  }
}
