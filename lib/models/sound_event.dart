import 'package:hive/hive.dart';

// ── Hive type ID ──────────────────────────────────────────────────────────────
const int kSoundEventTypeId = 10;
const String kSoundEventBoxName = 'sound_events';

// ── Sound type enum ───────────────────────────────────────────────────────────
enum SoundEventType {
  mumble, // < 2 s
  snore,  // 2–10 s
  talk,   // > 10 s
}

extension SoundEventTypeExt on SoundEventType {
  String get label {
    switch (this) {
      case SoundEventType.mumble: return 'Mumble';
      case SoundEventType.snore:  return 'Snore';
      case SoundEventType.talk:   return 'Sleep Talk';
    }
  }

  String get emoji {
    switch (this) {
      case SoundEventType.mumble: return '💤';
      case SoundEventType.snore:  return '😴';
      case SoundEventType.talk:   return '🗣️';
    }
  }

  /// Classify based on recording duration in seconds.
  static SoundEventType fromDuration(int seconds) {
    if (seconds < 2) return SoundEventType.mumble;
    if (seconds <= 10) return SoundEventType.snore;
    return SoundEventType.talk;
  }
}

// ── Data model ────────────────────────────────────────────────────────────────
class SoundEvent extends HiveObject {
  String id;
  String filePath;
  DateTime startTime;
  int durationSeconds;
  int typeIndex; // store enum index for Hive compatibility
  double peakAmplitude; // dBFS (negative, e.g. -28.5)

  SoundEvent({
    required this.id,
    required this.filePath,
    required this.startTime,
    required this.durationSeconds,
    required this.typeIndex,
    required this.peakAmplitude,
  });

  SoundEventType get type => SoundEventType.values[typeIndex];

  String get formattedDuration {
    if (durationSeconds < 60) return '${durationSeconds}s';
    return '${durationSeconds ~/ 60}m ${durationSeconds % 60}s';
  }
}

// ── Manual TypeAdapter (replaces build_runner generated code) ─────────────────
class SoundEventAdapter extends TypeAdapter<SoundEvent> {
  @override
  final int typeId = kSoundEventTypeId;

  @override
  SoundEvent read(BinaryReader reader) {
    return SoundEvent(
      id:              reader.readString(),
      filePath:        reader.readString(),
      startTime:       DateTime.fromMillisecondsSinceEpoch(reader.readInt()),
      durationSeconds: reader.readInt(),
      typeIndex:       reader.readInt(),
      peakAmplitude:   reader.readDouble(),
    );
  }

  @override
  void write(BinaryWriter writer, SoundEvent obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.filePath);
    writer.writeInt(obj.startTime.millisecondsSinceEpoch);
    writer.writeInt(obj.durationSeconds);
    writer.writeInt(obj.typeIndex);
    writer.writeDouble(obj.peakAmplitude);
  }
}

// ── Hive initialisation helper ────────────────────────────────────────────────
/// Call once from main() and once from the background isolate entry-point.
Future<void> initSoundEventHive(String hivePath) async {
  Hive.init(hivePath);
  if (!Hive.isAdapterRegistered(kSoundEventTypeId)) {
    Hive.registerAdapter(SoundEventAdapter());
  }
  await Hive.openBox<SoundEvent>(kSoundEventBoxName);
}
