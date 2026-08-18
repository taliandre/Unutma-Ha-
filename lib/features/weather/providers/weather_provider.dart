import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:weather/weather.dart';

// ─── OpenWeatherMap API Key ────────────────────────────────────────────────────
const _kOwmApiKey = '0edf7a23e1eb8d0385fd4d90e35135df';

// ─── Hava durumu state ────────────────────────────────────────────────────────

sealed class WeatherState {}

class WeatherLoading extends WeatherState {}

class WeatherLoaded extends WeatherState {
  WeatherLoaded(this.weather);
  final Weather weather;
}

class WeatherError extends WeatherState {
  WeatherError(this.message);
  final String message;
}

// ─── Provider ─────────────────────────────────────────────────────────────────

final weatherProvider =
    AsyncNotifierProvider<WeatherNotifier, WeatherState>(WeatherNotifier.new);

class WeatherNotifier extends AsyncNotifier<WeatherState> {
  final _wf = WeatherFactory(_kOwmApiKey, language: Language.TURKISH);

  @override
  Future<WeatherState> build() async {
    return _fetch();
  }

  Future<WeatherState> _fetch() async {
    try {
      // Konum iznini kontrol et
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever) {
        return WeatherError('Konum izni reddedildi.');
      }

      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return WeatherError('Konum servisi kapalı.');
      }

      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low, // Hava durumu için düşük doğruluk yeterli
        ),
      );

      final weather = await _wf.currentWeatherByLocation(
        pos.latitude,
        pos.longitude,
      );

      return WeatherLoaded(weather);
    } on OpenWeatherAPIException catch (e) {
      return WeatherError('Hava durumu alınamadı: $e');
    } catch (e) {
      return WeatherError('Bağlantı hatası. İnternet bağlantınızı kontrol edin.');
    }
  }

  /// Manuel yenile
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = AsyncData(await _fetch());
  }
}
