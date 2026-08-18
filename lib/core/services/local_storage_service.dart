import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:threshold/core/services/checklist_service.dart';
import 'package:threshold/core/services/history_service.dart';

class LocalStorageService {
  LocalStorageService._();

  static late final SharedPreferences _prefs;
  static late final Box<dynamic> _hiveBox;

  static Future<void> init() async {
    await Hive.initFlutter();
    _prefs = await SharedPreferences.getInstance();
    _hiveBox = await Hive.openBox<dynamic>('threshold_box');
    await HistoryService.init();
    await ChecklistService.init();
  }

  static SharedPreferences get prefs => _prefs;
  static Box<dynamic> get hiveBox => _hiveBox;
}
