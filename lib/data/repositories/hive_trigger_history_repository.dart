import 'package:hive/hive.dart';
import 'package:threshold/data/models/trigger_event_model.dart';
import 'package:threshold/domain/entities/trigger_event.dart';
import 'package:threshold/domain/repositories/trigger_history_repository.dart';

class HiveTriggerHistoryRepository implements TriggerHistoryRepository {
  HiveTriggerHistoryRepository(this._box);

  final Box<dynamic> _box;

  static const _key = 'trigger_history';

  @override
  Future<List<TriggerEvent>> getAll() async {
    final raw = _box.get(_key, defaultValue: const <Map<String, dynamic>>[]);
    final list = raw as List<dynamic>? ?? const <dynamic>[];
    return list
        .map(
          (e) =>
              TriggerEventModel.fromJson(Map<String, dynamic>.from(e as Map)),
        )
        .toList();
  }

  @override
  Future<void> add(TriggerEvent event) async {
    final events = await getAll();
    final payload = [
      ...events,
      TriggerEventModel(
        id: event.id,
        triggerType: event.triggerType,
        value: event.value,
        createdAt: event.createdAt,
        isConfirmed: event.isConfirmed,
      ),
    ];

    await _box.put(
      _key,
      payload
          .map(
            (item) => TriggerEventModel(
              id: item.id,
              triggerType: item.triggerType,
              value: item.value,
              createdAt: item.createdAt,
              isConfirmed: item.isConfirmed,
            ).toJson(),
          )
          .toList(),
    );
  }

  @override
  Future<void> markConfirmed(String id) async {
    final events = await getAll();
    final updated = events
        .map(
          (event) => event.id == id ? event.copyWith(isConfirmed: true) : event,
        )
        .toList();

    await _box.put(
      _key,
      updated
          .map(
            (event) => TriggerEventModel(
              id: event.id,
              triggerType: event.triggerType,
              value: event.value,
              createdAt: event.createdAt,
              isConfirmed: event.isConfirmed,
            ).toJson(),
          )
          .toList(),
    );
  }
}
