import 'dart:developer';

import 'package:chatapp_mst/models/chat.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import '../models/ai_response.dart';
import '../services/api/ai_service.dart';

class ChatViewModel extends ChangeNotifier {
  final AiService aiService = AiService();

  bool isLoading = false;
  String selectedModel = "gemini";

  bool? isMobile;
  bool? isTablet;
  bool? isDesktop;

  bool _isChatDetailVisibleOnMobile = false;
  bool get isChatDetailVisibleOnMobile => _isChatDetailVisibleOnMobile;

  final List<Chat> _originalChatList = [
    Chat(
      name: "Cameron Williamson",
      profileAsset: "assets/profile1.png",
      lastMessage: "Can’t log in",
      statusOrTime: "Open",
      timeMessage: "10:24 AM",
      isOpen: true,
      messages: [
        {
          "role": "user",
          "type": "text",
          "text": "Hi, I can't log in to my account.",
        },
        {
          "role": "model",
          "type": "text",
          "text": "I see. Can you provide your account ID?",
        },
      ],
    ),
    Chat(
      name: "Kristin Watson",
      profileAsset: "assets/profile2.png",
      lastMessage: "Error message",
      statusOrTime: "Tue",
      timeMessage: "Yesterday",
      messages: [
        {
          "role": "model",
          "type": "text",
          "text": "Hello Kristin. What is the error message you are seeing?",
        },
        {
          "role": "user",
          "type": "text",
          "text": "It says 'Permission Denied' every time I open the app.",
        },
      ],
    ),
    Chat(
      name: "Kathryn Murphy",
      profileAsset: "assets/profile3.png",
      lastMessage: "Payment issue",
      statusOrTime: "Mon",
      timeMessage: "2 days ago",
      messages: [
        {
          "role": "user",
          "type": "text",
          "text": "My recent payment failed, but I was charged.",
        },
      ],
    ),
    Chat(
      name: "Ralph Edwards",
      profileAsset: "assets/profile4.png",
      lastMessage: "Account issue",
      statusOrTime: "Mon",
      timeMessage: "2 days ago",
      messages: [
        {
          "role": "model",
          "type": "text",
          "text": "Good morning Ralph. What is the issue with your account?",
        },
      ],
    ),
  ];

  String _searchQuery = "";
  String get searchQuery => _searchQuery;

  List<Chat> get chatList {
    if (_searchQuery.isEmpty) {
      return _originalChatList;
    }
    return _originalChatList.where((chat) {
      final query = _searchQuery.toLowerCase();
      return chat.name.toLowerCase().contains(query) ||
          chat.lastMessage.toLowerCase().contains(query);
    }).toList();
  }

  int _selectedChatIndex = 0;

  int get selectedChatIndex => _selectedChatIndex;
  Chat get selectedChat => _originalChatList[_selectedChatIndex];

  ChatViewModel(BuildContext context);

  void changeModel(String model) {
    selectedModel = model;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    if (chatList.isNotEmpty) {
      final firstFilteredChat = chatList.first;
      final originalIndex = _originalChatList.indexWhere(
        (chat) => chat == firstFilteredChat,
      );
      if (originalIndex != -1) {
        _selectedChatIndex = originalIndex;
      }
    } else {
      _selectedChatIndex = 0;
    }
    notifyListeners();
  }

  void selectChat(int index) {
    final selectedChatInFilteredList = chatList[index];
    final originalIndex = _originalChatList.indexWhere(
      (chat) => chat == selectedChatInFilteredList,
    );

    if (originalIndex != -1 && _selectedChatIndex != originalIndex) {
      _selectedChatIndex = originalIndex;
    }
    _isChatDetailVisibleOnMobile = true;
    notifyListeners();
  }

  void backToChatList() {
    _isChatDetailVisibleOnMobile = false;
    notifyListeners();
  }

  List<Map<String, dynamic>> get _currentChatMessages => selectedChat.messages;

  Future<void> sendMessage(String text) async {
    const groqKey = "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";
    const geminiKey = "AIzaSyAZGo5j_IzMkrx9H96fpsy2_W5XB515Yko";

    _currentChatMessages.add({"role": "user", "type": "text", "text": text});

    _originalChatList[_selectedChatIndex] = selectedChat.copyWith(
      lastMessage: text,
      timeMessage: DateTime.now().toString().substring(11, 16),
    );

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

      _currentChatMessages.add({
        "role": "model",
        "type": "text",
        "text": response.text,
      });
      _originalChatList[_selectedChatIndex] = selectedChat.copyWith(
        lastMessage: response.text,
      );
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

  void sendImage(String path) {
    const message = "Sent an image";
    _currentChatMessages.add({
      "role": "user",
      "type": "image",
      "fileUrl": path,
    });
    _originalChatList[_selectedChatIndex] = selectedChat.copyWith(
      lastMessage: message,
    );
    notifyListeners();
  }

  void sendFile(String name, String path) {
    const message = "Sent a file";
    _currentChatMessages.add({
      "role": "user",
      "type": "file",
      "fileName": name,
      "fileUrl": path,
    });
    _originalChatList[_selectedChatIndex] = selectedChat.copyWith(
      lastMessage: message,
    );
    notifyListeners();
  }

  Future<void> sendVideo(String path) async {
    String? thumb;

    if (kIsWeb) {
      thumb = "assets/placeholder.png";
    } else {
      try {
        thumb = await VideoThumbnail.thumbnailFile(
          video: path,
          imageFormat: ImageFormat.PNG,
          maxHeight: 300,
          quality: 85,
        );
      } catch (e) {
        log("Error creating video thumbnail: $e");
        thumb = "assets/placeholder.png";
      }
    }

    const message = "Sent a video";

    _currentChatMessages.add({
      "role": "user",
      "type": "video",
      "videoUrl": path,
      "thumbnail": thumb,
      "duration": "0:24",
    });
    _originalChatList[_selectedChatIndex] = selectedChat.copyWith(
      lastMessage: message,
    );
    notifyListeners();
  }
}
