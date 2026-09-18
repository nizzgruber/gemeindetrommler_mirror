import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../models/post_item.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../services/storage_service.dart';

class AddIssueScreen extends StatefulWidget {
  final PostItem? issueToEdit;

  const AddIssueScreen({super.key, this.issueToEdit});

  @override
  State<AddIssueScreen> createState() => _AddIssueScreenState();
}

class _AddIssueScreenState extends State<AddIssueScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  final FirestoreService _firestoreService = FirestoreService();
  final StorageService _storageService = StorageService();

  final List<File> _selectedImages = [];
  List<String> _existingImageUrls = [];
  String _selectedStatus = 'Gemeldet';
  bool _isSaving = false;

  bool get isEditing => widget.issueToEdit != null;

  final List<String> _statuses = [
    'Gemeldet',
    'In Bearbeitung',
    'Erledigt',
  ];

  final List<String> _streets = [
    'Hauptstraße',
    'Seestraße',
    'Florianigasse',
    'Sebastiansplatz',
    'Sportplatzgasse',
    'Feldgasse',
    'Kirchengasse',
    'Quergasse',
    'Weinberggasse',
    'Hafen / Seebad',
    'Flur / Rad- & Wanderwege',
    'Sonstige / Außerorts',
  ];

  final List<String> _categories = [
    'Fahrbahn / Gehsteig / Radweg',
    'Straßenbeleuchtung',
    'Grünflächen / Bäume',
    'Müll / Verunreinigung',
    'Spielplatz / Freizeiteinrichtung',
    'Kanal / Entwässerung',
    'Verkehrszeichen / Markierung',
    'Sonstiges',
  ];

  String? _selectedStreet;
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    if (widget.issueToEdit != null) {
      final issue = widget.issueToEdit!;
      _titleController.text = issue.title;
      _descriptionController.text = issue.description;
      if (issue.street != null && _streets.contains(issue.street)) {
        _selectedStreet = issue.street;
      } else {
        _selectedStreet = _streets.first;
      }
      if (issue.category != null && _categories.contains(issue.category)) {
        _selectedCategory = issue.category;
      } else {
        _selectedCategory = _categories.first;
      }
      _existingImageUrls = List<String>.from(issue.imageUrls);
      if (_existingImageUrls.isEmpty && issue.imageUrl.isNotEmpty) {
        _existingImageUrls.add(issue.imageUrl);
      }
      if (issue.status != null && _statuses.contains(issue.status)) {
        _selectedStatus = issue.status!;
      }
    } else {
      _selectedStreet = _streets.first;
      _selectedCategory = _categories.first;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    if (_existingImageUrls.length + _selectedImages.length >= 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Es können maximal 2 Fotos hinzugefügt werden.')),
      );
      return;
    }

    try {
      final picked = await ImagePicker().pickImage(
        source: source,
        maxWidth: 1600,
        maxHeight: 1200,
        imageQuality: 85,
      );

      if (picked != null) {
        setState(() {
          _selectedImages.add(File(picked.path));
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fehler bei der Bildauswahl: $e')),
      );
    }
  }

  void _showImageSourceModal() {
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Foto aus Galerie wählen'),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Foto mit Kamera aufnehmen'),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitIssue() async {
    if (!_formKey.currentState!.validate() || _isSaving) return;

    setState(() {
      _isSaving = true;
    });

    try {
      if (isEditing) {
        // Delete removed old images from Storage
        for (final oldUrl in widget.issueToEdit!.imageUrls) {
          if (!_existingImageUrls.contains(oldUrl)) {
            try {
              await _storageService.deleteFileByUrl(oldUrl);
            } catch (_) {}
          }
        }

        // Upload newly selected images to Storage
        final List<String> newlyUploadedUrls = [];
        for (final file in _selectedImages) {
          final url = await _storageService.uploadFile(
            file: file,
            collectionName: 'Issues',
            optimize: true,
          );
          newlyUploadedUrls.add(url);
        }

        final allImages = [..._existingImageUrls, ...newlyUploadedUrls];

        final updatedIssue = widget.issueToEdit!.copyWith(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          imageUrl: allImages.isNotEmpty ? allImages.first : '',
          imageUrls: allImages,
          street: _selectedStreet,
          category: _selectedCategory,
          status: _selectedStatus,
        );

        await _firestoreService.updatePost('Issues', updatedIssue);

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Mangel erfolgreich aktualisiert!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, updatedIssue);
      } else {
        final currentUserId = FirebaseAuth.instance.currentUser?.uid;

        // Upload selected images to Firebase Storage
        final List<String> uploadedUrls = [];
        for (final file in _selectedImages) {
          final url = await _storageService.uploadFile(
            file: file,
            collectionName: 'Issues',
            optimize: true,
          );
          uploadedUrls.add(url);
        }

        final newIssue = PostItem(
          id: '',
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          imageUrl: uploadedUrls.isNotEmpty ? uploadedUrls.first : '',
          imageUrls: uploadedUrls,
          createdDate: DateTime.now(),
          authorUid: currentUserId,
          street: _selectedStreet,
          category: _selectedCategory,
          status: 'Gemeldet',
        );

        await _firestoreService.addPost('Issues', newIssue);

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Mangel wurde erfolgreich gemeldet!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, newIssue);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Fehler beim Speichern: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context, listen: false);
    final isAdmin = auth.isAdmin;
    final totalPhotos = _existingImageUrls.length + _selectedImages.length;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Mangel bearbeiten' : 'Mangel melden'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: 16.0,
          right: 16.0,
          top: 16.0,
          bottom: MediaQuery.paddingOf(context).bottom + 24.0,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Mängelüberschrift *',
                  border: OutlineInputBorder(),
                  hintText: 'z.B. Schlagloch, defekte Straßenlaterne',
                ),
                validator: (val) => (val == null || val.trim().isEmpty)
                    ? 'Bitte Überschrift eingeben'
                    : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _selectedStreet,
                decoration: const InputDecoration(
                  labelText: 'Straße / Örtlichkeit *',
                  border: OutlineInputBorder(),
                ),
                items: _streets
                    .map((street) => DropdownMenuItem(
                          value: street,
                          child: Text(street),
                        ))
                    .toList(),
                onChanged: (val) => setState(() => _selectedStreet = val),
                validator: (val) =>
                    (val == null || val.isEmpty) ? 'Bitte Ort auswählen' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Grundlage / Kategorie *',
                  border: OutlineInputBorder(),
                ),
                items: _categories
                    .map((cat) => DropdownMenuItem(
                          value: cat,
                          child: Text(cat),
                        ))
                    .toList(),
                onChanged: (val) => setState(() => _selectedCategory = val),
              ),
              if (isAdmin && isEditing) ...[
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _selectedStatus,
                  decoration: const InputDecoration(
                    labelText: 'Bearbeitungsstatus (Admin) *',
                    prefixIcon: Icon(Icons.assignment_turned_in_outlined),
                    border: OutlineInputBorder(),
                  ),
                  items: _statuses
                      .map((status) => DropdownMenuItem(
                            value: status,
                            child: Text(status),
                          ))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedStatus = val);
                  },
                ),
              ],
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Mangeltext (Beschreibung) *',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                  hintText: 'Genaue Beschreibung des Schadens...',
                ),
                validator: (val) => (val == null || val.trim().isEmpty)
                    ? 'Bitte Beschreibung angeben'
                    : null,
              ),
              const SizedBox(height: 20),
              const Text(
                'Fotos (maximal 2 im Querformat)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    // Existing images from Firebase Storage
                    ..._existingImageUrls.asMap().entries.map((entry) {
                      final index = entry.key;
                      final url = entry.value;
                      return Stack(
                        children: [
                          Container(
                            margin: const EdgeInsets.only(right: 12),
                            width: 110,
                            height: 80,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade400),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: CachedNetworkImage(
                              imageUrl: url,
                              fit: BoxFit.cover,
                              placeholder: (ctx, u) => const Center(
                                child: CircularProgressIndicator(),
                              ),
                              errorWidget: (ctx, u, e) => Container(
                                color: Colors.grey.shade200,
                                child: const Icon(Icons.broken_image, size: 28),
                              ),
                            ),
                          ),
                          Positioned(
                            top: -4,
                            right: 4,
                            child: CircleAvatar(
                              radius: 14,
                              backgroundColor: Colors.black54,
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                icon: const Icon(Icons.close,
                                    color: Colors.white, size: 16),
                                tooltip: 'Foto entfernen',
                                onPressed: () {
                                  setState(() {
                                    _existingImageUrls.removeAt(index);
                                  });
                                },
                              ),
                            ),
                          ),
                        ],
                      );
                    }),
                    // Newly picked local image files
                    ..._selectedImages.asMap().entries.map((entry) {
                      final index = entry.key;
                      final file = entry.value;
                      return Stack(
                        children: [
                          Container(
                            margin: const EdgeInsets.only(right: 12),
                            width: 110,
                            height: 80,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade400),
                              borderRadius: BorderRadius.circular(8),
                              image: DecorationImage(
                                image: FileImage(file),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Positioned(
                            top: -4,
                            right: 4,
                            child: CircleAvatar(
                              radius: 14,
                              backgroundColor: Colors.black54,
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                icon: const Icon(Icons.close,
                                    color: Colors.white, size: 16),
                                tooltip: 'Foto entfernen',
                                onPressed: () {
                                  setState(() {
                                    _selectedImages.removeAt(index);
                                  });
                                },
                              ),
                            ),
                          ),
                        ],
                      );
                    }),
                    if (totalPhotos < 2)
                      InkWell(
                        onTap: _showImageSourceModal,
                        child: Container(
                          width: 110,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: Colors.grey.shade400,
                                style: BorderStyle.solid),
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_a_photo, color: Colors.grey),
                              SizedBox(height: 4),
                              Text('Foto hinzufügen',
                                  style: TextStyle(
                                      fontSize: 11, color: Colors.black54)),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : _submitIssue,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : Icon(isEditing ? Icons.save : Icons.check_circle_outline),
                  label: Text(
                    _isSaving
                        ? 'Wird gespeichert...'
                        : (isEditing
                            ? 'Änderungen speichern'
                            : 'Mangel fertigstellen'),
                    style: const TextStyle(fontSize: 16),
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
