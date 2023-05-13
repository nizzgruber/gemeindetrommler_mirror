import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'DetailPage.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pdfWidgets;
import 'package:http/http.dart' as http;

class UserDefinedItem extends StatelessWidget {
  final String title;
  final String datum;
  final String description;
  final String imageUrl;
  final Function onLongPress;
  final bool isSelected;

  const UserDefinedItem({
    Key? key,
    required this.title,
    required this.description,
    required this.datum,
    required this.imageUrl,
    required this.onLongPress,
    required this.isSelected,
  }) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // Open a new screen when the user taps on the list item
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailPage(
              title: title,
              datum: datum,
              description: description,
              imageUrl: imageUrl,
            ),
          ),
        );
      },
      onLongPress: onLongPress as void Function()?,
      child: Card(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                SizedBox(
                  width: 120,
                  height: 120,
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
                if (isSelected)  // Wenn das Element ausgewählt ist, zeigen Sie die Checkbox an
                  Positioned(
                    top: 0,
                    left: 0,
                    child: Checkbox(
                      value: isSelected,
                      onChanged: (bool? value) {
                        onLongPress();  // Wenn die Checkbox angeklickt wird, rufen Sie die onLongPress-Funktion auf
                      },
                    ),
                  ),
              ],
            ),
            Flexible(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            title,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Text(
                          datum,
                          style: const TextStyle(
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      description,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}



class GenericList extends StatefulWidget {
  final String collectionName;
  const GenericList({Key? key, required this.collectionName}) : super(key: key);

  @override
  _GenericListState createState() => _GenericListState();
}

class _GenericListState extends State<GenericList> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  Map<String, bool> selectedItems = {};

  @override
  void initState() {
    super.initState();
    // Enable persistence
    firestore.enablePersistence();
    // Enable network
    firestore.settings =
    const Settings(cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED);
  }

  Stream<QuerySnapshot> getDocumentStream() {
    return firestore
        .collection(widget.collectionName)
        .orderBy('createdDate', descending: true)
        .snapshots(includeMetadataChanges: true);
  }

  Future<void> _deleteDocument(String documentId, String? imageUrl) async {
    try {
      if (imageUrl != null) {
        // Löschen Sie das Bild vom Firebase Storage
        await FirebaseStorage.instance.refFromURL(imageUrl).delete();
      }
      // Löschen Sie das Dokument von der Firestore-Kollektion
      await firestore.collection(widget.collectionName)
          .doc(documentId)
          .delete();
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting document: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          StreamBuilder<QuerySnapshot>(
            stream: getDocumentStream(),
            builder: (BuildContext context,
                AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                  return const Text('Loading...');
                default:
                  final List<QueryDocumentSnapshot> documents = snapshot.data!
                      .docs;
                  return ListView.builder(
                    itemCount: documents.length,
                    itemBuilder: (BuildContext context, int index) {
                      final Map<String, dynamic> data =
                      documents[index].data()! as Map<String, dynamic>;
                      final String documentId = documents[index].id;
                      final DateTime createdDate = data['createdDate'].toDate();
                      final formattedDate =
                      DateFormat('dd.MM.yyyy').format(createdDate);
                      return Dismissible(
                        key: UniqueKey(),
                        direction: DismissDirection.endToStart,
                        onDismissed: (direction) {
                          _deleteDocument(documentId, data['imageUrl']);
                        },
                        background: Container(
                          color: Colors.red,
                          child: const Align(
                            alignment: Alignment.centerRight,
                            child: Padding(
                              padding: EdgeInsets.only(right: 16),
                              child: Icon(Icons.delete, color: Colors.white),
                            ),
                          ),
                        ),
                        child: UserDefinedItem(
                          title: data['title'] ?? '',
                          datum: formattedDate,
                          description: data['description'] ?? '',
                          imageUrl: data['imageUrl'] ?? '',
                          isSelected: selectedItems.containsKey(documentId)
                              ? selectedItems[documentId]!
                              : false,
                          onLongPress: () {
                            // Aktualisieren Sie den ausgewählten Zustand des Elements
                            setState(() {
                              selectedItems[documentId] =
                              !selectedItems.containsKey(documentId)
                                  ? true
                                  : !selectedItems[documentId]!;
                            });
                          },
                        ),
                      );
                    },
                  );
              }
            },
          ),
          if (selectedItems.containsValue(true))
            Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: FloatingActionButton(
                  onPressed: () {
                    // Führen Sie hier die gewünschte Aktion aus
                  },
                  backgroundColor: Colors.red,
                  child: const Icon(Icons.picture_as_pdf),
                ),
              ),
            ),
        ],
      ),
    );
  }
  /*
  Future<pdfWidgets.ImageProvider> _loadNetworkImage(String url) async {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode != 200) {
      throw Exception('Failed to load network image.');
    }

    final Uint8List bytes = response.bodyBytes;
    final imageProvider = pdfWidgets.MemoryImage(bytes);

    return imageProvider;
  }
  Future<void> _printPdf() async {
    final pdf = pdfWidgets.Document();

    for (var docId in selectedItems.keys) {
      final title = selectedItems[docId]!['title'];
      final datum = selectedItems[docId]!['datum'];
      final description = selectedItems[docId]!['description'];
      final imageUrl = selectedItems[docId]!['imageUrl'];

      final image = await _loadNetworkImage(imageUrl);

      pdf.addPage(
        pdfWidgets.MultiPage(
          build: (context) => [
            pdfWidgets.Center(
              child: pdfWidgets.SizedBox(
                width: double.infinity,
                child: pdfWidgets.AspectRatio(
                  aspectRatio: 1,
                  child: pdfWidgets.Image(image),
                ),
              ),
            ),
            pdfWidgets.Text(
                title,
                style: pdfWidgets.TextStyle(
                    fontSize: 20,
                    fontWeight: pdfWidgets.FontWeight.bold
                )
            ),
            pdfWidgets.Text(datum, style: const pdfWidgets.TextStyle(fontSize: 14, )),
            pdfWidgets.Paragraph(text: description, style: const pdfWidgets.TextStyle(fontSize: 12)),
          ],
        ),
      );
    }

    await Printing.sharePdf(bytes: await pdf.save(), filename: 'selectedItems.pdf');
  }*/
}
