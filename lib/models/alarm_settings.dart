/// Полная модель настроек будильника и времени отхода ко сну.
/// Используется как единый источник истины в [AlarmSettingsProvider].
class AlarmSettings {
  // ── Будильник ────────────────────────────────────────────────────────────
  final int alarmHour;          // 0–23
  final int alarmMinute;        // 0–59
  final bool alarmEnabled;
  final String ringtone;        // ID встроенной мелодии или путь к файлу
  final double alarmVolume;     // 0.0–1.0
  final bool vibrationEnabled;

  // ── Умный будильник ──────────────────────────────────────────────────────
  final bool smartAlarmEnabled;
  final int wakeWindowMinutes;  // 5–60, шаг 5

  // ── Откладывание (snooze) ────────────────────────────────────────────────
  final int snoozeMinutes;      // 0 = Выкл., 5–30 мин с шагом 5
  final bool smartSnoozeEnabled;

  // ── Настроение после пробуждения ─────────────────────────────────────────
  final bool wakeMoodEnabled;

  // ── Время отхода ко сну ──────────────────────────────────────────────────
  final int bedtimeHour;        // 0–23
  final int bedtimeMinute;      // 0–59
  final bool bedtimeReminderEnabled;
  final int reminderOffsetHours;   // 0–3
  final int reminderOffsetMinutes; // 0–55, шаг 5

  // ── Факторы сна (дневник) ────────────────────────────────────────────────
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

  /// Иммутабельное копирование с изменением нужных полей.
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

  /// Форматированное время будильника, напр. "07:30".
  String get formattedAlarmTime =>
      '${alarmHour.toString().padLeft(2, '0')}:${alarmMinute.toString().padLeft(2, '0')}';

  /// Форматированное время отхода, напр. "23:00".
  String get formattedBedtime =>
      '${bedtimeHour.toString().padLeft(2, '0')}:${bedtimeMinute.toString().padLeft(2, '0')}';

  /// Смещение напоминания в виде "0ч. 30мин."
  String get formattedReminderOffset =>
      '$reminderOffsetHours ч. ${reminderOffsetMinutes.toString().padLeft(2, '0')} мин.';

  /// Текст откладывания: "Выкл." или "10 мин."
  String get formattedSnooze =>
      snoozeMinutes == 0 ? 'Выкл.' : '$snoozeMinutes мин.';
}

/// Встроенные мелодии будильника.
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
