import 'dart:convert';
import 'package:http/http.dart' as http;

class LLMService {
  static const String _apiKey =
      'AIzaSyBc8bdflPcsEoH4xtj0ELi-RU4eONs_ZdU'; // Replace with your actual Google AI API key
  static const String _apiUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent';

  Future<String> answerQuestion(String question) async {
    try {
      final response = await http.post(
        Uri.parse('$_apiUrl?key=$_apiKey'),
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
