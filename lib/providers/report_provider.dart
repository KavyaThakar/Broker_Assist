// lib/providers/report_provider.dart
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../models/report_model.dart';

class ReportProvider extends ChangeNotifier {
  static const _storageKey = 'brokerassist_reports';

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  final List<ReportModel> _reports = [];
  final Uuid _uuid = const Uuid();

  bool _loaded = false;
  bool get loaded => _loaded;

  List<ReportModel> get allReports => List.unmodifiable(_reports);

  List<ReportModel> reportsForClient(String email) {
    final lower = email.trim().toLowerCase();
    return _reports
        .where((r) => r.clientEmail.trim().toLowerCase() == lower)
        .toList();
  }

  // ----------------------------------------------------------
  // LOAD DATA
  // ----------------------------------------------------------
  Future<void> load() async {
    if (_loaded) return;

    // Load from Local
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_storageKey) ?? [];

    _reports
      ..clear()
      ..addAll(list.map((s) => ReportModel.fromJson(s)));

    // Load from Firebase
    final snap = await _db.collection("reports").get();
    for (var d in snap.docs) {
      _reports.add(ReportModel.fromMap(d.data()));
    }

    _loaded = true;
    notifyListeners();
  }

  // ----------------------------------------------------------
  // SAVE TO DEVICE
  // ----------------------------------------------------------
  Future<void> _saveLocal() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _storageKey,
      _reports.map((r) => r.toJson()).toList(),
    );
  }

  // ----------------------------------------------------------
  // ADD REPORT
  // ----------------------------------------------------------
  Future<void> addReport({
    required String clientEmail,
    required String title,
    required String type,
    required DateTime date,
    String description = '',
  }) async {
    final report = ReportModel(
      id: _uuid.v4(),
      clientEmail: clientEmail,
      title: title,
      type: type,
      date: date,
      description: description,
    );

    _reports.add(report);

    // store in local
    await _saveLocal();

    // store in Firebase
    await _db.collection("reports").doc(report.id).set(report.toMap());

    notifyListeners();
  }

  // ----------------------------------------------------------
  // DELETE REPORT
  // ----------------------------------------------------------
  Future<void> deleteReport(String id) async {
    _reports.removeWhere((r) => r.id == id);
    await _saveLocal();
    await _db.collection("reports").doc(id).delete();
    notifyListeners();
  }

  // ----------------------------------------------------------
  // RESET
  // ----------------------------------------------------------
  void clearAll() {
    _reports.clear();
    _loaded = false;
    notifyListeners();
  }
}
