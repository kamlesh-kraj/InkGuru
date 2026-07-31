import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
enum PenType { pen, eraser, shape, highlighter, pan, laser, text, lasso, stamp }
enum ShapeType { none, line, rectangle, circle, benzene, cyclohexane, smart }
enum GeometryTool { none, ruler, protractor, compass }
enum ToolbarItem { pen, highlighter, eraser, shapes, text, stamp, undo, redo, colors }

class DrawingPoint {
  final Offset point;
  final double pressure;
  DrawingPoint(this.point, this.pressure);
  
  Map<String, dynamic> toJson() => {
    'dx': point.dx,
    'dy': point.dy,
    'pressure': pressure,
  };
  
  factory DrawingPoint.fromJson(Map<String, dynamic> json) => DrawingPoint(
    Offset(json['dx'], json['dy']),
    json['pressure']?.toDouble() ?? 1.0,
  );
}

class Stroke {
  final List<DrawingPoint> points;
  final Color color;
  final double width;
  final PenType penType;
  final ShapeType shapeType;
  final Offset? shapeStart;
  final Offset? shapeEnd;
  Offset translation;

  Stroke({
    required this.points,
    required this.color,
    required this.width,
    required this.penType,
    this.shapeType = ShapeType.none,
    this.shapeStart,
    this.shapeEnd,
    this.translation = Offset.zero,
  });
  
  Map<String, dynamic> toJson() => {
    'points': points.map((p) => p.toJson()).toList(),
    'color': color.toARGB32(),
    'width': width,
    'penType': penType.index,
    'shapeType': shapeType.index,
    'shapeStart': shapeStart != null ? {'dx': shapeStart!.dx, 'dy': shapeStart!.dy} : null,
    'shapeEnd': shapeEnd != null ? {'dx': shapeEnd!.dx, 'dy': shapeEnd!.dy} : null,
    'translation': {'dx': translation.dx, 'dy': translation.dy},
  };
  
  factory Stroke.fromJson(Map<String, dynamic> json) {
    Offset? start;
    if (json['shapeStart'] != null) {
      start = Offset(json['shapeStart']['dx'], json['shapeStart']['dy']);
    }
    Offset? end;
    if (json['shapeEnd'] != null) {
      end = Offset(json['shapeEnd']['dx'], json['shapeEnd']['dy']);
    }
    Offset trans = Offset.zero;
    if (json['translation'] != null) {
      trans = Offset(json['translation']['dx'], json['translation']['dy']);
    }
    
    return Stroke(
      points: (json['points'] as List).map((p) => DrawingPoint.fromJson(p)).toList(),
      color: Color(json['color'] as int),
      width: json['width'].toDouble(),
      penType: PenType.values[json['penType']],
      shapeType: ShapeType.values[json['shapeType']],
      shapeStart: start,
      shapeEnd: end,
      translation: trans,
    );
  }
}

class CanvasImage {
  String path;
  final Offset position;
  final Size size;

  CanvasImage({required this.path, required this.position, required this.size});
  
  Map<String, dynamic> toJson() => {
    'path': path,
    'x': position.dx,
    'y': position.dy,
    'w': size.width,
    'h': size.height,
  };
  
  factory CanvasImage.fromJson(Map<String, dynamic> json) => CanvasImage(
    path: json['path'],
    position: Offset(json['x'].toDouble(), json['y'].toDouble()),
    size: Size(json['w'].toDouble(), json['h'].toDouble()),
  );
}

class CanvasEquation {
  final String tex;
  final Offset position;
  final double scale;
  
  CanvasEquation({required this.tex, required this.position, this.scale = 1.0});
  
  Map<String, dynamic> toJson() => {
    'tex': tex,
    'x': position.dx,
    'y': position.dy,
    'scale': scale,
  };
  
  factory CanvasEquation.fromJson(Map<String, dynamic> json) => CanvasEquation(
    tex: json['tex'],
    position: Offset(json['x'].toDouble(), json['y'].toDouble()),
    scale: json['scale']?.toDouble() ?? 1.0,
  );
}

class CanvasText {
  final String text;
  final Offset position;
  final TextStyle style;
  final bool isEditing;
  
  CanvasText({required this.text, required this.position, required this.style, this.isEditing = false});
  
