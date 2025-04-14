import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/speech_controller.dart';
import 'auto_scroll_mixin.dart';

class SpeechRecognitionSection extends StatefulWidget {
  const SpeechRecognitionSection({super.key});

  @override
  State<SpeechRecognitionSection> createState() =>
      _SpeechRecognitionSectionState();
}

class _SpeechRecognitionSectionState extends State<SpeechRecognitionSection>
    with AutoScrollMixin {
  String? _previousText;

  @override
  void initState() {
    super.initState();
    _previousText = '';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SpeechController>(
      builder: (context, controller, child) {
        final currentText = controller.completePhrase != ""
            ? controller.completePhrase
            : controller.speechEnabled
                ? 'Tap the microphone to start listening...'
                : 'Speech not available';

        if (currentText != _previousText) {
          _previousText = currentText;
          scrollToBottom();
        }

        return Expanded(
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                controller: scrollController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.mic, color: Theme.of(context).primaryColor),
                        const SizedBox(width: 8),
                        Text(
                          "Voice Recognition",
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).primaryColor,
                                  ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SelectableText(
                            currentText,
                            style:
                                Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      color: controller.isListening
                                          ? Colors.black87
                                          : Colors.black54,
                                    ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
