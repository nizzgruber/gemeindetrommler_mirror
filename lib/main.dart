//TEST
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
      title: 'Flutter Demo',
      home: MyHomePage(title: 'Bürger Forum Oggau'),
    );
  }
}

/*
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}
*/
/*class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key, required this.title});

  final String title;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class MangelPage extends StatefulWidget {
  const MangelPage({super.key, required this.title});

  final String title;

  @override
  State<MangelPage> createState() => _MangelPageState();
}*/
/*
class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  static const List<Widget> _widgetOptions = <Widget>[
    ListView(
      padding: const EdgeInsets.all(8),
      children: <Widget>[
        Container(
          height: 50,
          color: Colors.amber[600],
          child: const Center(child: Text('Entry A')),
        ),
        Container(
          height: 50,
          color: Colors.amber[500],
          child: const Center(child: Text('Entry B')),
        ),
        Container(
          height: 50,
          color: Colors.amber[100],
          child: const Center(child: Text('Entry C')),
        ),
      ],
    ),

    Text(
      'Index 1: Mängel',
    ),
    Text(
      'Index 2: Profil',
    ),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  /*  void _pushMangel(){
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const MangelPage(title: 'Mängel'),
        ),
      );
  }

    void _pushProfile(){
      Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const ProfilePage(title: 'Profil'),
          ),
      );
    }*/

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(

        title: Text(widget.title),
      ),
      body: Center(
/*
        child: Column(

          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Knopfdruck:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),*/
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
        bottomNavigationBar: BottomAppBar(
          color: const Color(0xFF1601FD),
          child: IconTheme(
            data: IconThemeData(color: Theme.of(context).colorScheme.onPrimary),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                IconButton(
                  tooltip: 'News',
                  icon: const Icon(Icons.newspaper),
                  onPressed: /*() {}*/() => _onItemTapped(0),
                ),
                //if (centerLocations.contains(fabLocation)) const Spacer(),
                IconButton(
                  tooltip: 'Mängel',
                  icon: const Icon(Icons.warning),
                  onPressed: () => /*{_pushMangel()}*/ _onItemTapped(1),
                ),
                IconButton(
                  tooltip: 'Profil',
                  icon: const Icon(Icons.person),
                  onPressed: () => /*{_pushProfile()}*/ _onItemTapped(2),
                ),
              ],
            ),
          ),
        )
    );
  }
}*/

/*
class _ProfilePageState extends State<ProfilePage> {

  void _pushMangel(){
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const MangelPage(title: 'Mängel'),
      ),
    );
  }

  void _pushNews(){
    Navigator.pop(context);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(

          title: Text(widget.title),
        ),
        body: Center(

          child: Column(
          ),
        ),
        bottomNavigationBar: BottomAppBar(
          color: const Color(0xFF1601FD),
          child: IconTheme(
            data: IconThemeData(color: Theme.of(context).colorScheme.onPrimary),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                IconButton(
                  tooltip: 'News',
                  icon: const Icon(Icons.newspaper),
                  onPressed: () => {_pushNews()},
                ),
                //if (centerLocations.contains(fabLocation)) const Spacer(),
                IconButton(
                  tooltip: 'Mängel',
                  icon: const Icon(Icons.warning),
                  onPressed: () => {_pushMangel()},
                ),
                IconButton(
                  tooltip: 'Profil',
                  icon: const Icon(Icons.person),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        )
    );
  }
}

class _MangelPageState extends State<MangelPage> {

  void _pushProfile(){
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ProfilePage(title: 'Profil'),
      ),
    );
  }

  void _pushNews(){
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(

          title: Text(widget.title),
        ),
        body: Center(

          child: Column(
          ),
        ),
        bottomNavigationBar: BottomAppBar(
          color: const Color(0xFF1601FD),
          child: IconTheme(
            data: IconThemeData(color: Theme.of(context).colorScheme.onPrimary),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                IconButton(
                  tooltip: 'News',
                  icon: const Icon(Icons.newspaper),
                  onPressed: () {},
                ),
                //if (centerLocations.contains(fabLocation)) const Spacer(),
                IconButton(
                  tooltip: 'Mängel',
                  icon: const Icon(Icons.warning),
                  onPressed: () {},
                ),
                IconButton(
                  tooltip: 'Profil',
                  icon: const Icon(Icons.person),
                  onPressed: () => {},
                ),
              ],
            ),
          ),
        )
    );
  }
}*/

//https://api.flutter.dev/flutter/material/BottomNavigationBar-class.html
/*
import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static const String _title = 'Flutter Code Sample';

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: _title,
      home: MyStatefulWidget(),
    );
  }
}

class MyStatefulWidget extends StatefulWidget {
  const MyStatefulWidget({super.key});

  @override
  State<MyStatefulWidget> createState() => _MyStatefulWidgetState();
}

class _MyStatefulWidgetState extends State<MyStatefulWidget> {
  int _selectedIndex = 0;
  static const TextStyle optionStyle =
  TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  static const List<Widget> _widgetOptions = <Widget>[
    Text(
      'Index 0: Home',
      style: optionStyle,
    ),
    Text(
      'Index 1: Business',
      style: optionStyle,
    ),
    Text(
      'Index 2: School',
      style: optionStyle,
    ),
    Text(
      'Index 3: Settings',
      style: optionStyle,
    ),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BottomNavigationBar Sample'),
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
            backgroundColor: Colors.red,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.business),
            label: 'Business',
            backgroundColor: Colors.green,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school),
            label: 'School',
            backgroundColor: Colors.purple,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
            backgroundColor: Colors.pink,
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
    );
  }
}
*/