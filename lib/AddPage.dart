import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class AddScreen extends StatefulWidget {
  final int initialIndex;

  AddScreen({required this.initialIndex});
  @override
  _AddScreenState createState() => _AddScreenState();

}

class _AddScreenState extends State<AddScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  File? _imageFile;
  bool _uploading = false;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  Future<void> _getImage(ImageSource source) async {
    final pickedFile = await ImagePicker().getImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }


  Future<void> addNewElementToFirestore(String title, String description, File imageFile) async {
    // Zunächst das Bild in Firebase Storage speichern
    Reference ref = FirebaseStorage.instance.ref().child("images/${DateTime.now().toString()}");
    UploadTask uploadTask = ref.putFile(imageFile);
    String imageUrl = await (await uploadTask).ref.getDownloadURL();

    // Das neue Element in der Firestore-Sammlung "Issues" speichern
    if(_selectedIndex == 1)
    {
      await FirebaseFirestore.instance.collection("Issues").add({
        "title": title,
        "description": description,
        "imageUrl": imageUrl,
        "createdDate": DateTime.now(),
      });
    }
    else
    {
      await FirebaseFirestore.instance.collection("News").add({
        "title": title,
        "description": description,
        "imageUrl": imageUrl,
        "createdDate": DateTime.now(),
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
              onPressed: () async {
                if (_formKey.currentState!.validate() && _imageFile != null && !_uploading) {
                  setState(() {
                    _uploading = true;
                  });
                  try {
                    await addNewElementToFirestore(_titleController.text, _descriptionController.text, _imageFile!);
                    Navigator.pop(context);
                  } catch (e) {
                    print(e);
                    // Fehlerbehandlung hier
                  } finally {
                    setState(() {
                      _uploading = false;
                    });
                  }
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
                                    title: Text('Galerie auswählen'),
                                    onTap: () {
                                      Navigator.pop(context);
                                      _getImage(ImageSource.gallery);
                                    }, //
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
