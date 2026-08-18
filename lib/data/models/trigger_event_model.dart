import 'package:threshold/domain/entities/trigger_event.dart';

class TriggerEventModel extends TriggerEvent {
  TriggerEventModel({
    required super.id,
    required super.triggerType,
    required super.value,
    required super.createdAt,
    required super.isConfirmed,
  });

  factory TriggerEventModel.fromJson(Map<String, dynamic> json) {
    return TriggerEventModel(
      id: json['id'] as String,
      triggerType: json['triggerType'] as String,
      value: json['value'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      isConfirmed: json['isConfirmed'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'triggerType': triggerType,
      'value': value,
      'createdAt': createdAt.toIso8601String(),
      'isConfirmed': isConfirmed,
    };
  }
}