  Map<String, dynamic> toJson() => {
    'text': text,
    'x': position.dx,
    'y': position.dy,
    'fontSize': style.fontSize ?? 24.0,
    'color': style.color?.toARGB32() ?? Colors.black.toARGB32(),
  };
  
  factory CanvasText.fromJson(Map<String, dynamic> json) => CanvasText(
    text: json['text'],
    position: Offset(json['x'].toDouble(), json['y'].toDouble()),
    style: TextStyle(
      fontSize: json['fontSize']?.toDouble() ?? 24.0,
      color: Color(json['color'] as int? ?? Colors.black.toARGB32()),
    ),
  );
}

class CanvasStamp {
  final String stampId;
  final Offset position;
  final Color color;
  final double size;
  
  CanvasStamp({required this.stampId, required this.position, required this.color, required this.size});
  
  Map<String, dynamic> toJson() => {
    'stampId': stampId,
    'x': position.dx,
    'y': position.dy,
    'color': color.toARGB32(),
    'size': size,
  };
  
  factory CanvasStamp.fromJson(Map<String, dynamic> json) => CanvasStamp(
    stampId: json['stampId'],
    position: Offset(json['x'].toDouble(), json['y'].toDouble()),
    color: Color(json['color'] ?? Colors.black.toARGB32()),
    size: json['size']?.toDouble() ?? 40.0,
  );
}

enum BackgroundTemplate { blank, ruled, grid, music, dotGrid }

class CanvasPage {
  final List<Stroke> strokes = [];
  final List<CanvasImage> images = [];
  final List<CanvasEquation> equations = [];
  final List<CanvasText> texts = [];
  final List<CanvasStamp> stamps = [];
  String? backgroundImagePath;
  BackgroundTemplate background = BackgroundTemplate.blank;

  CanvasPage();

  Map<String, dynamic> toJson() => {
    'strokes': strokes.map((s) => s.toJson()).toList(),
    'images': images.map((i) => i.toJson()).toList(),
    'equations': equations.map((e) => e.toJson()).toList(),
    'texts': texts.map((t) => t.toJson()).toList(),
    'stamps': stamps.map((s) => s.toJson()).toList(),
    'backgroundImagePath': backgroundImagePath,
    'background': background.index,
  };

  factory CanvasPage.fromJson(Map<String, dynamic> json) {
    final page = CanvasPage();
    if (json['strokes'] != null) {
      page.strokes.addAll((json['strokes'] as List).map((s) => Stroke.fromJson(s)));
    }
    if (json['images'] != null) {
      page.images.addAll((json['images'] as List).map((i) => CanvasImage.fromJson(i)));
    }
    if (json['equations'] != null) {
      page.equations.addAll((json['equations'] as List).map((e) => CanvasEquation.fromJson(e)));
    }
    if (json['texts'] != null) {
      page.texts.addAll((json['texts'] as List).map((t) => CanvasText.fromJson(t)));
    }
    if (json['stamps'] != null) {
      page.stamps.addAll((json['stamps'] as List).map((s) => CanvasStamp.fromJson(s)));
    }
    page.backgroundImagePath = json['backgroundImagePath'];
    if (json['background'] != null) {
      page.background = BackgroundTemplate.values[json['background']];
    }
    return page;
  }
}

class AppState extends ChangeNotifier {
  final List<CanvasPage> _pages = [CanvasPage()];
  int _currentPageIndex = 0;
  
  SharedPreferences? _prefs;
  String? _aiApiKey;
  String _rtmpUrl = '';
  List<ToolbarItem> _toolbarLayout = ToolbarItem.values.toList();
  
  String? _projectId;
  String? _projectName;
  String? _projectSubject;
  String? _projectChapter;

  AppState() {
    _initPrefs();
  }

  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    _aiApiKey = _prefs?.getString('aiApiKey');
    _rtmpUrl = _prefs?.getString('rtmpUrl') ?? '';
    
    final savedToolbar = _prefs?.getStringList('toolbarLayout');
    if (savedToolbar != null) {
      _toolbarLayout = savedToolbar.map((s) => ToolbarItem.values.firstWhere((e) => e.toString() == s, orElse: () => ToolbarItem.pen)).toList();
    }
    
