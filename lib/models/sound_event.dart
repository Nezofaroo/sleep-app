import 'package:hive/hive.dart';


const int kSoundEventTypeId = 10;
const String kSoundEventBoxName = 'sound_events';


enum SoundEventType {
  snore,          // Храп
  talk,           // Разговоры во сне
  cough,          // Кашель
  fart,           // Пуканье
  animals,        // Животные
  environmental,  // Экологический
  other,          // Другое
}

extension SoundEventTypeExt on SoundEventType {
  String get label {
    switch (this) {
      case SoundEventType.snore:         return 'Храп';
      case SoundEventType.talk:          return 'Разговоры во сне';
      case SoundEventType.cough:         return 'Кашель';
      case SoundEventType.fart:          return 'Пуканье';
      case SoundEventType.animals:       return 'Животные';
      case SoundEventType.environmental: return 'Экологический';
      case SoundEventType.other:         return 'Другое';
    }
  }

  String get emoji {
    switch (this) {
      case SoundEventType.snore:         return '😴';
      case SoundEventType.talk:          return '🗣️';
      case SoundEventType.cough:         return '😷';
      case SoundEventType.fart:          return '💨';
      case SoundEventType.animals:       return '🐾';
      case SoundEventType.environmental: return '🏡';
      case SoundEventType.other:         return '🎵';
    }
  }

  static SoundEventType fromDuration(int seconds) {
    final rand = (DateTime.now().millisecond + seconds) % 10;
    if (seconds < 2) {
      if (rand < 4) return SoundEventType.fart;
      if (rand < 7) return SoundEventType.cough;
      return SoundEventType.other;
    } else if (seconds <= 10) {
      if (rand < 6) return SoundEventType.snore;
      if (rand < 8) return SoundEventType.animals;
      return SoundEventType.environmental;
    } else {
      if (rand < 8) return SoundEventType.talk;
      return SoundEventType.other;
    }
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
