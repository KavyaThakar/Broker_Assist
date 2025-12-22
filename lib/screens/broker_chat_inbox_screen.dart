import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/chat_provider.dart';
import '../models/chat_message.dart';
import '../models/user_model.dart';

import 'broker_chat_screen.dart';

class BrokerChatInboxScreen extends StatefulWidget {
  const BrokerChatInboxScreen({super.key});

  @override
  State<BrokerChatInboxScreen> createState() => _BrokerChatInboxScreenState();
}

class _BrokerChatInboxScreenState extends State<BrokerChatInboxScreen> {
  bool _loading = true;
  final Map<String, List<ChatMessage>> _localCache = {};

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await _loadAll();
    });
  }

  Future<void> _loadAll() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final chatProv = Provider.of<ChatProvider>(context, listen: false);

    // load all users first
    final allUsers = auth.getAllUsers();

    // filter clients
    final List<UserModel> clients =
        allUsers.where((u) => u.role.toLowerCase() == "client").toList();

    // ALWAYS SHOW ALL CLIENTS, EVEN IF EMPTY CHAT
    for (var c in clients) {
      final msgs = await chatProv.loadHistory(c.email);

      // save even if empty to avoid invisibility
      _localCache[c.email] = msgs;
    }

    if (!mounted) return;
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final allUsers = auth.getAllUsers();

    final clients =
        allUsers.where((u) => u.role.toLowerCase() == "client").toList();

    // ensure display order based on last timestamp
    clients.sort((a, b) {
      final A = _localCache[a.email];
      final B = _localCache[b.email];

      if (A == null || A.isEmpty) return 1;
      if (B == null || B.isEmpty) return -1;

      return B.last.timestamp.compareTo(A.last.timestamp);
    });

    return Scaffold(
      appBar: AppBar(title: const Text("Client Chats")),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : clients.isEmpty
              ? const Center(
                  child: Text(
                    "No clients available",
                    style: TextStyle(fontSize: 16),
                  ),
                )
              : ListView.builder(
                  itemCount: clients.length,
                  itemBuilder: (_, i) {
                    final c = clients[i];
                    final msgs = _localCache[c.email] ?? [];
                    final last = msgs.isEmpty ? "Start chat" : msgs.last.text;

                    return ListTile(
                      title: Text(c.name),
                      subtitle: Text(
                        last,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: const Icon(Icons.chat),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BrokerChatScreen(
                              clientEmail: c.email,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
    );
  }
}
