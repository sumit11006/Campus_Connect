class LostFoundItem {
  final String id;
  final String type; // 'lost' or 'found'
  final String itemName;
  final String description;
  final String location;
  final String imageUrl;
  final String reporterName;
  final bool isResolved;
  final DateTime? createdAt;

  LostFoundItem({
    required this.id,
    required this.type,
    required this.itemName,
    required this.description,
    required this.location,
    this.imageUrl = '',
    this.reporterName = 'Student',
    this.isResolved = false,
    this.createdAt,
  });

  factory LostFoundItem.fromJson(Map<String, dynamic> json) {
    String rName = 'Student';
    if (json['reporterId'] is Map) {
      rName = json['reporterId']['name'] ?? 'Student';
    }

    return LostFoundItem(
      id: json['_id'] ?? json['id'] ?? '',
      type: json['type'] ?? 'lost',
      itemName: json['itemName'] ?? '',
      description: json['description'] ?? '',
      location: json['location'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      reporterName: rName,
      isResolved: json['isResolved'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
    );
  }
}
