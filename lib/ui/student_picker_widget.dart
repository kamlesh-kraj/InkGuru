import 'dart:math';
import 'package:flutter/material.dart';

class StudentPickerWidget extends StatefulWidget {
  const StudentPickerWidget({super.key});

  @override
  State<StudentPickerWidget> createState() => _StudentPickerWidgetState();
}

class _StudentPickerWidgetState extends State<StudentPickerWidget> {
  final List<String> _students = ['Aarav', 'Bhavya', 'Chirag', 'Diya', 'Eshaan', 'Fatima', 'Gaurav', 'Heena'];
  final TextEditingController _controller = TextEditingController();
  String? _selectedStudent;
  bool _isSpinning = false;

  void _pickRandom() async {
    if (_students.isEmpty) return;
    setState(() {
      _isSpinning = true;
      _selectedStudent = null;
    });

    // Simulate a spin
    for (int i = 0; i < 10; i++) {
      await Future.delayed(const Duration(milliseconds: 100));
      setState(() {
        _selectedStudent = _students[Random().nextInt(_students.length)];
      });
    }

    setState(() {
      _isSpinning = false;
    });
  }

  void _addStudent(String name) {
    if (name.isNotEmpty) {
      setState(() {
        _students.add(name);
      });
      _controller.clear();
    }
  }

  void _removeStudent(int index) {
    setState(() {
      _students.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Random Student Picker'),
      content: SizedBox(
        width: 350,
        height: 400,
        child: Column(
          children: [
            if (_selectedStudent != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _isSpinning ? Colors.grey[800] : Colors.blueAccent.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _isSpinning ? Colors.transparent : Colors.blueAccent),
                ),
                child: Center(
                  child: Text(
                    _selectedStudent!,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: _isSpinning ? Colors.white70 : Colors.blueAccent,
                    ),
                  ),
                ),
              )
            else
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Icon(Icons.casino, size: 64, color: Colors.purpleAccent),
              ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _isSpinning || _students.isEmpty ? null : _pickRandom,
              icon: const Icon(Icons.refresh),
              label: const Text('Pick Random'),
            ),
            const Divider(height: 32),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Add student...',
                      isDense: true,
                    ),
                    onSubmitted: _addStudent,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => _addStudent(_controller.text),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: _students.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    dense: true,
                    title: Text(_students[index]),
                    trailing: IconButton(
                      icon: const Icon(Icons.close, size: 16),
                      onPressed: () => _removeStudent(index),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
