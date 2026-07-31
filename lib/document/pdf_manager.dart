import 'dart:io';
import 'package:pdfx/pdfx.dart';
import 'package:path_provider/path_provider.dart';

class PdfManager {
  static Future<List<String>> renderPdfToImages(String pdfPath) async {
    final document = await PdfDocument.openFile(pdfPath);
    final pageCount = document.pagesCount;
    final List<String> imagePaths = [];
    
    final tempDir = await getTemporaryDirectory();
    final uniqueId = DateTime.now().millisecondsSinceEpoch;

    for (int i = 1; i <= pageCount; i++) {
      final page = await document.getPage(i);
      final pageImage = await page.render(
        width: page.width * 2, // 2x resolution for crispness
        height: page.height * 2,
        format: PdfPageImageFormat.png,
      );

      if (pageImage != null) {
        final imagePath = '${tempDir.path}/pdf_${uniqueId}_page_$i.png';
        final file = File(imagePath);
        await file.writeAsBytes(pageImage.bytes);
        imagePaths.add(imagePath);
      }
      await page.close();
    }
    
    await document.close();
    return imagePaths;
  }
}
