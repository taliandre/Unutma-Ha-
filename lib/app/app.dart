import 'package:flutter/material.dart';
import 'package:threshold/app/router.dart';
import 'package:threshold/core/theme/app_theme.dart';
import 'package:threshold/core/theme/theme_notifier.dart';

class ThresholdApp extends StatefulWidget {
  const ThresholdApp({super.key});

  @override
  State<ThresholdApp> createState() => _ThresholdAppState();
}

class _ThresholdAppState extends State<ThresholdApp> {
  late final ThemeNotifier _themeNotifier;

  @override
  void initState() {
    super.initState();
    _themeNotifier = ThemeNotifier();
    _themeNotifier.addListener(_onThemeChanged);
  }

  @override
  void dispose() {
    _themeNotifier.removeListener(_onThemeChanged);
    _themeNotifier.dispose();
    super.dispose();
  }

  void _onThemeChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final palette = _themeNotifier.palette;
    return ThemeNotifierProvider(
      notifier: _themeNotifier,
      child: MaterialApp.router(
        title: 'Threshold',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(palette.seedLight),
        darkTheme: AppTheme.dark(palette.seedDark),
        themeMode: _themeNotifier.themeMode,
        routerConfig: AppRouter.router,
      ),
    );
  }
}

/// InheritedWidget ile ThemeNotifier'ı widget ağacına dağıt
class ThemeNotifierProvider extends InheritedWidget {
  const ThemeNotifierProvider({
    super.key,
    required this.notifier,
    required super.child,
  });

  final ThemeNotifier notifier;

  static ThemeNotifier of(BuildContext context) {
    final provider = context
        .dependOnInheritedWidgetOfExactType<ThemeNotifierProvider>();
    assert(provider != null, 'ThemeNotifierProvider not found in context');
    return provider!.notifier;
  }

  @override
  bool updateShouldNotify(ThemeNotifierProvider oldWidget) =>
      notifier != oldWidget.notifier;
}
