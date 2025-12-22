import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/chat_message.dart';

class ChatProvider extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Local cache: { clientEmailLower : List<ChatMessage> }
  final Map<String, List<ChatMessage>> _threads = {};

  String _key(String email) => email.trim().toLowerCase();

  /// -------------------------------------------------------------------
  /// GET messages (live listener)
  /// -------------------------------------------------------------------
  Stream<List<ChatMessage>> watchMessages(String clientEmail) {
    final uid = _key(clientEmail);

    return _db
        .collection("chats")
        .doc(uid)
        .collection("messages")
        .orderBy("timestamp", descending: false)
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs.map((doc) {
        final data = doc.data();
        return ChatMessage(
          id: doc.id,
          sender: data["sender"],
          text: data["text"],
          timestamp: (data["timestamp"] as Timestamp).toDate(),
        );
      }).toList();

      _threads[uid] = list;
      notifyListeners();
      return list;
    });
  }

  /// -------------------------------------------------------------------
  /// LOAD once (optional for inbox preview)
  /// -------------------------------------------------------------------
  Future<List<ChatMessage>> loadHistory(String clientEmail) async {
    final uid = _key(clientEmail);

    final snap = await _db
        .collection("chats")
        .doc(uid)
        .collection("messages")
        .orderBy("timestamp", descending: false)
        .get();

    final list = snap.docs.map((doc) {
      final d = doc.data();

      return ChatMessage(
        id: doc.id,
        sender: d["sender"],
        text: d["text"],
        timestamp: (d["timestamp"] as Timestamp).toDate(),
      );
    }).toList();

    _threads[uid] = list;
    notifyListeners();
    return list;
  }

  /// -------------------------------------------------------------------
  /// SEND MESSAGE
  /// -------------------------------------------------------------------
  Future<void> sendMessage({
    required String clientEmail,
    required String senderEmail,
    required String text,
  }) async {
    final uid = _key(clientEmail);

    await _db.collection("chats").doc(uid).collection("messages").add({
      "sender": senderEmail,
      "text": text,
      "timestamp": FieldValue.serverTimestamp(),
    });
  }

  /// -------------------------------------------------------------------
  /// Get chat list from local cache
  /// -------------------------------------------------------------------
  List<ChatMessage> getChatForClient(String clientEmail) {
    return _threads[_key(clientEmail)] ?? [];
  }

  /// -------------------------------------------------------------------
  /// Clear cache (on sign-out)
  /// -------------------------------------------------------------------
  void reset() {
    _threads.clear();
    notifyListeners();
  }
}
