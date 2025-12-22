import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:pdf/widgets.dart' as pw;
import 'package:permission_handler/permission_handler.dart';

import '../providers/auth_provider.dart';
import '../providers/report_provider.dart';
import '../models/report_model.dart';

class ClientReportsScreen extends StatefulWidget {
  const ClientReportsScreen({super.key});

  @override
  State<ClientReportsScreen> createState() => _ClientReportsScreenState();
}

class _ClientReportsScreenState extends State<ClientReportsScreen> {
  bool _initDone = false;
  String _email = "";

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initDone) return;
    _initDone = true;

    final auth = Provider.of<AuthProvider>(context, listen: false);
    _email = auth.currentUser?.email ?? "";

    final reportProv = Provider.of<ReportProvider>(context, listen: false);

    Future.microtask(() async {
      await reportProv.load();
      if (mounted) setState(() {});
    });
  }

  Future<String> savePdfPublic(String fileName, Uint8List bytes) async {
    // Request both permissions
    await Permission.storage.request();
    await Permission.manageExternalStorage.request();

    if (!(await Permission.storage.isGranted ||
        await Permission.manageExternalStorage.isGranted)) {
      throw "Storage permission denied";
    }

    final path = "/storage/emulated/0/Download";

    final dir = Directory(path);

    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    final file = File("$path/$fileName.pdf");

    await file.writeAsBytes(bytes);

    return file.path;
  }

  // ============================================================
  // GENERATE PDF
  // ============================================================
  Future<void> _generatePDF(ReportModel r) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context ctx) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text("BrokerAssist Report",
                  style: pw.TextStyle(
                      fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 20),
              pw.Text("Title: ${r.title}", style: pw.TextStyle(fontSize: 18)),
              pw.Text("Type: ${r.type}", style: pw.TextStyle(fontSize: 16)),
              pw.Text("Client: ${r.clientEmail}",
                  style: pw.TextStyle(fontSize: 16)),
              pw.Text("Date: ${r.date.toLocal()}",
                  style: pw.TextStyle(fontSize: 14)),
              pw.SizedBox(height: 20),
              pw.Text(
                r.description.trim().isEmpty
                    ? "No Description Provided."
                    : r.description,
                style: pw.TextStyle(fontSize: 14),
              ),
            ],
          );
        },
      ),
    );

    final bytes = await pdf.save();
    final savedPath = await savePdfPublic(r.title, bytes);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("PDF saved → $savedPath")),
    );
  }

  @override
  Widget build(BuildContext context) {
    final reportProv = Provider.of<ReportProvider>(context);

    final List<ReportModel> myReports =
        _email.isEmpty ? [] : reportProv.reportsForClient(_email);

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Reports"),
      ),
      body: myReports.isEmpty
          ? const Center(
              child: Text(
                "No reports shared with you yet.",
                style: TextStyle(fontSize: 16),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: myReports.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (_, i) {
                final r = myReports[i];

                final dateStr =
                    "${r.date.day.toString().padLeft(2, '0')}/${r.date.month.toString().padLeft(2, '0')}/${r.date.year}";

                return ListTile(
                  leading: const Icon(Icons.picture_as_pdf,
                      color: Colors.deepPurple),
                  title: Text(r.title),
                  subtitle: Text("${r.type} • $dateStr"),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: Text(r.title),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Type: ${r.type}"),
                            const SizedBox(height: 6),
                            Text("Date: $dateStr"),
                            const SizedBox(height: 10),
                            Text(
                              r.description.trim().isEmpty
                                  ? "No extra description."
                                  : r.description,
                            ),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("Close"),
                          ),
                          TextButton(
                            onPressed: () async {
                              Navigator.pop(context);
                              await _generatePDF(r);
                            },
                            child: const Text("Download PDF"),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
