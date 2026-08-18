import 'package:flutter/material.dart';
import 'package:threshold/core/services/local_storage_service.dart';

// ─── Renk Paletleri ──────────────────────────────────────────────────────────

class AppColorPalette {
  const AppColorPalette({
    required this.id,
    required this.name,
    required this.seedLight,
    required this.seedDark,
    required this.emoji,
    required this.illustrationPath,
    required this.gradientColors,
  });

  final String id;
  final String name;
  final Color seedLight;
  final Color seedDark;
  final String emoji;
  final String illustrationPath;
  final List<Color> gradientColors;

  static const all = [
    AppColorPalette(
      id: 'rose',
      name: 'Gül / Bahar',
      seedLight: Color(0xFFF43F5E),
      seedDark: Color(0xFFFDA4AF),
      emoji: '🌸',
      illustrationPath: 'assets/illustrations/spring.svg',
      gradientColors: [Color(0xFFFDA4AF), Color(0xFFF43F5E)],
    ),
    AppColorPalette(
      id: 'ocean',
      name: 'Okyanus',
      seedLight: Color(0xFF0EA5E9),
      seedDark: Color(0xFF7DD3FC),
      emoji: '🌊',
      illustrationPath: 'assets/illustrations/ocean.svg',
      gradientColors: [Color(0xFF7DD3FC), Color(0xFF0284C7)],
    ),
    AppColorPalette(
      id: 'forest',
      name: 'Orman',
      seedLight: Color(0xFF10B981),
      seedDark: Color(0xFF6EE7B7),
      emoji: '🌿',
      illustrationPath: 'assets/illustrations/forest.svg',
      gradientColors: [Color(0xFF6EE7B7), Color(0xFF059669)],
    ),
    AppColorPalette(
      id: 'night',
      name: 'Mor Gece',
      seedLight: Color(0xFF8B5CF6),
      seedDark: Color(0xFFC4B5FD),
      emoji: '🔮',
      illustrationPath: 'assets/illustrations/night.svg',
      gradientColors: [Color(0xFFC4B5FD), Color(0xFF7C3AED)],
    ),
    AppColorPalette(
      id: 'sunset',
      name: 'Gün Batımı',
      seedLight: Color(0xFFEA580C),
      seedDark: Color(0xFFFDBA74),
      emoji: '🌇',
      illustrationPath: 'assets/illustrations/sunset.svg',
      gradientColors: [Color(0xFFFDBA74), Color(0xFFEA580C)],
    ),
    AppColorPalette(
      id: 'winter',
      name: 'Kış Buzulu',
      seedLight: Color(0xFF06B6D4),
      seedDark: Color(0xFF67E8F9),
      emoji: '❄️',
      illustrationPath: 'assets/illustrations/winter.svg',
      gradientColors: [Color(0xFF67E8F9), Color(0xFF0891B2)],
    ),
    AppColorPalette(
      id: 'galaxy',
      name: 'Galaksi',
      seedLight: Color(0xFFD946EF),
      seedDark: Color(0xFFF0ABFC),
      emoji: '🌌',
      illustrationPath: 'assets/illustrations/galaxy.svg',
      gradientColors: [Color(0xFFF0ABFC), Color(0xFFC026D3)],
    ),
    AppColorPalette(
      id: 'desert',
      name: 'Altın Çöl',
      seedLight: Color(0xFFD97706),
      seedDark: Color(0xFFFCD34D),
      emoji: '🏜️',
      illustrationPath: 'assets/illustrations/desert.svg',
      gradientColors: [Color(0xFFFCD34D), Color(0xFFD97706)],
    ),
  ];

  static AppColorPalette fromId(String id) =>
      all.firstWhere((p) => p.id == id, orElse: () => all.first);
}

// ─── Theme Notifier ───────────────────────────────────────────────────────────

class ThemeNotifier extends ChangeNotifier {
  static const _palettePrefKey = 'selected_palette';
  static const _darkModePrefKey = 'dark_mode';

  ThemeNotifier() {
    _load();
  }

  AppColorPalette _palette = AppColorPalette.all.first;
  bool _isDark = true;

  AppColorPalette get palette => _palette;
  bool get isDark => _isDark;
  ThemeMode get themeMode => _isDark ? ThemeMode.dark : ThemeMode.light;

  void _load() {
    final prefs = LocalStorageService.prefs;
    final id = prefs.getString(_palettePrefKey) ?? 'rose';
    _palette = AppColorPalette.fromId(id);
    _isDark = prefs.getBool(_darkModePrefKey) ?? true;
  }

  Future<void> setPalette(AppColorPalette palette) async {
    _palette = palette;
    await LocalStorageService.prefs.setString(_palettePrefKey, palette.id);
    notifyListeners();
  }

  Future<void> toggleDarkMode() async {
    _isDark = !_isDark;
    await LocalStorageService.prefs.setBool(_darkModePrefKey, _isDark);
    notifyListeners();
  }
}
