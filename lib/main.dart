//TEST, TEST
import 'package:flutter/material.dart';

import 'home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Oggauer Gemeindetrommler',
      home: MyHomePage(title: 'Oggauer Gemeindetrommler'),
      debugShowCheckedModeBanner: false,
    );
  }
}

