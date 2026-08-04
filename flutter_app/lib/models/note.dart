class NoteItem {
  final String id;
  final String title;
  final String subject;
  final String fileUrl;
  final String description;
  final String uploaderName;
  final int downloadsCount;
  final DateTime? createdAt;

  NoteItem({
    required this.id,
    required this.title,
    required this.subject,
    required this.fileUrl,
    this.description = '',
    this.uploaderName = 'Student',
    this.downloadsCount = 0,
    this.createdAt,
  });

  factory NoteItem.fromJson(Map<String, dynamic> json) {
    String uName = 'Student';
    if (json['uploaderId'] is Map) {
      uName = json['uploaderId']['name'] ?? 'Student';
    }

    return NoteItem(
      id: json['_id'] ?? json['id'] ?? '',
      title: json['title'] ?? '',
      subject: json['subject'] ?? '',
      fileUrl: json['fileUrl'] ?? '',
      description: json['description'] ?? '',
      uploaderName: uName,
      downloadsCount: json['downloadsCount'] ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
    );
  }
}
