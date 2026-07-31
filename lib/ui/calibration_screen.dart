// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import '../hardware/xppen_service.dart';

class CalibrationScreen extends StatefulWidget {
  const CalibrationScreen({super.key});

  @override
  State<CalibrationScreen> createState() => _CalibrationScreenState();
}

class _CalibrationScreenState extends State<CalibrationScreen> {
  double _pressureSensitivity = 0.5;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('XP-Pen Pressure Curve Calibration'),
        backgroundColor: Colors.grey[900],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Adjust Pressure Sensitivity',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Slider(
              value: _pressureSensitivity,
              onChanged: (value) {
                setState(() {
                  _pressureSensitivity = value;
                });
              },
              onChangeEnd: (value) async {
                // Generate a simple curve array based on sensitivity
                final curve = List.generate(10, (index) => (index / 9) * value);
                await XPPenService.setPressureCurve(curve);
              },
            ),
            const SizedBox(height: 32),
            const Text(
              'Pressure Curve Graph',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Container(
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey[200],
              ),
              child: CustomPaint(
                painter: _MockCurvePainter(sensitivity: _pressureSensitivity),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Test Area',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.white,
                ),
                alignment: Alignment.center,
                child: const Text(
                  'Test Pressure Here',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MockCurvePainter extends CustomPainter {
  final double sensitivity;

  _MockCurvePainter({required this.sensitivity});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(0, size.height);
    
    // A simple mock curve that changes based on sensitivity
    path.quadraticBezierTo(
      size.width * sensitivity, size.height * (1 - sensitivity),
      size.width, 0,
    );

    canvas.drawPath(path, paint);

    // Draw grid
    final gridPaint = Paint()
      ..color = Colors.grey.withOpacity(0.3)
      ..strokeWidth = 1;

    for (int i = 1; i < 4; i++) {
      double x = size.width * (i / 4);
      double y = size.height * (i / 4);
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _MockCurvePainter oldDelegate) {
    return oldDelegate.sensitivity != sensitivity;
  }
}
