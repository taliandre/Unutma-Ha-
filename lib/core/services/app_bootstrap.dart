import 'package:threshold/app/router.dart';
import 'package:threshold/core/services/geofence_monitor.dart';
import 'package:threshold/core/services/history_service.dart';
import 'package:threshold/core/services/local_storage_service.dart';
import 'package:threshold/core/services/network_monitor.dart';
import 'package:threshold/core/services/notification_service.dart';
import 'package:threshold/core/services/trigger_engine.dart';

class AppBootstrap {
  static Future<InitializationResult> initialize() async {
    await LocalStorageService.init();

    final notificationService = NotificationService();
    await notificationService.requestPermissions();
    await notificationService.initialize(
      // Buton tıklandı (Ertele / Hepsini Aldım) — uygulama açıkken
      onActionSelected: (actionId) async {
        await notificationService.dismiss();

        if (actionId == 'done') {
          await LocalStorageService.prefs.setString(
            'last_notification_action',
            'done',
          );
          await HistoryService.addEntry(
            action: 'done',
            note: 'Hepsini aldım — bildirim onaylandı.',
          );
        } else if (actionId == 'delay') {
          await LocalStorageService.prefs.setString(
            'last_notification_action',
            'delay',
          );
          await HistoryService.addEntry(
            action: 'delay',
            note: 'Bildirim ertelendi.',
          );
        }
      },

      // Bildirimin kendisine tıklandı → kontrol listesini aç
      onNotifTapped: (payload) {
        if (payload == 'checklist') {
          AppRouter.router.push('/checklist');
        }
      },
    );

    final networkMonitor = NetworkMonitor();
    final triggerEngine = TriggerEngine(
      networkMonitor: networkMonitor,
      notificationService: notificationService,
    );

    final geofenceMonitor = GeofenceMonitor(
      notificationService: notificationService,
    );
    await geofenceMonitor.start();

    return InitializationResult(
      notificationService: notificationService,
      networkMonitor: networkMonitor,
      triggerEngine: triggerEngine,
      geofenceMonitor: geofenceMonitor,
    );
  }
}

class InitializationResult {
  InitializationResult({
    required this.notificationService,
    required this.networkMonitor,
    required this.triggerEngine,
    required this.geofenceMonitor,
  });

  final NotificationService notificationService;
  final NetworkMonitor networkMonitor;
  final TriggerEngine triggerEngine;
  final GeofenceMonitor geofenceMonitor;
}
