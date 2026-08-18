import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:threshold/core/models/checklist_item.dart';
import 'package:threshold/core/services/checklist_service.dart';
import 'package:threshold/core/services/local_storage_service.dart';
import 'package:threshold/core/services/safe_zone_service.dart';
import 'package:threshold/core/theme/theme_notifier.dart';
import 'package:threshold/core/theme/themed_header_card.dart';
import 'package:threshold/features/calendar/presentation/today_events_widget.dart';
import 'package:threshold/features/weather/presentation/weather_card.dart';

// ... (Diğer importlar aynı kalacak) ...

// SATIR 64: Widget build(BuildContext context) içerisindeki değişiklikler

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen>
    with WidgetsBindingObserver {
  List<ChecklistItem> _items = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadItems();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Uygulama foreground'a döndüğünde (başka ekrandan geri gelince) yenile
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadItems();
    }
  }

  void _loadItems() {
    setState(() {
      _items = ChecklistService.getAll();
    });
  }

  Future<void> _toggle(ChecklistItem item) async {
    await ChecklistService.toggleItem(item);
    _loadItems();
  }

  Future<void> _uncheckAll() async {
    await ChecklistService.uncheckAll();
    _loadItems();
  }

  int get _checkedCount => _items.where((i) => i.isChecked).length;
  int get _totalCount => _items.length;
  double get _progress =>
      _totalCount == 0 ? 0 : _checkedCount / _totalCount;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final safeZoneEnabled = SafeZoneService.isEnabled;
    
    // Geçerli temayı bul
    final currentPaletteId = LocalStorageService.prefs.getString('selected_palette') ?? 'rose';
    final currentPalette = AppColorPalette.fromId(currentPaletteId);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Unutma Ha! 🔑'),
        actions: [
          IconButton(
            onPressed: () => context.push('/theme'),
            icon: const Icon(Icons.palette_outlined),
            tooltip: 'Tema',
          ),
          IconButton(
            onPressed: () => context.push('/settings'),
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Ayarlar',
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => _loadItems(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Durum banner ────────────────────────────────────────────
                ThemedHeaderCard(
                  palette: currentPalette,
                  title: _checkedCount == _totalCount && _totalCount > 0
                      ? 'Her şey hazır! 🎉'
                      : 'Akıllı çıkış\nasistanı',
                  subtitle: _totalCount == 0
                      ? 'Kontrol listesi boş.'
                      : '$_checkedCount / $_totalCount madde tamamlandı.',
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          safeZoneEnabled ? Icons.shield_rounded : Icons.home_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          safeZoneEnabled ? 'Korumalı' : 'Evde',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _InfoCard(
                        title: 'Kontrol',
                        value: '$_checkedCount/$_totalCount',
                        subtitle: 'Tamamlanan maddeler',
                        icon: Icons.checklist_rounded,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _InfoCard(
                        title: 'Güvenli Alan',
                        value: safeZoneEnabled ? 'Aktif' : 'Kapalı',
                        subtitle: safeZoneEnabled
                            ? 'Geofence izliyor'
                            : 'Konum ayarla',
                        icon: Icons.location_on_rounded,
                        valueColor: safeZoneEnabled
                            ? Colors.green
                            : colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // ── Hava Durumu Kartı ────────────────────────────────────────
                const WeatherCard(),
                const SizedBox(height: 24),

                // ── Kontrol Listesi ──────────────────────────────────────────
                Row(
                  children: [
                    const Text(
                      'Kontrol Listesi',
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                    const Spacer(),
                    if (_checkedCount > 0)
                      TextButton.icon(
                        onPressed: _uncheckAll,
                        icon: const Icon(Icons.refresh_rounded, size: 18),
                        label: const Text('Sıfırla'),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                    TextButton.icon(
                      onPressed: () async {
                        await context.push('/checklist');
                        _loadItems(); // Geri gelince yenile
                      },
                      icon: const Icon(Icons.edit_rounded, size: 18),
                      label: const Text('Düzenle'),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                if (_items.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.checklist_rounded,
                            size: 40, color: colorScheme.onSurfaceVariant),
                        const SizedBox(height: 8),
                        Text(
                          'Kontrol listesi boş.\nDüzenle\'ye bas ve madde ekle.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  )
                else
                  Container(
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        ..._items.asMap().entries.map((entry) {
                          final index = entry.key;
                          final item = entry.value;
                          final isLast = index == _items.length - 1;
                          return _ChecklistTile(
                            item: item,
                            isLast: isLast,
                            onToggle: () => _toggle(item),
                          );
                        }),
                      ],
                    ),
                  ),

                const SizedBox(height: 20),

                // ── Güvenli Bölge butonu ─────────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () async {
                      await context.push('/safe-zone');
                      setState(() {}); // safe zone durumu değişmiş olabilir
                    },
                    icon: const Icon(Icons.shield_rounded),
                    label: Text(
                      safeZoneEnabled
                          ? 'Güvenli Bölgeyi Görüntüle'
                          : 'Güvenli Bölge Ayarla',
                    ),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                      backgroundColor:
                          safeZoneEnabled ? Colors.green : colorScheme.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // ── Hızlı erişim ─────────────────────────────────────────────
                const Text(
                  'Hızlı erişim',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.55,
                  children: [
                    _QuickActionCard(
                      icon: Icons.list_alt_rounded,
                      title: 'Kontrol Listesi',
                      onTap: () async {
                        await context.push('/checklist');
                        _loadItems();
                      },
                    ),
                    _QuickActionCard(
                      icon: Icons.history_rounded,
                      title: 'Geçmiş',
                      onTap: () => context.push('/history'),
                    ),
                    _QuickActionCard(
                      icon: Icons.notifications_active_rounded,
                      title: 'Bildirimler',
                      onTap: () => context.push('/notifications'),
                    ),
                    _QuickActionCard(
                      icon: Icons.location_on_rounded,
                      title: 'Güvenli Bölge',
                      onTap: () async {
                        await context.push('/safe-zone');
                        setState(() {});
                      },
                    ),
                    _QuickActionCard(
                      icon: Icons.calendar_month_rounded,
                      title: 'Takvim',
                      onTap: () => context.push('/calendar'),
                    ),
                    _QuickActionCard(
                      icon: Icons.settings_suggest_rounded,
                      title: 'Ayarlar',
                      onTap: () => context.push('/settings'),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // ── Bugünkü Etkinlikler ──────────────────────────────────────
                const TodayEventsWidget(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Checklist Tile ─────────────────────────────────────────────────────────────

class _ChecklistTile extends StatelessWidget {
  const _ChecklistTile({
    required this.item,
    required this.isLast,
    required this.onToggle,
  });

  final ChecklistItem item;
  final bool isLast;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.vertical(
        top: const Radius.circular(0),
        bottom: isLast ? const Radius.circular(20) : Radius.zero,
      ),
      onTap: onToggle,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                item.isChecked
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked_rounded,
                key: ValueKey(item.isChecked),
                color: item.isChecked
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                item.title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: item.isChecked
                      ? colorScheme.onSurfaceVariant
                      : colorScheme.onSurface,
                  decoration:
                      item.isChecked ? TextDecoration.lineThrough : null,
                  decorationColor: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Info Card ─────────────────────────────────────────────────────────────────

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    this.valueColor,
  });

  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: colorScheme.primary),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
                fontSize: 13, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: valueColor,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: TextStyle(
                color: colorScheme.onSurfaceVariant, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

// ── Quick Action Card ──────────────────────────────────────────────────────────

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 28, color: colorScheme.primary),
              const Spacer(),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
