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
  @override
  Widget build(BuildContext context) {
    return Consumer<SpeechController>(
      builder: (context, controller, child) {
        // Scroll to bottom whenever the text changes
        WidgetsBinding.instance.addPostFrameCallback((_) {
          scrollToBottom();
        });

        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.mic, color: Theme.of(context).primaryColor),
                    const SizedBox(width: 8),
                    Text(
                      "Voice Recognition",
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: SelectableText(
                        controller.isListening
                            ? '${controller.completePhrase}\n${controller.currentPhrase}'
                            : controller.completePhrase,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: controller.isListening
                                  ? Colors.black87
                                  : Colors.black54,
                            ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
