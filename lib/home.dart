import 'package:demoapp/AddPage.dart';
import 'package:flutter/material.dart';
import 'UserDefinedList.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  bool login = false;
  bool isIssueItemEnabled = true;

  static const TextStyle optionStyle =
  TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  void setLogin(bool value) {
    setState(() {
      login = value;
      isIssueItemEnabled = value;
    });
  }
  @override
  Widget build(BuildContext context) {
    final List<Widget> widgetOptions = <Widget>[
      const NewsList(),
      login ? IssueList() : const Text(
        'Mängel (nur für angemeldete Benutzer verfügbar)',
        style: optionStyle,
        textAlign: TextAlign.center,
      ),
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
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
        ],
      ),
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
            MaterialPageRoute(builder: (context) => AddScreen()),
          );
        },
        tooltip: "Add",
        child: Icon(Icons.add),
      ),

      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>
        [
          BottomNavigationBarItem(
            icon: Icon(Icons.newspaper),
            label: 'News',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.report),
            label: 'Mängel',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
    );
  }
}