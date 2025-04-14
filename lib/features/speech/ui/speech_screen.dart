import 'package:flutter/material.dart';
import 'package:i_h/features/speech/ui/widgets/answer_question_section.dart';
import 'package:i_h/features/speech/ui/widgets/question_section.dart';
import 'package:i_h/features/speech/ui/widgets/speech_recognition_section.dart';
import 'package:provider/provider.dart';
import '../controllers/speech_controller.dart';

class SpeechScreen extends StatelessWidget {
  const SpeechScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SpeechController>(
      builder: (context, controller, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Speech Assistant'),
            actions: [
              if (MediaQuery.of(context).size.width < 600)
                IconButton(
                  icon: Icon(
                    controller.showQuestionsPanel ? Icons.close : Icons.history,
                  ),
                  onPressed: controller.toggleQuestionsPanel,
                ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isSmallScreen = constraints.maxWidth < 600;

                return isSmallScreen
                    ? Stack(
                        children: [
                          _buildMainContent(),
                          if (controller.showQuestionsPanel)
                            const QuestionSection(),
                        ],
                      )
                    : Row(
                        children: [
                          const QuestionSection(),
                          Expanded(child: _buildMainContent()),
                        ],
                      );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildLanguageSelector() {
    return Consumer<SpeechController>(
      builder: (context, controller, child) {
        return DropdownButton<String>(
          value: controller.selectedLanguage,
          items: controller.supportedLanguages.map((language) {
            return DropdownMenuItem<String>(
              value: language['code'],
              child: Text(language['name']!),
            );
          }).toList(),
          onChanged: (String? newValue) {
            if (newValue != null) {
              controller.changeLanguage(newValue);
            }
          },
        );
      },
    );
  }

  Widget _buildMainContent() {
    return Consumer<SpeechController>(
      builder: (context, controller, child) {
        return Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildLanguageSelector(),
                  const SizedBox(width: 16),
                  FloatingActionButton(
                    onPressed: controller.isListening
                        ? controller.stopListening
                        : controller.startListening,
                    tooltip: 'Listen',
                    backgroundColor: controller.isListening
                        ? Colors.redAccent
                        : Theme.of(context).colorScheme.surface,
                    child: Icon(
                      controller.isListening ? Icons.stop : Icons.mic,
                      color: controller.isListening
                          ? Colors.white
                          : Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(width: 16),
                  FloatingActionButton(
                    onPressed: () async => await controller
                        .analyzeQuestion(controller.completePhrase),
                    tooltip: 'Analyze Question',
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    child: Icon(
                      Icons.analytics,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const SpeechRecognitionSection(),
              const SizedBox(height: 16),
              const AnswerQuestionSection(),
            ],
          ),
        );
      },
    );
  }
}
