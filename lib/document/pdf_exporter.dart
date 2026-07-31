import 'dart:io';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:path_provider/path_provider.dart';
import '../app_state.dart';

class PdfExporter {
  static Future<void> exportBoardToPdf(AppState appState) async {
    final pdf = pw.Document();

    for (final page in appState.pages) {
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4.landscape,
          build: (pw.Context context) {
            return pw.FullPage(
              ignoreMargins: true,
              child: pw.CustomPaint(
                size: PdfPoint(PdfPageFormat.a4.landscape.width, PdfPageFormat.a4.landscape.height),
                painter: (PdfGraphics canvas, PdfPoint size) {
                  // Basic background
                  canvas.setFillColor(PdfColors.white);
                  canvas.drawRect(0, 0, size.x, size.y);
                  canvas.fillPath();

                  // Draw strokes
                  for (final stroke in page.strokes) {
                    if (stroke.points.isEmpty) continue;
                    
                    canvas.setStrokeColor(PdfColor.fromInt(stroke.color.toARGB32()));
                    canvas.setLineWidth(stroke.width);
                    
                    final firstPoint = stroke.points.first.point + stroke.translation;
                    canvas.moveTo(firstPoint.dx, size.y - firstPoint.dy); // PDF y-axis is inverted
                    
                    for (int i = 1; i < stroke.points.length; i++) {
                      final point = stroke.points[i].point + stroke.translation;
                      canvas.lineTo(point.dx, size.y - point.dy);
                    }
                    canvas.strokePath();
                  }
                },
              ),
            );
          },
        ),
      );
    }

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/inkguru_export_${DateTime.now().millisecondsSinceEpoch}.pdf');
    await file.writeAsBytes(await pdf.save());
  }
}
