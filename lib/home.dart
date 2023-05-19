import 'package:flutter/material.dart';
import 'package:oggauergemeindetrommler/LoginPage.dart';
import 'UserDefinedList.dart';
import 'anonym_aut.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title});

  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}
class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> widgetOptions = <Widget>[
      const GenericList(collectionName: 'CitizensForum', selectedIndex: 0,),
      const GenericList(collectionName: 'News', selectedIndex: 1,),
      const GenericList(collectionName: 'Issues', selectedIndex: 2,),
      AnonymAuthScreen()
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Oggauer Gemeinde Trommler'),
      ),
      body: Center(
        child: widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'BürgerForum',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.newspaper),
            label: 'Neuigkeiten',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.report),
            label: 'Mängel',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Profil',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.black26,
        onTap: _onItemTapped,
      ),
    );
  }
}
