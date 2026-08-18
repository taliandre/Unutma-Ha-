import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:threshold/core/theme/theme_notifier.dart';

/// Temaya özel gradient ve SVG arka plan desenini gösteren ana sayfa kartı.
class ThemedHeaderCard extends StatelessWidget {
  const ThemedHeaderCard({
    super.key,
    required this.palette,
    required this.title,
    required this.subtitle,
    required this.trailing,
  });

  final AppColorPalette palette;
  final String title;
  final String subtitle;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          colors: palette.gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: palette.gradientColors.first.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // ── Organik İllüstrasyon Arka Planı ──
          Positioned.fill(
            child: SvgPicture.asset(
              palette.illustrationPath,
              fit: BoxFit.cover,
              alignment: Alignment.center,
              // Beyaz renk ile çizimleri daha görünür, şık ve düşük opaklıklı gösteriyoruz
              colorFilter: const ColorFilter.mode(
                Colors.white,
                BlendMode.srcIn,
              ),
            ),
          ),
          
          // ── İçerik (Metinler ve İkonlar) ──
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                trailing,
              ],
            ),
          ),
        ],
      ),
    );
  }
}
