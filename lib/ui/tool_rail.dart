import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';

class ToolRail extends StatelessWidget {
  const ToolRail({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    final List<Widget> items = appState.toolbarLayout.map((item) => _buildGroup(item, appState)).toList();

    return Container(
      width: 70,
      color: Colors.grey[900],
      child: ReorderableListView(
        buildDefaultDragHandles: true,
        padding: const EdgeInsets.symmetric(vertical: 20),
        onReorder: (int oldIndex, int newIndex) {
          appState.reorderToolbar(oldIndex, newIndex);
        },
        children: items,
      ),
    );
  }

  Widget _buildGroup(ToolbarItem item, AppState appState) {
    switch (item) {
      case ToolbarItem.pen:
        return Column(key: ValueKey(item), children: [
          _buildPenTool(appState, PenType.pan, Icons.pan_tool, 'Pan', key: const ValueKey('pan')),
          _buildPenTool(appState, PenType.pen, Icons.edit, 'Pen', key: const ValueKey('pen')),
          _buildPenTool(appState, PenType.lasso, Icons.gesture, 'Lasso Select', key: const ValueKey('lasso')),
          _buildPenTool(appState, PenType.laser, Icons.adjust, 'Laser Pointer', key: const ValueKey('laser'), activeColor: Colors.redAccent),
        ]);
      case ToolbarItem.highlighter:
        return Column(key: ValueKey(item), children: [
          _buildPenTool(appState, PenType.highlighter, Icons.highlight, 'Highlighter', key: const ValueKey('highlighter')),
        ]);
      case ToolbarItem.eraser:
        return Column(key: ValueKey(item), children: [
          _buildPenTool(appState, PenType.eraser, Icons.cleaning_services, 'Eraser', key: const ValueKey('eraser')),
        ]);
      case ToolbarItem.shapes:
        return Column(key: ValueKey(item), children: [
          const Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Divider(color: Colors.grey)),
          _buildShapeTool(appState, ShapeType.line, Icons.horizontal_rule, 'Line', key: const ValueKey('line')),
          _buildShapeTool(appState, ShapeType.rectangle, Icons.crop_square, 'Rectangle', key: const ValueKey('rect')),
          _buildShapeTool(appState, ShapeType.circle, Icons.radio_button_unchecked, 'Circle', key: const ValueKey('circle')),
          _buildGeometryTool(appState, GeometryTool.ruler, Icons.straighten, 'Ruler', Colors.amberAccent, key: const ValueKey('ruler')),
          _buildGeometryTool(appState, GeometryTool.protractor, Icons.av_timer, 'Protractor', Colors.cyanAccent, key: const ValueKey('prot')),
          _buildGeometryTool(appState, GeometryTool.compass, Icons.architecture, 'Compass', Colors.purpleAccent, key: const ValueKey('comp')),
        ]);
      case ToolbarItem.text:
        return Column(key: ValueKey(item), children: [
          const Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Divider(color: Colors.grey)),
          _buildPenTool(appState, PenType.text, Icons.text_fields, 'Text Box', key: const ValueKey('text')),
        ]);
      case ToolbarItem.stamp:
        return Column(key: ValueKey(item), children: [
          _buildPenTool(appState, PenType.stamp, Icons.emoji_emotions, 'Stamp Tool', key: const ValueKey('stamp')),
        ]);
      case ToolbarItem.undo:
        return Column(key: ValueKey(item), children: [
          const Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Divider(color: Colors.grey)),
          IconButton(icon: const Icon(Icons.undo, color: Colors.white), onPressed: () => appState.undo(), tooltip: 'Undo', key: const ValueKey('undo')),
          IconButton(icon: const Icon(Icons.delete_outline, color: Colors.redAccent), onPressed: () => appState.clearBoard(), tooltip: 'Clear Board', key: const ValueKey('clear')),
        ]);
      case ToolbarItem.redo:
        return Column(key: ValueKey(item), children: [
          IconButton(icon: const Icon(Icons.redo, color: Colors.white), onPressed: () => appState.redo(), tooltip: 'Redo', key: const ValueKey('redo')),
        ]);
      case ToolbarItem.colors:
        return Column(key: ValueKey(item), children: [
          const Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Divider(color: Colors.grey)),
          _ColorButton(color: Colors.red, appState: appState, key: const ValueKey('c_red')),
          _ColorButton(color: Colors.green, appState: appState, key: const ValueKey('c_green')),
          _ColorButton(color: Colors.blue, appState: appState, key: const ValueKey('c_blue')),
          _ColorButton(color: Colors.white, appState: appState, key: const ValueKey('c_white')),
        ]);
    }
  }

  Widget _buildPenTool(AppState appState, PenType type, IconData icon, String tooltip, {required Key key, Color activeColor = Colors.blueAccent}) {
    return IconButton(
      key: key,
      icon: Icon(icon, color: appState.currentPenType == type ? activeColor : Colors.white),
      onPressed: () => appState.setPenType(type),
      tooltip: tooltip,
    );
  }

  Widget _buildShapeTool(AppState appState, ShapeType type, IconData icon, String tooltip, {required Key key}) {
    return IconButton(
      key: key,
      icon: Icon(icon, color: appState.currentShapeType == type ? Colors.blueAccent : Colors.white),
      onPressed: () => appState.setShapeType(type),
      tooltip: tooltip,
    );
  }

  Widget _buildGeometryTool(AppState appState, GeometryTool type, IconData icon, String tooltip, Color activeColor, {required Key key}) {
    return IconButton(
      key: key,
      icon: Icon(icon, color: appState.activeGeometryTool == type ? activeColor : Colors.white),
      onPressed: () => appState.toggleGeometryTool(type),
      tooltip: tooltip,
    );
  }
}

class _ColorButton extends StatelessWidget {
  final Color color;
  final AppState appState;

  const _ColorButton({super.key, required this.color, required this.appState});

  @override
  Widget build(BuildContext context) {
    final isSelected = appState.currentColor == color &&
        (appState.currentPenType == PenType.pen || appState.currentPenType == PenType.highlighter);
        
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
