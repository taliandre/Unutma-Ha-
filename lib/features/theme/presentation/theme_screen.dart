import 'package:flutter/material.dart';
import 'package:threshold/app/app.dart';
import 'package:threshold/core/theme/theme_notifier.dart';

class ThemeScreen extends StatelessWidget {
  const ThemeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notifier = ThemeNotifierProvider.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Tema')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          // ── Aydınlık / Karanlık ────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Icon(
                  notifier.isDark
                      ? Icons.dark_mode_rounded
                      : Icons.light_mode_rounded,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    notifier.isDark ? 'Karanlık Mod' : 'Aydınlık Mod',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ),
                Switch(
                  value: notifier.isDark,
                  onChanged: (_) => notifier.toggleDarkMode(),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          const Text(
            'Renk Paleti',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: 0.5),
          ),
          const SizedBox(height: 12),

          // ── Renk Paletleri ────────────────────────────────────────────
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.6,
            ),
            itemCount: AppColorPalette.all.length,
            itemBuilder: (context, index) {
              final palette = AppColorPalette.all[index];
              final isSelected = notifier.palette.id == palette.id;
              final seed = notifier.isDark ? palette.seedDark : palette.seedLight;

              return GestureDetector(
                onTap: () => notifier.setPalette(palette),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        seed,
                        seed.withValues(alpha: 0.6),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isSelected
                          ? Colors.white
                          : Colors.transparent,
                      width: 2.5,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: seed.withValues(alpha: 0.5),
                              blurRadius: 12,
                              spreadRadius: 2,
                            ),
                          ]
                        : [],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(palette.emoji, style: const TextStyle(fontSize: 22)),
                            if (isSelected)
                              const Icon(
                                Icons.check_circle_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                          ],
                        ),
                        Text(
                          palette.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            shadows: [
                              Shadow(
                                color: Colors.black26,
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
