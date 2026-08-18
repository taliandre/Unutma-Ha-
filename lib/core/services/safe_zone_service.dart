import 'package:threshold/core/services/local_storage_service.dart';

/// Ev konumunu ve güvenli bölge yarıçapını kaydeder/okur.
class SafeZoneService {
  static const _latKey = 'safe_zone_lat';
  static const _lngKey = 'safe_zone_lng';
  static const _radiusKey = 'safe_zone_radius_m';
  static const _enabledKey = 'safe_zone_enabled';

  static bool get hasHomeLocation =>
      LocalStorageService.prefs.containsKey(_latKey);

  static double? get homeLat =>
      LocalStorageService.prefs.getDouble(_latKey);
  static double? get homeLng =>
      LocalStorageService.prefs.getDouble(_lngKey);

  /// Varsayılan yarıçap: 30 metre (GPS doğruluğu göz önüne alınarak)
  static double get radiusMeters =>
      LocalStorageService.prefs.getDouble(_radiusKey) ?? 30.0;

  static bool get isEnabled =>
      LocalStorageService.prefs.getBool(_enabledKey) ?? false;

  static Future<void> saveHomeLocation(double lat, double lng) async {
    await LocalStorageService.prefs.setDouble(_latKey, lat);
    await LocalStorageService.prefs.setDouble(_lngKey, lng);
    await LocalStorageService.prefs.setBool(_enabledKey, true);
  }

  static Future<void> setRadius(double meters) async {
    await LocalStorageService.prefs.setDouble(_radiusKey, meters);
  }

  static Future<void> setEnabled(bool value) async {
    await LocalStorageService.prefs.setBool(_enabledKey, value);
  }

  static Future<void> clear() async {
    await LocalStorageService.prefs.remove(_latKey);
    await LocalStorageService.prefs.remove(_lngKey);
    await LocalStorageService.prefs.setBool(_enabledKey, false);
  }
}
