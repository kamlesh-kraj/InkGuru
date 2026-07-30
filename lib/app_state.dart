import 'package:flutter/material.dart';

enum PenType { pen, eraser, shape }
enum ShapeType { none, line, rectangle, circle }

class Stroke {
  final List<Offset> points;
  final Color color;
  final double width;
  final PenType penType;
  final ShapeType shapeType;
  final Offset? shapeStart;
  final Offset? shapeEnd;

  Stroke({
    required this.points,
    required this.color,
    required this.width,
    required this.penType,
    this.shapeType = ShapeType.none,
    this.shapeStart,
    this.shapeEnd,
  });
}

class AppState extends ChangeNotifier {
  final List<Stroke> _strokes = [];
  List<Stroke> get strokes => _strokes;

  final List<Stroke> _undoStack = [];

  Color _currentColor = Colors.white;
  Color get currentColor => _currentColor;

  double _currentWidth = 4.0;
  double get currentWidth => _currentWidth;

  PenType _currentPenType = PenType.pen;
  PenType get currentPenType => _currentPenType;

  ShapeType _currentShapeType = ShapeType.none;
  ShapeType get currentShapeType => _currentShapeType;

  String? _backgroundImagePath;
  String? get backgroundImagePath => _backgroundImagePath;

  int _themeMode = 2; // 0 for Light, 1 for Dark, 2 for Blackboard
  int get themeMode => _themeMode;

  void setThemeMode(int mode) {
    _themeMode = mode;
    notifyListeners();
  }

  bool _isHindi = false;
  bool get isHindi => _isHindi;

  void toggleLanguage() {
    _isHindi = !_isHindi;
    notifyListeners();
  }

  void addStroke(Stroke stroke) {
    _strokes.add(stroke);
    _undoStack.clear();
    notifyListeners();
  }

  void addPointToLastStroke(Offset point) {
    if (_strokes.isNotEmpty) {
      if (_strokes.last.penType == PenType.shape) {
        // Update shape end point
        _strokes[_strokes.length - 1] = Stroke(
          points: _strokes.last.points,
          color: _strokes.last.color,
          width: _strokes.last.width,
          penType: _strokes.last.penType,
          shapeType: _strokes.last.shapeType,
          shapeStart: _strokes.last.shapeStart,
          shapeEnd: point,
        );
      } else {
        _strokes.last.points.add(point);
      }
      notifyListeners();
    }
  }

  void setColor(Color color) {
    _currentColor = color;
    _currentPenType = PenType.pen;
    notifyListeners();
  }

  void setWidth(double width) {
    _currentWidth = width;
    notifyListeners();
  }

  void setPenType(PenType type) {
    _currentPenType = type;
    if (type != PenType.shape) {
      _currentShapeType = ShapeType.none;
    }
    notifyListeners();
  }

  void setShapeType(ShapeType type) {
    _currentShapeType = type;
    _currentPenType = PenType.shape;
    notifyListeners();
  }

  void setBackgroundImage(String path) {
    _backgroundImagePath = path;
    notifyListeners();
  }

  void clearBoard() {
    _undoStack.addAll(_strokes);
    _strokes.clear();
    notifyListeners();
  }

  void undo() {
    if (_strokes.isNotEmpty) {
      _undoStack.add(_strokes.removeLast());
      notifyListeners();
    }
  }

  void redo() {
    if (_undoStack.isNotEmpty) {
      _strokes.add(_undoStack.removeLast());
      notifyListeners();
    }
  }
}
