/*import 'package:flutter/material.dart';

class AddScreen extends StatefulWidget {
  @override
  _AddScreenState createState() => _AddScreenState();
}

class _AddScreenState extends State<AddScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Neues Element hinzufügen'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              icon: Icon(Icons.refresh),
              onPressed: () {
                _titleController.clear();
                _descriptionController.clear();
                _imageController.clear();
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              icon: Icon(Icons.check),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  // Hier wird die Logik zum Hinzufügen des neuen Elements ausgeführt
                  Navigator.pop(context);
                }
              },
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Titel',
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                ),
                controller: _titleController,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Bitte geben Sie einen Titel ein.';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Beschreibung',
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                ),
                controller: _descriptionController,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Bitte geben Sie eine Beschreibung ein.';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Bild',
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                ),
                controller: _imageController,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Bitte geben Sie ein Bild ein.';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}*/

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AddScreen extends StatefulWidget {
  @override
  _AddScreenState createState() => _AddScreenState();
}

class _AddScreenState extends State<AddScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  File? _imageFile;

  Future<void> _getImage(ImageSource source) async {
    final pickedFile = await ImagePicker().getImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Neues Element hinzufügen'),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: IconButton(
                icon: Icon(Icons.refresh),
                onPressed: () {
                  _titleController.clear();
                  _descriptionController.clear();
                  setState(() {
                    _imageFile = null;
                  });
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: IconButton(
                icon: Icon(Icons.check),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Hier wird die Logik zum Hinzufügen des neuen Elements ausgeführt
                    Navigator.pop(context);
                  }
                },
              ),
            ),
          ],
        ),
        body: Padding(
        padding: const EdgeInsets.all(16.0),
    child: Form(
    key: _formKey,
    child: Column(
    children: [
    TextFormField(
    decoration: InputDecoration(
    labelText: 'Titel',
    filled: true,
    fillColor: Colors.grey[200],
    border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(16.0),
    ),
    ),
    controller: _titleController,
    validator: (value) {
    if (value!.isEmpty) {
    return 'Bitte geben Sie einen Titel ein.';
    }
    return null;
    },
    ),
    SizedBox(height: 16.0),
    TextFormField(
    decoration: InputDecoration(
    labelText: 'Beschreibung',
    filled: true,
    fillColor: Colors.grey[200],
    border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(16.0),
    ),
    ),
    controller: _descriptionController,
    validator: (value) {
    if (value!.isEmpty) {
    return 'Bitte geben Sie eine Beschreibung ein.';
    }
    return null;
    },
    ),
    SizedBox(height: 16.0),
    _imageFile != null
    ? Image.file(_imageFile!)
        : Container(
    height: 150.0,
    decoration: BoxDecoration(
    color: Colors.grey[200],
    borderRadius: BorderRadius.circular(16.0),
    ),
    child: Center(
    child: TextButton(
    onPressed: () {
    showModalBottomSheet(
    context: context,
    builder: (context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
    ListTile(
    leading: Icon(Icons.photo_library),
    title: Text ('Galerie auswählen'),
      onTap: () {
        Navigator.pop(context);
        _getImage(ImageSource.gallery);
      },
    ),
      ListTile(
        leading: Icon(Icons.camera_alt),
        title: Text('Kamera verwenden'),
        onTap: () {
          Navigator.pop(context);
          _getImage(ImageSource.camera);
        },
      ),
    ],
    ),
    );
    },
      child: Text(
        'Bild hinzufügen',
        style: TextStyle(
          color: Theme.of(context).primaryColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
    ),
    ),
    ],
    ),
    ),
        ),
    );
  }
}


/*import 'package:flutter/material.dart';

class AddScreen extends StatelessWidget {
  const AddScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Neues Element hinzufügen'),
      ),
      body: Column(
        children: [
          TextFormField(
            decoration: InputDecoration(labelText: 'Titel'),
          ),
          TextFormField(
            decoration: InputDecoration(labelText: 'Beschreibung'),
          ),
          TextFormField(
            decoration: InputDecoration(labelText: 'Bild'),
          ),
          ElevatedButton(
            onPressed: () {
              // Fügen Sie hier die Logik zum Hinzufügen eines neuen Elements hinzu
              Navigator.pop(context);
            },
            child: Text('Hinzufügen'),
          ),
        ],
      ),
    );
  }
}*/
