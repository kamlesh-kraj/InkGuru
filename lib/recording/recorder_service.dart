import 'dart:convert';
import 'dart:io';
import 'package:ffmpeg_kit_flutter_video/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_video/ffmpeg_session.dart';
import 'package:path_provider/path_provider.dart';

class RecorderService {
  static FFmpegSession? _currentSession;
  static bool _isRecording = false;

  static bool get isRecording => _isRecording;

  static Future<void> startRecording({String? rtmpUrl}) async {
    if (_isRecording) return;

    final docDir = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final outputPath = '${docDir.path}\\InkGuru_Lecture_$timestamp.mp4';

    String ffmpegCommand;
    if (rtmpUrl != null && rtmpUrl.isNotEmpty) {
      ffmpegCommand = '-f gdigrab -framerate 30 -i desktop -f dshow -i audio="Microphone" '
          '-c:v libx264 -preset ultrafast -pix_fmt yuv420p -c:a aac -b:a 128k '
          '-f tee "[f=flv]$rtmpUrl|[f=mp4]$outputPath"';
    } else {
      ffmpegCommand = '-f gdigrab -framerate 30 -i desktop -f dshow -i audio="Microphone" '
          '-c:v libx264 -preset ultrafast -pix_fmt yuv420p -c:a aac -b:a 128k "$outputPath"';
    }

    _isRecording = true;

    _currentSession = await FFmpegKit.executeAsync(ffmpegCommand, (session) async {
      await session.getReturnCode();
      _isRecording = false;
    });
  }

  static Future<void> stopRecording(List<Map<String, dynamic>> markers) async {
    if (!_isRecording || _currentSession == null) return;
    
    await FFmpegKit.cancel();
    _isRecording = false;

    if (markers.isNotEmpty) {
      try {
        final docDir = await getApplicationDocumentsDirectory();
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final markersFile = File('${docDir.path}\\InkGuru_Markers_$timestamp.json');
        await markersFile.writeAsString(jsonEncode(markers));
      } catch (e) {
        // Ignore error
      }
    }
  }
}
