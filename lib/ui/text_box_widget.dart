import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';

class TextBoxWidget extends StatefulWidget {
  final CanvasText canvasText;
  const TextBoxWidget({super.key, required this.canvasText});

  @override
  State<TextBoxWidget> createState() => _TextBoxWidgetState();
}

class _TextBoxWidgetState extends State<TextBoxWidget> {
  late TextEditingController _controller;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.canvasText.text);
    _focusNode = FocusNode();
    if (widget.canvasText.isEditing) {
      _focusNode.requestFocus();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _finishEditing() {
    if (!mounted) return;
    final appState = Provider.of<AppState>(context, listen: false);
    
    // If text is empty, we could remove it, but for simplicity let's just update
    if (_controller.text.trim().isEmpty) {
      // Not strictly implementing removeText for MVP, so we just set it to empty
    }
    
    appState.updateText(
      widget.canvasText, 
      CanvasText(
        text: _controller.text, 
        position: widget.canvasText.position, 
        style: widget.canvasText.style,
        isEditing: false,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.canvasText.isEditing) {
      return Container(
        constraints: const BoxConstraints(minWidth: 100, maxWidth: 300),
        child: TextField(
          controller: _controller,
          focusNode: _focusNode,
          style: widget.canvasText.style,
          maxLines: null,
          autofocus: true,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            fillColor: Colors.black54,
            filled: true,
            hintText: 'Type here...',
            hintStyle: TextStyle(color: Colors.white54),
          ),
          onSubmitted: (_) => _finishEditing(),
          onTapOutside: (_) => _finishEditing(),
        ),
      );
    } else {
      if (widget.canvasText.text.trim().isEmpty) {
        return const SizedBox.shrink(); // Hide empty text boxes
      }
      return GestureDetector(
        onDoubleTap: () {
          final appState = Provider.of<AppState>(context, listen: false);
          appState.updateText(
            widget.canvasText, 
            CanvasText(
              text: widget.canvasText.text, 
              position: widget.canvasText.position, 
              style: widget.canvasText.style,
              isEditing: true,
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(4),
          color: Colors.transparent, // To catch taps
          child: Text(
            widget.canvasText.text,
            style: widget.canvasText.style,
          ),
        ),
      );
    }
  }
}
