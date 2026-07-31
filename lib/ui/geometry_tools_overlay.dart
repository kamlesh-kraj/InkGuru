import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';

class GeometryToolsOverlay extends StatefulWidget {
  const GeometryToolsOverlay({super.key});

  @override
  State<GeometryToolsOverlay> createState() => _GeometryToolsOverlayState();
}

class _GeometryToolsOverlayState extends State<GeometryToolsOverlay> {
  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    if (appState.activeGeometryTool == GeometryTool.none) {
      return const SizedBox.shrink();
    }

    Widget toolWidget;
    switch (appState.activeGeometryTool) {
      case GeometryTool.ruler:
        toolWidget = _buildRuler(appState);
        break;
      case GeometryTool.protractor:
        toolWidget = _buildProtractor(appState);
        break;
      case GeometryTool.compass:
        toolWidget = _buildCompass(appState);
        break;
      default:
        toolWidget = const SizedBox.shrink();
    }

    return Positioned(
      left: appState.geometryPosition.dx,
      top: appState.geometryPosition.dy,
      child: GestureDetector(
        onPanUpdate: (details) {
          appState.updateGeometry(
            appState.geometryPosition + details.delta,
            appState.geometryAngle,
          );
        },
        child: Transform.rotate(
          angle: appState.geometryAngle,
          child: toolWidget,
        ),
      ),
    );
  }

  Widget _buildRuler(AppState appState) {
    return Container(
      width: 400,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.brown, width: 2),
      ),
      child: Stack(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(40, (index) {
              return Container(
                width: 1,
                height: index % 5 == 0 ? 20 : 10,
                color: Colors.black,
                margin: const EdgeInsets.only(top: 2),
              );
            }),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: GestureDetector(
              onPanUpdate: (details) {
                appState.updateGeometry(
                  appState.geometryPosition,
                  appState.geometryAngle + details.delta.dy * 0.01,
                );
              },
              child: const Icon(Icons.rotate_right, size: 24, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProtractor(AppState appState) {
    return Container(
      width: 300,
      height: 150,
      decoration: BoxDecoration(
        color: Colors.cyan.withValues(alpha: 0.6),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(150),
          topRight: Radius.circular(150),
        ),
        border: Border.all(color: Colors.teal, width: 2),
      ),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: GestureDetector(
              onPanUpdate: (details) {
                appState.updateGeometry(
                  appState.geometryPosition,
                  appState.geometryAngle + details.delta.dy * 0.01,
                );
              },
              child: const Icon(Icons.rotate_right, size: 24, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompass(AppState appState) {
    return Container(
      width: 100,
      height: 200,
      decoration: BoxDecoration(
        color: Colors.purple.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.architecture, size: 50, color: Colors.black),
          GestureDetector(
            onPanUpdate: (details) {
              appState.updateGeometry(
                appState.geometryPosition,
                appState.geometryAngle + details.delta.dx * 0.01,
              );
            },
            child: const Icon(Icons.rotate_right, size: 24, color: Colors.black),
          ),
        ],
      ),
    );
  }
}
