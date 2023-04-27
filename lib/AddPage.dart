import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class AddScreen extends StatefulWidget {
  final int initialIndex;

  const AddScreen({super.key, required this.initialIndex});
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
    final pickedFile = await ImagePicker().pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }
  Future<void> addNewElementToFirestore(String title, String description, File imageFile) async {
    String collectionName;
    if (_selectedIndex == 0) {
      collectionName = "CitizensForum";
    } else if (_selectedIndex == 1) {
      collectionName = "News";
    } else {
      collectionName = "Issues";
    }

    String imageUrl = await uploadImageToFirebaseStorage(imageFile, collectionName);

    await FirebaseFirestore.instance.collection(collectionName).add({
      "title": title,
      "description": description,
      "imageUrl": imageUrl,
      "createdDate": DateTime.now(),
    });
  }

  Future<String> uploadImageToFirebaseStorage(File imageFile, String collectionName) async {
    Reference ref = FirebaseStorage.instance.ref().child("$collectionName/${DateTime.now().toString()}");
    UploadTask uploadTask = ref.putFile(imageFile);
    return await (await uploadTask).ref.getDownloadURL();
  }



  @override
  Widget build(BuildContext context) {
    String appBarTitle = '';

    if (_selectedIndex == 0) {
      appBarTitle = 'Neue BürgerForum Information';
    } else if (_selectedIndex == 1) {
      appBarTitle = 'Neue Neuigkeit';
    } else if (_selectedIndex == 2) {
      appBarTitle = 'Neuer Mängel';
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(appBarTitle),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              icon: const Icon(Icons.refresh),
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
              icon: const Icon(Icons.check),
              onPressed: () async {
                if (_formKey.currentState!.validate() && _imageFile != null &&
                    !_uploading) {
                  setState(() {
                    _uploading = true;
                  });
                  try {
                    await addNewElementToFirestore(
                        _titleController.text, _descriptionController.text,
                        _imageFile!);
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
              const SizedBox(height: 16.0),
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
              const SizedBox(height: 16.0),
              _imageFile != null
                  ? Image.file(_imageFile!)
                  : Container(
                height: 200.0,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: Center(
                  child: TextButton(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (context) =>
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  height: 60,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment
                                        .spaceBetween,
                                    children: [
                                      const Text(
                                        'Bild hinzufügen',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.close),
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                Center(
                                  child: Container(
                                    height: 80,
                                    child: ListTile(
                                      leading: const Icon(
                                          Icons.photo_library, size: 40),
                                      title: const Text(
                                        'Galerie auswählen',
                                        style: TextStyle(fontSize: 20),
                                      ),
                                      onTap: () {
                                        Navigator.pop(context);
                                        _getImage(ImageSource.gallery);
                                      },
                                    ),
                                  ),
                                ),
                                Center(
                                  child: Container(
                                    height: 80,
                                    child: ListTile(
                                      leading: const Icon(
                                          Icons.camera_alt, size: 40),
                                      title: const Text(
                                        'Kamera verwenden',
                                        style: TextStyle(fontSize: 20),
                                      ),
                                      onTap: () {
                                        Navigator.pop(context);
                                        _getImage(ImageSource.camera);
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                      );
                    },
                    child: Text(
                      'Bild hinzufügen',
                      style: TextStyle(
                        color: Theme
                            .of(context)
                            .primaryColor,
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
