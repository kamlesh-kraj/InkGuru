import 'package:flutter/material.dart';
import 'dart:io' show Platform;

/// WebcamPip widget - shows a draggable webcam picture-in-picture overlay.
/// Camera functionality is only supported on mobile platforms.
/// On Windows/Linux/macOS desktop, this shows a placeholder.
class WebcamPip extends StatefulWidget {
  const WebcamPip({super.key});

  @override
  State<WebcamPip> createState() => _WebcamPipState();
}

class _WebcamPipState extends State<WebcamPip> {
  Offset _position = const Offset(20, 80);
  bool get _isDesktop =>
      Platform.isWindows || Platform.isLinux || Platform.isMacOS;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: _position.dx,
      top: _position.dy,
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            _position += details.delta;
          });
        },
        child: Container(
          width: 200,
          height: 150,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 10,
                spreadRadius: 2,
              )
            ],
            border: Border.all(color: Colors.blueAccent, width: 2),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: _isDesktop
                ? _buildDesktopPlaceholder()
                : _buildDesktopPlaceholder(),
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopPlaceholder() {
    return Container(
      color: Colors.black87,
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.videocam_off, color: Colors.white54, size: 36),
          SizedBox(height: 8),
          Text(
            'Webcam',
            style: TextStyle(color: Colors.white54, fontSize: 12),
          ),
          Text(
            '(Desktop preview)',
            style: TextStyle(color: Colors.white38, fontSize: 10),
          ),
        ],
      ),
    );
  }
}
