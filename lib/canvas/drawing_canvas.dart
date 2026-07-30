import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';

class DrawingCanvas extends StatelessWidget {
  const DrawingCanvas({super.key});

  Widget _buildBackgroundImage(String path) {
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return Image.network(path, fit: BoxFit.cover);
    } else if (path.startsWith('assets/')) {
      return Image.asset(path, fit: BoxFit.cover);
    } else {
      return Image.file(File(path), fit: BoxFit.cover);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return Stack(
          fit: StackFit.expand,
          children: [
            if (appState.backgroundImagePath != null)
              _buildBackgroundImage(appState.backgroundImagePath!),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onPanStart: (details) {
                final RenderBox box = context.findRenderObject() as RenderBox;
                final offset = box.globalToLocal(details.globalPosition);
                appState.addStroke(Stroke(
                  points: [offset],
                  color: appState.currentColor,
                  width: appState.currentWidth,
                  penType: appState.currentPenType,
                  shapeType: appState.currentShapeType,
                  shapeStart: appState.currentPenType == PenType.shape ? offset : null,
                  shapeEnd: appState.currentPenType == PenType.shape ? offset : null,
                ));
              },
              onPanUpdate: (details) {
                final RenderBox box = context.findRenderObject() as RenderBox;
                final offset = box.globalToLocal(details.globalPosition);
                appState.addPointToLastStroke(offset);
              },
              onPanEnd: (details) {
                // Handled if necessary
              },
              child: RepaintBoundary(
                child: CustomPaint(
                  painter: DrawingPainter(
                    strokes: appState.strokes,
                  ),
                  size: Size.infinite,
                ),
              ),
            ),
          ],
        );
  }
}

class DrawingPainter extends CustomPainter {
  final List<Stroke> strokes;

  DrawingPainter({required this.strokes});

  @override
  void paint(Canvas canvas, Size size) {
    // Save a layer to allow BlendMode.clear to function without punching through the app's background
    canvas.saveLayer(Rect.fromLTWH(0, 0, size.width, size.height), Paint());

    for (final stroke in strokes) {
      final paint = Paint()
        ..strokeWidth = stroke.width
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;

      if (stroke.penType == PenType.eraser) {
        paint.color = Colors.transparent;
        paint.blendMode = BlendMode.clear;
      } else {
        paint.color = stroke.color;
        paint.blendMode = BlendMode.srcOver;
      }

      if (stroke.penType == PenType.shape && stroke.shapeStart != null && stroke.shapeEnd != null) {
        if (stroke.shapeType == ShapeType.line) {
          canvas.drawLine(stroke.shapeStart!, stroke.shapeEnd!, paint);
        } else if (stroke.shapeType == ShapeType.rectangle) {
          canvas.drawRect(Rect.fromPoints(stroke.shapeStart!, stroke.shapeEnd!), paint);
        } else if (stroke.shapeType == ShapeType.circle) {
          final rect = Rect.fromPoints(stroke.shapeStart!, stroke.shapeEnd!);
          canvas.drawOval(rect, paint);
        }
      } else {
        if (stroke.points.isEmpty) continue;
  
        if (stroke.points.length == 1) {
          canvas.drawPoints(ui.PointMode.points, stroke.points, paint);
        } else {
          final path = Path();
          path.moveTo(stroke.points.first.dx, stroke.points.first.dy);
          for (int i = 1; i < stroke.points.length; i++) {
            path.lineTo(stroke.points[i].dx, stroke.points[i].dy);
          }
          canvas.drawPath(path, paint);
        }
      }
    }
    
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant DrawingPainter oldDelegate) {
    return true; // Simplified for MVP
  }
}
