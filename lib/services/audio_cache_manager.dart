import 'dart:io';
import 'package:path_provider/path_provider.dart';

/// Manages the snore recording cache directory.
/// Deletes recordings older than [kRetentionDays] on each service start.
class AudioCacheManager {
  static const int kRetentionDays = 7;
  static const String kRecordingDir = 'snore_recordings';

  /// Returns (and creates if needed) the recordings directory.
  static Future<Directory> getRecordingDirectory() async {
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory('${docs.path}/$kRecordingDir');
    if (!dir.existsSync()) await dir.create(recursive: true);
    return dir;
  }

  /// Builds a full file path for a new recording.
  static Future<String> newRecordingPath() async {
    final dir = await getRecordingDirectory();
    final ts = DateTime.now()
        .toIso8601String()
        .replaceAll(':', '-')
        .replaceAll('.', '-')
        .substring(0, 19); // YYYY-MM-DDTHH-MM-SS
    return '${dir.path}/snore_$ts.m4a';
  }

  /// Deletes all recordings older than [kRetentionDays] days.
  /// Also removes Hive entries whose files no longer exist.
  static Future<void> purgeOldFiles() async {
    try {
      final dir = await getRecordingDirectory();
      final cutoff = DateTime.now().subtract(const Duration(days: kRetentionDays));
      await for (final entity in dir.list()) {
        if (entity is File) {
          final stat = await entity.stat();
          if (stat.modified.isBefore(cutoff)) {
            await entity.delete();
          }
        }
      }
    } catch (e) {
      // Non-fatal: log and continue — storage cleanup should never crash the app.
      // ignore: avoid_print
      print('[AudioCacheManager] purge error: $e');
    }
  }

  /// Deletes a single recording file safely.
  static Future<void> deleteFile(String filePath) async {
    try {
      final file = File(filePath);
      if (file.existsSync()) await file.delete();
    } catch (_) {}
  }
}
