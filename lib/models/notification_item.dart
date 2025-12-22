import 'dart:convert';

class NotificationItem {
  final String id;
  final String forEmail;
  final String title;
  final String body;
  final DateTime createdAt;
  final bool read;

  NotificationItem({
    required this.id,
    required this.forEmail,
    required this.title,
    required this.body,
    required this.createdAt,
    required this.read,
  });

  NotificationItem copyWith({bool? read}) {
    return NotificationItem(
      id: id,
      forEmail: forEmail,
      title: title,
      body: body,
      createdAt: createdAt,
      read: read ?? this.read,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'forEmail': forEmail,
      'title': title,
      'body': body,
      'createdAt': createdAt.toIso8601String(),
      'read': read,
    };
  }

  factory NotificationItem.fromMap(Map<String, dynamic> map) {
    return NotificationItem(
      id: map['id'],
      forEmail: map['forEmail'],
      title: map['title'],
      body: map['body'],
      createdAt: DateTime.parse(map['createdAt']),
      read: map['read'] ?? false,
    );
  }

  String toJson() => json.encode(toMap());

  factory NotificationItem.fromJson(String source) =>
      NotificationItem.fromMap(json.decode(source));
}
