import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';

class GroqService {
  static const String groqApiKey = String.fromEnvironment('GROQ_API_KEY');

  Future<String> getSleepRecommendations({
    required String userContextData,
    String? userCustomQuestion,
  }) async {
    if (groqApiKey.isEmpty) {
      return 'Ошибка: API-ключ GROQ_API_KEY не задан в переменных окружения. '
          'Пожалуйста, запустите приложение с флагом --dart-define=GROQ_API_KEY=ваш_ключ';
    }

    final client = HttpClient();
    try {
      final uri = Uri.parse('https://api.groq.com/openai/v1/chat/completions');
      final request = await client.postUrl(uri);
      
      request.headers.set(HttpHeaders.contentTypeHeader, 'application/json; charset=utf-8');
      request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $groqApiKey');

      const systemPrompt = "Ты — квалифицированный ИИ-эксперт в области сомнологии и здорового сна. "
          "Твоя цель — анализировать предоставленные JSON-данные пользователя (его логи сна и ежедневные заметки), "
          "выявлять закономерности (например, связь стресса в заметках с плохим сном) и давать персонализированные, "
          "емкие и практичные советы по улучшению качества сна. "
          "Пиши структурировано, используй списки, отвечай на русском языке, делай ответы адаптивными под мобильный экран (без длинных простыней текста).";

      final List<Map<String, String>> messages = [
        {'role': 'system', 'content': systemPrompt},
        {
          'role': 'user',
          'content': 'Вот мои данные сна в формате JSON:\n$userContextData\n\n'
              '${userCustomQuestion != null && userCustomQuestion.isNotEmpty ? "Мой вопрос к тебе: $userCustomQuestion" : "Пожалуйста, проанализируй мои данные и дай краткие рекомендации по улучшению сна."}'
        }
      ];

      final body = jsonEncode({
        'model': 'llama-3.3-70b-versatile',
        'messages': messages,
        'temperature': 0.7,
      });

      request.write(body);
      
      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();

      if (response.statusCode == 200) {
        final data = jsonDecode(responseBody);
        return data['choices'][0]['message']['content'] as String;
      } else {
        return 'Ошибка сервера (код ${response.statusCode}): $responseBody';
      }
    } catch (e) {
      debugPrint("GroqService error: $e");
      return 'Ошибка сети/подключения: $e';
    } finally {
      client.close();
    }
  }
}
