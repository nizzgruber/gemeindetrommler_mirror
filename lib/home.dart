import 'package:flutter/material.dart';
import 'AddPage.dart';
import 'UserDefinedList.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title});

  final String title;
  //final TextEditingController _emailController = TextEditingController();

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

bool isValidEmail(String email) {
  // Hier kannst du deine Validierungslogik implementieren
  // Rückgabe true, wenn die E-Mail gültig ist, andernfalls false
  // Beispiel:
  return RegExp(r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+$').hasMatch(email);
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  final TextEditingController _emailController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();


  static const TextStyle optionStyle =
  TextStyle(fontSize: 30, fontWeight: FontWeight.bold);

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
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              children: [
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'E-Mail',
                  ),

                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Bitte geben Sie eine E-Mail-Adresse ein.';
                    } else if (!isValidEmail(value)) {
                      return 'Bitte geben Sie eine gültige E-Mail-Adresse ein.';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),
                TextFormField(
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Passwort',
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    String email = _emailController.text;
                    if (isValidEmail(email)) {
                      // E-Mail ist gültig, führe die entsprechende Aktion aus
                    } else {/*
                      _scaffoldKey.currentState!.showSnackBar(
                          SnackBar(
                          content: Text('Ungültige E-Mail-Adresse'),
                    duration: Duration(seconds: 2),
                          ),
                      );
                    */
                    }
                  },
                  child: Text('Anmelden'),
                ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Noch kein Konto?'),
                TextButton(
                  onPressed: () {
                    // Navigiere zur Registrierungsseite
                  },
                  child: Text('Registrieren'),
                ),
                ],
                ),
            ],
          ),
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
      floatingActionButton: _selectedIndex == 3
          ? null
          : FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddScreen(initialIndex: _selectedIndex),
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
