import 'package:flutter/material.dart';

class RightPanel extends StatefulWidget {
  const RightPanel({super.key});

  @override
  State<RightPanel> createState() => _RightPanelState();
}

class _RightPanelState extends State<RightPanel> {
  bool _isOpen = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: _isOpen ? 250 : 40,
      color: Colors.grey[900],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconButton(
            icon: Icon(_isOpen ? Icons.chevron_right : Icons.chevron_left, color: Colors.white),
            onPressed: () {
              setState(() {
                _isOpen = !_isOpen;
              });
            },
          ),
          if (_isOpen)
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(8.0),
                children: [
                  const Text('Asset Library', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  _buildMockAsset('Science Diagram'),
                  _buildMockAsset('Math Symbols'),
                  _buildMockAsset('World Map'),
                  const Divider(color: Colors.grey),
                  const Text('Equation Editor', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Container(
                    height: 100,
                    color: Colors.grey[800],
                    child: const Center(child: Text('LaTeX / Ink Equation\n(Mockup)', textAlign: TextAlign.center, style: TextStyle(color: Colors.white70))),
                  ),
                  const Divider(color: Colors.grey),
                  const Text('AI Tools', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  _buildMockAsset('Auto-Transcription'),
                  _buildMockAsset('Smart Search'),
                  _buildMockAsset('Ink-to-Text'),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMockAsset(String name) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8.0),
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(name, style: const TextStyle(color: Colors.white70)),
    );
  }
}
