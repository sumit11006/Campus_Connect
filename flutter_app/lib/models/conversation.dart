import 'user.dart';

class ConversationItem {
  final String id;
  final List<User> participants;
  final bool isGroup;
  final String groupName;
  final String? clubId;
  final String lastMessage;
  final DateTime? lastMessageAt;

  ConversationItem({
    required this.id,
    required this.participants,
    this.isGroup = false,
    this.groupName = '',
    this.clubId,
    this.lastMessage = '',
    this.lastMessageAt,
  });

  factory ConversationItem.fromJson(Map<String, dynamic> json) {
    final rawParticipants = json['participantIds'] as List? ?? [];
    final participants = rawParticipants
        .whereType<Map<String, dynamic>>()
        .map((j) => User.fromJson(j))
        .toList();

    return ConversationItem(
      id: json['_id'] ?? json['id'] ?? '',
      participants: participants,
      isGroup: json['isGroup'] ?? false,
      groupName: json['groupName'] ?? '',
      clubId: json['clubId'] is Map
          ? json['clubId']['_id']
          : json['clubId'],
      lastMessage: json['lastMessage'] ?? '',
      lastMessageAt: json['lastMessageAt'] != null
          ? DateTime.tryParse(json['lastMessageAt'])
          : null,
    );
  }

  String getDisplayTitle(String currentUserId) {
    if (isGroup && groupName.isNotEmpty) return groupName;
    final other = participants.firstWhere(
      (p) => p.id != currentUserId,
      orElse: () => User(id: '', name: 'Chat', email: '', role: 'student'),
    );
    return other.name.isNotEmpty ? other.name : 'User';
  }

  String getDisplayAvatar(String currentUserId) {
    if (isGroup) return '';
    final other = participants.firstWhere(
      (p) => p.id != currentUserId,
      orElse: () => User(id: '', name: 'Chat', email: '', role: 'student'),
    );
    return other.avatarUrl;
  }
}
