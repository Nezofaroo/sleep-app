import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../models/alarm_settings.dart';




class AlarmSettingsProvider extends ChangeNotifier {
  static const _boxName = 'settings';

  AlarmSettings _settings = const AlarmSettings();
  AlarmSettings get settings => _settings;

  AlarmSettingsProvider() {
    _load();
  }


  void _load() {
    if (!Hive.isBoxOpen(_boxName)) return;
    final b = Hive.box(_boxName);
    _settings = AlarmSettings(
      alarmHour:              b.get('alarmHour',              defaultValue: 7)       as int,
      alarmMinute:            b.get('alarmMinute',            defaultValue: 0)       as int,
      alarmEnabled:           b.get('alarmEnabled',           defaultValue: false)   as bool,
      ringtone:               b.get('ringtone',               defaultValue: 'default') as String,
      alarmVolume:            (b.get('alarmVolume',           defaultValue: 0.7)     as num).toDouble(),
      vibrationEnabled:       b.get('vibrationEnabled',       defaultValue: true)    as bool,
      smartAlarmEnabled:      b.get('smartAlarmEnabled',      defaultValue: false)   as bool,
      wakeWindowMinutes:      b.get('wakeWindowMinutes',      defaultValue: 30)      as int,
      snoozeMinutes:          b.get('snoozeMinutes',          defaultValue: 10)      as int,
      smartSnoozeEnabled:     b.get('smartSnoozeEnabled',     defaultValue: false)   as bool,
      wakeMoodEnabled:        b.get('wakeMoodEnabled',        defaultValue: false)   as bool,
      bedtimeHour:            b.get('bedtimeHour',            defaultValue: 23)      as int,
      bedtimeMinute:          b.get('bedtimeMinute',          defaultValue: 0)       as int,
      bedtimeReminderEnabled: b.get('bedtimeReminderEnabled', defaultValue: false)   as bool,
      reminderOffsetHours:    b.get('reminderOffsetHours',    defaultValue: 0)       as int,
      reminderOffsetMinutes:  b.get('reminderOffsetMinutes',  defaultValue: 30)      as int,
      sleepFactorsEnabled:    b.get('sleepFactorsEnabled',    defaultValue: false)   as bool,
    );
    notifyListeners();
  }


  Future<void> save(AlarmSettings updated) async {
    _settings = updated;
    notifyListeners();

    if (!Hive.isBoxOpen(_boxName)) return;
    final b = Hive.box(_boxName);
    await Future.wait([
      b.put('alarmHour',              updated.alarmHour),
      b.put('alarmMinute',            updated.alarmMinute),
      b.put('alarmEnabled',           updated.alarmEnabled),
      b.put('ringtone',               updated.ringtone),
      b.put('alarmVolume',            updated.alarmVolume),
      b.put('vibrationEnabled',       updated.vibrationEnabled),
      b.put('smartAlarmEnabled',      updated.smartAlarmEnabled),
      b.put('wakeWindowMinutes',      updated.wakeWindowMinutes),
      b.put('snoozeMinutes',          updated.snoozeMinutes),
      b.put('smartSnoozeEnabled',     updated.smartSnoozeEnabled),
      b.put('wakeMoodEnabled',        updated.wakeMoodEnabled),
      b.put('bedtimeHour',            updated.bedtimeHour),
      b.put('bedtimeMinute',          updated.bedtimeMinute),
      b.put('bedtimeReminderEnabled', updated.bedtimeReminderEnabled),
      b.put('reminderOffsetHours',    updated.reminderOffsetHours),
      b.put('reminderOffsetMinutes',  updated.reminderOffsetMinutes),
      b.put('sleepFactorsEnabled',    updated.sleepFactorsEnabled),
    ]);
  }


  Future<void> update(AlarmSettings Function(AlarmSettings) updater) =>
      save(updater(_settings));
}
