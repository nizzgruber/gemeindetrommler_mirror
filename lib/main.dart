
import 'package:flutter/material.dart';

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
      home: const MyHomePage(title: 'Bürger Forum Oggau'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class ProfilePage extends StatefulWidget {
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
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

    void _pushMangel(){
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
    }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(

        title: Text(widget.title),
      ),
      body: Center(

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
        ),
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
                  onPressed: () {},
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
                  onPressed: () => {_pushProfile()},
                ),
              ],
            ),
          ),
        )
    );
  }
}

class _ProfilePageState extends State<ProfilePage> {


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
}

class _MangelPageState extends State<MangelPage> {


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
}
