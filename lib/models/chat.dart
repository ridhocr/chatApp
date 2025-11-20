class Chat {
  final String name;
  final String profileAsset;
  final String lastMessage;
  final String statusOrTime;
  final String timeMessage;
  final bool isOpen;
  final List<Map<String, dynamic>> messages; 

  Chat({
    required this.name,
    required this.profileAsset,
    required this.lastMessage,
    required this.statusOrTime,
    required this.timeMessage,
    this.isOpen = false,
    required this.messages,
  });

  Chat copyWith({String? lastMessage, String? timeMessage}) {
    return Chat(
      name: name,
      profileAsset: profileAsset,
      lastMessage: lastMessage ?? this.lastMessage,
      statusOrTime: statusOrTime,
      timeMessage: timeMessage ?? this.timeMessage,
      isOpen: isOpen,
      messages: messages,
    );
  }
}