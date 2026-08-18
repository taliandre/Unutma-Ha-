import 'package:hive/hive.dart';

part 'history_entry.g.dart';

@HiveType(typeId: 0)
class HistoryEntry extends HiveObject {
  @HiveField(0)
  final DateTime timestamp;

  @HiveField(1)
  final String action; // 'done' | 'delay' | 'trigger'

  @HiveField(2)
  final String note;

  HistoryEntry({
    required this.timestamp,
    required this.action,
    required this.note,
  });
}
