import 'dart:io';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image/image.dart' as img;

class AddScreen extends StatefulWidget {
  final int initialIndex;

  const AddScreen({Key? key, required this.initialIndex}) : super(key: key);

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

  Future<bool> isFileSizeValid(File file, int maxSizeInMB) async {
    final fileSize = await file.length();
    final maxSizeInBytes = maxSizeInMB * 1024 * 1024;
    return fileSize <= maxSizeInBytes;
  }

  Future<File> _cropImage(File imageFile) async {
    final originalImage = img.decodeImage(await imageFile.readAsBytes());

    if (originalImage != null) {
      int originSize = min(originalImage.width, originalImage.height);
      final croppedImage = img.copyCrop(originalImage,
          x: (originalImage.width - originSize) ~/ 2,
          y: (originalImage.height - originSize) ~/ 2,
          width: originSize,
          height: originSize);
      final newPath =
          imageFile.path.substring(0, imageFile.path.lastIndexOf('/'));
      final newFile = File('$newPath/cropped.jpg');
      await newFile.writeAsBytes(img.encodePng(croppedImage));
      return newFile;
    } else {
      throw Exception('Unable to decode image file.');
    }
  }

  Future<void> _getImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);

    if (pickedFile != null) {
      final tempFile = File(pickedFile.path);
      final bool isValid = await isFileSizeValid(tempFile, 10);
      if (isValid) {
        // Bildinformationen lesen
        final originalImage = img.decodeImage(await tempFile.readAsBytes());

        if (originalImage != null) {
          if (originalImage.width == originalImage.height) {
            // Wenn das Bild bereits im 1:1-Format ist, überspringen Sie das Zuschneiden
            if (mounted) {
              setState(() {
                _imageFile = tempFile;
                print("1:1");
              });
            }
          } else {
            // Wenn das Bild nicht im 1:1-Format ist, schneiden Sie es zu
            File croppedFile = await _cropImage(tempFile);
            if (mounted) {
              setState(() {
                _imageFile = croppedFile;
              });
              print("decode");
            }
          }
        } else {
          throw Exception('Unable to decode image file.');
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Die Dateigröße darf maximal 10 MB betragen.')),
        );
      }
    }
  }

  Future<void> addNewElementToFirestore(
      String title, String description, File imageFile,
      {required Function(bool) onComplete}) async {
    String collectionName;
    if (_selectedIndex == 0) {
      collectionName = "CitizensForum";
    } else if (_selectedIndex == 1) {
      collectionName = "News";
    } else {
      collectionName = "Issues";
    }

    String imageUrl =
        await uploadImageToFirebaseStorage(imageFile, collectionName);
    String? userId = FirebaseAuth.instance.currentUser?.uid; // get the user ID

    try {
      await FirebaseFirestore.instance.collection(collectionName).add({
        "title": title,
        "description": description,
        "imageUrl": imageUrl,
        "createdDate": DateTime.now(),
        "author_uid": userId, // add the user ID to the document
      });
      onComplete(true);
    } catch (e) {
      onComplete(false);
    }
  }

  Future<String> uploadImageToFirebaseStorage(
      File imageFile, String collectionName) async {
    Reference ref = FirebaseStorage.instance
        .ref()
        .child("$collectionName/${DateTime.now().toString()}");
    UploadTask uploadTask = ref.putFile(imageFile);
    return await (await uploadTask).ref.getDownloadURL();
  }

  @override
  Widget build(BuildContext context) {
    String appBarTitle = '';

    double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

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
                if (_formKey.currentState!.validate() &&
                    _imageFile != null &&
                    !_uploading) {
                  setState(() {
                    _uploading = true;
                  });
                  Navigator.pop(
                      context); // Fenster direkt schließen, nachdem der Upload-Button gedrückt wurde.
                  await addNewElementToFirestore(
                      _titleController.text,
                      _descriptionController.text,
                      _imageFile!, onComplete: (bool success) {
                    if (mounted) {
                      setState(() {
                        _uploading = false;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(success
                              ? 'Upload erfolgreich.'
                              : 'Upload fehlgeschlagen.'),
                        ),
                      );
                    }
                  });
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
                  ? Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    double imageHeight = max(0, constraints.maxHeight - keyboardHeight);
                    return Container(
                      height: imageHeight,
                      child: Image.file(_imageFile!),
                    );
                  },
                ),
              )

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
                              builder: (context) => Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    height: 60,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
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
                                    child: SizedBox(
                                      height: 80,
                                      child: ListTile(
                                        leading: const Icon(Icons.photo_library,
                                            size: 40),
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
                                    child: SizedBox(
                                      height: 80,
                                      child: ListTile(
                                        leading: const Icon(Icons.camera_alt,
                                            size: 40),
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
