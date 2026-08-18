import 'package:flutter/material.dart';
import 'package:threshold/core/models/history_entry.dart';
import 'package:threshold/core/services/history_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late List<HistoryEntry> _entries;

  @override
  void initState() {
    super.initState();
    _entries = HistoryService.getAll();
  }

  Future<void> _clearHistory() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Geçmişi Temizle'),
        content: const Text('Tüm geçmiş kayıtları silinecek. Emin misin?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('İptal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await HistoryService.clearAll();
      setState(() => _entries = []);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Geçmiş'),
        actions: [
          if (_entries.isNotEmpty)
            IconButton(
              onPressed: _clearHistory,
              icon: const Icon(Icons.delete_outline_rounded),
              tooltip: 'Temizle',
            ),
        ],
      ),
      body: _entries.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.history_rounded,
                    size: 72,
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Henüz kayıt yok',
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Bildirime yanıt verince burada görünür.',
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              itemCount: _entries.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final entry = _entries[index];
                return _HistoryTile(entry: entry);
              },
            ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({required this.entry});
  final HistoryEntry entry;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final config = _actionConfig(entry.action, colorScheme);

    final date = entry.timestamp;
    final dateStr =
        '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
    final timeStr =
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: config.bgColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: config.borderColor, width: 1.2),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: config.iconBg,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(config.icon, color: config.iconColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  config.label,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: config.iconColor,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  entry.note,
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                timeStr,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                dateStr,
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  _ActionConfig _actionConfig(String action, ColorScheme cs) {
    switch (action) {
      case 'done':
        return _ActionConfig(
          icon: Icons.check_circle_rounded,
          label: 'Hepsini Aldım',
          iconColor: Colors.green.shade600,
          iconBg: Colors.green.withValues(alpha: 0.12),
          bgColor: Colors.green.withValues(alpha: 0.05),
          borderColor: Colors.green.withValues(alpha: 0.2),
        );
      case 'delay':
        return _ActionConfig(
          icon: Icons.snooze_rounded,
          label: 'Ertelendi',
          iconColor: Colors.orange.shade700,
          iconBg: Colors.orange.withValues(alpha: 0.12),
          bgColor: Colors.orange.withValues(alpha: 0.05),
          borderColor: Colors.orange.withValues(alpha: 0.2),
        );
      default: // 'trigger'
        return _ActionConfig(
          icon: Icons.notifications_active_rounded,
          label: 'Bildirim Gönderildi',
          iconColor: cs.primary,
          iconBg: cs.primaryContainer,
          bgColor: cs.surfaceContainerHighest,
          borderColor: cs.outlineVariant,
        );
    }
  }
}

class _ActionConfig {
  const _ActionConfig({
    required this.icon,
    required this.label,
    required this.iconColor,
    required this.iconBg,
    required this.bgColor,
    required this.borderColor,
  });

  final IconData icon;
  final String label;
  final Color iconColor;
  final Color iconBg;
  final Color bgColor;
  final Color borderColor;
}
