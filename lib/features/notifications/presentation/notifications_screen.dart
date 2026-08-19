import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:threshold/core/services/local_storage_service.dart';
import 'package:threshold/core/services/notification_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  static const _keyVibration = 'notif_vibration';
  static const _keyBanner = 'notif_banner';

  bool _vibrationEnabled = false;
  bool _bannerEnabled = true;

  NotifSoundMode _soundMode = NotifSoundMode.systemDefault;
  String? _customSoundPath;

  // Önizleme için geçici service instance
  final _previewService = NotificationService();

  @override
  void initState() {
    super.initState();
    _previewService.initialize();
    _load();
  }

  @override
  void dispose() {
    _previewService.stopPreview();
    super.dispose();
  }

  void _load() {
    final prefs = LocalStorageService.prefs;
    setState(() {
      _vibrationEnabled = prefs.getBool(_keyVibration) ?? false;
      _bannerEnabled = prefs.getBool(_keyBanner) ?? true;
      _soundMode = NotificationService.getSoundMode();
      _customSoundPath = NotificationService.getCustomSoundPath();
    });
  }

  Future<void> _setVibration(bool value) async {
    await LocalStorageService.prefs.setBool(_keyVibration, value);
    setState(() => _vibrationEnabled = value);
    if (value) HapticFeedback.mediumImpact();
  }

  Future<void> _setBanner(bool value) async {
    await LocalStorageService.prefs.setBool(_keyBanner, value);
    setState(() => _bannerEnabled = value);
  }

  Future<void> _setSoundMode(NotifSoundMode mode) async {
    await NotificationService.setSoundMode(mode);
    setState(() => _soundMode = mode);
    // Önizleme çal
    await _previewService.previewSound(mode, _customSoundPath);
  }

  Future<void> _pickCustomSound() async {
    final file = await FilePickerPlatform.instance.pickFile(
      type: FileType.audio,
    );

    if (file != null && file.path != null) {
      final extDir = await getExternalStorageDirectory();
      final originalFile = File(file.path!);
      final ext = originalFile.path.split('.').last;
      
      // External storage may be null on some devices, fallback to docs if needed
      final targetDir = extDir ?? await getApplicationDocumentsDirectory();
      final newPath = '${targetDir.path}/custom_sound_${DateTime.now().millisecondsSinceEpoch}.$ext';
      
      final permanentFile = await originalFile.copy(newPath);
      final path = permanentFile.path;

      await NotificationService.setCustomSoundPath(path);
      await NotificationService.setSoundMode(NotifSoundMode.custom);
      setState(() {
        _customSoundPath = path;
        _soundMode = NotifSoundMode.custom;
      });

      // Seçilen sesi önizle
      await _previewService.previewSound(NotifSoundMode.custom, path);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Ses seçildi: ${File(path).uri.pathSegments.last}',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Bildirimler')),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        children: [
          _SectionHeader(title: 'Bildirim Türü'),
          const SizedBox(height: 8),
          _NotifOptionTile(
            icon: Icons.vibration_rounded,
            title: 'Titreşimli',
            subtitle: 'Tetiklendiğinde cihaz titreşir.',
            iconColor: Colors.orange,
            value: _vibrationEnabled,
            onChanged: _setVibration,
          ),
          const SizedBox(height: 10),
          _NotifOptionTile(
            icon: Icons.notifications_rounded,
            title: 'Üstten Bildirim',
            subtitle: "Ekranın üstünde bildirim banner'ı gösterilir.",
            iconColor: colorScheme.primary,
            value: _bannerEnabled,
            onChanged: _setBanner,
          ),
          const SizedBox(height: 24),

          _SectionHeader(title: 'Alarm Sesi'),
          const SizedBox(height: 8),
          ..._SoundOption.all.map(
            (opt) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _SoundOptionTile(
                option: opt,
                selected: _soundMode == opt.mode,
                onTap: () => _setSoundMode(opt.mode),
              ),
            ),
          ),

          const SizedBox(height: 4),
          _CustomSoundTile(
            selected: _soundMode == NotifSoundMode.custom,
            currentPath: _customSoundPath,
            onTap: _pickCustomSound,
          ),
          const SizedBox(height: 28),
        ],
      ),
    );
  }
}

