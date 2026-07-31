import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

import 'package:flutter/foundation.dart';

class RecorderService {
  static Process? _currentProcess;
  static bool _isRecording = false;

  static bool get isRecording => _isRecording;

  static Future<void> startRecording({String? rtmpUrl}) async {
    if (_isRecording) return;

    final docDir = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final outputPath = '${docDir.path}\\InkGuru_Lecture_$timestamp.mp4';

    List<String> ffmpegArgs;
    if (rtmpUrl != null && rtmpUrl.isNotEmpty) {
      ffmpegArgs = [
        '-f', 'gdigrab', '-framerate', '30', '-i', 'desktop', 
        '-f', 'dshow', '-i', 'audio=Microphone', 
        '-c:v', 'libx264', '-preset', 'ultrafast', '-pix_fmt', 'yuv420p', 
        '-c:a', 'aac', '-b:a', '128k', 
        '-f', 'tee', '[f=flv]$rtmpUrl|[f=mp4]$outputPath'
      ];
    } else {
      ffmpegArgs = [
        '-f', 'gdigrab', '-framerate', '30', '-i', 'desktop', 
        '-f', 'dshow', '-i', 'audio=Microphone', 
        '-c:v', 'libx264', '-preset', 'ultrafast', '-pix_fmt', 'yuv420p', 
        '-c:a', 'aac', '-b:a', '128k', outputPath
      ];
    }

    _isRecording = true;

    try {
      _currentProcess = await Process.start('ffmpeg', ffmpegArgs);
      
      _currentProcess!.exitCode.then((code) {
        _isRecording = false;
      });
    } catch (e) {
      debugPrint('Failed to start ffmpeg process: $e');
      _isRecording = false;
    }
  }

  static Future<void> stopRecording(List<Map<String, dynamic>> markers) async {
    if (!_isRecording || _currentProcess == null) return;
    
    _currentProcess!.stdin.writeln('q');
    await _currentProcess!.exitCode;
    _currentProcess = null;
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
