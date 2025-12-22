import 'dart:convert';

class IpoItem {
  final String id;
  final String name;
  final String symbol;
  final DateTime openDate;
  final DateTime closeDate;
  final String priceBand; // e.g. "₹100-₹120"
  final int lotSize;

  IpoItem({
    required this.id,
    required this.name,
    required this.symbol,
    required this.openDate,
    required this.closeDate,
    required this.priceBand,
    required this.lotSize,
  });

  String getStatus() {
    final now = DateTime.now();
    if (now.isBefore(openDate)) return 'UPCOMING';
    if (now.isAfter(closeDate)) return 'CLOSED';
    return 'OPEN';
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'symbol': symbol,
      'openDate': openDate.toIso8601String(),
      'closeDate': closeDate.toIso8601String(),
      'priceBand': priceBand,
      'lotSize': lotSize,
    };
  }

  factory IpoItem.fromMap(Map<String, dynamic> map) {
    return IpoItem(
      id: map['id'],
      name: map['name'],
      symbol: map['symbol'],
      openDate: DateTime.parse(map['openDate']),
      closeDate: DateTime.parse(map['closeDate']),
      priceBand: map['priceBand'],
      lotSize: map['lotSize'],
    );
  }

  String toJson() => json.encode(toMap());

  factory IpoItem.fromJson(String source) =>
      IpoItem.fromMap(json.decode(source));
}
