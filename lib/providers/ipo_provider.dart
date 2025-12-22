import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/ipo_item.dart';

class IpoProvider extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  bool _loaded = false;
  bool get loaded => _loaded;

  final List<IpoItem> _items = [];

  IpoProvider() {
    load();
  }

  List<IpoItem> get allIpos {
    if (!_loaded) return [];
    final list = List<IpoItem>.from(_items);
    list.sort((a, b) => a.openDate.compareTo(b.openDate));
    return list;
  }

  Future<void> load() async {
    try {
      _loaded = false;
      notifyListeners();

      final snap = await _db
          .collection("ipos")
          .orderBy("openDate", descending: false)
          .get();

      _items.clear();

      for (var doc in snap.docs) {
        final d = doc.data();

        _items.add(
          IpoItem(
            id: doc.id,
            name: d["name"] ?? "",
            symbol: d["symbol"] ?? "",
            openDate: (d["openDate"] as Timestamp).toDate(),
            closeDate: (d["closeDate"] as Timestamp).toDate(),
            priceBand: d["priceBand"] ?? "",
            lotSize: d["lotSize"] ?? 0,
          ),
        );
      }

      _loaded = true;
      notifyListeners();
    } catch (e) {
      debugPrint("IPO Load Error: $e");
      _loaded = true;
      notifyListeners();
    }
  }

  Future<void> addIpo(IpoItem ipo) async {
    try {
      await _db.collection("ipos").doc(ipo.id).set({
        "name": ipo.name,
        "symbol": ipo.symbol,
        "openDate": Timestamp.fromDate(ipo.openDate),
        "closeDate": Timestamp.fromDate(ipo.closeDate),
        "priceBand": ipo.priceBand,
        "lotSize": ipo.lotSize,
        "createdAt": FieldValue.serverTimestamp(),
      });

      await load();
    } catch (e) {
      debugPrint("IPO Add Error: $e");
    }
  }
}
