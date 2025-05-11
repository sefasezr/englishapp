import 'dart:convert';
import 'package:http/http.dart' as http;

class GeminiService {
  final String apiKey = 'AIzaSyCF53h2D_IIK3UyW6atzSrbCOB2fPvLXSs';
  final String baseUrl = 'https://generativelanguage.googleapis.com/v1/models';

  Future<String> getChatResponse(
    List<Map<String, String>> history, {
    String model = 'gemini-1.5-flash',
  }) async {
    final Uri url = Uri.parse('$baseUrl/$model:generateContent?key=$apiKey');
    final client = http.Client();

    try {
      final response = await client
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              "contents":
                  history.map((message) {
                    return {
                      "role": message['role'],
                      "parts": [
                        {"text": message['parts']},
                      ],
                    };
                  }).toList(),
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['candidates'][0]['content']['parts'][0]['text'] ??
            'Yanıt alınamadı.';
      } else {
        print('API Hatası: ${response.statusCode}, ${response.body}');
        return 'API isteği sırasında bir hata oluştu.';
      }
    } catch (e) {
      print('İstek Sırasında Hata: $e');
      return 'İstek gönderilirken bir hata oluştu.';
    } finally {
      client.close();
    }
  }
}
