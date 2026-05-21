class SleepRecord {
  final int? id;
  final DateTime startTime;
  final DateTime? endTime;
  final int? durationMinutes; // total sleep in minutes
  final String? alarmTime; // stored as HH:mm string
  final String? quality; // 'Poor', 'Fair', 'Good', 'Excellent'
  final String? notes;

  SleepRecord({
    this.id,
    required this.startTime,
    this.endTime,
    this.durationMinutes,
    this.alarmTime,
    this.quality,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'durationMinutes': durationMinutes,
      'alarmTime': alarmTime,
      'quality': quality,
      'notes': notes,
    };
  }

  factory SleepRecord.fromMap(Map<String, dynamic> map) {
    return SleepRecord(
      id: map['id'] as int?,
      startTime: DateTime.parse(map['startTime'] as String),
      endTime: map['endTime'] != null ? DateTime.parse(map['endTime'] as String) : null,
      durationMinutes: map['durationMinutes'] as int?,
      alarmTime: map['alarmTime'] as String?,
      quality: map['quality'] as String?,
      notes: map['notes'] as String?,
    );
  }

  SleepRecord copyWith({
    int? id,
    DateTime? startTime,
    DateTime? endTime,
    int? durationMinutes,
    String? alarmTime,
    String? quality,
    String? notes,
  }) {
    return SleepRecord(
      id: id ?? this.id,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      alarmTime: alarmTime ?? this.alarmTime,
      quality: quality ?? this.quality,
      notes: notes ?? this.notes,
    );
  }

  String get formattedDuration {
    if (durationMinutes == null) return '--';
    final h = durationMinutes! ~/ 60;
    final m = durationMinutes! % 60;
    return '${h}h ${m.toString().padLeft(2, '0')}m';
  }
}
