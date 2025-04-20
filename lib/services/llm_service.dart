// services/llm_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:i_h/models/qa_pair.dart';
import '../models/interview_model.dart';

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

  Future<String> answerQuestion(
    String question,
    InterviewPrep? interview,
    String voiceRecognition, {
    List<QAPair>? conversationHistory,
  }) async {
    try {
      String contextPrompt = '';
      if (interview != null) {
        contextPrompt = '''
        You are an expert interviewer in the field of ${interview.scenario}. 
        You are conducting an interview for a ${interview.scenario} position.
        
        Job Description:
        ${interview.jobDescription}
        
        Candidate's Resume:
        ${interview.resume}

        Voice Recognition Context:
        The following question was captured through voice recognition: "$voiceRecognition"
        Please consider any potential transcription errors or variations from the original voice input.
        ''';

        if (conversationHistory != null && conversationHistory.isNotEmpty) {
          contextPrompt += '\nPrevious conversation:\n';
          for (var qa in conversationHistory) {
            contextPrompt += 'Q: ${qa.question}\nA: ${qa.answer}\n\n';
          }
        }

        contextPrompt += '''
        Based on this context and previous conversation, please provide a detailed and relevant answer to the following question.
        Your answer should:
        1. Be specific to the candidate's background and experience
        2. Consider the job requirements
        3. Provide practical examples and insights
        4. Be professional and constructive
        5. Maintain consistency with previous answers
        6. Build upon previous discussion points when relevant
        7. Detect the language of the question and respond in the same language (Vietnamese or English)
        
        Question: $question
        ''';
      } else {
        contextPrompt = '''
        You are an expert interviewer. Please provide a detailed and relevant answer to the following question.
        Your answer should be professional, constructive, and provide practical insights.
        Detect the language of the question and respond in the same language (Vietnamese or English).

        Voice Recognition Context:
        The following question was captured through voice recognition: "$voiceRecognition"
        Please consider any potential transcription errors or variations from the original voice input.
        
        ${conversationHistory != null && conversationHistory.isNotEmpty ? 'Previous conversation:\n${conversationHistory.map((qa) => 'Q: ${qa.question}\nA: ${qa.answer}\n\n').join()}' : ''}
        
        Question: $question
        ''';
      }

      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': contextPrompt}
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
        return 'Sorry, I couldn\'t process the response properly. Xin lỗi, tôi không thể xử lý câu trả lời một cách chính xác.';
      } else {
        return 'Error processing question (Lỗi xử lý câu hỏi). Status code: ${response.statusCode}';
      }
    } catch (e) {
      return 'Error processing question (Lỗi xử lý câu hỏi): $e';
    }
  }
}
