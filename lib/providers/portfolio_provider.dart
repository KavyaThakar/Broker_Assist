import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/portfolio_model.dart';

class PortfolioProvider extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// caching portfolio data mapped by email
  final Map<String, List<PortfolioModel>> _cache = {};

  /// keeps track of loading state per email
  final Map<String, bool> _loadingMap = {};

  /// check if a user is currently loading
  bool isLoading(String email) {
    return _loadingMap[email.toLowerCase()] ?? false;
  }

  /// return cached list
  List<PortfolioModel> getList(String email) {
    return _cache[email.toLowerCase()] ?? [];
  }

  /// LOAD ONE USER PORTFOLIO
  Future<void> load(String email) async {
    final key = email.toLowerCase();

    /// already loading → avoid double fetch
    if (isLoading(key)) return;

    _loadingMap[key] = true;
    notifyListeners();

    try {
      final snap = await _db
          .collection("portfolio")
          .doc(key)
          .collection("entries")
          .orderBy("lastUpdated", descending: true)
          .get();

      if (snap.docs.isEmpty) {
        _cache[key] = [];
      } else {
        _cache[key] = snap.docs.map((doc) {
          final data = doc.data();

          return PortfolioModel(
            clientEmail: key,
            invested: (data["invested"] as num).toDouble(),
            currentValue: (data["currentValue"] as num).toDouble(),
            lastUpdated: (data["lastUpdated"] as Timestamp).toDate(),
          );
        }).toList();
      }
    } catch (e) {
      debugPrint("Portfolio load error → $e");
      _cache[key] = []; // prevent null bug
    }

    _loadingMap[key] = false;
    notifyListeners();
  }

  /// ADD ENTRY → auto refresh
  Future<void> addEntry({
    required String email,
    required double invested,
    required double currentValue,
  }) async {
    final key = email.toLowerCase();

    try {
      await _db.collection("portfolio").doc(key).collection("entries").add({
        "invested": invested,
        "currentValue": currentValue,
        "lastUpdated": DateTime.now(),
      });

      await load(key); // ← reload new values
    } catch (e) {
      debugPrint("Portfolio Add Error : $e");
    }
  }
}
