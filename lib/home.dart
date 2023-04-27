import 'package:oggauergemeindetrommler/AddPage.dart';
import 'package:flutter/material.dart';
import 'UserDefinedList.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  bool login = false;

  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void setLogin(bool value) {
    setState(() {
      login = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> widgetOptions = <Widget>[
      const CitizensForum(),
      const NewsList(),
      const IssueList(),
      Column(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
        ElevatedButton(
          child: Text(login ? 'Logout' : 'Login'),
          onPressed: () {
            setLogin(!login);
          },
        ),
        const Text(
          'Index 2: Profil',
          style: optionStyle,
        ),
      ])
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Oggauer Gemeinde Trommler'),
      ),
      body: Center(
        child: widgetOptions.elementAt(_selectedIndex),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => AddScreen(initialIndex: _selectedIndex)),
          );
        },
        tooltip: "Add",
        child: Icon(Icons.add),
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
