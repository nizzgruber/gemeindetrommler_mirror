import 'dart:ui';

import 'package:flutter/material.dart';

class NewsItem extends StatelessWidget {
  final String title;
  final String description;
  final Image image;

  NewsItem({
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
        NewsItem(
          title: 'News Title 1',
          description: 'This is the description for news item 1.',
          image: Image.file('C:\\Users\\kevin\\StudioProjects\\demoapp_1\\android\\app\\src\\main\\play_store_512.png')
          //network('https://example.com/image1.jpg'),
        ),
        NewsItem(
          title: 'News Title 2',
          description: 'This is the description for news item 2.',
          image: Image.network('https://example.com/image2.jpg'),
        ),
      ],
    );
  }
}
