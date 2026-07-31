import 'dart:convert';
import 'dart:io';
import 'package:archive/archive_io.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';

class ProjectInfo {
  final String path;
  final String id;
  final String name;
  final String subject;
  final String chapter;
  final DateTime modifiedAt;

  ProjectInfo({
    required this.path,
    required this.id,
    required this.name,
    required this.subject,
    required this.chapter,
    required this.modifiedAt,
  });
}

class ProjectManager {
  static Future<void> saveProject(BuildContext context, {String? projectName, String? subject, String? chapter}) async {
    final appState = Provider.of<AppState>(context, listen: false);
    
    // Assign new ID if not set
    final String id = appState.projectId ?? DateTime.now().millisecondsSinceEpoch.toString();
    appState.setProjectMetadata(
      id: id,
      name: projectName ?? appState.projectName ?? 'Untitled Lesson',
      subject: subject ?? appState.projectSubject ?? '',
      chapter: chapter ?? appState.projectChapter ?? '',
    );

    final docDir = await getApplicationDocumentsDirectory();
    final projectsDir = Directory('${docDir.path}/InkGuruProjects');
    if (!await projectsDir.exists()) {
      await projectsDir.create(recursive: true);
    }
    
    final String outputFile = '${projectsDir.path}/$id.inkg';

    final archive = Archive();

    // 1. Serialize Metadata
    final metadata = {
      'id': appState.projectId,
      'name': appState.projectName,
      'subject': appState.projectSubject,
      'chapter': appState.projectChapter,
      'pages': appState.pages.map((p) => p.toJson()).toList(),
    };
    
    final metadataBytes = utf8.encode(jsonEncode(metadata));
    archive.addFile(ArchiveFile('metadata.json', metadataBytes.length, metadataBytes));

    // 2. Add Images from all pages
    final Set<String> processedImagePaths = {};
    for (final page in appState.pages) {
      final allImagesForPage = [...page.images];
      if (page.backgroundImagePath != null) {
        allImagesForPage.add(CanvasImage(path: page.backgroundImagePath!, position: Offset.zero, size: Size.zero));
      }
      for (final img in allImagesForPage) {
        if (processedImagePaths.contains(img.path)) continue;
        processedImagePaths.add(img.path);
        
        final file = File(img.path);
        if (await file.exists()) {
          final bytes = await file.readAsBytes();
          final filename = img.path.split('/').last; // simple basename
          archive.addFile(ArchiveFile('assets/$filename', bytes.length, bytes));
        }
      }
    }

    // 3. Zip and Save
    final zipEncoder = ZipFileEncoder();
    zipEncoder.create(outputFile);
    for (final file in archive) {
      if (file.isFile) {
         final tempFile = File('${(await getTemporaryDirectory()).path}/${file.name.replaceAll('/', '_')}');
         await tempFile.writeAsBytes(file.content as List<int>);
         zipEncoder.addFile(tempFile, file.name);
      }
    }
    zipEncoder.close();

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Project saved successfully.')),
    );
  }

  static Future<List<ProjectInfo>> listProjects() async {
    final docDir = await getApplicationDocumentsDirectory();
    final projectsDir = Directory('${docDir.path}/InkGuruProjects');
    if (!await projectsDir.exists()) {
      return [];
    }

    List<ProjectInfo> projects = [];
    final files = projectsDir.listSync().where((e) => e.path.endsWith('.inkg')).toList();

    for (final file in files) {
      try {
        final bytes = await File(file.path).readAsBytes();
        final archive = ZipDecoder().decodeBytes(bytes);
        
        for (final archiveFile in archive) {
          if (archiveFile.name == 'metadata.json') {
            final metadata = jsonDecode(utf8.decode(archiveFile.content as List<int>));
            projects.add(ProjectInfo(
              path: file.path,
              id: metadata['id'] ?? file.path.split(Platform.pathSeparator).last.replaceAll('.inkg', ''),
              name: metadata['name'] ?? 'Untitled Lesson',
              subject: metadata['subject'] ?? '',
              chapter: metadata['chapter'] ?? '',
              modifiedAt: File(file.path).lastModifiedSync(),
            ));
            break;
          }
        }
      } catch (e) {
        debugPrint('Error reading project ${file.path}: $e');
      }
    }
    
    projects.sort((a, b) => b.modifiedAt.compareTo(a.modifiedAt));
    return projects;
  }

  static Future<void> loadProjectFromPath(BuildContext context, String path) async {
    final appState = Provider.of<AppState>(context, listen: false);

    try {
      final bytes = await File(path).readAsBytes();
      final archive = ZipDecoder().decodeBytes(bytes);
      
      final tempDir = await getTemporaryDirectory();
      final extDir = Directory('${tempDir.path}/inkg_ext_${DateTime.now().millisecondsSinceEpoch}');
      await extDir.create();

      Map<String, dynamic>? metadata;
      final Map<String, String> assetPaths = {};

      for (final file in archive) {
        if (file.isFile) {
          if (file.name == 'metadata.json') {
            metadata = jsonDecode(utf8.decode(file.content as List<int>));
          } else if (file.name.startsWith('assets/')) {
            final filename = file.name.split('/').last;
            final outPath = '${extDir.path}/$filename';
            await File(outPath).writeAsBytes(file.content as List<int>);
            assetPaths[filename] = outPath;
          }
        }
      }

      if (metadata != null) {
        // Set metadata
        appState.setProjectMetadata(
          id: metadata['id'],
          name: metadata['name'],
          subject: metadata['subject'],
          chapter: metadata['chapter'],
        );

        List<CanvasPage> newPages = [];
        
        if (metadata.containsKey('pages')) {
          final pagesList = (metadata['pages'] as List).map((p) => CanvasPage.fromJson(p)).toList();
          
          for (final page in pagesList) {
            final updatedImages = page.images.map((img) {
              final filename = img.path.split('/').last;
              return CanvasImage(
                path: assetPaths[filename] ?? img.path,
                position: img.position,
                size: img.size,
              );
            }).toList();
            
            page.images.clear();
            page.images.addAll(updatedImages);
            
            if (page.backgroundImagePath != null) {
              final bgFilename = page.backgroundImagePath!.split('/').last;
              if (assetPaths.containsKey(bgFilename)) {
                 page.backgroundImagePath = assetPaths[bgFilename];
              }
            }
            newPages.add(page);
          }
        }
        
        appState.setPages(newPages);

        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Project loaded successfully.')),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load project: $e')),
      );
    }
  }
}
