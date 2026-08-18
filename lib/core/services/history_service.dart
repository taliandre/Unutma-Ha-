import 'package:hive_flutter/hive_flutter.dart';
import 'package:threshold/core/models/history_entry.dart';

class HistoryService {
  static const _boxName = 'history_box';
  static late Box<HistoryEntry> _box;

  static Future<void> init() async {
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(HistoryEntryAdapter());
    }
    _box = await Hive.openBox<HistoryEntry>(_boxName);
  }

  static Future<void> addEntry({
    required String action,
    required String note,
  }) async {
    await _box.add(
      HistoryEntry(
        timestamp: DateTime.now(),
        action: action,
        note: note,
      ),
    );
  }

  /// En yeni kayıtlar önce gelsin
  static List<HistoryEntry> getAll() {
    final entries = _box.values.toList();
    entries.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return entries;
  }

  static Future<void> clearAll() async {
    await _box.clear();
  }
}
