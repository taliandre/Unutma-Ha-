import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:threshold/core/services/history_service.dart';
import 'package:threshold/core/services/local_storage_service.dart';
import 'package:threshold/core/services/network_monitor.dart';
import 'package:threshold/core/services/notification_service.dart';

class TriggerEngine {
  TriggerEngine({
    required this.networkMonitor,
    required this.notificationService,
  }) {
    networkMonitor.stream.listen(_onConnectivityChange);
  }

  final NetworkMonitor networkMonitor;
  final NotificationService notificationService;

  // Son bağlantı durumu — başlangıçta null (henüz bilinmiyor)
  ConnectivityResult? _lastResult;

  // Bildirim gönderildi mi? Tekrar bağlanana kadar bir daha gönderme.
  bool _notifSent = false;

  void _onConnectivityChange(ConnectivityResult result) {
    // ── Guard 1: Bildirim özelliği açık mı? ──────────────────────────────
    final notificationsEnabled =
        LocalStorageService.prefs.getBool('notifications_enabled') ?? true;
    if (!notificationsEnabled) {
      _lastResult = result;
      return;
    }

    // ── Guard 2: Ev Wi-Fi adı girilmiş mi? ──────────────────────────────
    final homeWifi =
        LocalStorageService.prefs.getString('home_wifi_name') ?? '';
    if (homeWifi.isEmpty) {
      // Ev Wi-Fi ayarlanmamışsa tetikleme
      _lastResult = result;
      return;
    }

    // ── Guard 3: Önceki durum Wi-Fi idi mi? ─────────────────────────────
    // Eğer daha önce Wi-Fi'ya bağlı değilsek (4G, vb.), kopuş sayılmaz.
    final wasOnWifi = _lastResult == ConnectivityResult.wifi;

    if (result == ConnectivityResult.none && wasOnWifi && !_notifSent) {
      // Ev Wi-Fi'sından kopuldu → bildirim gönder
      _notifSent = true;
      _handleWiFiDisconnect(homeWifi);
    } else if (result == ConnectivityResult.wifi) {
      // Wi-Fi'ya tekrar bağlandı → sıfırla
      _notifSent = false;
    }

    _lastResult = result;
  }

  Future<void> _handleWiFiDisconnect(String wifiName) async {
    await notificationService.showExitReminder(wifiName: wifiName);
    await HistoryService.addEntry(
      action: 'trigger',
      note: '$wifiName\'den ayrıldı — çıkış bildirimi gönderildi.',
    );
  }
}
