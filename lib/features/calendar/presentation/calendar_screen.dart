import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:threshold/features/calendar/providers/calendar_provider.dart';

/// Takvim yönetim ekranı — bugünkü etkinlikleri görüntüle + yeni etkinlik ekle
class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  static const _gunler = [
    'Pazartesi', 'Salı', 'Çarşamba', 'Perşembe',
    'Cuma', 'Cumartesi', 'Pazar'
  ];
  static const _aylar = [
    '', 'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
    'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'
  ];

  String _formatDate(DateTime dt) {
    final gun = _gunler[dt.weekday - 1];
    final ay = _aylar[dt.month];
    return '${dt.day} $ay ${dt.year}, $gun';
  }

  @override
  Widget build(BuildContext context) {
    final asyncState = ref.watch(calendarProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final today = _formatDate(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Takvim'),
        actions: [
          IconButton(
            onPressed: () => ref.read(calendarProvider.notifier).refresh(),
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Yenile',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEventSheet(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Etkinlik Ekle'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Tarih başlığı ──────────────────────────────────────────────────
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [colorScheme.primary, colorScheme.secondary],
              ),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Bugün',
                    style:
                        TextStyle(color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 4),
                Text(today,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                asyncState.when(
                  loading: () => const Text('Etkinlikler yükleniyor...',
                      style: TextStyle(color: Colors.white60, fontSize: 12)),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (state) {
                    if (state is CalendarLoaded) {
                      final count = state.events.length;
                      return Text(
                        count == 0
                            ? 'Bugün etkinlik yok'
                            : '$count etkinlik var',
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 13),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),

          // ── Etkinlik listesi ───────────────────────────────────────────────
          Expanded(
            child: asyncState.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (err, _) => _centerMessage(
                context,
                icon: Icons.error_outline_rounded,
                message: err.toString(),
              ),
              data: (state) => switch (state) {
                CalendarLoading() =>
                  const Center(child: CircularProgressIndicator()),
                CalendarPermissionDenied() =>
                  _permissionView(context),
                CalendarError(:final message) =>
                  _centerMessage(context,
                      icon: Icons.error_outline_rounded,
                      message: message),
                CalendarLoaded(:final events) => events.isEmpty
                    ? _centerMessage(context,
                        icon: Icons.event_available_rounded,
                        message: 'Bugün etkinlik yok.\nEklemek için + düğmesine bas.')
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: events.length,
                        itemBuilder: (context, i) =>
                            _EventCard(event: events[i]),
                      ),
              },
            ),
          ),
        ],
      ),
    );
  }

  // ── Etkinlik ekleme bottom sheet ─────────────────────────────────────────────

  void _showAddEventSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _AddEventSheet(),
    );
  }

  // ── İzin ekranı ──────────────────────────────────────────────────────────────

  Widget _permissionView(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_today_rounded,
                size: 64, color: cs.onSurfaceVariant),
            const SizedBox(height: 16),
            const Text('Takvime erişim izni gerekli',
                style:
                    TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(
              'Etkinliklerinizi görüntülemek için\ntakvim iznini verin.',
              textAlign: TextAlign.center,
              style: TextStyle(color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () =>
                  ref.read(calendarProvider.notifier).refresh(),
              icon: const Icon(Icons.lock_open_rounded),
              label: const Text('İzin Ver'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _centerMessage(BuildContext context,
      {required IconData icon, required String message}) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 56, color: cs.onSurfaceVariant),
            const SizedBox(height: 16),
            Text(message,
                textAlign: TextAlign.center,
                style: TextStyle(color: cs.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}

// ── Etkinlik Kartı ────────────────────────────────────────────────────────────

class _EventCard extends ConsumerWidget {
  const _EventCard({required this.event});
  final CalendarEvent event;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final timeFmt = DateFormat('HH:mm');

    final color = event.calendarColor != null
        ? Color(event.calendarColor!)
        : cs.primary;

    final timeStr = event.allDay
        ? 'Tüm Gün'
        : '${timeFmt.format(event.start)} – ${timeFmt.format(event.end)}';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(18),
        border: Border(left: BorderSide(color: color, width: 4)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Saat sütunu
            SizedBox(
              width: 68,
              child: Text(
                timeStr,
                style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w800,
                    fontSize: 12),
              ),
            ),
            const SizedBox(width: 12),
            // İçerik
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(event.title,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 15),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                  if (event.location != null &&
                      event.location!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.location_on_rounded,
                            size: 13, color: cs.onSurfaceVariant),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(event.location!,
                              style: TextStyle(
                                  fontSize: 12,
                                  color: cs.onSurfaceVariant),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            // Silme butonu (Eğer _ID varsa)
            if (event.id != 0)
              IconButton(
                icon: Icon(Icons.delete_outline_rounded,
                    color: cs.error.withValues(alpha: 0.8)),
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Etkinliği Sil'),
                      content: Text('"${event.title}" silinecek. Onaylıyor musunuz?'),
                      actions: [
                        TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('İptal')),
                        FilledButton(
                            onPressed: () => Navigator.pop(context, true),
                            style: FilledButton.styleFrom(
                                backgroundColor: cs.error),
                            child: const Text('Sil')),
                      ],
                    ),
                  );

                  if (confirm == true) {
                    await ref
                        .read(calendarProvider.notifier)
                        .deleteEvent(event.id);
                  }
                },
              ),
          ],
        ),
      ),
    );
  }
}

