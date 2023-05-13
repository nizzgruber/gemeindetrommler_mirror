import 'package:flutter/material.dart';
import 'package:oggauergemeindetrommler/LoginPage.dart';
import 'AddPage.dart';
import 'UserDefinedList.dart';

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
      const GenericList(collectionName: 'CitizensForum'),
      const GenericList(collectionName: 'News'),
      const GenericList(collectionName: 'Issues'),
      LoginPage()
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Oggauer Gemeinde Trommler'),
      ),
      body: Center(
        child: widgetOptions.elementAt(_selectedIndex),
      ),
      floatingActionButton: _selectedIndex == 3
          ? null
          : FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        AddScreen(initialIndex: _selectedIndex),
                  ),
                );
              },
              tooltip: 'Add',
              child: const Icon(Icons.add),
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
