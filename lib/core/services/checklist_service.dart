import 'package:hive_flutter/hive_flutter.dart';
import 'package:threshold/core/models/checklist_item.dart';

class ChecklistService {
  static const _boxName = 'checklist_box';
  static late Box<ChecklistItem> _box;

  static Future<void> init() async {
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(ChecklistItemAdapter());
    }
    _box = await Hive.openBox<ChecklistItem>(_boxName);

    // İlk kurulumda örnek maddeler ekle
    if (_box.isEmpty) {
      await _addDefaults();
    }
  }

  static Future<void> _addDefaults() async {
    final defaults = ['Anahtar', 'Cüzdan', 'Telefon', 'Şarj aleti', 'Kapı kilidi kontrolü'];
    for (final title in defaults) {
      await _box.add(ChecklistItem(title: title, createdAt: DateTime.now()));
    }
  }

  static List<ChecklistItem> getAll() {
    return _box.values.toList();
  }

  static Future<void> addItem(String title) async {
    await _box.add(
      ChecklistItem(title: title.trim(), createdAt: DateTime.now()),
    );
  }

  static Future<void> toggleItem(ChecklistItem item) async {
    item.isChecked = !item.isChecked;
    await item.save();
  }

  static Future<void> deleteItem(ChecklistItem item) async {
    await item.delete();
  }

  static Future<void> updateTitle(ChecklistItem item, String newTitle) async {
    item.title = newTitle.trim();
    await item.save();
  }

  static Future<void> uncheckAll() async {
    for (final item in _box.values) {
      if (item.isChecked) {
        item.isChecked = false;
        await item.save();
      }
    }
  }

  static int get checkedCount => _box.values.where((i) => i.isChecked).length;
  static int get totalCount => _box.length;
}
