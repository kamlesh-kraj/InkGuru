import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class AIService {
  final String apiKey;
  late final GenerativeModel _model;

  AIService({required this.apiKey}) {
    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: apiKey,
    );
  }

  Future<String> convertHandwritingToText(Uint8List imageBytes) async {
    try {
      final prompt = TextPart("Transcribe the handwritten text in this image. Return only the transcription without any markdown formatting or extra conversational text.");
      final imagePart = DataPart('image/png', imageBytes);
      
      final response = await _model.generateContent([
        Content.multi([prompt, imagePart])
      ]);
      
      return response.text?.trim() ?? '';
    } catch (e) {
      debugPrint('AI Error (Text): $e');
      return '';
    }
  }

  Future<String> convertMathToLatex(Uint8List imageBytes) async {
    try {
      final prompt = TextPart("Convert the handwritten mathematical equation in this image into LaTeX code. Return ONLY the LaTeX code. Do not wrap it in markdown code blocks like `latex ... `. Just return the raw LaTeX string.");
      final imagePart = DataPart('image/png', imageBytes);
      
      final response = await _model.generateContent([
        Content.multi([prompt, imagePart])
      ]);
      
      return response.text?.trim() ?? '';
    } catch (e) {
      debugPrint('AI Error (Math): $e');
      return '';
    }
  }

  Future<String> cleanUpDiagram(Uint8List imageBytes) async {
    try {
      final prompt = TextPart("Analyze the rough hand-drawn diagram in this image and return clean SVG code for the diagram. Ensure lines are straight and shapes are perfect.");
      final imagePart = DataPart('image/png', imageBytes);
      
      final response = await _model.generateContent([
        Content.multi([prompt, imagePart])
      ]);
      
      return response.text?.trim() ?? '';
    } catch (e) {
      debugPrint('AI Error (Diagram): $e');
      return '';
    }
  }

  Future<List<String>> searchTranscripts(String query) async {
    // In a real implementation, this would use AI vector search or full-text search against the saved recording transcripts.
    // We mock the response here.
    await Future.delayed(const Duration(seconds: 1));
    return [
      'Found "$query" in Lecture 42 (00:15:30)',
      'Found "$query" in Lecture 41 (00:05:12)',
    ];
  }
}
