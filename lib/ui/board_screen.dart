import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import '../canvas/drawing_canvas.dart';
import 'tool_rail.dart';
import 'top_bar.dart';
import 'right_panel.dart';
import 'webcam_pip.dart';
import 'timer_widget.dart';
import 'geometry_tools_overlay.dart';
import 'page_navigator.dart';
import 'interactive_overlays.dart';
import 'lasso_context_menu.dart';

class BoardScreen extends StatelessWidget {
  const BoardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return Scaffold(
      body: Row(
        children: [
          const ToolRail(),
          Expanded(
            child: Stack(
              children: [
                const DrawingCanvas(),
                const GeometryToolsOverlay(),
                const Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Column(
                    children: [
                      TopBar(),
                      PageNavigator(),
                    ],
                  ),
                ),
                if (appState.showWebcam) const WebcamPip(),
                if (appState.showTimer) const TimerWidget(),
                if (appState.isTranscribing)
                  Positioned(
                    bottom: 20,
                    left: 200,
                    right: 200,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Text(
                        'Live Transcript: "Welcome to today\'s lesson on calculus..."',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                if (appState.isSpotlightActive) const SpotlightOverlay(),
                if (appState.isCurtainActive) const CurtainOverlay(),
                const LassoContextMenu(),
              ],
            ),
          ),
          const RightPanel(),
        ],
      ),
    );
  }
}
