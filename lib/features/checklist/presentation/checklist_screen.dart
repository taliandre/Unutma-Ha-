import 'package:flutter/material.dart';
import 'package:threshold/core/models/checklist_item.dart';
import 'package:threshold/core/services/checklist_service.dart';

class ChecklistScreen extends StatefulWidget {
  const ChecklistScreen({super.key});

  @override
  State<ChecklistScreen> createState() => _ChecklistScreenState();
}

class _ChecklistScreenState extends State<ChecklistScreen> {
  late List<ChecklistItem> _items;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() => setState(() => _items = ChecklistService.getAll());

  Future<void> _addItem() async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Yeni Madde Ekle'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(
            hintText: 'Örn: Şemsiye',
            border: OutlineInputBorder(),
          ),
          onSubmitted: (v) => Navigator.pop(ctx, v),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('İptal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text),
            child: const Text('Ekle'),
          ),
        ],
      ),
    );

    if (result != null && result.trim().isNotEmpty) {
      await ChecklistService.addItem(result);
      _refresh();
    }
  }

  Future<void> _editItem(ChecklistItem item) async {
    final controller = TextEditingController(text: item.title);
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Düzenle'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(border: OutlineInputBorder()),
          onSubmitted: (v) => Navigator.pop(ctx, v),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('İptal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text),
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );

    if (result != null && result.trim().isNotEmpty) {
      await ChecklistService.updateTitle(item, result);
      _refresh();
    }
  }

  Future<void> _toggleItem(ChecklistItem item) async {
    await ChecklistService.toggleItem(item);
    _refresh();
  }

  Future<void> _deleteItem(ChecklistItem item) async {
    await ChecklistService.deleteItem(item);
    _refresh();
  }

  Future<void> _uncheckAll() async {
    await ChecklistService.uncheckAll();
    _refresh();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final checked = _items.where((i) => i.isChecked).length;
    final total = _items.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kontrol Listesi'),
        actions: [
          if (checked > 0)
            TextButton.icon(
              onPressed: _uncheckAll,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Sıfırla'),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addItem,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Ekle'),
      ),
      body: Column(
        children: [
          // ── İlerleme Çubuğu ────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$checked / $total tamamlandı',
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (total > 0)
                      Text(
                        '${(checked / total * 100).round()}%',
                        style: TextStyle(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: total == 0 ? 0 : checked / total,
                    minHeight: 8,
                    backgroundColor: colorScheme.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      checked == total && total > 0
                          ? Colors.green
                          : colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ── Liste ───────────────────────────────────────────────────────
          Expanded(
            child: _items.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.checklist_rounded,
                          size: 72,
                          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Liste boş',
                          style: TextStyle(color: colorScheme.onSurfaceVariant),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Sağ alttaki + ile madde ekle',
                          style: TextStyle(
                            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(18, 0, 18, 100),
                    itemCount: _items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final item = _items[index];
                      return _ChecklistTile(
                        item: item,
                        onToggle: () => _toggleItem(item),
                        onEdit: () => _editItem(item),
                        onDelete: () => _deleteItem(item),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _ChecklistTile extends StatelessWidget {
  const _ChecklistTile({
    required this.item,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  final ChecklistItem item;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Dismissible(
      key: ValueKey(item.key),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Icon(Icons.delete_rounded, color: Colors.red),
      ),
      onDismissed: (_) => onDelete(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: item.isChecked
              ? colorScheme.primaryContainer.withValues(alpha: 0.4)
              : colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(18),
          border: item.isChecked
              ? Border.all(
                  color: colorScheme.primary.withValues(alpha: 0.3),
                  width: 1.2,
                )
              : null,
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: onToggle,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  item.isChecked
                      ? Icons.check_circle_rounded
                      : Icons.radio_button_unchecked_rounded,
                  key: ValueKey(item.isChecked),
                  color: item.isChecked
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant,
                  size: 28,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                item.title,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  decoration: item.isChecked
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                  color: item.isChecked
                      ? colorScheme.onSurfaceVariant
                      : colorScheme.onSurface,
                ),
              ),
            ),
            IconButton(
              onPressed: onEdit,
              icon: Icon(
                Icons.edit_outlined,
                size: 20,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
