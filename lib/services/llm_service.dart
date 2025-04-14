// services/llm_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class QuestionResult {
  final bool isQuestion;
  final List<String> formattedQuestions;

  QuestionResult({required this.isQuestion, required this.formattedQuestions});
}

class LLMService {
  static const String _apiKey =
      'AIzaSyBc8bdflPcsEoH4xtj0ELi-RU4eONs_ZdU'; // Replace with your actual Google AI API key
  static const String _apiUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$_apiKey';

  Future<QuestionResult> analyzeQuestion(String text) async {
    try {
      final prompt = '''
        You are a smart language assistant. Your task is to analyze the following text and extract all questions from it.

        Instructions:

        1. Determine if the text contains any questions.
        2. If it contains questions:
            * Extract all questions from the text
            * Correct any spelling or grammar mistakes in each question
            * Add a question mark at the end if it's missing
            * Return a JSON object in the following format: `{"isQuestion": true, "formattedQuestions": ["<corrected question 1>", "<corrected question 2>", ...]}`
        3. If it does NOT contain any questions:
            * Return a JSON object in the following format: `{"isQuestion": false, "formattedQuestions": []}`

        Example 1:

        Text: "what is the capital of france and how many people live there"

        Output:

        `{"isQuestion": true, "formattedQuestions": ["What is the capital of France?", "How many people live there?"]}`

        Example 2:

        Text: "The capital of France is Paris."

        Output:

        `{"isQuestion": false, "formattedQuestions": []}`

        Now, analyze the following text:

        Text: "$text"
      ''';

      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt}
              ]
            }
          ],
          "generationConfig": {
            "temperature": 0.0,
            "topP": 1,
            "topK": 1,
          },
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['candidates'] != null &&
            data['candidates'].isNotEmpty &&
            data['candidates'][0]['content'] != null &&
            data['candidates'][0]['content']['parts'] != null &&
            data['candidates'][0]['content']['parts'].isNotEmpty) {
          try {
            final String responseText =
                data['candidates'][0]['content']['parts'][0]['text'];
            // Clean up the response text by removing markdown code block markers
            final String cleanedText = responseText
                .replaceAll('```json', '')
                .replaceAll('```', '')
                .trim();
            final Map<String, dynamic> jsonResponse = jsonDecode(cleanedText);

            return QuestionResult(
              isQuestion: jsonResponse['isQuestion'] ?? false,
              formattedQuestions:
                  List<String>.from(jsonResponse['formattedQuestions'] ?? []),
            );
          } catch (e) {
            return QuestionResult(
                isQuestion: false,
                formattedQuestions: []); // Handle JSON decode errors
          }
        } else {
          return QuestionResult(
              isQuestion: false,
              formattedQuestions: []); // Handle empty candidates
        }
      } else {
        return QuestionResult(
            isQuestion: false, formattedQuestions: []); // Handle API errors
      }
    } catch (e) {
      return QuestionResult(
          isQuestion: false,
          formattedQuestions: []); // Handle network or other errors
    }
  }

  Future<String> answerQuestion(String question) async {
    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': question}
              ]
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['candidates'] != null &&
            data['candidates'].isNotEmpty &&
            data['candidates'][0]['content'] != null &&
            data['candidates'][0]['content']['parts'] != null &&
            data['candidates'][0]['content']['parts'].isNotEmpty) {
          return data['candidates'][0]['content']['parts'][0]['text'];
        }
        return 'Sorry, I couldn\'t process the response properly.';
      } else {
        return 'Sorry, I encountered an error while processing your question. Status code: ${response.statusCode}';
      }
    } catch (e) {
      return 'Sorry, I encountered an error while processing your question: $e';
    }
  }
}
