import 'dart:convert';

class PortfolioModel {
  final String clientEmail;
  final double invested;
  final double currentValue;
  final DateTime lastUpdated;

  PortfolioModel({
    required this.clientEmail,
    required this.invested,
    required this.currentValue,
    required this.lastUpdated,
  });

  double get profitLoss => currentValue - invested;

  double get profitLossPercent =>
      invested == 0 ? 0 : ((currentValue - invested) / invested) * 100;

  Map<String, dynamic> toMap() {
    return {
      'clientEmail': clientEmail,
      'invested': invested,
      'currentValue': currentValue,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  factory PortfolioModel.fromMap(Map<String, dynamic> map) {
    return PortfolioModel(
      clientEmail: map['clientEmail'],
      invested: map['invested'],
      currentValue: map['currentValue'],
      lastUpdated: DateTime.parse(map['lastUpdated']),
    );
  }

  String toJson() => jsonEncode(toMap());

  factory PortfolioModel.fromJson(String source) =>
      PortfolioModel.fromMap(jsonDecode(source));
}
