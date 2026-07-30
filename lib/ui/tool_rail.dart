import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';

class ToolRail extends StatelessWidget {
  const ToolRail({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return Container(
          width: 70,
          color: Colors.grey[900],
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(
                  Icons.edit,
                  color: appState.currentPenType == PenType.pen
                      ? Colors.blueAccent
                      : Colors.white,
                ),
                onPressed: () => appState.setPenType(PenType.pen),
                tooltip: 'Pen',
              ),
              IconButton(
                icon: Icon(
                  Icons.cleaning_services,
                  color: appState.currentPenType == PenType.eraser
                      ? Colors.blueAccent
                      : Colors.white,
                ),
                onPressed: () => appState.setPenType(PenType.eraser),
                tooltip: 'Eraser',
              ),
              const Divider(color: Colors.grey),
              IconButton(
                icon: const Icon(Icons.undo, color: Colors.white),
                onPressed: () => appState.undo(),
                tooltip: 'Undo',
              ),
              IconButton(
                icon: const Icon(Icons.redo, color: Colors.white),
                onPressed: () => appState.redo(),
                tooltip: 'Redo',
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                onPressed: () => appState.clearBoard(),
                tooltip: 'Clear Board',
              ),
              const Divider(color: Colors.grey),
              IconButton(
                icon: Icon(
                  Icons.horizontal_rule,
                  color: appState.currentShapeType == ShapeType.line
                      ? Colors.blueAccent
                      : Colors.white,
                ),
                onPressed: () => appState.setShapeType(ShapeType.line),
                tooltip: 'Line',
              ),
              IconButton(
                icon: Icon(
                  Icons.crop_square,
                  color: appState.currentShapeType == ShapeType.rectangle
                      ? Colors.blueAccent
                      : Colors.white,
                ),
                onPressed: () => appState.setShapeType(ShapeType.rectangle),
                tooltip: 'Rectangle',
              ),
              IconButton(
                icon: Icon(
                  Icons.radio_button_unchecked,
                  color: appState.currentShapeType == ShapeType.circle
                      ? Colors.blueAccent
                      : Colors.white,
                ),
                onPressed: () => appState.setShapeType(ShapeType.circle),
                tooltip: 'Circle',
              ),
              const Divider(color: Colors.grey),
              _ColorButton(color: Colors.red, appState: appState),
              _ColorButton(color: Colors.green, appState: appState),
              _ColorButton(color: Colors.blue, appState: appState),
              _ColorButton(color: Colors.white, appState: appState),
            ],
          ),
        );
  }
}

class _ColorButton extends StatelessWidget {
  final Color color;
  final AppState appState;

  const _ColorButton({required this.color, required this.appState});

  @override
  Widget build(BuildContext context) {
    final isSelected = appState.currentColor == color &&
        appState.currentPenType == PenType.pen;
        
    return GestureDetector(
      onTap: () => appState.setColor(color),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? Colors.blueAccent : Colors.grey,
            width: isSelected ? 3 : 1,
          ),
        ),
      ),
    );
  }
}
