import 'dart:math' as math;
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:perfect_freehand/perfect_freehand.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import '../app_state.dart';
import '../ui/text_box_widget.dart';

class DrawingCanvas extends StatefulWidget {
  const DrawingCanvas({super.key});

  @override
  State<DrawingCanvas> createState() => _DrawingCanvasState();
}

class _DrawingCanvasState extends State<DrawingCanvas> {
  Offset? _lastDragPos;
  bool _isDraggingSelection = false;

  IconData _getIconDataForStamp(String id) {
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

    return InteractiveViewer(
      boundaryMargin: const EdgeInsets.all(double.infinity),
      minScale: 0.1,
      maxScale: 10.0,
      panEnabled: appState.currentPenType == PenType.pan,
      scaleEnabled: true, // Allow pinch-to-zoom always
      child: SizedBox(
        width: 10000,
        height: 10000,
        child: Stack(
          fit: StackFit.expand,
          children: [
            CustomPaint(
              size: Size.infinite,
              painter: BackgroundPainter(template: appState.pages[appState.currentPageIndex].background),
            ),
            if (appState.backgroundImagePath != null)
              _buildBackgroundImage(appState.backgroundImagePath!),
            for (final img in appState.images)
              Positioned(
                left: img.position.dx,
                top: img.position.dy,
                width: img.size.width,
                height: img.size.height,
                child: Image.file(File(img.path), fit: BoxFit.contain),
              ),
            for (final eq in appState.equations)
              Positioned(
                left: eq.position.dx,
                top: eq.position.dy,
                child: Math.tex(
                  eq.tex,
                  textStyle: TextStyle(fontSize: 24 * eq.scale, color: appState.themeMode == 0 ? Colors.black : Colors.white),
                ),
              ),
            for (final text in appState.texts)
              Positioned(
                left: text.position.dx,
                top: text.position.dy,
                child: TextBoxWidget(canvasText: text),
              ),
            for (final stamp in appState.stamps)
              Positioned(
                left: stamp.position.dx - (stamp.size / 2),
                top: stamp.position.dy - (stamp.size / 2),
                child: Icon(
                  _getIconDataForStamp(stamp.stampId),
                  color: stamp.color,
                  size: stamp.size,
                ),
              ),
            Listener(
              behavior: HitTestBehavior.opaque,
              onPointerDown: (event) {
                if (appState.currentPenType == PenType.pan) return;
                if (appState.currentPenType == PenType.text) {
                  final RenderBox box = context.findRenderObject() as RenderBox;
                  final offset = box.globalToLocal(event.position);
                  appState.addText(CanvasText(
                    text: '',
                    position: offset,
                    style: TextStyle(fontSize: 24, color: appState.currentColor),
                    isEditing: true,
                  ));
                  appState.setPenType(PenType.pan); 
                  return;
                }
                final RenderBox box = context.findRenderObject() as RenderBox;
                final offset = box.globalToLocal(event.position);

                if (appState.currentPenType == PenType.stamp) {
                  appState.addStamp(CanvasStamp(
                    stampId: appState.currentStampId,
                    position: offset,
                    color: appState.currentColor,
                    size: appState.currentWidth * 8 + 30,
                  ));
                  return;
                }

                if (appState.currentPenType == PenType.lasso) {
                  if (appState.hasSelection) {
                    // Start dragging selection
                    _isDraggingSelection = true;
                    _lastDragPos = offset;
                    return;
                  }
                  // Otherwise start a new lasso stroke
                  appState.clearSelection();
                  appState.addStroke(Stroke(
                    points: [DrawingPoint(offset, 1.0)],
                    color: Colors.blueAccent,
                    width: 2.0,
                    penType: PenType.lasso,
                  ));
                  return;
                }
                
                if (appState.currentPenType == PenType.eraser) {
                  appState.clearSelection();
                  final strokesToRemove = <Stroke>[];
                  for (final stroke in appState.strokes) {
                    for (final p in stroke.points) {
                      if ((p.point - offset).distance < 20) {
                        strokesToRemove.add(stroke);
                        break;
                      }
                    }
                  }
                  for (final s in strokesToRemove) {
                    appState.removeStroke(s);
                  }
                  return; // Do not add a new stroke
                }

                bool isSmart = appState.currentShapeType == ShapeType.smart;
                appState.addStroke(Stroke(
                  points: [DrawingPoint(offset, event.pressure)],
                  color: appState.currentColor,
                  width: appState.currentWidth,
                  penType: isSmart ? PenType.pen : appState.currentPenType, // Temporarily draw as pen
                  shapeType: appState.currentShapeType,
                  shapeStart: (appState.currentPenType == PenType.shape && !isSmart) ? offset : null,
                  shapeEnd: (appState.currentPenType == PenType.shape && !isSmart) ? offset : null,
                ));
              },
              onPointerMove: (event) {
                if (appState.currentPenType == PenType.pan) return;
                if (appState.currentPenType == PenType.text) return;
                if (appState.currentPenType == PenType.stamp) return;
                final RenderBox box = context.findRenderObject() as RenderBox;
                final offset = box.globalToLocal(event.position);
                
                if (appState.currentPenType == PenType.eraser) {
                  final strokesToRemove = <Stroke>[];
                  for (final stroke in appState.strokes) {
                    for (final p in stroke.points) {
                      if ((p.point - offset).distance < 20) {
                        strokesToRemove.add(stroke);
                        break;
                      }
                    }
                  }
                  for (final s in strokesToRemove) {
                    appState.removeStroke(s);
                  }
                  return;
                }

                if (appState.currentPenType == PenType.lasso) {
                  if (_isDraggingSelection && _lastDragPos != null) {
                    final delta = offset - _lastDragPos!;
                    appState.translateSelection(delta);
                    _lastDragPos = offset;
                    return;
                  }
                  appState.addPointToLastStroke(DrawingPoint(offset, 1.0));
                  return;
                }

                if (appState.currentShapeType == ShapeType.smart) {
                   appState.addPointToLastStroke(DrawingPoint(offset, event.pressure));
                   return;
                }

                appState.addPointToLastStroke(DrawingPoint(offset, event.pressure));
              },
              onPointerUp: (event) {
                _isDraggingSelection = false;
                _lastDragPos = null;

                if (appState.currentPenType == PenType.lasso && appState.strokes.isNotEmpty && appState.strokes.last.penType == PenType.lasso) {
                  final lassoStroke = appState.strokes.last;
                  appState.removeLastStroke(); // Remove the lasso path

                  // Simple Bounding Box selection logic
                  if (lassoStroke.points.isEmpty) return;
                  double minX = lassoStroke.points.first.point.dx;
                  double maxX = minX;
                  double minY = lassoStroke.points.first.point.dy;
                  double maxY = minY;
                  
                  for (final p in lassoStroke.points) {
                    if (p.point.dx < minX) minX = p.point.dx;
                    if (p.point.dx > maxX) maxX = p.point.dx;
                    if (p.point.dy < minY) minY = p.point.dy;
                    if (p.point.dy > maxY) maxY = p.point.dy;
                  }
                  final Rect lassoRect = Rect.fromLTRB(minX, minY, maxX, maxY);

                  appState.finalizeLassoSelection(lassoRect);
                  return;
                }

                if (appState.currentPenType == PenType.laser) {
                  appState.removeLastStroke();
                  return;
                }

                if (appState.currentShapeType == ShapeType.smart && appState.strokes.isNotEmpty) {
                  final stroke = appState.strokes.last;
                  if (stroke.points.length > 5) {
                    double minX = stroke.points.first.point.dx;
                    double maxX = minX;
                    double minY = stroke.points.first.point.dy;
                    double maxY = minY;
                    
                    for (final p in stroke.points) {
                      if (p.point.dx < minX) minX = p.point.dx;
                      if (p.point.dx > maxX) maxX = p.point.dx;
                      if (p.point.dy < minY) minY = p.point.dy;
                      if (p.point.dy > maxY) maxY = p.point.dy;
                    }
                    
                    final startP = stroke.points.first.point;
                    final endP = stroke.points.last.point;
                    
                    // Basic heuristic: if start and end are close, it's a closed shape (circle or rectangle)
                    // If not, it's a line
                    appState.removeLastStroke();
                    ShapeType inferredShape = ShapeType.line;
                    Offset shapeStart = startP;
                    Offset shapeEnd = endP;

                    if ((startP - endP).distance < 50) {
                      final width = maxX - minX;
                      final height = maxY - minY;
                      // if aspect ratio is close to 1, circle, else rectangle
                      if (width > 0 && height > 0) {
                        double ratio = width / height;
                        inferredShape = (ratio > 0.7 && ratio < 1.3) ? ShapeType.circle : ShapeType.rectangle;
                        shapeStart = Offset(minX, minY);
                        shapeEnd = Offset(maxX, maxY);
                      }
                    }
                    
                    appState.addStroke(Stroke(
                      points: [],
                      color: stroke.color,
                      width: stroke.width,
                      penType: PenType.shape,
                      shapeType: inferredShape,
                      shapeStart: shapeStart,
                      shapeEnd: shapeEnd,
                    ));
                  }
                }
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
        ),
      ),
    );
  }
}

class DrawingPainter extends CustomPainter {
  final List<Stroke> strokes;

  DrawingPainter({required this.strokes});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.saveLayer(Rect.fromLTWH(0, 0, size.width, size.height), Paint());

    for (final stroke in strokes) {
      canvas.save();
      if (stroke.translation != Offset.zero) {
        canvas.translate(stroke.translation.dx, stroke.translation.dy);
      }

      if (stroke.penType == PenType.lasso) {
        if (stroke.points.isNotEmpty) {
          final paint = Paint()
            ..color = stroke.color
            ..strokeWidth = stroke.width
            ..style = PaintingStyle.stroke;
          final path = Path();
          path.moveTo(stroke.points[0].point.dx, stroke.points[0].point.dy);
          for (int i = 1; i < stroke.points.length; i++) {
            path.lineTo(stroke.points[i].point.dx, stroke.points[i].point.dy);
          }
          // Close the lasso path visually
          path.close();
          canvas.drawPath(path, paint);
        }
      } else if (stroke.penType == PenType.shape && stroke.shapeStart != null && stroke.shapeEnd != null) {
        final paint = Paint()
          ..color = stroke.color
          ..strokeWidth = stroke.width
          ..style = PaintingStyle.stroke;
          
        if (stroke.shapeType == ShapeType.line) {
          canvas.drawLine(stroke.shapeStart!, stroke.shapeEnd!, paint);
        } else if (stroke.shapeType == ShapeType.rectangle) {
          canvas.drawRect(Rect.fromPoints(stroke.shapeStart!, stroke.shapeEnd!), paint);
        } else if (stroke.shapeType == ShapeType.circle) {
          final rect = Rect.fromPoints(stroke.shapeStart!, stroke.shapeEnd!);
          canvas.drawOval(rect, paint);
        } else if (stroke.shapeType == ShapeType.benzene || stroke.shapeType == ShapeType.cyclohexane) {
          final rect = Rect.fromPoints(stroke.shapeStart!, stroke.shapeEnd!);
          final center = rect.center;
          final radius = (rect.width < rect.height ? rect.width : rect.height) / 2;
          final path = Path();
          
          for (int i = 0; i < 6; i++) {
            final angle = (math.pi / 3) * i - (math.pi / 2); // Pointy top hexagon
            final dx = center.dx + radius * math.cos(angle);
            final dy = center.dy + radius * math.sin(angle);
            if (i == 0) {
              path.moveTo(dx, dy);
            } else {
              path.lineTo(dx, dy);
            }
          }
          path.close();
          canvas.drawPath(path, paint);
          
          if (stroke.shapeType == ShapeType.benzene) {
             canvas.drawCircle(center, radius * 0.65, paint);
          }
        }
      } else {
        if (stroke.points.isEmpty) continue;
        
        final paint = Paint()
          ..color = (stroke.penType == PenType.laser ? Colors.redAccent : (stroke.penType == PenType.highlighter ? stroke.color.withValues(alpha: 0.5) : stroke.color))
          ..blendMode = (stroke.penType == PenType.highlighter ? BlendMode.multiply : BlendMode.srcOver)
          ..maskFilter = stroke.penType == PenType.laser ? const MaskFilter.blur(BlurStyle.normal, 5) : null
          ..style = PaintingStyle.fill;

        final freehandPoints = stroke.points.map((p) => PointVector(p.point.dx, p.point.dy, p.pressure)).toList();
        final outlinePoints = getStroke(
          freehandPoints,
          options: StrokeOptions(
            size: stroke.width * 2,
            thinning: 0.7,
            smoothing: 0.5,
            streamline: 0.5,
          ),
        );

        if (outlinePoints.isNotEmpty) {
          final path = Path();
          path.moveTo(outlinePoints[0].dx, outlinePoints[0].dy);
          for (int i = 1; i < outlinePoints.length - 1; ++i) {
            final p0 = outlinePoints[i];
            final p1 = outlinePoints[i + 1];
            path.quadraticBezierTo(
                p0.dx, p0.dy, (p0.dx + p1.dx) / 2, (p0.dy + p1.dy) / 2);
          }
          canvas.drawPath(path, paint);
        }
      }
      
      canvas.restore();
    }
    
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant DrawingPainter oldDelegate) {
    return true; 
  }
}

class BackgroundPainter extends CustomPainter {
  final BackgroundTemplate template;

  BackgroundPainter({required this.template});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    if (template == BackgroundTemplate.ruled) {
      for (double y = 50; y < size.height; y += 50) {
        canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
      }
    } else if (template == BackgroundTemplate.grid) {
      for (double x = 50; x < size.width; x += 50) {
        canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
      }
      for (double y = 50; y < size.height; y += 50) {
        canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
      }
    } else if (template == BackgroundTemplate.dotGrid) {
      paint.style = PaintingStyle.fill;
      for (double x = 50; x < size.width; x += 50) {
        for (double y = 50; y < size.height; y += 50) {
          canvas.drawCircle(Offset(x, y), 2.0, paint);
        }
      }
    } else if (template == BackgroundTemplate.music) {
      double startY = 100;
      while (startY < size.height - 100) {
        for (int i = 0; i < 5; i++) {
          final y = startY + (i * 15);
          canvas.drawLine(Offset(50, y), Offset(size.width - 50, y), paint..color = Colors.black.withValues(alpha: 0.5));
        }
        startY += 150;
      }
    }
  }

  @override
  bool shouldRepaint(covariant BackgroundPainter oldDelegate) {
    return oldDelegate.template != template;
  }
}
