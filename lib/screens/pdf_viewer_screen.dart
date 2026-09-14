import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:url_launcher/url_launcher.dart';

class PdfViewerScreen extends StatelessWidget {
  final String title;
  final String pdfUrl;

  const PdfViewerScreen({
    super.key,
    required this.title,
    required this.pdfUrl,
  });

  Future<void> _openExternal() async {
    final uri = Uri.parse(pdfUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final safeTitle = title.replaceAll(RegExp(r'[\\/:*?<>|]'), '_');

 return Scaffold(
 appBar: AppBar(
 title: Text(title, overflow: TextOverflow.ellipsis),
 actions: [
 IconButton(
 icon: const Icon(Icons.open_in_browser),
 tooltip: 'Im Browser öffnen',
 onPressed: _openExternal,
 ),
 ],
 ),
 body: PdfPreview(
        build: (PdfPageFormat format) async {
          final response = await http
              .get(Uri.parse(pdfUrl))
              .timeout(const Duration(seconds: 15));
          if (response.statusCode == 200) {
            return response.bodyBytes;
          }
          throw Exception('Fehler beim Abrufen der Datei (${response.statusCode})');
        },
        canChangeOrientation: false,
        canChangePageFormat: false,
        canDebug: false,
        maxPageWidth: 700,
        pdfFileName: '$safeTitle.pdf',
 loadingWidget: const Center(
 child: Column(
 mainAxisSize: MainAxisSize.min,
 children: [
 CircularProgressIndicator(),
 SizedBox(height: 16),
 Text('Aussendung wird geladen...'),
 ],
 ),
 ),
 onError: (context, error) => Center(
 child: Padding(
 padding: const EdgeInsets.all(24.0),
 child: Column(
 mainAxisSize: MainAxisSize.min,
 children: [
 const Icon(Icons.error_outline, color: Colors.red, size: 48),
 const SizedBox(height: 12),
                Text(
                  'Fehler beim Laden des Dokuments: $error',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
 const SizedBox(height: 16),
 ElevatedButton.icon(
 onPressed: _openExternal,
 icon: const Icon(Icons.open_in_browser),
 label: const Text('Direkt im Browser öffnen'),
 ),
 ],
 ),
 ),
 ),
 ),
 );
 }
}
