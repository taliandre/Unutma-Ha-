import 'package:threshold/domain/entities/trigger_event.dart';

abstract class TriggerHistoryRepository {
  Future<List<TriggerEvent>> getAll();
  Future<void> add(TriggerEvent event);
  Future<void> markConfirmed(String id);
}
