import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
              builder: (context) =>
                  DetailPage(
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
                errorWidget: (context, url, error) => Icon(Icons.error),
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
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
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

// ...

// Ändern Sie die Verwendung von Image.network in UserDefinedItem-Widgets in Ihren ListView.builder-Aufrufen:



class NewsList extends StatefulWidget {
  const NewsList({Key? key}) : super(key: key);

  @override
  _NewsListState createState() => _NewsListState();
}
class _NewsListState extends State<NewsList> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  late Stream<QuerySnapshot> newsStream;

  @override
  void initState() {
    super.initState();

    // Enable persistence
    firestore.enablePersistence();

    // Enable network
    firestore.settings = Settings(cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED);

    // Configure the stream to use the cache first and then the server
    newsStream = firestore
        .collection('News')
        .orderBy('createdDate', descending: true)
        .snapshots(includeMetadataChanges: true);
  }

  Future<void> _deleteNews(String newsId) async {
    try {
      await firestore.collection('News').doc(newsId).delete();
    } catch (e) {
      print('Error deleting news: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: newsStream,
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
                final String newsId = documents[index].id;
                final DateTime createdDate = data['createdDate'].toDate();
                final formattedDate =
                DateFormat('dd.MM.yyyy').format(createdDate);
                return Dismissible(
                  key: UniqueKey(),
                  direction: DismissDirection.endToStart,
                  onDismissed: (direction) {
                    _deleteNews(newsId);
                  },
                  background: Container(
                    color: Colors.red,
                    child: Align(
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


class IssueList extends StatefulWidget {
  const IssueList({Key? key}) : super(key: key);

  @override
  _IssueListState createState() => _IssueListState();
}
class _IssueListState extends State<IssueList> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  late Stream<QuerySnapshot> issueStream;

  @override
  void initState() {
    super.initState();

    // Enable persistence
    firestore.enablePersistence();

    // Enable network
    firestore.settings = Settings(cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED);

    // Configure the stream to use the cache first and then the server
    issueStream = firestore
        .collection('Issues')
        .orderBy('createdDate', descending: true)
        .snapshots(includeMetadataChanges: true);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: issueStream,
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
                final DateTime createdDate =
                data['createdDate'].toDate();
                final formattedDate =
                DateFormat('dd.MM.yyyy').format(createdDate);
                return UserDefinedItem(
                  title: data['title'] ?? '',
                  datum: formattedDate,
                  description: data['description'] ?? '',
                  imageUrl: data['imageUrl'] ?? '',
                );
              },
            );
        }
      },
    );
  }
}
class CitizensForum extends StatefulWidget {
  const CitizensForum({Key? key}) : super(key: key);

  @override
  _CitizensForumState createState() => _CitizensForumState();
}

class _CitizensForumState extends State<CitizensForum> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  late Stream<QuerySnapshot<Map<String, dynamic>>> citizenStream;

  @override
  void initState() {
    super.initState();

    // Enable persistence
    firestore.enablePersistence();

    // Enable network
    firestore.settings = Settings(cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED);

    // Configure the stream to use the cache first and then the server
    citizenStream = firestore
        .collection('CitizensForum')
        .orderBy('createdDate', descending: true)
        .snapshots(includeMetadataChanges: true);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: citizenStream,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return const Text('Loading...');
          default:
            final List<QueryDocumentSnapshot<Map<String, dynamic>>> documents = snapshot.data!.docs;
            return ListView.builder(
              itemCount: documents.length,
              itemBuilder: (BuildContext context, int index) {
                final Map<String, dynamic> data = documents[index].data();
                final DateTime createdDate = data['createdDate'].toDate();
                final formattedDate = DateFormat('dd.MM.yyyy').format(createdDate);
                return UserDefinedItem(
                  title: data['title'] ?? '',
                  datum: formattedDate,
                  description: data['description'] ?? '',
                  imageUrl: data['imageUrl'] ?? '',
                );
              },
            );
        }
      },
    );
  }
}