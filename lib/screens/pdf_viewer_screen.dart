import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:url_launcher/url_launcher.dart';

class PdfViewerScreen extends StatefulWidget {
  final String title;
  final String pdfUrl;

  const PdfViewerScreen({
    super.key,
    required this.title,
    required this.pdfUrl,
  });

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  final TransformationController _transformationController =
      TransformationController();
  double _zoomLevel = 1.0;
  Uint8List? _cachedBytes;

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  void _zoomIn() {
    setState(() {
      _zoomLevel = (_zoomLevel * 1.3).clamp(0.8, 5.0);
      _transformationController.value = Matrix4.diagonal3Values(_zoomLevel, _zoomLevel, _zoomLevel);
    });
  }

  void _zoomOut() {
    setState(() {
      _zoomLevel = (_zoomLevel / 1.3).clamp(0.8, 5.0);
      _transformationController.value = Matrix4.diagonal3Values(_zoomLevel, _zoomLevel, _zoomLevel);
    });
  }

  void _resetZoom() {
    setState(() {
      _zoomLevel = 1.0;
      _transformationController.value = Matrix4.identity();
    });
  }

  Future<void> _openExternal() async {
    final uri = Uri.parse(widget.pdfUrl);
    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Browser konnte nicht geöffnet werden: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _sharePdf() async {
    if (_cachedBytes != null) {
      final safeTitle =
          widget.title.replaceAll(RegExp(r'[\\/:*?<>|]'), '_');
      await Printing.sharePdf(
        bytes: _cachedBytes!,
        filename: '$safeTitle.pdf',
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PDF wird noch geladen...')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final safeTitle =
        widget.title.replaceAll(RegExp(r'[\\/:*?<>|]'), '_');

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title, overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'PDF teilen / drucken',
            onPressed: _sharePdf,
          ),
          IconButton(
            icon: const Icon(Icons.open_in_browser),
            tooltip: 'Im Browser öffnen',
            onPressed: _openExternal,
          ),
        ],
      ),
      body: Stack(
        children: [
          PdfPreview.builder(
            build: (PdfPageFormat format) async {
              if (_cachedBytes != null) return _cachedBytes!;
              final response = await http
                  .get(Uri.parse(widget.pdfUrl))
                  .timeout(const Duration(seconds: 15));
              if (response.statusCode == 200) {
                _cachedBytes = response.bodyBytes;
                return response.bodyBytes;
              }
              throw Exception(
                  'Fehler beim Abrufen der Datei (${response.statusCode})');
            },
            canChangeOrientation: false,
            canChangePageFormat: false,
            canDebug: false,
            allowPrinting: false,
            allowSharing: false,
            useActions: false,
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
            pagesBuilder: (context, pages) {
              return InteractiveViewer(
                transformationController: _transformationController,
                minScale: 0.8,
                maxScale: 5.0,
                panEnabled: true,
                scaleEnabled: true,
                onInteractionEnd: (details) {
                  final scale =
                      _transformationController.value.getMaxScaleOnAxis();
                  if (scale != _zoomLevel) {
                    setState(() {
                      _zoomLevel = scale;
                    });
                  }
                },
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8.0, vertical: 16.0),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (int i = 0; i < pages.length; i++) ...[
                          Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.15),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Image(
                              image: pages[i].image,
                              fit: BoxFit.contain,
                            ),
                          ),
                          if (pages.length > 1)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: Text(
                                'Seite ${i + 1} von ${pages.length}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          // Floating Zoom Controls Overlay
          Positioned(
            right: 16,
            bottom: 24,
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24)),
              color: Colors.white.withValues(alpha: 0.92),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.zoom_in, color: Colors.black87),
                      tooltip: 'Vergrößern (+)',
                      onPressed: _zoomIn,
                    ),
                    InkWell(
                      onTap: _resetZoom,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 4, horizontal: 6),
                        child: Text(
                          '${(_zoomLevel * 100).round()}%',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.zoom_out, color: Colors.black87),
                      tooltip: 'Verkleinern (-)',
                      onPressed: _zoomOut,
                    ),
                    IconButton(
                      icon: const Icon(Icons.restart_alt, size: 20, color: Colors.grey),
                      tooltip: 'Zoom zurücksetzen (1:1)',
                      onPressed: _resetZoom,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
