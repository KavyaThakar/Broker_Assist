import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/chat_provider.dart';
import '../providers/auth_provider.dart';
import '../models/chat_message.dart';

class ClientChatScreen extends StatefulWidget {
  const ClientChatScreen({super.key});

  @override
  State<ClientChatScreen> createState() => _ClientChatScreenState();
}

class _ClientChatScreenState extends State<ClientChatScreen> {
  final TextEditingController _msgCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();

  String _clientEmail = "";

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    /// keeps email synced always
    final auth = Provider.of<AuthProvider>(context, listen: false);
    _clientEmail = auth.currentUser?.email ?? "";
  }

  void _scrollBottom() {
    Future.delayed(const Duration(milliseconds: 250), () {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.jumpTo(_scrollCtrl.position.maxScrollExtent);
      }
    });
  }

  @override
  void dispose() {
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chatProv = Provider.of<ChatProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: const Text("Chat with Broker")),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<ChatMessage>>(
              stream: chatProv.watchMessages(_clientEmail),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data!;
                _scrollBottom();

                if (messages.isEmpty) {
                  return const Center(
                    child: Text("Say hi to your broker 👋"),
                  );
                }

                return ListView.builder(
                  controller: _scrollCtrl,
                  padding: const EdgeInsets.all(12),
                  itemCount: messages.length,
                  itemBuilder: (_, i) {
                    final m = messages[i];
                    final isMe = m.sender == _clientEmail;

                    final timeString = m.timestamp == null
                        ? ""
                        : "${m.timestamp!.hour}:${m.timestamp!.minute.toString().padLeft(2, '0')}";

                    return Align(
                      alignment:
                          isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 12),
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        decoration: BoxDecoration(
                          color: isMe ? Colors.green[300] : Colors.grey[300],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(m.text),
                            const SizedBox(height: 3),
                            Text(
                              timeString,
                              style: const TextStyle(
                                  fontSize: 10, color: Colors.black54),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // message box
          Container(
            color: Colors.grey[200],
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _msgCtrl,
                    decoration: const InputDecoration(
                      hintText: "Type message...",
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.green),
                  onPressed: () async {
                    final txt = _msgCtrl.text.trim();
                    if (txt.isEmpty) return;

                    await chatProv.sendMessage(
                      clientEmail: _clientEmail,
                      senderEmail: _clientEmail,
                      text: txt,
                    );

                    _msgCtrl.clear();
                    _scrollBottom();
                  },
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
