import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';


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


  /*static /*const*/ final List<Widget> _widgetOptions = <Widget>[
    /*Text(
      'Index 0: News',
      style: optionStyle,
    ),*/
    NewsList(),
    IssueList(),
    const Text(
      'Index 2: Profil',
      style: optionStyle,
    )
  ];*/

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
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
    final List<Widget> _widgetOptions = <Widget>[
      NewsList(),
      login ? IssueList() : Container(
        child: const Text(
          'Mängel (nur für angemeldete Benutzer verfügbar)',
          style: optionStyle,
          textAlign: TextAlign.center,
        ),
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

      /*const Text(
        'Index 2: Profil',
        style: optionStyle,
      )*/

    return Scaffold(
      appBar: AppBar(
        title: const Text('Oggauer Gemeinde Trommler'),
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
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