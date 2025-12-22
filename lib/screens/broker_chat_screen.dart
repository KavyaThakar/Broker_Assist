import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/chat_provider.dart';
import '../providers/auth_provider.dart';
import '../models/chat_message.dart';

class BrokerChatScreen extends StatefulWidget {
  final String clientEmail;

  const BrokerChatScreen({super.key, required this.clientEmail});

  @override
  State<BrokerChatScreen> createState() => _BrokerChatScreenState();
}

class _BrokerChatScreenState extends State<BrokerChatScreen> {
  final TextEditingController _msgCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();

  String _brokerEmail = "";

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final auth = Provider.of<AuthProvider>(context, listen: false);

    // update email every build
    _brokerEmail = auth.currentUser?.email ?? "";
  }

  void _scroll() {
    Future.delayed(const Duration(milliseconds: 250), () {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.jumpTo(_scrollCtrl.position.maxScrollExtent);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final chatProv = Provider.of<ChatProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text("Chat with ${widget.clientEmail}"),
      ),
      body: StreamBuilder<List<ChatMessage>>(
        stream: chatProv.watchMessages(widget.clientEmail),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final messages = snap.data!;

          WidgetsBinding.instance.addPostFrameCallback((_) => _scroll());

          return Column(
            children: [
              Expanded(
                child: messages.isEmpty
                    ? const Center(child: Text("No messages yet"))
                    : ListView.builder(
                        controller: _scrollCtrl,
                        padding: const EdgeInsets.all(12),
                        itemCount: messages.length,
                        itemBuilder: (_, i) {
                          final m = messages[i];
                          final isMe = m.sender == _brokerEmail;

                          final timeString = m.timestamp == null
                              ? ""
                              : "${m.timestamp!.hour}:${m.timestamp!.minute.toString().padLeft(2, '0')}";

                          return Align(
                            alignment: isMe
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              decoration: BoxDecoration(
                                color:
                                    isMe ? Colors.blue[200] : Colors.grey[300],
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(m.text),
                                  const SizedBox(height: 4),
                                  Text(
                                    timeString,
                                    style: const TextStyle(
                                        fontSize: 10, color: Colors.black54),
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),

              // Text Input
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _msgCtrl,
                        decoration: const InputDecoration(
                          hintText: "Message...",
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: () async {
                        final text = _msgCtrl.text.trim();
                        if (text.isEmpty) return;

                        await chatProv.sendMessage(
                          clientEmail: widget.clientEmail,
                          senderEmail: _brokerEmail,
                          text: text,
                        );

                        _msgCtrl.clear();
                        _scroll();
                      },
                    )
                  ],
                ),
              )
            ],
          );
        },
      ),
    );
  }
}
