import 'package:flutter/material.dart';
import 'package:i_h/features/speech/controllers/speech_controller.dart';
import 'package:provider/provider.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'auto_scroll_mixin.dart';

class AnswerQuestionSection extends StatefulWidget {
  const AnswerQuestionSection({super.key});

  @override
  State<AnswerQuestionSection> createState() => _AnswerQuestionSectionState();
}

class _AnswerQuestionSectionState extends State<AnswerQuestionSection>
    with AutoScrollMixin {
  MarkdownStyleSheet _getMarkdownStyleSheet(BuildContext context) {
    final theme = Theme.of(context);
    return MarkdownStyleSheet(
      h1: theme.textTheme.headlineMedium?.copyWith(
        color: theme.primaryColor,
        fontWeight: FontWeight.bold,
      ),
      h2: theme.textTheme.titleLarge?.copyWith(
        color: theme.primaryColor,
        fontWeight: FontWeight.bold,
      ),
      h3: theme.textTheme.titleMedium?.copyWith(
        color: theme.primaryColor,
        fontWeight: FontWeight.bold,
      ),
      p: theme.textTheme.bodyLarge,
      strong: theme.textTheme.bodyLarge?.copyWith(
        fontWeight: FontWeight.bold,
        color: theme.primaryColor,
      ),
      em: theme.textTheme.bodyLarge?.copyWith(
        fontStyle: FontStyle.italic,
      ),
      listBullet: theme.textTheme.bodyLarge,
      blockquote: theme.textTheme.bodyLarge?.copyWith(
        color: theme.primaryColor.withAlpha(800),
        fontStyle: FontStyle.italic,
      ),
      code: theme.textTheme.bodyLarge?.copyWith(
        fontFamily: 'monospace',
        backgroundColor: theme.primaryColor.withAlpha(100),
      ),
      codeblockDecoration: BoxDecoration(
        color: theme.primaryColor.withAlpha(100),
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SpeechController>(
      builder: (context, controller, child) {
        return Expanded(
          flex: 3,
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
                        Icon(Icons.question_answer,
                            color: Theme.of(context).primaryColor),
                        const SizedBox(width: 8),
                        Text(
                          "Question & Answer",
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).primaryColor,
                                  ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: controller.qaPairs.length,
                      itemBuilder: (context, index) {
                        final qaPair = controller.qaPairs[index];
                        final isProcessing = qaPair.answer.isEmpty;
                        return Column(
                          children: [
                            Card(
                              color:
                                  Theme.of(context).primaryColor.withAlpha(100),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.chat_bubble_outline,
                                            color:
                                                Theme.of(context).primaryColor,
                                            size: 20),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Question:',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                                color: Theme.of(context)
                                                    .primaryColor,
                                              ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    MarkdownBody(
                                      data: qaPair.question,
                                      styleSheet:
                                          _getMarkdownStyleSheet(context),
                                      selectable: true,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Card(
                              color: Colors.white,
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.lightbulb_outline,
                                            color:
                                                Theme.of(context).primaryColor,
                                            size: 20),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Answer:',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                                color: Theme.of(context)
                                                    .primaryColor,
                                              ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    if (isProcessing)
                                      Center(
                                        child: Padding(
                                          padding: const EdgeInsets.all(16.0),
                                          child: CircularProgressIndicator(
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                              Theme.of(context).primaryColor,
                                            ),
                                          ),
                                        ),
                                      )
                                    else
                                      MarkdownBody(
                                        data: qaPair.answer,
                                        styleSheet:
                                            _getMarkdownStyleSheet(context),
                                        selectable: true,
                                      ),
                                  ],
                                ),
                              ),
                            ),
                            if (index < controller.qaPairs.length - 1)
                              const SizedBox(height: 16),
                          ],
                        );
                      },
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
