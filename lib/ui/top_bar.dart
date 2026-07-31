import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'settings_screen.dart';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import '../app_state.dart';
import '../document/pdf_manager.dart';
import '../document/pdf_exporter.dart';
import '../document/project_manager.dart';
import '../recording/recorder_service.dart';
import 'student_picker_widget.dart';
import 'quiz_poll_widget.dart';
class TopBar extends StatelessWidget {
  const TopBar({super.key});

  void _showStudentPicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const StudentPickerWidget(),
    );
  }

  void _showQuizPoll(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const QuizPollDialog(),
    );
  }

  Future<void> _openPresenterMode() async {
    final window = await DesktopMultiWindow.createWindow('{}');
    window
      ..setFrame(const Offset(0, 0) & const Size(1280, 720))
      ..center()
      ..setTitle('InkGuru - Projector View')
      ..show();
  }

  Future<void> _importSlide(BuildContext context) async {
    final appState = Provider.of<AppState>(context, listen: false);
    
    FilePickerResult? result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'png', 'jpg', 'pptx', 'docx'],
    );
    
    if (result != null && result.files.single.path != null) {
      final path = result.files.single.path!;
      final lowerPath = path.toLowerCase();
      
      if (lowerPath.endsWith('.pdf') || lowerPath.endsWith('.pptx') || lowerPath.endsWith('.docx')) {
        if (!context.mounted) return;
        final isSimulated = lowerPath.endsWith('.pptx') || lowerPath.endsWith('.docx');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(isSimulated ? 'Simulating PPTX/DOCX to PDF conversion in cloud... Please wait.' : 'Importing PDF... Please wait.')),
        );
        
        try {
          if (isSimulated) {
             // Simulate network delay for cloud conversion
             await Future.delayed(const Duration(seconds: 2));
          }
          // Assuming for MVP that the user selects a file, we can just render the PDF (if it's PPTX/DOCX it will fail here natively without an actual converter, but we'll try to just show a dummy page or handle error)
          // Since we can't actually parse PPTX with PdfManager, we should mock the result if it's not a real PDF
          List<String> imagePaths = [];
          if (isSimulated) {
             // Provide a dummy list of images or just one dummy image
             imagePaths = []; // We would need a dummy image. Let's just add a text alert or an empty page.
          } else {
             imagePaths = await PdfManager.renderPdfToImages(path);
          }

          if (imagePaths.isEmpty && isSimulated) {
             appState.addPage();
             appState.addText(CanvasText(
                text: 'Simulated $lowerPath Import Successful.\n(Cloud converter would return images here)',
                position: const Offset(200, 200),
                style: const TextStyle(fontSize: 32, color: Colors.blue),
             ));
          }
          
          for (int i = 0; i < imagePaths.length; i++) {
            bool isCurrentEmpty = appState.strokes.isEmpty && 
                                  appState.images.isEmpty && 
                                  appState.equations.isEmpty && 
                                  appState.texts.isEmpty && 
                                  appState.stamps.isEmpty && 
                                  appState.backgroundImagePath == null;
            if (!isCurrentEmpty || i > 0) {
              appState.addPage();
            }
            appState.addCanvasImage(
              CanvasImage(
                path: imagePaths[i],
                position: const Offset(50, 50),
                size: const Size(1000, 1400),
              ),
            );
          }
          
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(isSimulated ? 'File Imported (Simulated)' : 'PDF Imported Successfully')),
          );

        } catch (e) {
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      } else {
        // Image import
        appState.addCanvasImage(
          CanvasImage(
            path: path,
            position: const Offset(50, 50),
            size: const Size(800, 600),
          ),
        );
      }
    }
  }

  void _showEquationDialog(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);
    final controller = TextEditingController(text: r'x = \frac{-b \pm \sqrt{b^2 - 4ac}}{2a}');
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Insert Equation (LaTeX)'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: r'e.g. \sum_{i=1}^n i = \frac{n(n+1)}{2}',
            ),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                appState.addEquation(CanvasEquation(
                  tex: controller.text,
                  position: const Offset(100, 100),
                ));
                Navigator.pop(context);
              },
              child: const Text('Insert'),
            ),
          ],
        );
      },
    );
  }

  void _showToolMockup(BuildContext context, String toolName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(toolName),
        content: Text('$toolName is running in mockup mode for this demo.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))
        ],
      ),
    );
  }

  void _showSaveDialog(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);
    final nameController = TextEditingController(text: appState.projectName == 'Untitled Lesson' ? '' : appState.projectName);
    final subjectController = TextEditingController(text: appState.projectSubject);
    final chapterController = TextEditingController(text: appState.projectChapter);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Save Project Metadata'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Project Name')),
            TextField(controller: subjectController, decoration: const InputDecoration(labelText: 'Subject')),
            TextField(controller: chapterController, decoration: const InputDecoration(labelText: 'Chapter')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ProjectManager.saveProject(
                context,
                projectName: nameController.text.isNotEmpty ? nameController.text : 'Untitled Lesson',
                subject: subjectController.text,
                chapter: chapterController.text,
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    
    return Container(
      height: 60,
      color: Colors.grey[850],
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'InkGuru',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: _openPresenterMode,
                icon: const Icon(Icons.cast),
                label: const Text('Present'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purpleAccent,
                  foregroundColor: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.timer, color: Colors.orangeAccent),
                tooltip: 'Timer & Stopwatch',
                onPressed: () => _showToolMockup(context, 'Timer / Stopwatch'),
              ),
              IconButton(
                icon: const Icon(Icons.casino, color: Colors.purpleAccent),
                tooltip: 'Random Student Picker',
                onPressed: () => _showStudentPicker(context),
              ),
              IconButton(
                icon: const Icon(Icons.poll, color: Colors.lightBlueAccent),
                tooltip: 'Quick Quiz / Poll',
                onPressed: () => _showQuizPoll(context),
              ),
              IconButton(
                icon: const Icon(Icons.calculate, color: Colors.blueAccent),
                tooltip: 'Insert Equation',
                onPressed: () => _showEquationDialog(context),
              ),
              IconButton(
                icon: const Icon(Icons.timer, color: Colors.blueAccent),
                tooltip: 'Toggle Timer',
                onPressed: () => appState.toggleTimerVisibility(),
              ),
              IconButton(
                icon: const Icon(Icons.home, color: Colors.white),
                tooltip: 'Dashboard',
                onPressed: () {
                   Navigator.pop(context);
                },
              ),
              IconButton(
                icon: const Icon(Icons.save, color: Colors.blueAccent),
                tooltip: 'Save Project',
                onPressed: () {
                   final appState = Provider.of<AppState>(context, listen: false);
                   if (appState.projectName == null || appState.projectName == 'Untitled Lesson') {
                      _showSaveDialog(context);
                   } else {
                      ProjectManager.saveProject(context);
                   }
                },
              ),
              IconButton(
                icon: const Icon(Icons.picture_as_pdf, color: Colors.redAccent),
                tooltip: 'Export as PDF',
                onPressed: () async {
                  await PdfExporter.exportBoardToPdf(appState);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Board exported to PDF successfully!')),
                    );
                  }
                },
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () => _importSlide(context),
                icon: const Icon(Icons.image),
                label: const Text('Import Slide'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: Icon(appState.isMicOn ? Icons.mic : Icons.mic_off, color: appState.isMicOn ? Colors.white : Colors.red),
                tooltip: 'Mic Audio',
                onPressed: () => appState.toggleMic(),
              ),
              IconButton(
                icon: Icon(Icons.videocam, color: appState.showWebcam ? Colors.blueAccent : Colors.white),
                tooltip: 'Webcam Pip',
                onPressed: () => appState.toggleWebcam(),
              ),
              IconButton(
                icon: const Icon(Icons.settings, color: Colors.white),
                tooltip: 'Settings',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SettingsScreen()),
                  );
                },
              ),
              const SizedBox(width: 16),
              if (appState.isRecording)
                IconButton(
                  icon: const Icon(Icons.bookmark_add, color: Colors.orangeAccent),
                  tooltip: 'Add Chapter Marker',
                  onPressed: () {
                    appState.addRecordingMarker('Chapter Marker');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Chapter Marker added at ${DateTime.now().toIso8601String().split('T').last.substring(0, 8)}')),
                    );
                  },
                ),
              ElevatedButton.icon(
                onPressed: () async {
                  final isRec = appState.isRecording;
                  if (isRec) {
                    await RecorderService.stopRecording(appState.recordingMarkers);
                    appState.setRecording(false);
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Recording Saved to Documents.')),
                    );
                  } else {
                    await RecorderService.startRecording(rtmpUrl: appState.rtmpUrl);
                    appState.setRecording(true);
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Recording Started...')),
                    );
                  }
                },
                icon: Icon(appState.isRecording ? Icons.stop : Icons.fiber_manual_record),
                label: Text(appState.isRecording ? 'Stop' : 'Record'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: appState.isRecording ? Colors.grey : Colors.redAccent,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
