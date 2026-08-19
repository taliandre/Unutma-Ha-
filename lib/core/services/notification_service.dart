import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:threshold/core/services/local_storage_service.dart';
import 'package:threshold/main.dart' show onBackgroundNotificationResponse;

const _kChannelId = 'threshold_exit_channel';
const _kChannelName = 'Threshold';
const _kNotifId = 1;

enum NotifSoundMode {
  systemDefault,
  alarm,
  ringtone,
  silent,
  custom,
}

class NotificationService {
  NotificationService();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  final AudioPlayer _audioPlayer = AudioPlayer();

  void Function(String actionId)? _onActionSelected;
  void Function(String payload)? _onNotifTapped;

  // ─── İzinler ──────────────────────────────────────────────────────────────

  Future<bool> requestPermissions() async {
    if (Platform.isAndroid) {
      for (final perm in [
        Permission.notification,
        Permission.locationWhenInUse,
        Permission.locationAlways,
      ]) {
        if (await perm.isDenied) await perm.request();
      }
    }
    final notifGranted = await Permission.notification.isGranted;
    final locGranted = await Permission.locationWhenInUse.isGranted ||
        await Permission.locationAlways.isGranted;
    return notifGranted && locGranted;
  }

  // ─── Başlatma ─────────────────────────────────────────────────────────────

  Future<void> initialize({
    void Function(String actionId)? onActionSelected,
    void Function(String payload)? onNotifTapped,
  }) async {
    _onActionSelected = onActionSelected;
    _onNotifTapped = onNotifTapped;

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: androidSettings);

    await _plugin.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: _handleForegroundResponse,
      onDidReceiveBackgroundNotificationResponse:
          onBackgroundNotificationResponse,
    );
  }

  void _handleForegroundResponse(NotificationResponse response) {
    final actionId = response.actionId;
    final payload = response.payload ?? '';
    if (actionId != null && actionId.isNotEmpty) {
      _onActionSelected?.call(actionId);
    } else {
      _onNotifTapped?.call(payload);
    }
  }

  // ─── Bildirim Göster ──────────────────────────────────────────────────────

  Future<void> showExitReminder({required String wifiName}) async {
    final soundMode = NotificationService.getSoundMode();
    final customPath = NotificationService.getCustomSoundPath();

    // Ses çal
    await _playSound(soundMode, customPath);

    final androidDetails = AndroidNotificationDetails(
      _kChannelId,
      _kChannelName,
      channelDescription: 'Evden çıkış hatırlatıcıları',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'Threshold',
      playSound: false, // Biz manuel çalıyoruz
      enableVibration: true,
      fullScreenIntent: true,
      actions: const [
        AndroidNotificationAction(
          'done',
          'Hepsini Aldım',
          showsUserInterface: false,
          cancelNotification: true,
        ),
        AndroidNotificationAction(
          'delay',
          'Ertele',
          showsUserInterface: false,
          cancelNotification: true,
        ),
      ],
    );

    await _plugin.show(
      id: _kNotifId,
      title: 'Evden çıkıyorsun 🔑',
      body: 'Kontrol listeni gözden geçir. $wifiName ağından ayrıldın.',
      payload: 'checklist',
      notificationDetails: NotificationDetails(android: androidDetails),
    );
  }

  Future<void> _playSound(NotifSoundMode mode, String? customPath) async {
    try {
      await _audioPlayer.stop();
      await _audioPlayer.setVolume(1.0);
      await _audioPlayer.setReleaseMode(ReleaseMode.stop);

      switch (mode) {
        case NotifSoundMode.alarm:
          // Android sistem alarm URI
          await _audioPlayer.play(
            DeviceFileSource(
              '/system/media/audio/alarms/Alarm_Beep_01.ogg',
            ),
          );
        case NotifSoundMode.ringtone:
          await _audioPlayer.play(
            DeviceFileSource(
              '/system/media/audio/ringtones/Andromeda.ogg',
            ),
          );
        case NotifSoundMode.custom:
          if (customPath != null && File(customPath).existsSync()) {
            await _audioPlayer.play(DeviceFileSource(customPath));
          }
        case NotifSoundMode.silent:
          break;
        case NotifSoundMode.systemDefault:
          await _audioPlayer.play(
            DeviceFileSource(
              '/system/media/audio/notifications/Argon.ogg',
            ),
          );
      }
    } catch (_) {
      // Ses çalamazsa sessizce devam et
    }
  }

  // ─── Önizleme (Notifications screen için) ────────────────────────────────

  Future<void> previewSound(NotifSoundMode mode, String? customPath) async {
    await _playSound(mode, customPath);
  }

  Future<void> stopPreview() async {
    await _audioPlayer.stop();
  }

  // ─── Dismiss ─────────────────────────────────────────────────────────────

  Future<void> dismiss() async {
    await _plugin.cancel(id: _kNotifId);
    await _audioPlayer.stop();
    FlutterBackgroundService().invoke('stopSound');
  }

  // ─── Tercih Yardımcıları ──────────────────────────────────────────────────

  static const _soundModeKey = 'notif_sound_mode';
  static const _customSoundKey = 'notif_custom_sound_path';

  static NotifSoundMode getSoundMode() {
    final val = LocalStorageService.prefs.getString(_soundModeKey);
    return NotifSoundMode.values.firstWhere(
      (e) => e.name == val,
      orElse: () => NotifSoundMode.systemDefault,
    );
  }

  static Future<void> setSoundMode(NotifSoundMode mode) async {
    await LocalStorageService.prefs.setString(_soundModeKey, mode.name);
  }

  static String? getCustomSoundPath() =>
      LocalStorageService.prefs.getString(_customSoundKey);

  static Future<void> setCustomSoundPath(String path) async {
    await LocalStorageService.prefs.setString(_customSoundKey, path);
  }
}
