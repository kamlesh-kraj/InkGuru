import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';

class RightPanel extends StatefulWidget {
  const RightPanel({super.key});

  @override
  State<RightPanel> createState() => _RightPanelState();
}

class _RightPanelState extends State<RightPanel> {
  bool _isOpen = false;

  final List<Map<String, String>> _stamps = [
    {'id': 'star', 'label': 'Star'},
    {'id': 'check', 'label': 'Check'},
    {'id': 'close', 'label': 'Cross'},
    {'id': 'thumb_up', 'label': 'Thumbs Up'},
    {'id': 'favorite', 'label': 'Heart'},
    {'id': 'warning', 'label': 'Warning'},
    {'id': 'school', 'label': 'School'},
    {'id': 'emoji_emotions', 'label': 'Smile'},
  ];

  IconData _getIconData(String id) {
    switch (id) {
      case 'star': return Icons.star;
      case 'check': return Icons.check_circle;
      case 'close': return Icons.cancel;
      case 'thumb_up': return Icons.thumb_up;
      case 'favorite': return Icons.favorite;
      case 'warning': return Icons.warning;
      case 'school': return Icons.school;
      case 'emoji_emotions': return Icons.emoji_emotions;
      default: return Icons.star;
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

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
                  const Text('Stickers & Stamps', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _stamps.map((stamp) {
                      final isSelected = appState.currentPenType == PenType.stamp && appState.currentStampId == stamp['id'];
                      return InkWell(
                        onTap: () {
                          appState.setStampId(stamp['id']!);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.blueAccent.withValues(alpha: 0.5) : Colors.grey[800],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: isSelected ? Colors.blueAccent : Colors.transparent),
                          ),
                          child: Icon(_getIconData(stamp['id']!), color: Colors.white),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  const Divider(color: Colors.grey),
                  const Text('Smart Shapes', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  _buildChemistryTool(context, 'Rough-to-Perfect', ShapeType.smart),
                  const Divider(color: Colors.grey),
                  const Text('Asset Library (Built-in)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  _buildLocalAsset(context, 'Human Anatomy', 'assets/anatomy.png'),
                  _buildLocalAsset(context, 'India Map', 'assets/india_map.png'),
                  _buildLocalAsset(context, 'World Map', 'assets/world_map.png'),
                  _buildLocalAsset(context, 'Physics Forces', 'assets/physics_diagram.png'),
                  const Divider(color: Colors.grey),
                  const Text('Chemistry Tools', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  _buildChemistryTool(context, 'Benzene Ring', ShapeType.benzene),
                  _buildChemistryTool(context, 'Cyclohexane', ShapeType.cyclohexane),
                  const Divider(color: Colors.grey),
                  const Text('Backgrounds', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  _buildBackgroundTool(context, 'Blank', BackgroundTemplate.blank),
                  _buildBackgroundTool(context, 'Ruled', BackgroundTemplate.ruled),
                  _buildBackgroundTool(context, 'Grid (Math)', BackgroundTemplate.grid),
                  _buildBackgroundTool(context, 'Dot Grid', BackgroundTemplate.dotGrid),
                  _buildBackgroundTool(context, 'Music Staff', BackgroundTemplate.music),
                  const Divider(color: Colors.grey),
                  const Text('Classroom Tools', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  _buildAITool(
                    context, 
                    'Quick Poll', 
                    () => _showQuickPollDialog(context),
                  ),
                  _buildAITool(
                    context, 
                    'Spotlight', 
                    () => appState.toggleSpotlight(),
                    isActive: appState.isSpotlightActive,
                  ),
                  _buildAITool(
                    context, 
                    'Curtain', 
                    () => appState.toggleCurtain(),
                    isActive: appState.isCurtainActive,
                  ),
                  const Divider(color: Colors.grey),
                  const Text('AI Tools', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  _buildAITool(
                    context, 
                    'Auto-Transcription', 
                    () => appState.toggleTranscription(),
                    isActive: appState.isTranscribing,
                  ),
                  _buildAITool(
                    context, 
                    'Smart Search', 
                    () => _showSmartSearchDialog(context),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLocalAsset(BuildContext context, String name, String assetPath) {
    return InkWell(
      onTap: () {
        final appState = Provider.of<AppState>(context, listen: false);
        appState.addCanvasImage(CanvasImage(
          path: assetPath,
          position: const Offset(300, 150),
          size: const Size(400, 400),
        ));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Added $name to canvas')),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8.0),
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Colors.grey[800],
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            const Icon(Icons.image, color: Colors.blueAccent, size: 20),
            const SizedBox(width: 8),
            Text(name, style: const TextStyle(color: Colors.white70)),
          ],
        ),
      ),
    );
  }

  Widget _buildChemistryTool(BuildContext context, String name, ShapeType type) {
    final appState = Provider.of<AppState>(context, listen: true);
    final isActive = appState.currentPenType == PenType.shape && appState.currentShapeType == type;

    return InkWell(
      onTap: () {
        appState.setPenType(PenType.shape);
        appState.setShapeType(type);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8.0),
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: isActive ? Colors.blueAccent.withValues(alpha: 0.3) : Colors.grey[800],
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: isActive ? Colors.blueAccent : Colors.transparent),
        ),
        child: Row(
          children: [
            const Icon(Icons.science, color: Colors.blueAccent, size: 20),
            const SizedBox(width: 8),
            Text(name, style: const TextStyle(color: Colors.white70)),
          ],
        ),
      ),
    );
  }

  Widget _buildAITool(BuildContext context, String name, VoidCallback onTap, {bool isActive = false}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8.0),
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: isActive ? Colors.blueAccent.withValues(alpha: 0.3) : Colors.grey[800],
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: isActive ? Colors.blueAccent : Colors.transparent),
        ),
        child: Row(
          children: [
            Icon(
              name == 'Auto-Transcription' ? Icons.subtitles : 
              name == 'Smart Search' ? Icons.search :
              name == 'Spotlight' ? Icons.highlight :
              name == 'Curtain' ? Icons.visibility_off : Icons.build,
              color: Colors.white, size: 20
            ),
            const SizedBox(width: 8),
            Text(name, style: const TextStyle(color: Colors.white70)),
          ],
        ),
      ),
    );
  }

  void _showSmartSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Smart AI Search'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const TextField(
              decoration: InputDecoration(
                hintText: 'Search handwriting, notes, tags...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            const Text('AI is indexing your handwritten notes for semantic search.', style: TextStyle(color: Colors.grey)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
          ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Search')),
        ],
      ),
    );
  }

  void _showQuickPollDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Broadcast Quick Poll'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const TextField(
              decoration: InputDecoration(
                hintText: 'e.g. What is the derivative of x^2?',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            const TextField(
              decoration: InputDecoration(hintText: 'Option A'),
            ),
            const TextField(
              decoration: InputDecoration(hintText: 'Option B'),
            ),
            const TextField(
              decoration: InputDecoration(hintText: 'Option C'),
            ),
            const SizedBox(height: 16),
            const Text('Students will see this poll on their devices.', style: TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Poll Broadcasted to Class!')));
            },
            child: const Text('Broadcast'),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundTool(BuildContext context, String name, BackgroundTemplate template) {
    final appState = Provider.of<AppState>(context, listen: true);
    final isActive = appState.pages[appState.currentPageIndex].background == template;
    return InkWell(
      onTap: () => appState.setPageBackground(template),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8.0),
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: isActive ? Colors.blueAccent.withValues(alpha: 0.3) : Colors.grey[800],
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: isActive ? Colors.blueAccent : Colors.transparent),
        ),
        child: Row(
          children: [
            const Icon(Icons.wallpaper, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(name, style: const TextStyle(color: Colors.white70)),
          ],
        ),
      ),
    );
  }
}
