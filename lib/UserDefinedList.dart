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
    return ListTile(
      leading: image,
      title: Text(title),
      subtitle: Text(description),
    );
  }
}


class NewsList extends StatelessWidget {
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
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        UserDefinedItem(
          title: 'Licht ausgebrannt',
          description: 'Licht ist ausgebrannt in der Sebastianstraße',
          image: Image.network('https://www.best-of-burgenland.com/assets/img/gemeinden/oggau/oggau_feuerwehr_2022-04-12_003.jpg'),
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
