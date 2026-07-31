import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import '../services/ai_service.dart';
import '../utils/drawing_utils.dart';

class LassoContextMenu extends StatefulWidget {
  const LassoContextMenu({super.key});

  @override
  State<LassoContextMenu> createState() => _LassoContextMenuState();
}

class _LassoContextMenuState extends State<LassoContextMenu> {
  bool _isProcessing = false;

  void _processAI(BuildContext context, bool isMath) async {
    final appState = context.read<AppState>();
    if (appState.aiApiKey == null || appState.aiApiKey!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please set your AI API Key in Settings first.')),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      final rect = appState.selectionRect!;
      // Find strokes in selection
      final selectedStrokes = appState.strokes.where((stroke) {
        return stroke.points.any((p) => rect.contains(p.point + stroke.translation));
      }).toList();

      if (selectedStrokes.isEmpty) {
        setState(() {
          _isProcessing = false;
        });
        return;
      }

      final imageBytes = await DrawingUtils.rasterizeStrokesToImage(selectedStrokes, rect);
      
      if (imageBytes != null) {
        final aiService = AIService(apiKey: appState.aiApiKey!);
        
        if (isMath) {
          final latex = await aiService.convertMathToLatex(imageBytes);
          if (!context.mounted) return;
          if (latex.isNotEmpty) {
            appState.incrementAiUsage();
            appState.addEquation(CanvasEquation(tex: latex, position: rect.topLeft));
            // Optional: delete original strokes
            for (var s in selectedStrokes) {
              appState.removeStroke(s);
            }
          }
        } else {
          final text = await aiService.convertHandwritingToText(imageBytes);
          if (!context.mounted) return;
          if (text.isNotEmpty) {
            appState.incrementAiUsage();
            appState.addText(CanvasText(
              text: text, 
              position: rect.topLeft, 
              style: const TextStyle(fontSize: 24, color: Colors.black)
            ));
            for (var s in selectedStrokes) {
              appState.removeStroke(s);
            }
          }
        }
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      appState.clearSelection();
      setState(() {
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    if (!appState.hasSelection || appState.selectionRect == null) return const SizedBox.shrink();

    final rect = appState.selectionRect!;
    
    return Positioned(
      left: rect.left,
      top: rect.bottom + 10,
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: _isProcessing 
            ? const Padding(
                padding: EdgeInsets.all(8.0),
                child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
              )
            : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.text_fields, color: Colors.blue),
                tooltip: 'Convert to Text',
                onPressed: () => _processAI(context, false),
              ),
              IconButton(
                icon: const Icon(Icons.functions, color: Colors.green),
                tooltip: 'Convert to Math',
                onPressed: () => _processAI(context, true),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                tooltip: 'Delete Selection',
                onPressed: () {
                  final selectedStrokes = appState.strokes.where((stroke) {
                    return stroke.points.any((p) => rect.contains(p.point + stroke.translation));
                  }).toList();
                  for (var s in selectedStrokes) {
                    appState.removeStroke(s);
                  }
                  appState.clearSelection();
                },
              ),
              IconButton(
                icon: const Icon(Icons.close),
                tooltip: 'Cancel',
                onPressed: () {
                  appState.clearSelection();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
