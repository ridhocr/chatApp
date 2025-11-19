import 'package:flutter/material.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import '../models/ai_response.dart';
import '../services/api/ai_service.dart';

class ChatViewModel extends ChangeNotifier {
  final AiService aiService = AiService();

  ChatViewModel(BuildContext context);

  List<Map<String, dynamic>> messages = [];
  bool isLoading = false;

  // ============================
  // MODEL SELECTION
  // ============================
  String selectedModel = "gemini"; // default

  void changeModel(String model) {
    selectedModel = model;
    notifyListeners();
  }

  // ============================
  // SEND TEXT MESSAGE
  // ============================
  Future<void> sendMessage(String text) async {
    const groqKey = "xxx";
    const geminiKey = "xxx";

    messages.add({"role": "user", "type": "text", "text": text});
    notifyListeners();

    isLoading = true;
    notifyListeners();

    try {
      final AiResponse response;

      if (selectedModel == "groq") {
        response = await aiService.getGroqResponse(text, groqKey);
      } else {
        response = await aiService.getGeminiResponse(text, geminiKey);
      }

      messages.add({
        "role": "ai",
        "type": "text",
        "text": response.text,
      });
    } catch (e) {
      messages.add({
        "role": "ai",
        "type": "text",
        "text": "Error: $e",
      });
    }

    isLoading = false;
    notifyListeners();
  }

  // ============================
  // UPLOAD IMAGE
  // ============================
  void sendImage(String path) {
    messages.add({
      "role": "user",
      "type": "image",
      "fileUrl": path,
    });
    notifyListeners();
  }

  // ============================
  // UPLOAD DOCUMENT
  // ============================
  void sendFile(String name, String path) {
    messages.add({
      "role": "user",
      "type": "file",
      "fileName": name,
      "fileUrl": path,
    });
    notifyListeners();
  }

  // ============================
  // UPLOAD VIDEO WITH THUMBNAIL
  // ============================
  Future<void> sendVideo(String path) async {
    final thumb = await VideoThumbnail.thumbnailFile(
      video: path,
      imageFormat: ImageFormat.PNG,
      maxHeight: 300,
      quality: 85,
    );

    messages.add({
      "role": "user",
      "type": "video",
      "videoUrl": path,
      "thumbnail": thumb,
      "duration": "0:24",
    });
    notifyListeners();
  }
}
