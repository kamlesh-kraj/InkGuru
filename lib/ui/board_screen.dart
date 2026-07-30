import 'package:flutter/material.dart';
import '../canvas/drawing_canvas.dart';
import 'tool_rail.dart';
import 'top_bar.dart';
import 'right_panel.dart';

class BoardScreen extends StatelessWidget {
  const BoardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          const ToolRail(),
          Expanded(
            child: Stack(
              children: [
                const DrawingCanvas(),
                const Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: TopBar(),
                ),
              ],
            ),
          ),
          const RightPanel(),
        ],
      ),
    );
  }
}
