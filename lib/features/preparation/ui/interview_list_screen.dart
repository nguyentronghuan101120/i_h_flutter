import 'package:flutter/material.dart';
import 'package:i_h/features/speech/ui/speech_screen.dart';
import 'package:provider/provider.dart';
import '../controllers/interview_controller.dart';
import 'new_interview_screen.dart';

class InterviewPreparationListScreen extends StatelessWidget {
  const InterviewPreparationListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Interview Preparations'),
      ),
      body: Consumer<InterviewController>(
        builder: (context, controller, child) {
          if (controller.interviews.isEmpty) {
            return const Center(
              child: Text(
                  'No interviews yet. Add your first interview preparation!'),
            );
          }

          return ListView.builder(
            itemCount: controller.interviews.length,
            itemBuilder: (context, index) {
              final interview = controller.interviews[index];
              return Card(
                margin: const EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text(interview.scenario,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          'Job Description: ${interview.jobDescription.substring(0, interview.jobDescription.length.clamp(0, 50))}...'),
                      Text(
                          'Resume: ${interview.resume.substring(0, interview.resume.length.clamp(0, 50))}...'),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          controller.setCurrentInterview(interview);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const NewInterviewScreen(),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () async {
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Confirm Delete'),
                              content: Text(
                                  'Are you sure you want to delete the interview for ${interview.scenario}?'),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('Delete'),
                                ),
                              ],
                            ),
                          );

                          if (confirmed == true) {
                            await controller.removeInterview(interview);
                          }
                        },
                      ),
                    ],
                  ),
                  onTap: () {
                    controller.setCurrentInterview(interview);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SpeechScreen(),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const NewInterviewScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
