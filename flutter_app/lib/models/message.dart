class ChatMessage {
  final String id;
  final String conversationId;
  final String senderId;
  final String senderName;
  final String senderAvatar;
  final String content;
  final DateTime? createdAt;

  ChatMessage({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.senderName,
    this.senderAvatar = '',
    required this.content,
    this.createdAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    String sId = '';
    String sName = 'User';
    String sAvatar = '';

    if (json['senderId'] is Map) {
      final sMap = json['senderId'] as Map<String, dynamic>;
      sId = sMap['_id'] ?? '';
      sName = sMap['name'] ?? 'User';
      sAvatar = sMap['avatarUrl'] ?? '';
    } else if (json['senderId'] is String) {
      sId = json['senderId'];
    }

    return ChatMessage(
      id: json['_id'] ?? json['id'] ?? '',
      conversationId: json['conversationId'] ?? '',
      senderId: sId,
      senderName: sName,
      senderAvatar: sAvatar,
      content: json['content'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
    );
  }
}
