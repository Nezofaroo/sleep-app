import 'package:hive/hive.dart';


const int kSoundEventTypeId = 10;
const String kSoundEventBoxName = 'sound_events';


enum SoundEventType {
  mumble,
  snore,
  talk,
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


  static SoundEventType fromDuration(int seconds) {
    if (seconds < 2) return SoundEventType.mumble;
    if (seconds <= 10) return SoundEventType.snore;
    return SoundEventType.talk;
  }
}


class SoundEvent extends HiveObject {
  String id;
  String filePath;
  DateTime startTime;
  int durationSeconds;
  int typeIndex;
  double peakAmplitude;

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



Future<void> initSoundEventHive(String hivePath) async {
  Hive.init(hivePath);
  if (!Hive.isAdapterRegistered(kSoundEventTypeId)) {
    Hive.registerAdapter(SoundEventAdapter());
  }
  await Hive.openBox<SoundEvent>(kSoundEventBoxName);
}
