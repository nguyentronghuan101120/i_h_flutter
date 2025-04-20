import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../services/llm_service.dart';
import '../../../models/qa_pair.dart';
import '../../../models/interview_model.dart';

class SpeechController extends ChangeNotifier {
  final SpeechToText _speechToText = SpeechToText();
  final LLMService _llmService = LLMService();
  bool _speechEnabled = false;
  String _completePhrase = '';
  String _livePhrase = '';
  String _currentPhrase = '';
  final List<String> _questions = [];
  final List<QAPair> _qaPairs = [];
  bool _showQuestionsPanel = true;
  bool _isProcessing = false;
  String _selectedLanguage = 'en-US';
  String? _selectedQuestion;
  bool _isListening = false;
  InterviewPrep? _currentInterview;
  String _status = '';
  // Getters
  bool get speechEnabled => _speechEnabled;
  List<String> get questions => _questions;
  bool get showQuestionsPanel => _showQuestionsPanel;
  bool get isProcessing => _isProcessing;
  String get selectedLanguage => _selectedLanguage;
  String? get selectedQuestion => _selectedQuestion;
  bool get isListening => _isListening;
  String get livePhrase => _livePhrase;
  List<QAPair> get qaPairs => _qaPairs;
  InterviewPrep? get currentInterview => _currentInterview;
  String get status => _status;
  String get completePhrase => _completePhrase;
  String get currentPhrase => _currentPhrase;

  // List of supported languages
  final List<Map<String, String>> supportedLanguages = [
    {'code': 'en-US', 'name': 'English'},
    {'code': 'vi-VN', 'name': 'Vietnamese'},
  ];

  SpeechController() {
    _initSpeech();
  }

  void setCurrentInterview(InterviewPrep interview) {
    _currentInterview = interview;
    notifyListeners();
  }

  Future<void> _initSpeech() async {
    final status = await Permission.microphone.request();
    if (status.isGranted) {
      _speechEnabled = await _speechToText.initialize(
        debugLogging: true,
        onStatus: (status) async {
          _status = status;
          if ((status == "done" || status == "notListening") && _isListening) {
            await stopListening();

            await startListening();
          }
          notifyListeners();
        },
      );
    } else {
      _speechEnabled = false;
    }
    notifyListeners();
  }

  Future<void> startListening() async {
    if (!_speechEnabled) {
      await _initSpeech();
    }

    if (_speechEnabled) {
      _isListening = true;
      _livePhrase = '';
      _currentPhrase = '';
      await _speechToText.listen(
        onResult: _onSpeechResult,
        localeId: _selectedLanguage,
      );
      notifyListeners();
    }
  }

  Future<void> _onSpeechResult(SpeechRecognitionResult result) async {
    final recognizedWords = result.recognizedWords;
    _livePhrase = recognizedWords;
    if (recognizedWords.isNotEmpty) {
      _currentPhrase = recognizedWords;
    }
    notifyListeners();
  }

  Future<void> stopListening() async {
    _isListening = false;
    await _speechToText.stop();
    if (_currentPhrase.isNotEmpty) {
      _completePhrase = _completePhrase.isEmpty
          ? _currentPhrase
          : '$_completePhrase $_currentPhrase';
      _currentPhrase = '';
    }
    _livePhrase = '';
    notifyListeners();
  }

  Future<void> analyzeQuestion(String recognizedWords) async {
    _isProcessing = true;
    notifyListeners();
    final questionResult = await _llmService.analyzeQuestion(recognizedWords);
    if (questionResult.isQuestion) {
      // Filter out questions that already exist in the list
      final newQuestions = questionResult.formattedQuestions
          .where((question) => !_questions.contains(question))
          .toList();
      _questions.insertAll(0, newQuestions);
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

    // Create a new QAPair with loading state
    final qaPair = QAPair(
      question: question,
      answer: '',
    );
    _qaPairs.insert(0, qaPair);
    notifyListeners();

    try {
      final answer = await _llmService.answerQuestion(
        question,
        _currentInterview,
        '$_completePhrase\n$_currentPhrase',
        conversationHistory:
            _qaPairs.sublist(1), // Exclude the current question
      );

      // Update the Q&A pair with the answer
      final index = _qaPairs.indexWhere((pair) => pair.question == question);
      if (index != -1) {
        _qaPairs[index] = QAPair(
          question: question,
          answer: answer,
        );
      }
      notifyListeners();
    } catch (e) {
      // Update the Q&A pair with error state
      final index = _qaPairs.indexWhere((pair) => pair.question == question);
      if (index != -1) {
        _qaPairs[index] = QAPair(
          question: question,
          answer: 'Error processing question (Lỗi xử lý câu hỏi)',
        );
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

  void clearConversation() {
    _qaPairs.clear();
    _questions.clear();
    notifyListeners();
  }
}
