// main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'features/speech/controllers/speech_controller.dart';
import 'features/preparation/controllers/interview_controller.dart';
import 'features/preparation/ui/interview_list_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SpeechController()),
        ChangeNotifierProvider(create: (_) => InterviewController()),
      ],
      child: MaterialApp(
        title: 'Interview Helper',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        home: const InterviewPreparationListScreen(),
      ),
    );
  }
}
