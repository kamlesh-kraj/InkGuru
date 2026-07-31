import 'package:flutter/material.dart';

class SpotlightOverlay extends StatefulWidget {
  const SpotlightOverlay({super.key});

  @override
  State<SpotlightOverlay> createState() => _SpotlightOverlayState();
}

class _SpotlightOverlayState extends State<SpotlightOverlay> {
  Offset _position = const Offset(400, 300);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: (details) {
        setState(() {
          _position += details.delta;
        });
      },
      child: CustomPaint(
        size: Size.infinite,
        painter: _SpotlightPainter(position: _position, radius: 150),
      ),
    );
  }
}

class _SpotlightPainter extends CustomPainter {
  final Offset position;
  final double radius;

  _SpotlightPainter({required this.position, required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withValues(alpha: 0.85)
      ..style = PaintingStyle.fill;
    
    final path = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final circlePath = Path()..addOval(Rect.fromCircle(center: position, radius: radius));
    
    final resultPath = Path.combine(PathOperation.difference, path, circlePath);
    canvas.drawPath(resultPath, paint);
  }

  @override
  bool shouldRepaint(_SpotlightPainter oldDelegate) {
    return oldDelegate.position != position || oldDelegate.radius != radius;
  }
}

class CurtainOverlay extends StatefulWidget {
  const CurtainOverlay({super.key});

  @override
  State<CurtainOverlay> createState() => _CurtainOverlayState();
}

class _CurtainOverlayState extends State<CurtainOverlay> {
  double _curtainHeight = 400.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: _curtainHeight,
              child: GestureDetector(
                onPanUpdate: (details) {
                  setState(() {
                    _curtainHeight = (_curtainHeight + details.delta.dy)
                        .clamp(100.0, constraints.maxHeight);
                  });
                },
                child: Container(
                  color: Colors.grey[800],
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      height: 10,
                      color: Colors.blueAccent,
                      margin: const EdgeInsets.only(bottom: 2),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      }
    );
  }
}
