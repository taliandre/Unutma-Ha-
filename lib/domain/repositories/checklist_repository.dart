import 'package:threshold/domain/entities/checklist_item.dart';

abstract class ChecklistRepository {
  Future<List<ChecklistItem>> getAll();
  Future<void> save(List<ChecklistItem> items);
  Future<void> add(ChecklistItem item);
  Future<void> update(ChecklistItem item);
  Future<void> remove(String id);
}
