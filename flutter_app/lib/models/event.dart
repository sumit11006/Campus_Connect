class CampusEvent {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final String location;
  final String? clubId;
  final String? clubName;
  final String createdBy;
  final String? creatorName;
  final String imageUrl;
  final int? capacity;
  final int registrationCount;
  final DateTime? createdAt;
  final bool isPinned;
  final String priority;

  CampusEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.location,
    this.clubId,
    this.clubName,
    required this.createdBy,
    this.creatorName,
    this.imageUrl = '',
    this.capacity,
    this.registrationCount = 0,
    this.createdAt,
    this.isPinned = false,
    this.priority = 'normal',
  });

  factory CampusEvent.fromJson(Map<String, dynamic> json) {
    String cId = '';
    String? cName;
    String creatorId = '';
    String? creatorName;

    if (json['clubId'] is Map) {
      cId = json['clubId']['_id'] ?? '';
      cName = json['clubId']['name'];
    } else if (json['clubId'] is String) {
      cId = json['clubId'];
    }

    if (json['createdBy'] is Map) {
      creatorId = json['createdBy']['_id'] ?? '';
      creatorName = json['createdBy']['name'];
    } else if (json['createdBy'] is String) {
      creatorId = json['createdBy'];
    }

    return CampusEvent(
      id: json['_id'] ?? json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
      location: json['location'] ?? '',
      clubId: cId.isNotEmpty ? cId : null,
      clubName: cName,
      createdBy: creatorId,
      creatorName: creatorName,
      imageUrl: json['imageUrl'] ?? '',
      capacity: json['capacity'],
      registrationCount: json['registrationCount'] ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
      isPinned: json['isPinned'] ?? false,
      priority: json['priority'] ?? 'normal',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
      'location': location,
      'clubId': clubId,
      'createdBy': createdBy,
      'imageUrl': imageUrl,
      'capacity': capacity,
      'registrationCount': registrationCount,
    };
  }
}
