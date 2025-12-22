import 'dart:convert';

class ServiceRequest {
  final String id;
  final String title;
  final String description;
  final String status; // pending, in_progress, completed
  final String createdByEmail;
  final DateTime createdAt;

  ServiceRequest({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.createdByEmail,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'status': status,
      'createdByEmail': createdByEmail,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ServiceRequest.fromMap(Map<String, dynamic> map) {
    return ServiceRequest(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      status: map['status'],
      createdByEmail: map['createdByEmail'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  String toJson() => json.encode(toMap());

  factory ServiceRequest.fromJson(String source) =>
      ServiceRequest.fromMap(json.decode(source));
}
