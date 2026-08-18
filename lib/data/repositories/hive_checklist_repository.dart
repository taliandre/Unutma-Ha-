import 'package:hive/hive.dart';
import 'package:threshold/data/models/checklist_item_model.dart';
import 'package:threshold/domain/entities/checklist_item.dart';
import 'package:threshold/domain/repositories/checklist_repository.dart';

class HiveChecklistRepository implements ChecklistRepository {
  HiveChecklistRepository(this._box);

  final Box<dynamic> _box;

  static const _key = 'checklist_items';

  @override
  Future<List<ChecklistItem>> getAll() async {
    final raw = _box.get(_key, defaultValue: <Map<String, dynamic>>[]);
    final list = raw as List<dynamic>? ?? const <dynamic>[];

    return list
        .map(
          (e) =>
              ChecklistItemModel.fromJson(Map<String, dynamic>.from(e as Map)),
        )
        .toList();
  }

  @override
  Future<void> save(List<ChecklistItem> items) async {
    final payload = items
        .map(
          (item) => ChecklistItemModel(
            id: item.id,
            title: item.title,
            category: item.category,
            iconCode: item.iconCode,
            isRequired: item.isRequired,
            createdAt: item.createdAt,
          ).toJson(),
        )
        .toList();

    await _box.put(_key, payload);
  }

  @override
  Future<void> add(ChecklistItem item) async {
    final items = await getAll();
    await save([...items, item]);
  }

  @override
  Future<void> update(ChecklistItem item) async {
    final items = await getAll();
    final updated = items
        .map((existing) => existing.id == item.id ? item : existing)
        .toList();
    await save(updated);
  }

  @override
  Future<void> remove(String id) async {
    final items = await getAll();
    await save(items.where((item) => item.id != id).toList());
  }
}
