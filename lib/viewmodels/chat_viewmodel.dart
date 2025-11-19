import 'package:chatapp_mst/models/chat.dart';
import 'package:flutter/material.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import '../models/ai_response.dart';
import '../services/api/ai_service.dart';

class ChatViewModel extends ChangeNotifier {
  final AiService aiService = AiService();

  // HILANGKAN List<Map<String, dynamic>> messages = [];
  bool isLoading = false;
  String selectedModel = "gemini"; 
  
  // State untuk kontrol tampilan di Mobile
  bool _isChatDetailVisibleOnMobile = false; 
  bool get isChatDetailVisibleOnMobile => _isChatDetailVisibleOnMobile;

  // Data List Chat
  final List<Chat> _chatList = [
    Chat(
      name: "Cameron Williamson",
      profileAsset: "assets/profile1.png",
      lastMessage: "Can’t log in",
      statusOrTime: "Open",
      isOpen: true,
      messages: [
        {"role": "user", "type": "text", "text": "Hi, I can't log in to my account."},
        {"role": "model", "type": "text", "text": "I see. Can you provide your account ID?"},
      ],
    ),
    Chat(
      name: "Kristin Watson",
      profileAsset: "assets/profile2.png",
      lastMessage: "Error message",
      statusOrTime: "Tue",
      messages: [
        {"role": "model", "type": "text", "text": "Hello Kristin. What is the error message you are seeing?"},
        {"role": "user", "type": "text", "text": "It says 'Permission Denied' every time I open the app."},
      ],
    ),
    Chat(
      name: "Kathryn Murphy",
      profileAsset: "assets/profile3.png",
      lastMessage: "Payment issue",
      statusOrTime: "Mon",
      messages: [
        {"role": "user", "type": "text", "text": "My recent payment failed, but I was charged."},
      ],
    ),
    Chat(
      name: "Ralph Edwards",
      profileAsset: "assets/profile4.png",
      lastMessage: "Account issue",
      statusOrTime: "Mon",
      messages: [
        {"role": "model", "type": "text", "text": "Good morning Ralph. What is the issue with your account?"},
      ],
    ),
  ];

  List<Chat> get chatList => _chatList;
  int _selectedChatIndex = 0;

  int get selectedChatIndex => _selectedChatIndex;
  Chat get selectedChat => _chatList[_selectedChatIndex];
  
  ChatViewModel(BuildContext context);

  void changeModel(String model) {
    selectedModel = model;
    notifyListeners();
  }

  void selectChat(int index) {
    if (_selectedChatIndex != index) {
      _selectedChatIndex = index;
    }
    // Tambahkan logika navigasi mobile
    _isChatDetailVisibleOnMobile = true;
    notifyListeners();
  }
  
  void backToChatList() {
    _isChatDetailVisibleOnMobile = false;
    notifyListeners();
  }
  
  // Dapatkan pesan dari chat yang sedang aktif untuk diproses AI
  List<Map<String, dynamic>> get _currentChatMessages => selectedChat.messages;

  // 1. FIX: Method untuk mengirim pesan Teks
  Future<void> sendMessage(String text) async {
    const groqKey = "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";
    const geminiKey = "AIzaSyAZGo5j_IzMkrx9H96fpsy2_W5XB515Yko";
    
    // Tambahkan pesan pengguna ke chat yang aktif
    _currentChatMessages.add({"role": "user", "type": "text", "text": text});
    // Update lastMessage di objek Chat
    _chatList[_selectedChatIndex] = selectedChat.copyWith(lastMessage: text);

    notifyListeners();

    isLoading = true;
    notifyListeners();

    try {
      final AiResponse response;
      
      // Kirim pesan, mungkin perlu riwayat pesan (tidak diimplementasi di sini)
      if (selectedModel == "groq") {
        response = await aiService.getGroqResponse(text, groqKey);
      } else {
        response = await aiService.getGeminiResponse(text, geminiKey);
      }

      // Tambahkan balasan AI ke chat yang aktif
      _currentChatMessages.add({
        "role": "model",
        "type": "text",
        "text": response.text,
      });
      // Update lastMessage dengan balasan AI
      _chatList[_selectedChatIndex] = selectedChat.copyWith(lastMessage: response.text);

    } catch (e) {
      _currentChatMessages.add({
        "role": "model",
        "type": "text",
        "text": "Error: $e",
      });
    }

    isLoading = false;
    notifyListeners();
  }
  
  // 2. FIX: Method untuk mengirim Gambar
  void sendImage(String path) {
    const message = "Sent an image";
    _currentChatMessages.add({
      "role": "user",
      "type": "image",
      "fileUrl": path,
    });
    _chatList[_selectedChatIndex] = selectedChat.copyWith(lastMessage: message);
    notifyListeners();
    // Di aplikasi nyata, Anda mungkin ingin memanggil AI setelah ini
  }

  // 3. FIX: Method untuk mengirim File
  void sendFile(String name, String path) {
    const message = "Sent a file";
    _currentChatMessages.add({
      "role": "user",
      "type": "file",
      "fileName": name,
      "fileUrl": path,
    });
    _chatList[_selectedChatIndex] = selectedChat.copyWith(lastMessage: message);
    notifyListeners();
  }

  // 4. FIX: Method untuk mengirim Video
  Future<void> sendVideo(String path) async {
    final thumb = await VideoThumbnail.thumbnailFile(
      video: path,
      imageFormat: ImageFormat.PNG,
      maxHeight: 300,
      quality: 85,
    );
    const message = "Sent a video";
    
    _currentChatMessages.add({
      "role": "user",
      "type": "video",
      "videoUrl": path,
      "thumbnail": thumb,
      "duration": "0:24",
    });
    _chatList[_selectedChatIndex] = selectedChat.copyWith(lastMessage: message);
    notifyListeners();
  }
}