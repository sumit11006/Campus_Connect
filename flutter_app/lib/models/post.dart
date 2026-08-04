class Post {
  final String id;
  final String authorId;
  final String authorName;
  final String authorEmail;
  final String authorAvatar;
  final String authorRole;
  final String authorBranch;
  final String content;
  final String imageUrl;
  final int likesCount;
  final int commentsCount;
  final bool isLiked;
  final DateTime? createdAt;

  Post({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.authorEmail,
    this.authorAvatar = '',
    this.authorRole = 'student',
    this.authorBranch = '',
    required this.content,
    this.imageUrl = '',
    this.likesCount = 0,
    this.commentsCount = 0,
    this.isLiked = false,
    this.createdAt,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    String aId = '';
    String aName = 'User';
    String aEmail = '';
    String aAvatar = '';
    String aRole = 'student';
    String aBranch = '';

    if (json['authorId'] is Map) {
      final aMap = json['authorId'] as Map<String, dynamic>;
      aId = aMap['_id'] ?? '';
      aName = aMap['name'] ?? 'User';
      aEmail = aMap['email'] ?? '';
      aAvatar = aMap['avatarUrl'] ?? '';
      aRole = aMap['role'] ?? 'student';
      aBranch = aMap['branch'] ?? '';
    } else if (json['authorId'] is String) {
      aId = json['authorId'];
    }

    return Post(
      id: json['_id'] ?? json['id'] ?? '',
      authorId: aId,
      authorName: aName,
      authorEmail: aEmail,
      authorAvatar: aAvatar,
      authorRole: aRole,
      authorBranch: aBranch,
      content: json['content'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      likesCount: json['likesCount'] ?? 0,
      commentsCount: json['commentsCount'] ?? 0,
      isLiked: json['isLiked'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
    );
  }

  Post copyWith({
    int? likesCount,
    int? commentsCount,
    bool? isLiked,
  }) {
    return Post(
      id: id,
      authorId: authorId,
      authorName: authorName,
      authorEmail: authorEmail,
      authorAvatar: authorAvatar,
      authorRole: authorRole,
      authorBranch: authorBranch,
      content: content,
      imageUrl: imageUrl,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      isLiked: isLiked ?? this.isLiked,
      createdAt: createdAt,
    );
  }
}
