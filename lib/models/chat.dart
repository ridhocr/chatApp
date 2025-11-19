// Buat List<Map> mutable agar bisa di-add pesan baru
class Chat {
  final String name;
  final String profileAsset;
  final String lastMessage;
  final String statusOrTime;
  final bool isOpen;
  // Ganti dari final List<Map<String, dynamic>> menjadi List<Map<String, dynamic>>
  final List<Map<String, dynamic>> messages; 

  Chat({
    required this.name,
    required this.profileAsset,
    required this.lastMessage,
    required this.statusOrTime,
    this.isOpen = false,
    required this.messages,
  });

  // Tambahkan method untuk meng-update lastMessage (Opsional tapi direkomendasikan)
  Chat copyWith({String? lastMessage}) {
    return Chat(
      name: name,
      profileAsset: profileAsset,
      lastMessage: lastMessage ?? this.lastMessage,
      statusOrTime: statusOrTime,
      isOpen: isOpen,
      messages: messages,
    );
  }
}