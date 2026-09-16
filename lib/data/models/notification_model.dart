enum NotificationType { trip, alert, message }

class NotificationModel {
  final String id;
  final String title;
  final String body;
  final DateTime timestamp;
  final NotificationType type;
  final String? referenceType;
  final int? referenceId;
  bool isRead;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.timestamp,
    required this.type,
    this.referenceType,
    this.referenceId,
    this.isRead = false,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    NotificationType nType = NotificationType.message;
    if (json['type'] == 'trip' || json['action_type'] == 'trip_assigned') {
      nType = NotificationType.trip;
    }
    if (json['type'] == 'alert') nType = NotificationType.alert;

    var rawId = json['reference_id'] ?? json['data']?['trip_id'];
    int? parsedId;
    if (rawId != null) {
      parsedId = rawId is int ? rawId : int.tryParse(rawId.toString());
    }

    return NotificationModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? json['data']?['title'] ?? 'بدون عنوان',
      body: json['body'] ?? json['data']?['body'] ?? '',
      timestamp: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      isRead: json['read_at'] != null,
      type: nType,
      referenceType: json['reference_type']?.toString(),
      referenceId: parsedId,
    );
  }
}
