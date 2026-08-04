class CommentItem {
  final String id;
  final String postId;
  final String authorId;
  final String authorName;
  final String authorAvatar;
  final String text;
  final DateTime? createdAt;

  CommentItem({
    required this.id,
    required this.postId,
    required this.authorId,
    required this.authorName,
    this.authorAvatar = '',
    required this.text,
    this.createdAt,
  });

  factory CommentItem.fromJson(Map<String, dynamic> json) {
    String aId = '';
    String aName = 'User';
    String aAvatar = '';

    if (json['authorId'] is Map) {
      final aMap = json['authorId'] as Map<String, dynamic>;
      aId = aMap['_id'] ?? '';
      aName = aMap['name'] ?? 'User';
      aAvatar = aMap['avatarUrl'] ?? '';
    } else if (json['authorId'] is String) {
      aId = json['authorId'];
    }

    return CommentItem(
      id: json['_id'] ?? '',
      postId: json['postId'] ?? '',
      authorId: aId,
      authorName: aName,
      authorAvatar: aAvatar,
      text: json['text'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
    );
  }
}
