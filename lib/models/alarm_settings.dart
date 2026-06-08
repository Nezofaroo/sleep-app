

class AlarmSettings {

  final int alarmHour;
  final int alarmMinute;
  final bool alarmEnabled;
  final String ringtone;
  final double alarmVolume;
  final bool vibrationEnabled;


  final bool smartAlarmEnabled;
  final int wakeWindowMinutes;


  final int snoozeMinutes;
  final bool smartSnoozeEnabled;


  final bool wakeMoodEnabled;


  final int bedtimeHour;
  final int bedtimeMinute;
  final bool bedtimeReminderEnabled;
  final int reminderOffsetHours;
  final int reminderOffsetMinutes;


  final bool sleepFactorsEnabled;

  const AlarmSettings({
    this.alarmHour              = 7,
    this.alarmMinute            = 0,
    this.alarmEnabled           = false,
    this.ringtone               = 'default',
    this.alarmVolume            = 0.7,
    this.vibrationEnabled       = true,
    this.smartAlarmEnabled      = false,
    this.wakeWindowMinutes      = 30,
    this.snoozeMinutes          = 10,
    this.smartSnoozeEnabled     = false,
    this.wakeMoodEnabled        = false,
    this.bedtimeHour            = 23,
    this.bedtimeMinute          = 0,
    this.bedtimeReminderEnabled = false,
    this.reminderOffsetHours    = 0,
    this.reminderOffsetMinutes  = 30,
    this.sleepFactorsEnabled    = false,
  });


  AlarmSettings copyWith({
    int?    alarmHour,
    int?    alarmMinute,
    bool?   alarmEnabled,
    String? ringtone,
    double? alarmVolume,
    bool?   vibrationEnabled,
    bool?   smartAlarmEnabled,
    int?    wakeWindowMinutes,
    int?    snoozeMinutes,
    bool?   smartSnoozeEnabled,
    bool?   wakeMoodEnabled,
    int?    bedtimeHour,
    int?    bedtimeMinute,
    bool?   bedtimeReminderEnabled,
    int?    reminderOffsetHours,
    int?    reminderOffsetMinutes,
    bool?   sleepFactorsEnabled,
  }) {
    return AlarmSettings(
      alarmHour:              alarmHour              ?? this.alarmHour,
      alarmMinute:            alarmMinute            ?? this.alarmMinute,
      alarmEnabled:           alarmEnabled           ?? this.alarmEnabled,
      ringtone:               ringtone               ?? this.ringtone,
      alarmVolume:            alarmVolume            ?? this.alarmVolume,
      vibrationEnabled:       vibrationEnabled       ?? this.vibrationEnabled,
      smartAlarmEnabled:      smartAlarmEnabled      ?? this.smartAlarmEnabled,
      wakeWindowMinutes:      wakeWindowMinutes      ?? this.wakeWindowMinutes,
      snoozeMinutes:          snoozeMinutes          ?? this.snoozeMinutes,
      smartSnoozeEnabled:     smartSnoozeEnabled     ?? this.smartSnoozeEnabled,
      wakeMoodEnabled:        wakeMoodEnabled        ?? this.wakeMoodEnabled,
      bedtimeHour:            bedtimeHour            ?? this.bedtimeHour,
      bedtimeMinute:          bedtimeMinute          ?? this.bedtimeMinute,
      bedtimeReminderEnabled: bedtimeReminderEnabled ?? this.bedtimeReminderEnabled,
      reminderOffsetHours:    reminderOffsetHours    ?? this.reminderOffsetHours,
      reminderOffsetMinutes:  reminderOffsetMinutes  ?? this.reminderOffsetMinutes,
      sleepFactorsEnabled:    sleepFactorsEnabled    ?? this.sleepFactorsEnabled,
    );
  }


  String get formattedAlarmTime =>
      '${alarmHour.toString().padLeft(2, '0')}:${alarmMinute.toString().padLeft(2, '0')}';


  String get formattedBedtime =>
      '${bedtimeHour.toString().padLeft(2, '0')}:${bedtimeMinute.toString().padLeft(2, '0')}';


  String get formattedReminderOffset =>
      '$reminderOffsetHours ч. ${reminderOffsetMinutes.toString().padLeft(2, '0')} мин.';


  String get formattedSnooze =>
      snoozeMinutes == 0 ? 'Выкл.' : '$snoozeMinutes мин.';
}


class BuiltInRingtone {
  final String id;
  final String name;
  const BuiltInRingtone(this.id, this.name);

  static const List<BuiltInRingtone> all = [
    BuiltInRingtone('default',   'По умолчанию'),
    BuiltInRingtone('gentle',    'Нежный рассвет'),
    BuiltInRingtone('chime',     'Колокольчики'),
    BuiltInRingtone('nature',    'Природа'),
    BuiltInRingtone('digital',   'Цифровой'),
    BuiltInRingtone('piano',     'Пианино'),
  ];
}
