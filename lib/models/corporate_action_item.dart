import 'dart:convert';

class CorporateActionItem {
  final String id;
  final String companyName;
  final String symbol;
  final String type; // Dividend, Bonus, Split, Rights
  final DateTime recordDate;
  final DateTime exDate;
  final String details;

  CorporateActionItem({
    required this.id,
    required this.companyName,
    required this.symbol,
    required this.type,
    required this.recordDate,
    required this.exDate,
    required this.details,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'companyName': companyName,
      'symbol': symbol,
      'type': type,
      'recordDate': recordDate.toIso8601String(),
      'exDate': exDate.toIso8601String(),
      'details': details,
    };
  }

  factory CorporateActionItem.fromMap(Map<String, dynamic> map) {
    return CorporateActionItem(
      id: map['id'],
      companyName: map['companyName'],
      symbol: map['symbol'],
      type: map['type'],
      recordDate: DateTime.parse(map['recordDate']),
      exDate: DateTime.parse(map['exDate']),
      details: map['details'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory CorporateActionItem.fromJson(String source) =>
      CorporateActionItem.fromMap(json.decode(source));
}
