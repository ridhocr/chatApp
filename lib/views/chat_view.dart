// ignore_for_file: use_build_context_synchronously

import 'package:chatapp_mst/models/chat.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../viewmodels/chat_viewmodel.dart';

class ChatView extends StatefulWidget {
  const ChatView({super.key});

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  final TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isMobile = constraints.maxWidth < 600;
        final bool isTablet =
            constraints.maxWidth >= 600 && constraints.maxWidth < 1024;
        final bool isDesktop = constraints.maxWidth >= 1024;

        return ChangeNotifierProvider<ChatViewModel>(
          create: (context) => ChatViewModel(context),
          child: Consumer<ChatViewModel>(
            builder: (context, viewModel, child) {
              final Chat activeChat = viewModel.selectedChat;

              Widget bodyContent;

              if (isMobile) {
                if (viewModel.isChatDetailVisibleOnMobile) {
                  bodyContent = _buildChatDetail(
                    viewModel,
                    activeChat,
                    isMobile,
                    isDesktop,
                  );
                } else {
                  bodyContent = _buildChatList(viewModel, isMobile, isTablet);
                }
              } else {
                bodyContent = Row(
                  children: [
                    _buildChatList(viewModel, isMobile, isTablet),
                    Expanded(
                      child: _buildChatDetail(
                        viewModel,
                        activeChat,
                        isMobile,
                        isDesktop,
                      ),
                    ),
                  ],
                );
              }

              return Scaffold(backgroundColor: Colors.white, body: bodyContent);
            },
          ),
        );
      },
    );
  }

  Widget _buildChatList(ChatViewModel viewModel, bool isMobile, bool isTablet) {
    return SafeArea(
      child: Container(
        width: isMobile ? double.infinity : (isTablet ? 270 : 350),
        decoration: BoxDecoration(
          border: Border(right: BorderSide(color: Colors.grey.shade300)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 50),
            const Text(
              "Helpdesk Chat",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Search",
                  filled: true,
                  fillColor: Colors.grey.shade200,
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: viewModel.chatList.length,
                itemBuilder: (context, index) {
                  final chat = viewModel.chatList[index];
                  final bool isSelected = index == viewModel.selectedChatIndex;

                  return ListTile(
                    onTap: () {
                      viewModel.selectChat(index);
                    },
                    tileColor: isSelected ? Colors.blue.shade50 : null,
                    leading: CircleAvatar(
                      backgroundImage: AssetImage(chat.profileAsset),
                    ),
                    title: Text(chat.name),
                    subtitle: Text(chat.lastMessage),
                    trailing: Text(
                      chat.statusOrTime,
                      style: TextStyle(
                        color: chat.isOpen ? Colors.green : Colors.grey,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatDetail(
    ChatViewModel viewModel,
    Chat activeChat,
    bool isMobile,
    bool isDesktop,
  ) {
    return SafeArea(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(left: 14, right: 14, bottom: 15),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
            ),
            child: Row(
              children: [
                if (isMobile)
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => viewModel.backToChatList(),
                  ),

                CircleAvatar(
                  radius: 22,
                  backgroundImage: AssetImage(activeChat.profileAsset),
                ),
                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        activeChat.name, 
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        "Helpdesk Chat",
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    "Open",
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: activeChat.messages.length,
              itemBuilder: (context, index) {
                final msg = activeChat.messages[index];
                // final bool isUser = msg["role"] == "user";

                final bool isUserMessage = (msg["role"] ?? 'model') == "user";

                return Align(
                  alignment: isUserMessage
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: isUserMessage
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: [
                      Container(
                        constraints: BoxConstraints(
                          maxWidth: isDesktop ? 500 : 350,
                        ),
                        padding: const EdgeInsets.all(14),
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: isUserMessage
                              ? Colors.blue
                              : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: buildMediaBubble(msg, isUserMessage, isDesktop),
                      ),
                      Text(
                        "9:36 AM", 
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                );
              },
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey.shade300)),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                      ),
                      builder: (ctx) {
                        return Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Select Model",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 20),

                              ListTile(
                                leading: const Icon(Icons.memory),
                                title: const Text("Groq (Llama3)"),
                                trailing: viewModel.selectedModel == "groq"
                                    ? const Icon(
                                        Icons.check,
                                        color: Colors.blue,
                                      )
                                    : null,
                                onTap: () {
                                  viewModel.changeModel("groq");
                                  Navigator.pop(ctx);
                                },
                              ),

                              ListTile(
                                leading: const Icon(Icons.auto_awesome),
                                title: const Text("Gemini (Flash/Pro)"),
                                trailing: viewModel.selectedModel == "gemini"
                                    ? const Icon(
                                        Icons.check,
                                        color: Colors.blue,
                                      )
                                    : null,
                                onTap: () {
                                  viewModel.changeModel("gemini");
                                  Navigator.pop(ctx);
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                  child: const Icon(Icons.add_circle_outline),
                ),

                const SizedBox(width: 10),

                GestureDetector(
                  child: const Icon(Icons.attach_file),
                  onTap: () => showUploadMenu(context, viewModel),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      hintText: "Message",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                GestureDetector(
                  child: const Icon(Icons.send),
                  onTap: () {
                    final text = controller.text.trim();
                    if (text.isNotEmpty) {
                      controller.clear();
                      viewModel.sendMessage(text);
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void showUploadMenu(BuildContext context, ChatViewModel vm) async {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return SizedBox(
          height: 180,
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.image),
                title: const Text("Upload Image"),
                onTap: () async {
                  final picker = ImagePicker();
                  final picked = await picker.pickImage(
                    source: ImageSource.gallery,
                  );
                  if (picked != null) vm.sendImage(picked.path);
                  Navigator.pop(ctx);
                },
              ),
              ListTile(
                leading: const Icon(Icons.video_library),
                title: const Text("Upload Video"),
                onTap: () async {
                  final picker = ImagePicker();
                  final picked = await picker.pickVideo(
                    source: ImageSource.gallery,
                  );
                  if (picked != null) await vm.sendVideo(picked.path);
                  Navigator.pop(ctx);
                },
              ),
              ListTile(
                leading: const Icon(Icons.insert_drive_file),
                title: const Text("Upload File"),
                onTap: () async {
                  final result = await FilePicker.platform.pickFiles();
                  if (result != null) {
                    vm.sendFile(
                      result.files.single.name,
                      result.files.single.path!,
                    );
                  }
                  Navigator.pop(ctx);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget buildMediaBubble(Map msg, bool isUser, bool isDesktop) {
    final String type = msg["type"] ?? "text";

    switch (type) {
      case "image":
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.asset(
            msg["fileUrl"] ?? "assets/placeholder.png",
            width: isDesktop ? 250 : 180,
            fit: BoxFit.cover,
          ),
        );

      case "video":
        return Container(
          width: isDesktop ? 280 : 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.black12,
          ),
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  msg["thumbnail"] ??
                      "assets/placeholder.png", 
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              const Positioned.fill(
                child: Center(
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Icon(Icons.play_arrow, color: Colors.black),
                  ),
                ),
              ),
              Positioned(
                bottom: 6,
                right: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    msg["duration"] ?? "0:00",
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ),
            ],
          ),
        );

      case "file":
        return Container(
          width: isDesktop ? 250 : 200,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            children: [
              const Icon(Icons.insert_drive_file, color: Colors.blue, size: 32),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  msg["fileName"] ?? "file.txt",
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        );

      default:
        return Text(
          msg["text"] ?? "",
          style: TextStyle(
            color: isUser ? Colors.white : Colors.black,
            fontSize: 15,
          ),
        );
    }
  }
}