    startAutosave();
    notifyListeners();
  }

  String? get aiApiKey => _aiApiKey;
  String get rtmpUrl => _rtmpUrl;
  List<ToolbarItem> get toolbarLayout => _toolbarLayout;
  
  String? get projectId => _projectId;
  String? get projectName => _projectName;
  String? get projectSubject => _projectSubject;
  String? get projectChapter => _projectChapter;

  void setProjectMetadata({String? id, String? name, String? subject, String? chapter}) {
    if (id != null) _projectId = id;
    if (name != null) _projectName = name;
    if (subject != null) _projectSubject = subject;
    if (chapter != null) _projectChapter = chapter;
    notifyListeners();
  }


  void setRtmpUrl(String url) {
    _rtmpUrl = url;
    _prefs?.setString('rtmpUrl', url);
    notifyListeners();
  }

  void reorderToolbar(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final item = _toolbarLayout.removeAt(oldIndex);
    _toolbarLayout.insert(newIndex, item);
    _prefs?.setStringList('toolbarLayout', _toolbarLayout.map((e) => e.toString()).toList());
    notifyListeners();
  }

  set aiApiKey(String? value) {
    _aiApiKey = value;
    if (value != null && value.isNotEmpty) {
      _prefs?.setString('aiApiKey', value);
    } else {
      _prefs?.remove('aiApiKey');
    }
    notifyListeners();
  }

  CanvasPage get currentPage => _pages[_currentPageIndex];
  List<CanvasPage> get pages => _pages;
  int get currentPageIndex => _currentPageIndex;
  
  List<Stroke> get strokes => currentPage.strokes;
  List<CanvasImage> get images => currentPage.images;
  List<CanvasEquation> get equations => currentPage.equations;
  List<CanvasText> get texts => currentPage.texts;
  List<CanvasStamp> get stamps => currentPage.stamps;
  String? get backgroundImagePath => currentPage.backgroundImagePath;

  void addPage() {
    _pagesCreated++;
    _pages.add(CanvasPage());
    _currentPageIndex = _pages.length - 1;
    clearSelection();
    _undoStack.clear();
    notifyListeners();
  }
  
  void setPages(List<CanvasPage> newPages) {
    if (newPages.isEmpty) {
      _pages.clear();
      _pages.add(CanvasPage());
    } else {
      _pages.clear();
      _pages.addAll(newPages);
    }
    _currentPageIndex = 0;
    clearSelection();
    _undoStack.clear();
    notifyListeners();
  }

  void switchPage(int index) {
    if (index >= 0 && index < _pages.length) {
      _currentPageIndex = index;
      clearSelection();
      _undoStack.clear();
      notifyListeners();
    }
  }
  
  void setPageBackground(BackgroundTemplate template) {
    currentPage.background = template;
    notifyListeners();
  }

  final List<Stroke> _undoStack = [];

  Color _currentColor = Colors.white;
  Color get currentColor => _currentColor;

  double _currentWidth = 3.0;
  double get currentWidth => _currentWidth;

  PenType _currentPenType = PenType.pen;
  PenType get currentPenType => _currentPenType;

  ShapeType _currentShapeType = ShapeType.none;
  ShapeType get currentShapeType => _currentShapeType;
  
  GeometryTool _activeGeometryTool = GeometryTool.none;
  GeometryTool get activeGeometryTool => _activeGeometryTool;
  
  String _currentStampId = 'star';
  String get currentStampId => _currentStampId;
  
  bool _isSpotlightActive = false;
  bool get isSpotlightActive => _isSpotlightActive;
  
  bool _isCurtainActive = false;
  bool get isCurtainActive => _isCurtainActive;
  
  bool _isTranscribing = false;
  bool get isTranscribing => _isTranscribing;
  
  int _themeMode = 0; // 0 = light, 1 = dark, 2 = blackboard
  int get themeMode => _themeMode;
  
  bool _isHindi = false;
  bool get isHindi => _isHindi;
  
  bool _hasSelection = false;
  bool get hasSelection => _hasSelection;
  Rect? _selectionRect;
  Rect? get selectionRect => _selectionRect;
  
  void setThemeMode(int mode) {
    _themeMode = mode;
    notifyListeners();
  }
  
  void toggleLanguage() {
    _isHindi = !_isHindi;
    notifyListeners();
  }
  
  void setStampId(String id) {
    _currentStampId = id;
    _currentPenType = PenType.stamp;
    notifyListeners();
  }
  
  void toggleSpotlight() {
    _isSpotlightActive = !_isSpotlightActive;
    notifyListeners();
  }
  
  void toggleCurtain() {
    _isCurtainActive = !_isCurtainActive;
    notifyListeners();
  }
  
  void toggleTranscription() {
    _isTranscribing = !_isTranscribing;
    notifyListeners();
  }
  
  void toggleGeometryTool(GeometryTool tool) {
    if (_activeGeometryTool == tool) {
      _activeGeometryTool = GeometryTool.none;
    } else {
      _activeGeometryTool = tool;
    }
    notifyListeners();
  }

  void setColor(Color color) {
    _currentColor = color;
    notifyListeners();
  }

  void setWidth(double width) {
    _currentWidth = width;
    notifyListeners();
  }

  void setPenType(PenType type) {
    logToolUsage(type.name);
    _currentPenType = type;
    if (type != PenType.shape) {
      _currentShapeType = ShapeType.none;
    }
    clearSelection();
    notifyListeners();
  }

  void setShapeType(ShapeType type) {
    logToolUsage('shape_$type');
    _currentShapeType = type;
    _currentPenType = PenType.shape;
    clearSelection();
    notifyListeners();
  }

  void addStroke(Stroke stroke) {
    strokes.add(stroke);
    _undoStack.clear();
    notifyListeners();
  }
  
  void addCanvasImage(CanvasImage image) {
    images.add(image);
    _undoStack.clear();
    notifyListeners();
  }
  
  void addEquation(CanvasEquation equation) {
    equations.add(equation);
    notifyListeners();
  }
  
  void addText(CanvasText text) {
    texts.add(text);
    notifyListeners();
  }
  
  void addStamp(CanvasStamp stamp) {
    stamps.add(stamp);
    notifyListeners();
  }
  
  void updateText(CanvasText oldText, CanvasText newText) {
    final idx = texts.indexOf(oldText);
    if (idx != -1) {
      texts[idx] = newText;
      notifyListeners();
    }
  }

  void addPointToLastStroke(DrawingPoint point) {
    if (strokes.isNotEmpty) {
      if (strokes.last.penType == PenType.shape) {
        strokes.last = Stroke(
          points: strokes.last.points,
          color: strokes.last.color,
          width: strokes.last.width,
          penType: strokes.last.penType,
          shapeType: strokes.last.shapeType,
          shapeStart: strokes.last.shapeStart,
          shapeEnd: point.point,
        );
      } else {
        strokes.last.points.add(point);
      }
      notifyListeners();
    }
  }

  void removeLastStroke() {
    if (strokes.isNotEmpty) {
      strokes.removeLast();
      notifyListeners();
    }
  }
  
  void removeStroke(Stroke s) {
    strokes.remove(s);
    notifyListeners();
  }

  void undo() {
    if (strokes.isNotEmpty) {
      _undoStack.add(strokes.removeLast());
      notifyListeners();
    }
  }

  void redo() {
    if (_undoStack.isNotEmpty) {
      strokes.add(_undoStack.removeLast());
      notifyListeners();
    }
  }

  void clearBoard() {
    strokes.clear();
    images.clear();
    equations.clear();
    texts.clear();
    stamps.clear();
    currentPage.backgroundImagePath = null;
    _undoStack.clear();
    clearSelection();
    notifyListeners();
  }
  
  void finalizeLassoSelection(Rect rect) {
    _hasSelection = true;
    _selectionRect = rect;
    notifyListeners();
  }
  
  void clearSelection() {
    _hasSelection = false;
    _selectionRect = null;
    notifyListeners();
  }
  
  void translateSelection(Offset delta) {
    if (!_hasSelection || _selectionRect == null) return;
    
    // Find strokes intersecting the selection rect
    for (final stroke in strokes) {
      bool isSelected = false;
      for (final p in stroke.points) {
        if (_selectionRect!.contains(p.point + stroke.translation)) {
          isSelected = true;
          break;
        }
      }
      if (isSelected) {
        stroke.translation += delta;
      }
    }
    
    _selectionRect = _selectionRect!.shift(delta);
    notifyListeners();
  }
  // TopBar / Webcam Variables
  bool _showTimer = false;
  bool get showTimer => _showTimer;
  void toggleTimerVisibility() { _showTimer = !_showTimer; notifyListeners(); }

  Offset _geometryPosition = const Offset(200, 200);
  Offset get geometryPosition => _geometryPosition;
  double _geometryAngle = 0.0;
  double get geometryAngle => _geometryAngle;
  void updateGeometry(Offset pos, double angle) { _geometryPosition = pos; _geometryAngle = angle; notifyListeners(); }

  void deletePage(int index) {
    if (_pages.length > 1) {
      _pages.removeAt(index);
      if (_currentPageIndex >= _pages.length) _currentPageIndex = _pages.length - 1;
      notifyListeners();
    }
  }

  bool _isMicOn = false;
  bool get isMicOn => _isMicOn;
  void toggleMic() { _isMicOn = !_isMicOn; notifyListeners(); }

  bool _showWebcam = false;
  bool get showWebcam => _showWebcam;
  void toggleWebcam() { _showWebcam = !_showWebcam; notifyListeners(); }

  bool _isRecording = false;
  bool get isRecording => _isRecording;
  void setRecording(bool val) { _isRecording = val; notifyListeners(); }

  // Analytics & Recording Markers
  final DateTime _sessionStartTime = DateTime.now();
  final Map<String, int> _toolUsageStats = {};
  int _pagesCreated = 1;
  int _aiFeaturesUsed = 0;
  final List<Map<String, dynamic>> _recordingMarkers = [];

  DateTime get sessionStartTime => _sessionStartTime;
  Map<String, int> get toolUsageStats => _toolUsageStats;
  int get pagesCreated => _pagesCreated;
  int get aiFeaturesUsed => _aiFeaturesUsed;
  List<Map<String, dynamic>> get recordingMarkers => _recordingMarkers;

  void addRecordingMarker(String label) {
    final diff = DateTime.now().difference(_sessionStartTime);
    _recordingMarkers.add({
      'time': diff.toString(),
      'label': label,
    });
    notifyListeners();
  }

  void logToolUsage(String toolName) {
    _toolUsageStats[toolName] = (_toolUsageStats[toolName] ?? 0) + 1;
    notifyListeners();
  }

  void incrementAiUsage() {
    _aiFeaturesUsed++;
    notifyListeners();
  }

  // Accessibility
  double _uiScale = 1.0;
  bool _highContrast = false;
  
  double get uiScale => _uiScale;
  bool get highContrast => _highContrast;
  
  void setUiScale(double scale) {
    _uiScale = scale;
    notifyListeners();
  }
  
  void toggleHighContrast() {
    _highContrast = !_highContrast;
    notifyListeners();
  }

  // File Management
  Timer? _autosaveTimer;

  Future<void> saveBoard(String filePath) async {
    final Map<String, dynamic> data = {
      'pages': _pages.map((p) => p.toJson()).toList(),
    };
    final String jsonStr = jsonEncode(data);
    final File file = File(filePath);
    await file.writeAsString(jsonStr);
  }

  Future<void> loadBoard(String filePath) async {
    final File file = File(filePath);
    if (!await file.exists()) return;
    
    try {
      final String jsonStr = await file.readAsString();
      final Map<String, dynamic> data = jsonDecode(jsonStr);
      
      if (data['pages'] != null) {
        _pages.clear();
        _pages.addAll((data['pages'] as List).map((p) => CanvasPage.fromJson(p)));
        _currentPageIndex = 0;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Failed to load board: $e');
    }
  }

  void startAutosave() {
    _autosaveTimer?.cancel();
    _autosaveTimer = Timer.periodic(const Duration(minutes: 3), (timer) async {
      try {
        final dir = await getApplicationDocumentsDirectory();
        final file = File('${dir.path}/autosave.inkguru');
        await saveBoard(file.path);
        debugPrint('Autosaved to ${file.path}');
      } catch (e) {
        debugPrint('Autosave failed: $e');
      }
    });
  }

  void stopAutosave() {
    _autosaveTimer?.cancel();
  }
}
