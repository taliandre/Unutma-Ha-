import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:threshold/features/calendar/providers/calendar_provider.dart';

class TodayEventsWidget extends ConsumerWidget {
  const TodayEventsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncState = ref.watch(calendarProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Bugünkü Etkinlikler 📅',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: () => ref.read(calendarProvider.notifier).refresh(),
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Yenile'),
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        asyncState.when(
          loading: () => _shell(
            context,
            child: const Center(child: CircularProgressIndicator()),
          ),
          error: (err, _) => _errorCard(context, err.toString(), ref),
          data: (state) => switch (state) {
            CalendarLoading() => _shell(
                context,
                child: const Center(child: CircularProgressIndicator()),
              ),
            CalendarPermissionDenied() => _permissionCard(context, ref),
            CalendarError(:final message) => _errorCard(context, message, ref),
            CalendarLoaded(:final events) =>
              events.isEmpty ? _emptyCard(context) : _list(context, events),
          },
        ),
      ],
    );
  }

  Widget _shell(BuildContext context, {required Widget child}) => Container(
        height: 80,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(18),
        ),
        child: child,
      );

  Widget _list(BuildContext context, List<CalendarEvent> events) => Column(
        children: events.map((e) => _EventTile(event: e)).toList(),
      );

  Widget _emptyCard(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(Icons.event_available_rounded, color: cs.primary, size: 28),
          const SizedBox(width: 12),
          Text('Bugün için etkinlik yok 🎉',
              style: TextStyle(color: cs.onSurfaceVariant, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _permissionCard(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.errorContainer.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(Icons.calendar_today_rounded, color: cs.error, size: 24),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Takvim erişimi gerekli',
                    style: TextStyle(fontWeight: FontWeight.w700)),
                SizedBox(height: 4),
                Text('Etkinlikleri görmek için izin ver.',
                    style: TextStyle(fontSize: 12)),
              ],
            ),
          ),
          TextButton(
            onPressed: () => ref.read(calendarProvider.notifier).refresh(),
            child: const Text('İzin Ver'),
          ),
        ],
      ),
    );
  }

  Widget _errorCard(BuildContext context, String msg, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded,
              color: cs.onSurfaceVariant, size: 24),
          const SizedBox(width: 12),
          Expanded(
              child: Text(msg,
                  style:
                      TextStyle(color: cs.onSurfaceVariant, fontSize: 12))),
          TextButton(
            onPressed: () => ref.read(calendarProvider.notifier).refresh(),
            child: const Text('Tekrar'),
          ),
        ],
      ),
    );
  }
}

class _EventTile extends StatelessWidget {
  const _EventTile({required this.event});
  final CalendarEvent event;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final timeFmt = DateFormat('HH:mm');

    final timeStr = event.allDay
        ? 'Tüm Gün'
        : '${timeFmt.format(event.start)} – ${timeFmt.format(event.end)}';

    final color = event.calendarColor != null
        ? Color(event.calendarColor!)
        : cs.primary;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border(left: BorderSide(color: color, width: 4)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            SizedBox(
              width: 72,
              child: Text(
                timeStr,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (event.location != null && event.location!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(Icons.location_on_rounded,
                            size: 12, color: cs.onSurfaceVariant),
                        const SizedBox(width: 2),
                        Expanded(
                          child: Text(
                            event.location!,
                            style: TextStyle(
                                fontSize: 11, color: cs.onSurfaceVariant),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