// ── Section Header ────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title.toUpperCase(),
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}

// ── Toggle Tile ───────────────────────────────────────────────────────────────

class _NotifOptionTile extends StatelessWidget {
  const _NotifOptionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.iconColor,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color iconColor;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: value
            ? iconColor.withValues(alpha: 0.08)
            : cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: value ? iconColor.withValues(alpha: 0.35) : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: SwitchListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        secondary: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        title: Text(title,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
        subtitle: Text(subtitle,
            style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 12)),
        value: value,
        onChanged: onChanged,
        activeColor: iconColor,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
    );
  }
}

// ── Ses Seçenekleri ───────────────────────────────────────────────────────────

class _SoundOption {
  const _SoundOption({
    required this.mode,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  final NotifSoundMode mode;
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  static const all = [
    _SoundOption(
      mode: NotifSoundMode.systemDefault,
      icon: Icons.notifications_outlined,
      title: 'Sistem Bildirimi',
      subtitle: "Cihazın varsayılan bildirim sesi.",
      color: Colors.blue,
    ),
    _SoundOption(
      mode: NotifSoundMode.alarm,
      icon: Icons.alarm_rounded,
      title: 'Alarm Sesi',
      subtitle: "Android'in yerleşik alarm zili.",
      color: Colors.red,
    ),
    _SoundOption(
      mode: NotifSoundMode.ringtone,
      icon: Icons.ring_volume_rounded,
      title: 'Zil Sesi',
      subtitle: 'Telefon zil sesi.',
      color: Colors.purple,
    ),
    _SoundOption(
      mode: NotifSoundMode.silent,
      icon: Icons.volume_off_rounded,
      title: 'Sessiz',
      subtitle: 'Ses çalmaz, sadece titreşim.',
      color: Colors.grey,
    ),
  ];
}

class _SoundOptionTile extends StatelessWidget {
  const _SoundOptionTile({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  final _SoundOption option;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: selected
              ? option.color.withValues(alpha: 0.08)
              : cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected
                ? option.color.withValues(alpha: 0.4)
                : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: option.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(option.icon, color: option.color, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(option.title,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 14)),
                  const SizedBox(height: 2),
                  Text(option.subtitle,
                      style:
                          TextStyle(color: cs.onSurfaceVariant, fontSize: 12)),
                ],
              ),
            ),
            if (selected)
              Icon(Icons.check_circle_rounded, color: option.color, size: 22)
            else
              Icon(Icons.radio_button_unchecked_rounded,
                  color: cs.onSurfaceVariant, size: 22),
          ],
        ),
      ),
    );
  }
}

// ── Özel Ses Tile ─────────────────────────────────────────────────────────────

class _CustomSoundTile extends StatelessWidget {
  const _CustomSoundTile({
    required this.selected,
    required this.currentPath,
    required this.onTap,
  });

  final bool selected;
  final String? currentPath;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final fileName = currentPath != null
        ? File(currentPath!).uri.pathSegments.last
        : null;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: selected
              ? Colors.teal.withValues(alpha: 0.08)
              : cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected
                ? Colors.teal.withValues(alpha: 0.4)
                : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.teal.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.folder_open_rounded,
                  color: Colors.teal, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Özel Ses Dosyası',
                      style: TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 14)),
                  const SizedBox(height: 2),
                  Text(
                    fileName ?? 'Dosyadan ses seç (MP3, WAV, OGG…)',
                    style:
                        TextStyle(color: cs.onSurfaceVariant, fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (selected)
              const Icon(Icons.check_circle_rounded,
                  color: Colors.teal, size: 22)
            else
              Icon(Icons.chevron_right_rounded,
                  color: cs.onSurfaceVariant, size: 22),
          ],
        ),
      ),
    );
  }
}
