import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/request_provider.dart';
import '../models/service_request.dart';

class AdminRequestsScreen extends StatefulWidget {
  const AdminRequestsScreen({super.key});

  @override
  State<AdminRequestsScreen> createState() => _AdminRequestsScreenState();
}

class _AdminRequestsScreenState extends State<AdminRequestsScreen> {
  String _search = "";
  String _filterStatus = "all";

  @override
  Widget build(BuildContext context) {
    final reqProv = Provider.of<RequestProvider>(context, listen: false);
    final authEmail =
        Provider.of<RequestProvider>(context, listen: false); // not needed
    final auth = Provider.of<RequestProvider>(context, listen: false);

    List<ServiceRequest> list =
        Provider.of<RequestProvider>(context).allRequests;

    // Filter
    if (_filterStatus != "all") {
      list = list.where((r) => r.status == _filterStatus).toList();
    }

    // Search
    if (_search.isNotEmpty) {
      list = list
          .where((r) =>
              r.title.toLowerCase().contains(_search.toLowerCase()) ||
              r.description.toLowerCase().contains(_search.toLowerCase()))
          .toList();
    }

    // Sort latest first
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return Scaffold(
      appBar: AppBar(title: const Text("All Client Requests")),
      body: Column(
        children: [
          // SEARCH
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search requests…",
                prefixIcon: const Icon(Icons.search),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: (v) => setState(() => _search = v),
            ),
          ),

          // FILTER
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                const Text("Filter:  "),
                DropdownButton<String>(
                  value: _filterStatus,
                  items: const [
                    DropdownMenuItem(value: "all", child: Text("All")),
                    DropdownMenuItem(value: "pending", child: Text("Pending")),
                    DropdownMenuItem(
                        value: "in_progress", child: Text("In Progress")),
                    DropdownMenuItem(
                        value: "completed", child: Text("Completed")),
                  ],
                  onChanged: (v) => setState(() => _filterStatus = v!),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // LIST
          Expanded(
            child: list.isEmpty
                ? const Center(child: Text("No requests found"))
                : ListView.builder(
                    itemCount: list.length,
                    itemBuilder: (_, i) {
                      final r = list[i];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        child: ListTile(
                          title: Text(r.title,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(
                            r.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: PopupMenuButton<String>(
                            onSelected: (status) {
                              reqProv.updateStatus(
                                r.id,
                                status,
                                r.createdByEmail,
                                true,
                              );
                            },
                            itemBuilder: (_) => const [
                              PopupMenuItem(
                                  value: "pending", child: Text("Pending")),
                              PopupMenuItem(
                                  value: "in_progress",
                                  child: Text("In Progress")),
                              PopupMenuItem(
                                  value: "completed", child: Text("Completed")),
                            ],
                            child: Text(
                              r.status.replaceAll("_", " "),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
