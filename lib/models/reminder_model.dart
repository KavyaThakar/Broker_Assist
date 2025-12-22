import 'package:cloud_firestore/cloud_firestore.dart';

class ReminderModel {
  final String id;
  final String title;
  final String? details;
  final DateTime dueAt;
  final bool done;

  /// Who created the reminder
  final String createdByEmail;

  /// Optional client email
  final String? clientEmail;

  /// Optional created timestamp
  final DateTime? createdAt;

  ReminderModel({
    required this.id,
    required this.title,
    this.details,
    required this.dueAt,
    required this.done,
    required this.createdByEmail,
    this.clientEmail,
    this.createdAt,
  });

  ReminderModel copyWith({
    String? id,
    String? title,
    String? details,
    DateTime? dueAt,
    bool? done,
    String? createdByEmail,
    String? clientEmail,
    DateTime? createdAt,
  }) {
    return ReminderModel(
      id: id ?? this.id,
      title: title ?? this.title,
      details: details ?? this.details,
      dueAt: dueAt ?? this.dueAt,
      done: done ?? this.done,
      createdByEmail: createdByEmail ?? this.createdByEmail,
      clientEmail: clientEmail ?? this.clientEmail,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// ---------- Convert TO firestore map ----------
  Map<String, dynamic> toMap() {
    return {
      "title": title,
      "details": details,
      "dueAt": Timestamp.fromDate(dueAt),
      "done": done,
      "createdByEmail": createdByEmail,
      "clientEmail": clientEmail,
      "createdAt": createdAt ?? DateTime.now(),
    };
  }

  /// ---------- Create object FROM firestore snapshot ----------
  factory ReminderModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final map = doc.data()!;

    return ReminderModel(
      id: doc.id,
      title: map["title"] ?? "",
      details: map["details"],
      dueAt: (map["dueAt"] as Timestamp).toDate(),
      done: map["done"] ?? false,
      createdByEmail: map["createdByEmail"] ?? "",
      clientEmail: map["clientEmail"],
      createdAt: map["createdAt"] != null
          ? (map["createdAt"] as Timestamp).toDate()
          : null,
    );
  }

  /// old style support
  factory ReminderModel.fromMap(String id, Map<String, dynamic> map) {
    return ReminderModel(
      id: id,
      title: map["title"] ?? "",
      details: map["details"],
      dueAt: (map["dueAt"] as Timestamp).toDate(),
      done: map["done"] ?? false,
      createdByEmail: map["createdByEmail"] ?? "",
      clientEmail: map["clientEmail"],
      createdAt: map["createdAt"] != null
          ? (map["createdAt"] as Timestamp).toDate()
          : null,
    );
  }
}
