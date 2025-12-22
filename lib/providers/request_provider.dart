import 'package:flutter/material.dart';
import '../models/service_request.dart';
import '../services/request_service.dart';

class RequestProvider extends ChangeNotifier {
  final RequestService _service = RequestService();

  bool _loaded = false;
  bool get loaded => _loaded;

  List<ServiceRequest> _myRequests = [];
  List<ServiceRequest> _allRequests = [];

  List<ServiceRequest> get myRequests => _myRequests;
  List<ServiceRequest> get allRequests => _allRequests;

  // Load all requests from SharedPreferences
  Future<void> load(String currentUserEmail, bool isBroker) async {
    await _service.loadRequests();

    _myRequests = _service.getRequestsForUser(currentUserEmail);

    if (isBroker) {
      _allRequests = _service.getAllRequests();
    }

    _loaded = true;
    notifyListeners();
  }

  // Create new request
  Future<void> createRequest(
      ServiceRequest r, String email, bool isBroker) async {
    await _service.createRequest(r);
    await load(email, isBroker);
  }

  // Broker updates request status
  Future<void> updateStatus(
      String id, String status, String email, bool isBroker) async {
    await _service.updateStatus(id, status);
    await load(email, isBroker);
  }

  void clear() {
    _loaded = false;
    _myRequests = [];
    _allRequests = [];
    notifyListeners();
  }
}
