import 'package:chatapp_mst/models/ai_response.dart';
import 'package:dio/dio.dart';

class AiService {
  final Dio dio;

  AiService({Dio? dio})
    : dio =
          dio ??
          Dio(
            BaseOptions(
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 10),
            ),
          );

  Future<String> callGroq(String prompt, String apiKey) async {
    final response = await dio.post(
      "https://api.groq.com/openai/v1/chat/completions",
      options: Options(
        headers: {
          "Authorization": "Bearer $apiKey",
          "Content-Type": "application/json",
        },
      ),
      data: {
        "model": "llama-3.3-70b-versatile",
        "messages": [
          {"role": "user", "content": prompt},
        ],
      },
    );

    return response.data["choices"][0]["message"]["content"];
  }

  Future<String> callGemini(String prompt, String apiKey) async {
    final response = await dio.post(
      "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=$apiKey",
      options: Options(headers: {"Content-Type": "application/json"}),
      data: {
        "contents": [
          {
            "parts": [
              {"text": prompt},
            ],
          },
        ],
      },
    );

    return response.data["candidates"][0]["content"]["parts"][0]["text"];
  }

  Future<AiResponse> getGroqResponse(String prompt, String apiKey) async {
    final text = await callGroq(prompt, apiKey);
    return AiResponse(text: text);
  }

  Future<AiResponse> getGeminiResponse(String prompt, String apiKey) async {
    final text = await callGemini(prompt, apiKey);
    return AiResponse(text: text);
  }

}
