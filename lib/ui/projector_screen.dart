import 'package:flutter/material.dart';
import '../canvas/drawing_canvas.dart';

class ProjectorApp extends StatelessWidget {
  final int windowId;
  final Map<String, dynamic> arguments;

  const ProjectorApp({super.key, required this.windowId, required this.arguments});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'InkGuru - Projector View',
      theme: ThemeData.dark(useMaterial3: true).copyWith(
        scaffoldBackgroundColor: const Color(0xFF1E3F20),
      ),
      home: const ProjectorScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ProjectorScreen extends StatelessWidget {
  const ProjectorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const DrawingCanvas(),
          // For presenter view, we explicitly DO NOT include the ToolRail, TopBar, WebcamPip, etc.
          // This gives a clean output.
        ],
      ),
    );
  }
}
