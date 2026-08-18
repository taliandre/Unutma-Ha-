import 'package:hive/hive.dart';

part 'checklist_item.g.dart';

@HiveType(typeId: 1)
class ChecklistItem extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  bool isChecked;

  @HiveField(2)
  final DateTime createdAt;

  ChecklistItem({
    required this.title,
    this.isChecked = false,
    required this.createdAt,
  });
}
