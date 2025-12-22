import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/reminder_model.dart';

class ReminderProvider extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  bool _initialized = false;
  bool get initialized => _initialized;

  /// Cache
  final List<ReminderModel> _items = [];

  /// Constructor → live listener
  ReminderProvider() {
    _listen();
  }

  /// Ordered safe copy
  List<ReminderModel> get all {
    final list = List<ReminderModel>.from(_items);
    list.sort((a, b) => a.dueAt.compareTo(b.dueAt));
    return list;
  }

  /// ----------------------------------------------------------------------
  /// 🔥 LIVE FIRESTORE LISTENER → auto refresh UI
  /// ----------------------------------------------------------------------
  void _listen() {
    _db
        .collection("reminders")
        .orderBy("dueAt", descending: false)
        .snapshots()
        .listen((snapshot) {
      _items.clear();

      for (var doc in snapshot.docs) {
        final data = doc.data();

        _items.add(
          ReminderModel(
            id: doc.id,
            title: data["title"] ?? "",
            details: data["details"],
            done: data["done"] ?? false,
            createdByEmail: data["createdByEmail"] ?? "",
            clientEmail: data["clientEmail"],
            dueAt: (data["dueAt"] as Timestamp).toDate(),
          ),
        );
      }

      _initialized = true;
      notifyListeners();
    });
  }

  /// ----------------------------------------------------------------------
  /// FILTER HELPERS
  /// ----------------------------------------------------------------------
  List<ReminderModel> forClient(String email) {
    email = email.toLowerCase();
    return _items.where((r) {
      if (r.clientEmail == null) return true;
      return r.clientEmail!.toLowerCase() == email;
    }).toList();
  }

  List<ReminderModel> createdBy(String email) {
    final e = email.trim().toLowerCase();
    return all.where((r) => r.createdByEmail.toLowerCase() == e).toList();
  }

  List<ReminderModel> get pending => all.where((r) => !r.done).toList();
  List<ReminderModel> get completed => all.where((r) => r.done).toList();

  /// ----------------------------------------------------------------------
  /// ADD REMINDER
  /// ----------------------------------------------------------------------
  Future<void> addReminder({
    required String title,
    String? details,
    required DateTime dueAt,
    required String createdByEmail,
    String? clientEmail,
  }) async {
    await _db.collection("reminders").add({
      "title": title.trim(),
      "details": details?.trim(),
      "done": false,
      "createdByEmail": createdByEmail.trim(),
      "clientEmail": clientEmail?.trim(),
      "dueAt": Timestamp.fromDate(dueAt),
      "createdAt": FieldValue.serverTimestamp(),
    });
  }

  /// ----------------------------------------------------------------------
  /// TOGGLE DONE
  /// ----------------------------------------------------------------------
  Future<void> toggleDone(String id) async {
    final doc = _db.collection("reminders").doc(id);
    final snap = await doc.get();

    if (!snap.exists) return;

    final current = snap.data()!["done"] ?? false;

    await doc.update({
      "done": !current,
    });
  }

  /// ----------------------------------------------------------------------
  /// DELETE REMINDER
  /// ----------------------------------------------------------------------
  Future<void> deleteReminder(String id) async {
    await _db.collection("reminders").doc(id).delete();
  }
}
