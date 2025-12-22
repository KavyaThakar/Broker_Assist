import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/corporate_action_item.dart';

class CorporateActionProvider extends ChangeNotifier {
  static const _actionsKey = 'brokerassist_corporate_actions';

  List<CorporateActionItem> _actions = [];
  bool _loaded = false;

  bool get loaded => _loaded;

  List<CorporateActionItem> get allActions {
    final list = List<CorporateActionItem>.from(_actions);
    list.sort((a, b) => a.recordDate.compareTo(b.recordDate));
    return list;
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_actionsKey) ?? [];
    _actions = list.map((s) => CorporateActionItem.fromJson(s)).toList();
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final list = _actions.map((a) => a.toJson()).toList();
    await prefs.setStringList(_actionsKey, list);
  }

  Future<void> load() async {
    await _loadFromPrefs();
    _loaded = true;
    notifyListeners();
  }

  Future<void> addAction(CorporateActionItem item) async {
    await _loadFromPrefs();
    _actions.add(item);
    await _saveToPrefs();
    _loaded = true;
    notifyListeners();
  }

  Future<void> deleteAction(String id) async {
    await _loadFromPrefs();
    _actions.removeWhere((a) => a.id == id);
    await _saveToPrefs();
    notifyListeners();
  }

  void reset() {
    _loaded = false;
    _actions = [];
    notifyListeners();
  }
}
