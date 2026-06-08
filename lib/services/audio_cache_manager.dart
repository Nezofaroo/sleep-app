import 'dart:io';
import 'package:path_provider/path_provider.dart';



class AudioCacheManager {
  static const int kRetentionDays = 7;
  static const String kRecordingDir = 'snore_recordings';


  static Future<Directory> getRecordingDirectory() async {
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory('${docs.path}/$kRecordingDir');
    if (!dir.existsSync()) await dir.create(recursive: true);
    return dir;
  }


  static Future<String> newRecordingPath() async {
    final dir = await getRecordingDirectory();
    final ts = DateTime.now()
        .toIso8601String()
        .replaceAll(':', '-')
        .replaceAll('.', '-')
        .substring(0, 19);
    return '${dir.path}/snore_$ts.m4a';
  }



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


      print('[AudioCacheManager] purge error: $e');
    }
  }


  static Future<void> deleteFile(String filePath) async {
    try {
      final file = File(filePath);
      if (file.existsSync()) await file.delete();
    } catch (_) {}
  }
}
