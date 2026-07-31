import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:perfect_freehand/perfect_freehand.dart';
import '../app_state.dart';

class DrawingUtils {
  static Future<Uint8List?> rasterizeStrokesToImage(List<Stroke> strokes, Rect bounds) async {
    if (strokes.isEmpty) return null;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    
    // Fill white background for better OCR
    final bgPaint = Paint()..color = Colors.white;
    canvas.drawRect(Rect.fromLTWH(0, 0, bounds.width, bounds.height), bgPaint);

    // Translate canvas so the bounds.topLeft is at 0,0
    canvas.translate(-bounds.left, -bounds.top);

    for (final stroke in strokes) {
      canvas.save();
      if (stroke.translation != Offset.zero) {
        canvas.translate(stroke.translation.dx, stroke.translation.dy);
      }

      if (stroke.penType == PenType.shape && stroke.shapeStart != null && stroke.shapeEnd != null) {
        final paint = Paint()
          ..color = Colors.black // Force black for AI to read easily
          ..strokeWidth = stroke.width
          ..style = PaintingStyle.stroke;
          
        if (stroke.shapeType == ShapeType.line) {
          canvas.drawLine(stroke.shapeStart!, stroke.shapeEnd!, paint);
        } else if (stroke.shapeType == ShapeType.rectangle) {
          canvas.drawRect(Rect.fromPoints(stroke.shapeStart!, stroke.shapeEnd!), paint);
        } else if (stroke.shapeType == ShapeType.circle) {
          final rect = Rect.fromPoints(stroke.shapeStart!, stroke.shapeEnd!);
          canvas.drawOval(rect, paint);
        }
      } else {
        final points = stroke.points.map((p) => PointVector(p.point.dx, p.point.dy, p.pressure)).toList();
        final outlinePoints = getStroke(
          points,
          options: StrokeOptions(
            size: stroke.width * 2,
            thinning: 0.5,
            smoothing: 0.5,
            streamline: 0.5,
          ),
        );

        final path = Path();
        if (outlinePoints.isNotEmpty) {
          path.moveTo(outlinePoints[0].dx, outlinePoints[0].dy);
          for (int i = 1; i < outlinePoints.length - 1; i++) {
            final p0 = outlinePoints[i];
            final p1 = outlinePoints[i + 1];
            path.quadraticBezierTo(p0.dx, p0.dy, (p0.dx + p1.dx) / 2, (p0.dy + p1.dy) / 2);
          }
        }
        
        // Use black for AI
        final paint = Paint()..color = Colors.black;
        canvas.drawPath(path, paint);
      }
      
      canvas.restore();
    }

    final picture = recorder.endRecording();
    final image = await picture.toImage(bounds.width.toInt(), bounds.height.toInt());
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData?.buffer.asUint8List();
  }
}
