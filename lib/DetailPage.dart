import 'dart:typed_data';
import 'package:pdf/widgets.dart' as pdfWidgets;
import 'package:printing/printing.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';

class DetailPage extends StatelessWidget {
  final String title;
  final String datum;
  final String description;
  final String imageUrl;

  const DetailPage({
    Key? key,
    required this.title,
    required this.datum,
    required this.description,
    required this.imageUrl,
  }) : super(key: key);


  Future<void> _printPdf() async {
    final pdf = pdfWidgets.Document();
    final image = await _loadNetworkImage(imageUrl);

    pdf.addPage(
      pdfWidgets.MultiPage(
        build: (context) => [
          pdfWidgets.Center(
            child: pdfWidgets.SizedBox(
              width: double.infinity, // Die Breite auf die maximal mögliche Breite setzen
              child: pdfWidgets.AspectRatio(
                aspectRatio: 1, // Sie können das Seitenverhältnis entsprechend Ihrem Bild anpassen
                child: pdfWidgets.Image(image),
              ),
            ),
          ),
          pdfWidgets.Text(
              title,
              style: pdfWidgets.TextStyle(
                  fontSize: 20,
                  fontWeight: pdfWidgets.FontWeight.bold // Titel fett
              )
          ),
          pdfWidgets.Text(datum, style: const pdfWidgets.TextStyle(fontSize: 14, )),
          pdfWidgets.Paragraph(text: description, style: const pdfWidgets.TextStyle(fontSize: 12)),
        ],
      ),
    );
    await Printing.sharePdf(bytes: await pdf.save(), filename: '$title.pdf');
  }

  Future<pdfWidgets.ImageProvider> _loadNetworkImage(String url) async {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode != 200) {
      throw Exception('Failed to load network image.');
    }

    final Uint8List bytes = response.bodyBytes;
    final imageProvider = pdfWidgets.MemoryImage(bytes);

    return imageProvider;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: _printPdf,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8.0),
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                placeholder: (context, url) => const Center(
                  child: SizedBox(
                    width: 50,
                    height: 50,
                    child: CircularProgressIndicator(),
                  ),
                ),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
              child: Text(
                datum,
                style: const TextStyle(
                  fontSize: 18,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                description,
                style: const TextStyle(
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
