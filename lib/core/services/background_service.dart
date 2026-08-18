import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:threshold/core/services/app_bootstrap.dart';

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();
  WidgetsFlutterBinding.ensureInitialized();

  // Arka planda tüm asistanları (Wi-Fi, Konum vb.) başlat.
  await AppBootstrap.initialize();

  // Uygulama tamamen kapatılsa bile bu döngü çalışmaya devam eder.
  service.on('stopService').listen((event) {
    service.stopSelf();
  });
}

class AppBackgroundService {
  static Future<void> initialize() async {
    final service = FlutterBackgroundService();

    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        autoStart: true,
        isForegroundMode: true,
        notificationChannelId: 'high_priority_channel', 
        initialNotificationTitle: 'Unutma Ha!',
        initialNotificationContent: 'Evden çıkışını takip ediyor (Arka plan servisi aktif)',
        foregroundServiceNotificationId: 888,
      ),
      iosConfiguration: IosConfiguration(
        autoStart: true,
        onForeground: onStart,
        onBackground: onIosBackground,
      ),
    );
  }

  @pragma('vm:entry-point')
  static Future<bool> onIosBackground(ServiceInstance service) async {
    DartPluginRegistrant.ensureInitialized();
    return true;
  }
}
