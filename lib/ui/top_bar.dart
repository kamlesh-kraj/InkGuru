import 'package:flutter/material.dart';
import 'settings_screen.dart';

class TopBar extends StatelessWidget {
  const TopBar({super.key});

  Future<void> _importSlide(BuildContext context) async {
    // Mocking file picker for MVP to avoid platform getter issues
    // Mocking file picker for MVP
    // In production, we'd use file_picker or image_picker
    // FilePickerResult? result = await FilePicker.platform.pickFiles();
  }

  void _showToolMockup(BuildContext context, String toolName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(toolName),
        content: Text('$toolName is running in mockup mode for this demo.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      color: Colors.grey[850],
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'InkGuru',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.cloud_sync, color: Colors.greenAccent),
                tooltip: 'Cloud Sync',
                onPressed: () => _showToolMockup(context, 'Cloud Sync'),
              ),
              IconButton(
                icon: const Icon(Icons.timer, color: Colors.orangeAccent),
                tooltip: 'Timer & Stopwatch',
                onPressed: () => _showToolMockup(context, 'Timer / Stopwatch'),
              ),
              IconButton(
                icon: const Icon(Icons.casino, color: Colors.purpleAccent),
                tooltip: 'Random Student Picker',
                onPressed: () => _showToolMockup(context, 'Random Student Picker'),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: () => _importSlide(context),
                icon: const Icon(Icons.image),
                label: const Text('Import Slide'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.mic, color: Colors.white),
                tooltip: 'Mic Audio',
                onPressed: () => _showToolMockup(context, 'Mic Toggle'),
              ),
              IconButton(
                icon: const Icon(Icons.videocam, color: Colors.white),
                tooltip: 'Webcam Pip',
                onPressed: () => _showToolMockup(context, 'Webcam Overlay'),
              ),
              IconButton(
                icon: const Icon(Icons.settings, color: Colors.white),
                tooltip: 'Settings',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SettingsScreen()),
                  );
                },
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Starting local & cloud recording...')),
                  );
                },
                icon: const Icon(Icons.fiber_manual_record),
                label: const Text('Record'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
