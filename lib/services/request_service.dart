import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import '../models/service_request.dart';

class RequestService {
  static const _reqKey = 'brokerassist_requests';

  List<ServiceRequest> _requests = [];

  // Load on app start
  Future<void> loadRequests() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_reqKey) ?? [];

    _requests = list.map((e) => ServiceRequest.fromJson(e)).toList();
  }

  Future<void> _saveRequests() async {
    final prefs = await SharedPreferences.getInstance();
    final list = _requests.map((e) => e.toJson()).toList();
    await prefs.setStringList(_reqKey, list);
  }

  // Create new service request
  Future<void> createRequest(ServiceRequest r) async {
    _requests.add(r);
    await _saveRequests();
  }

  // For clients: get their own requests
  List<ServiceRequest> getRequestsForUser(String email) {
    return _requests
        .where((r) => r.createdByEmail.toLowerCase() == email.toLowerCase())
        .toList();
  }

  // For brokers: get all requests
  List<ServiceRequest> getAllRequests() {
    return List.from(_requests.reversed); // newest first
  }

  // Broker updates status
  Future<void> updateStatus(String id, String newStatus) async {
    final index = _requests.indexWhere((r) => r.id == id);
    if (index != -1) {
      final old = _requests[index];
      _requests[index] = ServiceRequest(
        id: old.id,
        title: old.title,
        description: old.description,
        status: newStatus,
        createdByEmail: old.createdByEmail,
        createdAt: old.createdAt,
      );
      await _saveRequests();
    }
  }
}
