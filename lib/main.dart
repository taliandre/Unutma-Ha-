import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:threshold/app/app.dart';
import 'package:threshold/core/services/app_bootstrap.dart';
import 'package:threshold/core/services/background_service.dart';
import 'package:threshold/core/services/history_service.dart';
import 'package:threshold/core/services/local_storage_service.dart';

/// Uygulama KAPALI/ARKA PLANDA iken bildirim butonlarına basılınca
/// bu top-level fonksiyon çalışır (Dart VM entry point).
@pragma('vm:entry-point')
Future<void> onBackgroundNotificationResponse(
  NotificationResponse response,
) async {
  await LocalStorageService.init();
  final actionId = response.actionId;
  if (actionId == 'done') {
    await LocalStorageService.prefs.setString('last_notification_action', 'done');
    await HistoryService.addEntry(action: 'done', note: 'Hepsini aldım — bildirim onaylandı (arka plan).');
  } else if (actionId == 'delay') {
    await LocalStorageService.prefs.setString('last_notification_action', 'delay');
    await HistoryService.addEntry(action: 'delay', note: 'Bildirim ertelendi (arka plan).');
  }
  await FlutterLocalNotificationsPlugin().cancel(id: 1);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppBackgroundService.initialize();
  await AppBootstrap.initialize();
  runApp(
    const ProviderScope(
      child: ThresholdApp(),
    ),
  );
}
