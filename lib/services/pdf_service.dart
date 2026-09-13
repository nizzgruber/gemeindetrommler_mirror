import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/post_item.dart';

class PdfService {
  static Future<pw.ImageProvider?> _fetchImage(String url) async {
    if (url.isEmpty) return null;
    try {
      final response =
          await http.get(Uri.parse(url)).timeout(const Duration(seconds: 8));
      if (response.statusCode == 200) {
        final Uint8List bytes = response.bodyBytes;
        // Optionally resize image to save PDF memory
        final decoded = img.decodeImage(bytes);
        if (decoded != null) {
          final resized = img.copyResize(decoded, width: 300);
          final encoded = Uint8List.fromList(img.encodeJpg(resized, quality: 80));
          return pw.MemoryImage(encoded);
        }
        return pw.MemoryImage(bytes);
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to load image for PDF: $e');
      }
    }
    return null;
  }

  /// Print single post item as PDF
  static Future<void> printSinglePost(PostItem item) async {
    final pdf = pw.Document();
    final formattedDate = DateFormat('dd.MM.yyyy HH:mm').format(item.createdDate);
    final pw.ImageProvider? imageProvider = await _fetchImage(item.imageUrl);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'Marktgemeinde Oggau',
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blue800,
                  ),
                ),
                pw.Text(
                  formattedDate,
                  style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 12),
          pw.Text(
            item.title,
            style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
          ),
          if (item.street != null && item.street!.isNotEmpty) ...[
            pw.SizedBox(height: 6),
            pw.Text(
              'Örtlichkeit / Straße: ${item.street}',
              style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold),
            ),
          ],
          if (item.category != null && item.category!.isNotEmpty) ...[
            pw.SizedBox(height: 4),
            pw.Text(
              'Kategorie: ${item.category}',
              style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey800),
            ),
          ],
          pw.Divider(thickness: 1, color: PdfColors.grey400),
          pw.SizedBox(height: 10),
          if (imageProvider != null) ...[
            pw.Center(
              child: pw.Container(
                height: 220,
                child: pw.Image(imageProvider, fit: pw.BoxFit.contain),
              ),
            ),
            pw.SizedBox(height: 14),
          ],
          pw.Text(
            'Beschreibung:',
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 6),
          pw.Paragraph(
            text: item.description,
            style: const pw.TextStyle(fontSize: 12, lineSpacing: 1.5),
          ),
        ],
      ),
    );

    final cleanTitle = item.title.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: '$cleanTitle.pdf',
    );
  }

  /// Print a list of selected items in table format for Bauhof / Gemeinde
  static Future<void> printSelectedItemsTable({
    required List<PostItem> items,
    required String title,
  }) async {
    final pdf = pw.Document();

    // Preload all images in parallel
    final Map<String, pw.ImageProvider?> imageMap = {};
    await Future.wait(items.map((item) async {
      if (item.imageUrl.isNotEmpty) {
        imageMap[item.id] = await _fetchImage(item.imageUrl);
      }
    }));

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(24),
        header: (context) => pw.Container(
          alignment: pw.Alignment.centerLeft,
          margin: const pw.EdgeInsets.only(bottom: 12),
          padding: const pw.EdgeInsets.only(bottom: 6),
          decoration: const pw.BoxDecoration(
            border: pw.Border(bottom: pw.BorderSide(color: PdfColors.blue800, width: 2)),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'Oggauer Gemeindetrommler - $title',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blue800,
                ),
              ),
              pw.Text(
                'Erstellt am: ${DateFormat('dd.MM.yyyy HH:mm').format(DateTime.now())}',
                style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
              ),
            ],
          ),
        ),
        build: (context) => [
          pw.TableHelper.fromTextArray(
            border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
            cellHeight: 65,
            cellAlignments: {
              0: pw.Alignment.centerLeft,
              1: pw.Alignment.centerLeft,
              2: pw.Alignment.centerLeft,
              3: pw.Alignment.centerLeft,
              4: pw.Alignment.center,
            },
            headers: <String>['Datum', 'Örtlichkeit / Kat.', 'Titel & Mangel', 'Status', 'Foto'],
            data: items.map((item) {
              final formattedDate = DateFormat('dd.MM.yyyy').format(item.createdDate);
              final locInfo = '${item.street ?? "Keine Angabe"}\n(${item.category ?? "-"})';
              final descSnippet = item.description.length > 120
                  ? '${item.description.substring(0, 120)}...'
                  : item.description;

              return [
                formattedDate,
                locInfo,
                '${item.title}\n$descSnippet',
                item.status ?? 'Gemeldet',
                imageMap[item.id] != null ? 'Foto vorhanden' : '-',
              ];
            }).toList(),
          ),
        ],
      ),
    );

    final filename = '${title.toLowerCase().replaceAll(' ', '_')}_tabelle.pdf';
    await Printing.sharePdf(bytes: await pdf.save(), filename: filename);
  }
}
