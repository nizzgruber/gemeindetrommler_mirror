import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';

class UserDefinedItem extends StatelessWidget {
  final String title;
  final String description;
  final Image image;

  const UserDefinedItem({super.key,
    required this.title,
    required this.description,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: ListTile(
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 24, // beliebige Schriftgröße
          ),
        ),
        subtitle: Text(
          description,
          style: const TextStyle(
            fontSize: 18, // beliebige Schriftgröße
          ),
        ),
        leading: Container(
          child: image,
        ),
      ),
    );
  }
}


class NewsList extends StatelessWidget {
  const NewsList({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(

      children: [
        UserDefinedItem(
          title: 'Rosalia Kapelle',
          description: 'Kapelle bei der Ausfahrt von Oggau',
          image: Image.network('https://upload.wikimedia.org/wikipedia/commons/d/d7/Oggau_Rosaliakapelle.JPG'),
        ),

        UserDefinedItem(
          title: 'Gemeinde Amt Oggau',
          description: 'Gemeide Amt der Marktgemeinde Oggau. SPÖ regierend',
          image: Image.network('https://upload.wikimedia.org/wikipedia/commons/a/a1/Oggau_am_Neusiedler_See_-_Gemeindeamt_%2801%29.jpg'),
        ),

      ],
    );
  }
}

class IssueList extends StatelessWidget {
  const IssueList({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        UserDefinedItem(
          title: 'Licht ausgebrannt',
          description: 'Licht ist ausgebrannt in der Sebastianstraße',
          image: Image.network('https://api.ebsg.at/uploads/immo70/originals/objekt_809_oggau-am-neusiedler-see_7063_6021.jpeg',),
        ),
        UserDefinedItem(
          title: 'test2',
          description: 'Gemeide Amt der Marktgemeinde Oggau. SPÖ regierend',
          image: Image.network('https://upload.wikimedia.org/wikipedia/commons/a/a1/Oggau_am_Neusiedler_See_-_Gemeindeamt_%2801%29.jpg'),
        ),

      ],
    );
  }
}
