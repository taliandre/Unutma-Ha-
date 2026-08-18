import 'package:threshold/domain/entities/checklist_item.dart';

class ChecklistItemModel extends ChecklistItem {
  ChecklistItemModel({
    required super.id,
    required super.title,
    required super.category,
    required super.iconCode,
    required super.isRequired,
    required super.createdAt,
  });

  factory ChecklistItemModel.fromJson(Map<String, dynamic> json) {
    return ChecklistItemModel(
      id: json['id'] as String,
      title: json['title'] as String,
      category: json['category'] as String,
      iconCode: json['iconCode'] as int,
      isRequired: json['isRequired'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'iconCode': iconCode,
      'isRequired': isRequired,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
