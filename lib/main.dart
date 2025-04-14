// main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'features/speech/controllers/speech_controller.dart';
import 'features/speech/ui/speech_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SpeechController(),
      child: MaterialApp(
        title: 'Speech Assistant',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        home: const SpeechScreen(),
      ),
    );
  }
}

