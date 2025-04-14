import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../services/llm_service.dart';

class SpeechController extends ChangeNotifier {
  final SpeechToText _speechToText = SpeechToText();
  final LLMService _llmService = LLMService();
  bool _speechEnabled = false;
  String _completePhrase = '';
  final List<String> _questions = [
    "What is the App state?",
    "Should use state management?",
    "what is The pros and cons of different state management solutions?"
  ];
  final Map<String, String> _answers = {};
  final List<Map<String, dynamic>> _qaPairs = [];
  bool _showQuestionsPanel = true;
  bool _isProcessing = false;
  String _selectedLanguage = 'en-US';
  String? _selectedQuestion;
  bool _isListening = false;

  // Getters
  bool get speechEnabled => _speechEnabled;
  List<String> get questions => _questions;
  Map<String, String> get answers => _answers;
  bool get showQuestionsPanel => _showQuestionsPanel;
  bool get isProcessing => _isProcessing;
  String get selectedLanguage => _selectedLanguage;
  String? get selectedQuestion => _selectedQuestion;
  bool get isListening => _isListening;
  String get completePhrase => _completePhrase;
  List<Map<String, dynamic>> get qaPairs => _qaPairs;

  // List of supported languages
  final List<Map<String, String>> supportedLanguages = [
    {'code': 'en-US', 'name': 'English'},
    {'code': 'vi-VN', 'name': 'Vietnamese'},
  ];

  SpeechController() {
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    final status = await Permission.microphone.request();
    if (status.isGranted) {
      _speechEnabled = await _speechToText.initialize(
        debugLogging: true,
      );
    } else {
      _speechEnabled = false;
    }
    notifyListeners();
  }

  Future<void> startListening() async {
    _isListening = true;
    await _speechToText.listen(
      onResult: _onSpeechResult,
      listenOptions: SpeechListenOptions(listenMode: ListenMode.dictation),
      localeId: _selectedLanguage,
    );
    notifyListeners();
  }

  Future<void> stopListening() async {
    _isListening = false;
    await _speechToText.stop();
    notifyListeners();
  }

  Future<void> _onSpeechResult(SpeechRecognitionResult result) async {
    final recognizedWords = result.recognizedWords;

    _completePhrase = recognizedWords;

    notifyListeners();
  }

  Future<void> analyzeQuestion(String recognizedWords) async {
    _isProcessing = true;
    notifyListeners();
    final questionResult = await _llmService.analyzeQuestion(recognizedWords);
    if (questionResult.isQuestion) {
      _questions.insertAll(0, questionResult.formattedQuestions);
    }
    _isProcessing = false;
    notifyListeners();
  }

  void changeLanguage(String languageCode) async {
    bool wasListening = _isListening;
    if (wasListening) {
      await stopListening();
      await Future.delayed(const Duration(milliseconds: 100));
    }

    _selectedLanguage = languageCode;
    notifyListeners();

    if (wasListening && !_isListening) {
      try {
        await startListening();
      } catch (e) {
        debugPrint('Error restarting speech recognition: $e');
      }
    }
  }

  Future<void> handleQuestionTap(String question) async {
    _selectedQuestion = question;

    // Add the question immediately with loading state
    _qaPairs.insert(0, {
      'question': question,
      'answer': '',
      'isProcessing': true,
    });
    notifyListeners();

    try {
      final answer = await _llmService.answerQuestion(question);
      _answers[question] = answer;

      // Update the Q&A pair with the answer
      final index = _qaPairs.indexWhere((pair) => pair['question'] == question);
      if (index != -1) {
        _qaPairs[index] = {
          'question': question,
          'answer': answer,
          'isProcessing': false,
        };
      }
      notifyListeners();
    } catch (e) {
      // Update the Q&A pair with error state
      final index = _qaPairs.indexWhere((pair) => pair['question'] == question);
      if (index != -1) {
        _qaPairs[index] = {
          'question': question,
          'answer': 'Error: Failed to get answer',
          'isProcessing': false,
        };
      }
      notifyListeners();
    }
  }

  void toggleQuestionsPanel() {
    _showQuestionsPanel = !_showQuestionsPanel;
    notifyListeners();
  }

  void clearCompletePhrase() {
    _completePhrase = '';
    notifyListeners();
  }
}
