import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:threshold/features/weather/providers/weather_provider.dart';
import 'package:threshold/features/weather/services/weather_suggestion.dart';
import 'package:weather/weather.dart';

/// Dashboard'da gösterilecek hava durumu kartı + öneriler.
class WeatherCard extends ConsumerWidget {
  const WeatherCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncState = ref.watch(weatherProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return asyncState.when(
      loading: () => _shell(context,
          child: const Center(child: CircularProgressIndicator())),
      error: (err, _) => _shell(context,
          child: _ErrorBody(
              message: err.toString(),
              onRetry: () => ref.read(weatherProvider.notifier).refresh())),
      data: (state) => switch (state) {
        WeatherLoading() => _shell(context,
            child: const Center(child: CircularProgressIndicator())),
        WeatherError(:final message) => _shell(context,
            child: _ErrorBody(
                message: message,
                onRetry: () =>
                    ref.read(weatherProvider.notifier).refresh())),
        WeatherLoaded(:final weather) =>
          _buildContent(context, ref, weather),
      },
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, Weather weather) {
    final suggestions = WeatherSuggestion.getSuggestions(weather);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCard(context, ref, weather),
        if (suggestions.isNotEmpty) ...[
          const SizedBox(height: 10),
          ...suggestions.map((tip) => _SuggestionTile(tip: tip)),
        ],
      ],
    );
  }

  Widget _buildCard(BuildContext context, WidgetRef ref, Weather weather) {
    final temp = weather.temperature?.celsius?.round() ?? '--';
    final feels = weather.tempFeelsLike?.celsius?.round() ?? '--';
    final desc = weather.weatherDescription ?? '';
    final city = weather.areaName ?? '';
    final icon = _weatherIcon(weather.weatherConditionCode ?? 0);
    final gradient = _weatherGradient(weather.weatherMain ?? '');

    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: gradient.colors.first.withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.location_on_rounded,
                    color: Colors.white70, size: 16),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(city,
                      style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          fontWeight: FontWeight.w500),
                      overflow: TextOverflow.ellipsis),
                ),
                GestureDetector(
                  onTap: () => ref.read(weatherProvider.notifier).refresh(),
                  child: const Icon(Icons.refresh_rounded,
                      color: Colors.white60, size: 18),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$temp°',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 58,
                      fontWeight: FontWeight.w800,
                      height: 1,
                    )),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(icon, style: const TextStyle(fontSize: 36)),
                      Text(_capitalize(desc),
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                _Chip('🌡️ Hissedilen $feels°'),
                if (weather.humidity != null)
                  _Chip('💧 %${weather.humidity!.round()}'),
                if (weather.windSpeed != null)
                  _Chip('💨 ${weather.windSpeed!.round()} m/s'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _shell(BuildContext context, {required Widget child}) => Container(
        height: 150,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(24),
        ),
        child: child,
      );

  String _capitalize(String s) =>
      s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';

  String _weatherIcon(int code) {
    if (code >= 200 && code < 300) return '⛈️';
    if (code >= 300 && code < 400) return '🌦️';
    if (code >= 500 && code < 600) return '🌧️';
    if (code >= 600 && code < 700) return '❄️';
    if (code >= 700 && code < 800) return '🌫️';
    if (code == 800) return '☀️';
    if (code == 801) return '🌤️';
    if (code >= 802) return '☁️';
    return '🌡️';
  }

  LinearGradient _weatherGradient(String main) => switch (main.toLowerCase()) {
        'clear' => const LinearGradient(
            colors: [Color(0xFF4facfe), Color(0xFF00f2fe)]),
        'clouds' => const LinearGradient(
            colors: [Color(0xFF4e54c8), Color(0xFF8f94fb)]),
        'rain' || 'drizzle' => const LinearGradient(
            colors: [Color(0xFF373b44), Color(0xFF4286f4)]),
        'thunderstorm' => const LinearGradient(
            colors: [Color(0xFF0f0c29), Color(0xFF302b63)]),
        'snow' => const LinearGradient(
            colors: [Color(0xFFa8edea), Color(0xFFfed6e3)]),
        _ => const LinearGradient(colors: [Color(0xFF667eea), Color(0xFF764ba2)]),
      };
}

// ── Öneri kartı ────────────────────────────────────────────────────────────────

class _SuggestionTile extends StatelessWidget {
  const _SuggestionTile({required this.tip});
  final WeatherTip tip;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: tip.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: tip.color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Text(tip.emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tip.title,
                  style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: tip.color),
                ),
                Text(
                  tip.body,
                  style: TextStyle(
                      fontSize: 12,
                      color:
                          Theme.of(context).colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip(this.label);
  final String label;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label,
            style: const TextStyle(color: Colors.white, fontSize: 12)),
      );
}

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.cloud_off_rounded, color: cs.onSurfaceVariant, size: 32),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(message,
                textAlign: TextAlign.center,
                style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12)),
          ),
          TextButton(onPressed: onRetry, child: const Text('Tekrar Dene')),
        ],
      ),
    );
  }
}
