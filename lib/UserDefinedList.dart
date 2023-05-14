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
  final int selectedIndex;

  const GenericList({required this.collectionName, required this.selectedIndex});

  @override
  _GenericListState createState() => _GenericListState();
}

class _GenericListState extends State<GenericList> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  Map<String, Map<String, dynamic>> selectedItems = {};

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
                          isSelected: selectedItems.containsKey(documentId),
                          onLongPress: () {
                            setState(() {
                              if (selectedItems.containsKey(documentId)) {
                                selectedItems.remove(documentId);
                              } else {
                                selectedItems[documentId] = data;
                              }
                            });
                          },
                        ),
                      );
                    },
                  );
              }
            },
          ),
          if (selectedItems.isNotEmpty)
            Stack(
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: FloatingActionButton(
                      backgroundColor: Colors.blue,
                      onPressed: () {
                        setState(() {
                          selectedItems.clear();
                        });
                      },
                      child: const Icon(Icons.refresh),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: FloatingActionButton(
                      backgroundColor: Colors.red,
                      onPressed: () => _printSelectedItemsAsPdf(widget.selectedIndex),
                      child: const Icon(Icons.picture_as_pdf),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
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

  Future<void> _printSelectedItemsAsPdf(int selectedIndex) async {
    final pdfWidgets.Document pdf = pdfWidgets.Document();

    final List<pdfWidgets.Widget> items = [];
    for (final entry in selectedItems.entries) {
      final String title = entry.value['title'] ?? '';
      final String description = (entry.value['description'] ?? '').length > 200 ? (entry.value['description'] ?? '').substring(0, 200) + '...' : (entry.value['description'] ?? '');
      final String imageUrl = entry.value['imageUrl'] ?? '';
      final DateTime date = entry.value['createdDate'].toDate();
      final String formattedDate = DateFormat('dd.MM.yyyy').format(date);
      final pdfWidgets.ImageProvider imageProvider = await _loadNetworkImage(imageUrl);

      items.add(
        pdfWidgets.Container(
          height: 150, // Begrenzt die Höhe des Containers
          padding: const pdfWidgets.EdgeInsets.all(5.0), // Reduziert den Abstand
          child: pdfWidgets.Row(
            children: [
              pdfWidgets.Container(
                width: 150, // Reduziert die Breite des Bildes
                height: 150, // Reduziert die Höhe des Bildes
                child: pdfWidgets.Image(imageProvider),
              ),
              pdfWidgets.Flexible(
                child: pdfWidgets.Padding(
                  padding: const pdfWidgets.EdgeInsets.all(5.0), // Reduziert den Abstand
                  child: pdfWidgets.Column(
                    crossAxisAlignment: pdfWidgets.CrossAxisAlignment.start,
                    children: [
                      pdfWidgets.Row(
                        mainAxisAlignment: pdfWidgets.MainAxisAlignment.spaceBetween,
                        children: [
                          pdfWidgets.Flexible(
                            child: pdfWidgets.Text(
                              title,
                              style: pdfWidgets.TextStyle(
                                  fontSize: 20, fontWeight: pdfWidgets.FontWeight.bold),
                            ),
                          ),
                          pdfWidgets.Text(
                            formattedDate,
                            style: const pdfWidgets.TextStyle(
                              fontSize: 15,
                            ),
                          ),

                        ],
                      ),
                      pdfWidgets.Padding(
                        padding: const pdfWidgets.EdgeInsets.all(5.0), // Reduziert den Abstand
                        child: pdfWidgets.Text(
                          description,
                          style: const pdfWidgets.TextStyle(
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    pdf.addPage(
      pdfWidgets.MultiPage(
        build: (pdfWidgets.Context context) => items,
      ),
    );

    String filename;
    switch(selectedIndex) {
      case 0:
        filename = 'Bürgerforum_items.pdf';
        break;
      case 1:
        filename = 'Neuigkeiten_items.pdf';
        break;
      case 2:
        filename = 'Mängel_items.pdf';
        break;
      default:
        filename = 'selected_items.pdf';
    }

    await Printing.sharePdf(bytes: await pdf.save(), filename: filename);
    setState(() {
      selectedItems.clear();
    });
  }
}