// ── Etkinlik Ekleme Sheet ─────────────────────────────────────────────────────

class _AddEventSheet extends ConsumerStatefulWidget {
  const _AddEventSheet();

  @override
  ConsumerState<_AddEventSheet> createState() => _AddEventSheetState();
}

class _AddEventSheetState extends ConsumerState<_AddEventSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();

  bool _allDay = false;
  bool _isSaving = false;

  TimeOfDay _startTime = TimeOfDay.now();
  TimeOfDay _endTime = TimeOfDay(
    hour: (TimeOfDay.now().hour + 1) % 24,
    minute: TimeOfDay.now().minute,
  );

  @override
  void dispose() {
    _titleCtrl.dispose();
    _locationCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickTime(bool isStart) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _startTime : _endTime,
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      // Android takvime native ekle
      final now = DateTime.now();
      final start = _allDay
          ? DateTime(now.year, now.month, now.day)
          : DateTime(now.year, now.month, now.day,
              _startTime.hour, _startTime.minute);
      final end = _allDay
          ? DateTime(now.year, now.month, now.day, 23, 59)
          : DateTime(now.year, now.month, now.day,
              _endTime.hour, _endTime.minute);

      await ref.read(calendarProvider.notifier).addEvent(
            title: _titleCtrl.text.trim(),
            location: _locationCtrl.text.trim(),
            startMs: start.millisecondsSinceEpoch,
            endMs: end.millisecondsSinceEpoch,
            allDay: _allDay,
          );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Etkinlik eklendi!'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottomInset),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: cs.onSurfaceVariant.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Yeni Etkinlik',
                style:
                    TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
            const SizedBox(height: 16),

            // Başlık
            TextFormField(
              controller: _titleCtrl,
              decoration: const InputDecoration(
                labelText: 'Etkinlik adı *',
                prefixIcon: Icon(Icons.event_rounded),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(14))),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Boş bırakılamaz' : null,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 12),

            // Konum
            TextFormField(
              controller: _locationCtrl,
              decoration: const InputDecoration(
                labelText: 'Konum (isteğe bağlı)',
                prefixIcon: Icon(Icons.location_on_rounded),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(14))),
              ),
              textInputAction: TextInputAction.done,
            ),
            const SizedBox(height: 12),

            // Tüm gün toggle
            SwitchListTile(
              value: _allDay,
              onChanged: (v) => setState(() => _allDay = v),
              title: const Text('Tüm Gün'),
              contentPadding: EdgeInsets.zero,
            ),

            // Saat seçimi
            if (!_allDay) ...[
              Row(
                children: [
                  Expanded(
                    child: _TimePicker(
                      label: 'Başlangıç',
                      time: _startTime,
                      onTap: () => _pickTime(true),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _TimePicker(
                      label: 'Bitiş',
                      time: _endTime,
                      onTap: () => _pickTime(false),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],

            // Kaydet
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _isSaving ? null : _save,
                icon: _isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.check_rounded),
                label: Text(_isSaving ? 'Kaydediliyor...' : 'Kaydet'),
                style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimePicker extends StatelessWidget {
  const _TimePicker(
      {required this.label, required this.time, required this.onTap});
  final String label;
  final TimeOfDay time;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: cs.outline),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(Icons.access_time_rounded, size: 18, color: cs.primary),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                        fontSize: 11, color: cs.onSurfaceVariant)),
                Text(time.format(context),
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 15)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
