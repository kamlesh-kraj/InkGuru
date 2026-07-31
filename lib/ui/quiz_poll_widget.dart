import 'package:flutter/material.dart';

class QuizPollDialog extends StatefulWidget {
  const QuizPollDialog({super.key});

  @override
  State<QuizPollDialog> createState() => _QuizPollDialogState();
}

class _QuizPollDialogState extends State<QuizPollDialog> {
  String _question = "";
  final List<String> _options = ["", ""];

  void _addOption() {
    setState(() {
      _options.add("");
    });
  }

  void _removeOption(int index) {
    if (_options.length > 2) {
      setState(() {
        _options.removeAt(index);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create Quick Quiz / Poll'),
      content: SizedBox(
        width: 400,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Question',
                  border: OutlineInputBorder(),
                ),
                onChanged: (val) => _question = val,
              ),
              const SizedBox(height: 16),
              ...List.generate(_options.length, (index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            labelText: 'Option ${index + 1}',
                            border: const OutlineInputBorder(),
                          ),
                          onChanged: (val) => _options[index] = val,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.remove_circle, color: Colors.redAccent),
                        onPressed: () => _removeOption(index),
                      )
                    ],
                  ),
                );
              }),
              TextButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Add Option'),
                onPressed: _addOption,
              )
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            // In a full implementation, this would broadcast the quiz to students or render it on the board
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Quiz "$_question" launched!')),
            );
          },
          child: const Text('Launch Poll'),
        ),
      ],
    );
  }
}
