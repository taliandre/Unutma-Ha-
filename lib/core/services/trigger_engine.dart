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
    _init();
  }

  Future<void> _init() async {
    _lastResult = await networkMonitor.currentStatus;
    networkMonitor.stream.listen(_onConnectivityChange);
  }

  final NetworkMonitor networkMonitor;
  final NotificationService notificationService;

  // Son bağlantı durumu — başlangıçta null (henüz bilinmiyor)
  ConnectivityResult? _lastResult;

  // Bildirim gönderildi mi? Tekrar bağlanana kadar bir daha gönderme.
  bool _notifSent = false;

  Future<void> _onConnectivityChange(ConnectivityResult result) async {
    // ── Isolate senkronizasyonu için önbelleği yenile ───────────────────
    await LocalStorageService.prefs.reload();

    // ── Guard 1: Bildirim özelliği açık mı? ──────────────────────────────
    final notificationsEnabled =
        LocalStorageService.prefs.getBool('notifications_enabled') ?? true;
    if (!notificationsEnabled) {
      _lastResult = result;
      return;
    }

    // ── Guard 2: Ev Wi-Fi adı girilmiş mi? ──────────────────────────────
    var homeWifi = LocalStorageService.prefs.getString('home_wifi_name') ?? '';
    if (homeWifi.isEmpty) {
      homeWifi = 'Ev Wi-Fi'; // Girmemişse bile varsayılan bir isimle çalışsın!
    }

    // ── Guard 3: Önceki durum Wi-Fi idi mi? ─────────────────────────────
    // Eğer daha önce Wi-Fi'ya bağlı değilsek (4G, vb.), kopuş sayılmaz.
    final wasOnWifi = _lastResult == ConnectivityResult.wifi;

    if (result != ConnectivityResult.wifi && wasOnWifi && !_notifSent) {
      // Ev Wi-Fi'sından kopuldu (mobil veriye geçti veya tamamen internetsiz) → bildirim gönder
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
