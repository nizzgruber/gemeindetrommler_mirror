import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'DetailPage.dart';
import 'package:intl/intl.dart';

class UserDefinedItem extends StatelessWidget {
  final String title;
  final String datum;
  final String description;
  final Image? image;

  const UserDefinedItem({
    Key? key,
    required this.title,
    required this.description,
    required this.datum,
    this.image,
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
                image: image != null ? image! : null,
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
              child: image,
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
                                fontWeight: FontWeight.bold// beliebige Schriftgröße
                            ),
                          ),
                        ),
                        Text(
                          datum,
                          style: const TextStyle(
                            fontSize: 15, // beliebige Schriftgröße
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),  // feste Höhe für 2 Zeilen
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
    newsStream = firestore.collection('News').snapshots();
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
                final Map<String, dynamic> data = documents[index].data()! as Map<String, dynamic>;
                final DateTime createdDate = data['createdDate'].toDate();
                final formattedDate = DateFormat('dd.MM.yyyy').format(createdDate);
                return Dismissible(
                  key: Key(documents[index].id),
                  direction: DismissDirection.endToStart,
                  onDismissed: (direction) async {
                    await firestore.collection('News').doc(documents[index].id).delete();
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text("News wurde gelöscht"),
                    ));
                  },
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    child: const Icon(
                      Icons.delete,
                      color: Colors.white,
                    ),
                  ),
                  child: UserDefinedItem(
                    title: data['title'] ?? '',
                    datum: formattedDate,
                    description: data['description'] ?? '',
                    image: Image.network((data['imageUrl'])),
                  ),
                );
              },
            );
        }
      },
    );
  }
}


/*
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
    newsStream = firestore.collection('News').snapshots();
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
                final Map<String, dynamic> data = documents[index]
                    .data()! as Map<String, dynamic>;
                final DateTime createdDate = data['createdDate'].toDate();
                final formattedDate = DateFormat('dd.MM.yyyy').format(
                    createdDate);
                return Dismissible(
                  key: UniqueKey(),
                  onDismissed: (direction) {
                    setState(() {
                      documents.removeAt(index);
                    });
                  },
                  child: UserDefinedItem(
                    title: data['title'] ?? '',
                    datum: formattedDate,
                    description: data['description'] ?? '',
                    image: Image.network((data['imageUrl'])),
                  ),
                );
              },
            );
        }
      },
    );
  }
}
*/


  /*
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
                final Map<String, dynamic> data = documents[index].data()! as Map<String, dynamic>;
                final DateTime createdDate = data['createdDate'].toDate();
                final formattedDate = DateFormat('dd.MM.yyyy').format(createdDate);
                return UserDefinedItem(
                  title: data['title'] ?? '',
                  datum: formattedDate,
                  description: data['description'] ?? '',
                  image: Image.network((data['imageUrl'])),
                );
              },
            );
        }
      },
    );
  }
}
*/

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
    issueStream = firestore.collection('Issues').snapshots();
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
                final Map<String, dynamic> data = documents[index].data()! as Map<String, dynamic>;
                final DateTime createdDate = data['createdDate'].toDate();
                final formattedDate = DateFormat('dd.MM.yyyy').format(createdDate);
                return UserDefinedItem(
                  title: data['title'] ?? '',
                  datum: formattedDate,
                  description: data['description'] ?? '',
                  image: Image.network((data['imageUrl'])),
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
  _CitizensForum createState() => _CitizensForum();
}

class _CitizensForum extends State<IssueList> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  late Stream<QuerySnapshot> citizenStream;

  @override
  void initState() {
    super.initState();
    citizenStream = firestore.collection('CitizensForum').snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: citizenStream,
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
                final Map<String, dynamic> data = documents[index].data()! as Map<String, dynamic>;
                final DateTime createdDate = data['createdDate'].toDate();
                final formattedDate = DateFormat('dd.MM.yyyy').format(createdDate);
                return UserDefinedItem(
                  title: data['title'] ?? '',
                  datum: formattedDate,
                  description: data['description'] ?? '',
                  image: Image.network((data['imageUrl'])),
                );
              },
            );
        }
      },
    );
  }
}