import 'package:flutter/material.dart';
import 'package:weather/weather.dart';

/// Hava durumu önerisi modeli — public, farklı dosyalardan erişilebilir.
class WeatherTip {
  const WeatherTip({
    required this.emoji,
    required this.title,
    required this.body,
    required this.color,
  });

  final String emoji;
  final String title;
  final String body;
  final Color color;
}

/// Hava durumuna göre evden çıkış önerileri üretir.
class WeatherSuggestion {
  const WeatherSuggestion._();

  static List<WeatherTip> getSuggestions(Weather weather) {
    final code = weather.weatherConditionCode ?? 800;
    final main = (weather.weatherMain ?? '').toLowerCase();
    final temp = weather.temperature?.celsius ?? 20.0;
    final windSpeed = weather.windSpeed ?? 0.0;
    final humidity = weather.humidity ?? 0;

    final tips = <WeatherTip>[];

    // ── Yağmur / Sağanak / Fırtına ────────────────────────────────────────
    if (code >= 200 && code < 300) {
      tips.add(const WeatherTip(
        emoji: '⛈️',
        title: 'Fırtına var!',
        body: 'Şemsiyeni ve yağmurluk al, mümkünse evde kal.',
        color: Color(0xFF374151),
      ));
    } else if (code >= 300 && code < 400) {
      tips.add(const WeatherTip(
        emoji: '🌦️',
        title: 'Çisenti var',
        body: 'Hafif şemsiye almayı unutma.',
        color: Color(0xFF4B6EAF),
      ));
    } else if (code >= 400 && code < 600) {
      tips.add(const WeatherTip(
        emoji: '☂️',
        title: 'Yağmur yağıyor',
        body: 'Şemsiyeni al! Islak yollarda dikkatli sür.',
        color: Color(0xFF2563EB),
      ));
    }

    // ── Kar ───────────────────────────────────────────────────────────────
    if (code >= 600 && code < 700) {
      tips.add(const WeatherTip(
        emoji: '❄️',
        title: 'Kar yağıyor',
        body: 'Kalın giyim ve kaymaz ayakkabı giy. Trafiğe dikkat!',
        color: Color(0xFF60A5FA),
      ));
    }

    // ── Sis ───────────────────────────────────────────────────────────────
    if (code >= 700 && code < 800) {
      tips.add(const WeatherTip(
        emoji: '🌫️',
        title: 'Görüş mesafesi düşük',
        body: 'Araç kullanıyorsan dikkat et, sisli hava tehlikeli.',
        color: Color(0xFF9CA3AF),
      ));
    }

    // ── Sıcaklık ──────────────────────────────────────────────────────────
    if (temp >= 35) {
      tips.add(const WeatherTip(
        emoji: '🥵',
        title: 'Aşırı sıcak!',
        body: 'Bol su iç, şapka tak, güneş kremi sür.',
        color: Color(0xFFDC2626),
      ));
    } else if (temp >= 28) {
      tips.add(const WeatherTip(
        emoji: '☀️',
        title: 'Sıcak hava',
        body: 'Su şişeni al, güneşten korun.',
        color: Color(0xFFF59E0B),
      ));
    } else if (temp <= 5) {
      tips.add(const WeatherTip(
        emoji: '🧥',
        title: 'Hava çok soğuk!',
        body: 'Kalın mont, atkı ve eldiven giyme unutma.',
        color: Color(0xFF1D4ED8),
      ));
    } else if (temp <= 15) {
      tips.add(const WeatherTip(
        emoji: '🧣',
        title: 'Serin hava',
        body: 'Hafif bir ceket veya hırka giy.',
        color: Color(0xFF0EA5E9),
      ));
    }

    // ── Rüzgar ────────────────────────────────────────────────────────────
    if (windSpeed >= 10) {
      tips.add(WeatherTip(
        emoji: '💨',
        title: 'Çok rüzgarlı',
        body: windSpeed >= 15
            ? 'Rüzgar çok kuvvetli! Şemsiye ters dönebilir.'
            : 'Rüzgarlı, saçılabilecek eşyalara dikkat et.',
        color: const Color(0xFF6B7280),
      ));
    }

    // ── Yüksek nem ────────────────────────────────────────────────────────
    if (humidity >= 80 && !main.contains('rain')) {
      tips.add(const WeatherTip(
        emoji: '💧',
        title: 'Nem çok yüksek',
        body: 'Boğucu bir hava olabilir, bol su iç.',
        color: Color(0xFF0369A1),
      ));
    }

    // ── Mükemmel hava ─────────────────────────────────────────────────────
    if (code == 800 && temp >= 18 && temp < 28) {
      tips.add(const WeatherTip(
        emoji: '🌟',
        title: 'Harika hava!',
        body: 'Güneşli ve ideal sıcaklık — keyfini çıkar!',
        color: Color(0xFF16A34A),
      ));
    }

    return tips;
  }
}
