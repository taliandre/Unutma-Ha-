import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ─── Model ────────────────────────────────────────────────────────────────────

class CalendarEvent {
  const CalendarEvent({
    required this.id,
    required this.title,
    required this.startMs,
    required this.endMs,
    required this.allDay,
    this.location,
    this.calendarColor,
  });

  final int id;        // Android Calendar event _ID — silmek için gerekli
  final String title;
  final int startMs;
  final int endMs;
  final bool allDay;
  final String? location;
  final int? calendarColor;

  DateTime get start => DateTime.fromMillisecondsSinceEpoch(startMs);
  DateTime get end => DateTime.fromMillisecondsSinceEpoch(endMs);

  factory CalendarEvent.fromMap(Map m) => CalendarEvent(
        id: (m['id'] as int?) ?? 0,
        title: m['title'] as String? ?? '(İsimsiz)',
        startMs: (m['startMs'] as int?) ?? 0,
        endMs: (m['endMs'] as int?) ?? 0,
        allDay: (m['allDay'] as bool?) ?? false,
        location: m['location'] as String?,
        calendarColor: m['calendarColor'] as int?,
      );
}

// ─── State ────────────────────────────────────────────────────────────────────

sealed class CalendarState {}
class CalendarLoading extends CalendarState {}
class CalendarLoaded extends CalendarState {
  CalendarLoaded(this.events);
  final List<CalendarEvent> events;
}
class CalendarPermissionDenied extends CalendarState {}
class CalendarError extends CalendarState {
  CalendarError(this.message);
  final String message;
}

// ─── Provider ─────────────────────────────────────────────────────────────────

final calendarProvider =
    AsyncNotifierProvider<CalendarNotifier, CalendarState>(
  CalendarNotifier.new,
);

class CalendarNotifier extends AsyncNotifier<CalendarState> {
  static const _channel = MethodChannel('com.example.threshold/calendar');

  @override
  Future<CalendarState> build() => _fetch();

  Future<CalendarState> _fetch() async {
    try {
      final result = await _channel.invokeMethod<dynamic>('getTodayEvents');

      if (result == null) return CalendarLoaded([]);

      // result: List<Map> 
      final raw = List<Map>.from(result as List);
      final events = raw
          .map((m) => CalendarEvent.fromMap(m))
          .toList()
        ..sort((a, b) => a.startMs.compareTo(b.startMs));

      return CalendarLoaded(events);
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        return CalendarPermissionDenied();
      }
      return CalendarError(e.message ?? 'Takvim okunamadı.');
    } catch (e) {
      return CalendarError('Takvim hatası: $e');
    }
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = AsyncData(await _fetch());
  }

  Future<void> addEvent({
    required String title,
    required String location,
    required int startMs,
    required int endMs,
    required bool allDay,
  }) async {
    await _channel.invokeMethod('addEvent', {
      'title': title,
      'location': location,
      'startMs': startMs,
      'endMs': endMs,
      'allDay': allDay,
    });
    state = const AsyncLoading();
    state = AsyncData(await _fetch());
  }

  Future<void> deleteEvent(int eventId) async {
    await _channel.invokeMethod('deleteEvent', {'id': eventId});
    state = const AsyncLoading();
    state = AsyncData(await _fetch());
  }
}
