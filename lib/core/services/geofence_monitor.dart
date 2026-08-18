import 'dart:async';
import 'dart:math';

import 'package:geolocator/geolocator.dart';
import 'package:threshold/core/services/history_service.dart';
import 'package:threshold/core/services/notification_service.dart';
import 'package:threshold/core/services/safe_zone_service.dart';

/// Kullanıcının güvenli bölgeden çıkıp çıkmadığını kontrol eder.
class GeofenceMonitor {
  GeofenceMonitor({required this.notificationService});

  final NotificationService notificationService;

  StreamSubscription<Position>? _positionSub;

  // null = ilk konum henüz alınmadı (başlangıçta varsayım yapma!)
  bool? _wasInsideZone;
  bool _alertSent = false;

  Future<void> start() async {
    // ── Guard: Güvenli bölge aktif ve ev konumu ayarlı mı? ────────────────
    if (!SafeZoneService.isEnabled || !SafeZoneService.hasHomeLocation) return;

    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever ||
        permission == LocationPermission.denied) return;

    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10, // Her 10 metrede bir kontrol et (daha az hassas, daha az yanlış tetik)
    );

    _positionSub = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen(_onPosition);
  }

  void stop() {
    _positionSub?.cancel();
    _positionSub = null;
    _wasInsideZone = null;
    _alertSent = false;
  }

  void _onPosition(Position position) {
    // ── Guard: Bölge hâlâ aktif mi? ──────────────────────────────────────
    if (!SafeZoneService.isEnabled || !SafeZoneService.hasHomeLocation) return;

    final homeLat = SafeZoneService.homeLat!;
    final homeLng = SafeZoneService.homeLng!;
    final radius = SafeZoneService.radiusMeters;

    final distance = _calculateDistance(
      position.latitude,
      position.longitude,
      homeLat,
      homeLng,
    );

    final isInsideZone = distance <= radius;

    // İlk konum alındığında sadece durumu kaydet, bildirim GÖNDERME
    if (_wasInsideZone == null) {
      _wasInsideZone = isInsideZone;
      return;
    }

    if (_wasInsideZone! && !isInsideZone && !_alertSent) {
      // İçeriden dışarıya geçiş → bildirim gönder
      _alertSent = true;
      _sendExitAlert();
    } else if (isInsideZone) {
      // Eve döndü → sıfırla (bir dahaki çıkışta tekrar bildirim gönder)
      _wasInsideZone = true;
      _alertSent = false;
    }

    _wasInsideZone = isInsideZone;
  }

  Future<void> _sendExitAlert() async {
    await notificationService.showExitReminder(wifiName: 'Ev');
    await HistoryService.addEntry(
      action: 'trigger',
      note: 'Güvenli bölgeden çıkıldı — konum bazlı bildirim gönderildi.',
    );
  }

  /// Haversine formülü — iki nokta arası mesafe (metre)
  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const R = 6371000.0;
    final phi1 = lat1 * pi / 180;
    final phi2 = lat2 * pi / 180;
    final dPhi = (lat2 - lat1) * pi / 180;
    final dLambda = (lon2 - lon1) * pi / 180;

    final a = sin(dPhi / 2) * sin(dPhi / 2) +
        cos(phi1) * cos(phi2) * sin(dLambda / 2) * sin(dLambda / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return R * c;
  }
}
