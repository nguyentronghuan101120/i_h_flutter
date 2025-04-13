// main.dart
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:permission_handler/permission_handler.dart';
import 'services/llm_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Speech Assistant',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  final SpeechToText _speechToText = SpeechToText();
  final LLMService _llmService = LLMService();
  bool _speechEnabled = false;
  String _lastWords = '';
  final List<String> _questions = [];
  final Map<String, String> _answers = {}; // Store answers for each question
  bool _showQuestionsPanel = true;
  bool _isProcessing = false;
  String _selectedLanguage = 'en-US'; // Default to English
  String? _selectedQuestion; // Track the currently selected question
  final ScrollController _scrollController = ScrollController();

  // List of supported languages
  final List<Map<String, String>> _supportedLanguages = [
    {'code': 'en-US', 'name': 'English'},
    {'code': 'vi-VN', 'name': 'Vietnamese'},
  ];

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// Request microphone permission and initialize speech recognition
  void _initSpeech() async {
    // Request microphone permission
    final status = await Permission.microphone.request();
    if (status.isGranted) {
      _speechEnabled = await _speechToText.initialize(
        debugLogging: true,
      );
    } else {
      _speechEnabled = false;
    }
    setState(() {});
  }

  /// Each time to start a speech recognition session
  void _startListening() async {
    await _speechToText.listen(
      onResult: _onSpeechResult,
      listenOptions: SpeechListenOptions(onDevice: true),
      localeId: _selectedLanguage,
    );
    setState(() {});
  }

  /// Manually stop the active speech recognition session
  /// Note that there are also timeouts that each platform enforces
  /// and the SpeechToText plugin supports setting timeouts on the
  /// listen method.
  void _stopListening() async {
    await _speechToText.stop();
    setState(() {});
  }

  Future<void> _onSpeechResult(SpeechRecognitionResult result) async {
    final recognizedWords = result.recognizedWords;
    setState(() {
      _lastWords = recognizedWords;
      _isProcessing = true;
    });

    // Scroll to bottom when new words are recognized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });

    // Only analyze if the speech recognition is final
    if (result.finalResult || _isProcessing == false) {
      final questionResult = await _llmService.analyzeQuestion(recognizedWords);
      if (questionResult.isQuestion) {
        setState(() {
          _questions.addAll(questionResult.formattedQuestions);
        });
      }
      setState(() {
        _isProcessing = false;
      });
    } else {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  // Function to change language
  void _changeLanguage(String languageCode) {
    setState(() {
      _selectedLanguage = languageCode;
    });
    if (_speechToText.isListening) {
      _stopListening();
      _startListening();
    }
  }

  Future<void> _handleQuestionTap(String question) async {
    setState(() {
      _selectedQuestion = question;
      _isProcessing = true;
    });

    try {
      final answer = await _llmService.answerQuestion(question);
      setState(() {
        _answers[question] = answer;
        _isProcessing = false;
      });
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    Widget buildLanguageSelector() {
      return DropdownButton<String>(
        value: _selectedLanguage,
        items: _supportedLanguages.map((language) {
          return DropdownMenuItem<String>(
            value: language['code'],
            child: Text(language['name']!),
          );
        }).toList(),
        onChanged: (String? newValue) {
          if (newValue != null) {
            _changeLanguage(newValue);
          }
        },
      );
    }

    Widget buildQuestionsPanel() {
      return Container(
        width: isSmallScreen ? screenWidth : 300,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          border: Border(
            right: BorderSide(
              color: Colors.grey.shade300,
              width: 1.0,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Text(
                    'Questions History',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  if (_isProcessing)
                    const Padding(
                      padding: EdgeInsets.only(left: 8.0),
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _questions.length,
                itemBuilder: (context, index) {
                  final question = _questions[index];
                  final isSelected = question == _selectedQuestion;
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    color: isSelected ? Colors.blue.shade50 : null,
                    child: ListTile(
                      title: Text(
                        question,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      onTap: () => _handleQuestionTap(question),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      );
    }

    Widget buildMainContent() {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recognized words:',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                buildLanguageSelector(),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _speechToText.isListening
                            ? _lastWords
                            : _speechEnabled
                                ? 'Tap the microphone to start listening...'
                                : 'Speech not available',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      if (_selectedQuestion != null) ...[
                        const SizedBox(height: 24),
                        Text(
                          'Answer:',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _answers[_selectedQuestion!] ?? 'Loading answer...',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Speech Assistant'),
        actions: [
          if (isSmallScreen)
            IconButton(
              icon: Icon(
                _showQuestionsPanel ? Icons.close : Icons.history,
              ),
              onPressed: () {
                setState(() {
                  _showQuestionsPanel = !_showQuestionsPanel;
                });
              },
            ),
        ],
      ),
      body: isSmallScreen
          ? Stack(
              children: [
                buildMainContent(),
                if (_showQuestionsPanel) buildQuestionsPanel(),
              ],
            )
          : Row(
              children: [
                buildQuestionsPanel(),
                Expanded(child: buildMainContent()),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed:
            _speechToText.isNotListening ? _startListening : _stopListening,
        tooltip: 'Listen',
        child: Icon(_speechToText.isNotListening ? Icons.mic_off : Icons.mic),
      ),
    );
  }
}
