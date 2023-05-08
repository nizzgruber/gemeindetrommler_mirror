import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'DetailPage.dart';
import 'package:intl/intl.dart';

class UserDefinedItem extends StatelessWidget {
  final String title;
  final String datum;
  final String description;
  final String imageUrl;

  const UserDefinedItem({
    Key? key,
    required this.title,
    required this.description,
    required this.datum,
    required this.imageUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
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
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
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
      await firestore.collection(widget.collectionName).doc(documentId).delete();
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting document: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: getDocumentStream(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return const Text('Loading...');
          default:
            final List<QueryDocumentSnapshot> documents = snapshot.data!.docs;
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
                  ),
                );
              },
            );
        }
      },
    );
  }
}
