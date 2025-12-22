import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/request_provider.dart';
import '../models/service_request.dart';

class MyRequestsScreen extends StatefulWidget {
  const MyRequestsScreen({super.key});

  @override
  State<MyRequestsScreen> createState() => _MyRequestsScreenState();
}

class _MyRequestsScreenState extends State<MyRequestsScreen> {
  String _search = "";
  String _filterStatus = "all";

  @override
  Widget build(BuildContext context) {
    final reqProv = Provider.of<RequestProvider>(context);
    List<ServiceRequest> list = reqProv.myRequests;

    // 1. APPLY FILTERS
    if (_filterStatus != "all") {
      list = list.where((r) => r.status == _filterStatus).toList();
    }

    // 2. APPLY SEARCH
    if (_search.isNotEmpty) {
      list = list
          .where((r) =>
              r.title.toLowerCase().contains(_search.toLowerCase()) ||
              r.description.toLowerCase().contains(_search.toLowerCase()))
          .toList();
    }

    // 3. SORT BY DATE (LATEST FIRST)
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return Scaffold(
      appBar: AppBar(title: const Text("My Requests")),
      body: Column(
        children: [
          // 🔍 SEARCH BAR
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

          // 🔧 FILTER DROPDOWN
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

          // 🧾 LIST
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
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          title: Text(r.title,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(
                            r.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: Text(
                            r.status.replaceAll("_", " "),
                            style: TextStyle(
                              color: r.status == "completed"
                                  ? Colors.green
                                  : r.status == "in_progress"
                                      ? Colors.orange
                                      : Colors.blue,
                              fontWeight: FontWeight.bold,
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
