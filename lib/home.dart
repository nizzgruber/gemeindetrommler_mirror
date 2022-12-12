import 'package:flutter/material.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}
//Da haben wir letztes mal gemacht aber ich weiß jetzt nicht warum es nicht funktioniert
//??????
/*class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  static final List<Widget> _widgetOptions = <Widget>
  [
    Table(border: TableBorder.all(),
          columnWidths:const<

    int, TableColumnWidth>{
    0: IntrinsicColumnWidth(),
    1: FlexColumnWidth(),
    2: FixedColumnWidth(64),
    },
  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
  children: <TableRow>[
  TableRow(
  children: <Widget>[
  Container(
  height: 32,
  color: Colors.green,
  ),
  TableCell(
  verticalAlignment: TableCellVerticalAlignment.top,
  child: Container(
  height: 32,
  width: 32,
  color: Colors.red,
  ),
  ),
  Container(
  height: 64,
  color: Colors.blue,
  ),
  ],
  ),
  TableRow(
  decoration: const BoxDecoration(
  color: Colors.grey,
  ),
  children: <Widget>[
  Container(
  height: 64,
  width: 128,
  color: Colors.purple,
  ),
  Container(
  height: 32,
  color: Colors.yellow,
  ),
  Center(
  child: Container(
  height: 32,
              width: 32,
              color: Colors.orange,
              ),
            ),
          ],
        ),
      ],
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
}

*/
class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  static const TextStyle optionStyle =
  TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  static const List<Widget> _widgetOptions = <Widget>[
    Text(
      'Index 0: News',
      style: optionStyle,
    ),
    Text(
      'Index 1: Mängel',
      style: optionStyle,
    ),
    Text(
      'Index 2: Profil',
      style: optionStyle,
    )
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