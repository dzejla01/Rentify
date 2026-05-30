class NotificationItem {
  final int id;
  final int userId;
  final String title;
  final String message;
  final String? type;
  final String? referenceType;
  final int? referenceId;
  final bool isRead;
  final DateTime createdAt;
  final DateTime? readAt;

  NotificationItem({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    this.type,
    this.referenceType,
    this.referenceId,
    required this.isRead,
    required this.createdAt,
    this.readAt,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: (json['id'] as num).toInt(),
      userId: (json['userId'] as num).toInt(),
      title: json['title']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      type: json['type']?.toString(),
      referenceType: json['referenceType']?.toString(),
      referenceId: json['referenceId'] == null
          ? null
          : (json['referenceId'] as num).toInt(),
      isRead: json['isRead'] == true,
      createdAt: DateTime.parse(json['createdAt'].toString()),
      readAt: json['readAt'] == null
          ? null
          : DateTime.parse(json['readAt'].toString()),
    );
  }
}
