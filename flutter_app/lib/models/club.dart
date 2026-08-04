class Club {
  final String id;
  final String name;
  final String description;
  final String category;
  final String bannerUrl;
  final String coordinatorId;
  final String? coordinatorName;
  final int memberCount;
  final DateTime? createdAt;

  Club({
    required this.id,
    required this.name,
    required this.description,
    this.category = 'General',
    this.bannerUrl = '',
    required this.coordinatorId,
    this.coordinatorName,
    this.memberCount = 1,
    this.createdAt,
  });

  factory Club.fromJson(Map<String, dynamic> json) {
    String coordId = '';
    String? coordName;

    if (json['coordinatorId'] is Map) {
      coordId = json['coordinatorId']['_id'] ?? '';
      coordName = json['coordinatorId']['name'];
    } else if (json['coordinatorId'] is String) {
      coordId = json['coordinatorId'];
    }

    return Club(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? 'General',
      bannerUrl: json['bannerUrl'] ?? '',
      coordinatorId: coordId,
      coordinatorName: coordName,
      memberCount: json['memberCount'] ?? 1,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'description': description,
      'category': category,
      'bannerUrl': bannerUrl,
      'coordinatorId': coordinatorId,
      'memberCount': memberCount,
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}

class ClubMemberItem {
  final String id;
  final String clubId;
  final String userId;
  final String userName;
  final String userEmail;
  final String userAvatar;
  final String role;
  final DateTime? joinedAt;

  ClubMemberItem({
    required this.id,
    required this.clubId,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.userAvatar,
    required this.role,
    this.joinedAt,
  });

  factory ClubMemberItem.fromJson(Map<String, dynamic> json) {
    String uName = '';
    String uEmail = '';
    String uAvatar = '';
    String uId = '';

    if (json['userId'] is Map) {
      uId = json['userId']['_id'] ?? '';
      uName = json['userId']['name'] ?? '';
      uEmail = json['userId']['email'] ?? '';
      uAvatar = json['userId']['avatarUrl'] ?? '';
    } else {
      uId = json['userId'] ?? '';
    }

    return ClubMemberItem(
      id: json['_id'] ?? '',
      clubId: json['clubId'] ?? '',
      userId: uId,
      userName: uName,
      userEmail: uEmail,
      userAvatar: uAvatar,
      role: json['role'] ?? 'member',
      joinedAt: json['joinedAt'] != null
          ? DateTime.tryParse(json['joinedAt'])
          : null,
    );
  }
}
