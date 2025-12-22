import 'dart:convert';

class ReportModel {
  final String id;
  final String clientEmail;
  final String title;
  final String type;
  final DateTime date;
  final String description;

  ReportModel({
    required this.id,
    required this.clientEmail,
    required this.title,
    required this.type,
    required this.date,
    required this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'clientEmail': clientEmail,
      'title': title,
      'type': type,
      'date': date.toIso8601String(),
      'description': description,
    };
  }

  factory ReportModel.fromMap(Map<String, dynamic> map) {
    return ReportModel(
      id: map['id'],
      clientEmail: map['clientEmail'],
      title: map['title'],
      type: map['type'],
      date: DateTime.parse(map['date']),
      description: map['description'] ?? '',
    );
  }

  String toJson() => jsonEncode(toMap());

  factory ReportModel.fromJson(String source) =>
      ReportModel.fromMap(jsonDecode(source));
}
