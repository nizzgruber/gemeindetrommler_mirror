import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/post_item.dart';
import '../services/firestore_service.dart';
import '../services/storage_service.dart';

class AddPostScreen extends StatefulWidget {
  final String collectionName;
  final String screenTitle;
  final PostItem? postToEdit;

  const AddPostScreen({
    super.key,
    required this.collectionName,
    required this.screenTitle,
    this.postToEdit,
  });

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  final FirestoreService _firestoreService = FirestoreService();
  final StorageService _storageService = StorageService();

  File? _selectedImage;
  String? _existingImageUrl;
  bool _isSaving = false;

  bool get isEditing => widget.postToEdit != null;

  @override
  void initState() {
    super.initState();
    if (widget.postToEdit != null) {
      _titleController.text = widget.postToEdit!.title;
      _descriptionController.text = widget.postToEdit!.description;
      if (widget.postToEdit!.imageUrls.isNotEmpty) {
        _existingImageUrl = widget.postToEdit!.imageUrls.first;
      } else if (widget.postToEdit!.imageUrl.isNotEmpty) {
        _existingImageUrl = widget.postToEdit!.imageUrl;
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await ImagePicker().pickImage(
        source: source,
        maxWidth: 1600,
        maxHeight: 1200,
        imageQuality: 85,
      );

      if (picked != null) {
        setState(() {
          _selectedImage = File(picked.path);
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
              title: const Text('Aus Galerie wählen'),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Kamera verwenden'),
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

  Future<void> _submitPost() async {
    if (!_formKey.currentState!.validate() || _isSaving) return;

    setState(() {
      _isSaving = true;
    });

    try {
      if (isEditing) {
        String imageUrl = _existingImageUrl ?? '';

        if (_selectedImage != null) {
          // If a new image was chosen, remove the old one from storage if it existed
          if (widget.postToEdit!.imageUrls.isNotEmpty) {
            for (final oldUrl in widget.postToEdit!.imageUrls) {
              try {
                await _storageService.deleteFileByUrl(oldUrl);
              } catch (_) {}
            }
          }
          imageUrl = await _storageService.uploadFile(
            file: _selectedImage!,
            collectionName: widget.collectionName,
            optimize: true,
          );
        } else if (_existingImageUrl == null &&
            widget.postToEdit!.imageUrls.isNotEmpty) {
          // Existing image was deleted by the user
          for (final oldUrl in widget.postToEdit!.imageUrls) {
            try {
              await _storageService.deleteFileByUrl(oldUrl);
            } catch (_) {}
          }
        }

        final updatedPost = widget.postToEdit!.copyWith(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          imageUrl: imageUrl,
          imageUrls: imageUrl.isNotEmpty ? [imageUrl] : [],
        );

        await _firestoreService.updatePost(widget.collectionName, updatedPost);

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Eintrag erfolgreich aktualisiert!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, updatedPost);
      } else {
        final currentUserId = FirebaseAuth.instance.currentUser?.uid;
        String imageUrl = '';

        if (_selectedImage != null) {
          imageUrl = await _storageService.uploadFile(
            file: _selectedImage!,
            collectionName: widget.collectionName,
            optimize: true,
          );
        }

        final newPost = PostItem(
          id: '',
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          imageUrl: imageUrl,
          imageUrls: imageUrl.isNotEmpty ? [imageUrl] : [],
          createdDate: DateTime.now(),
          authorUid: currentUserId,
        );

        await _firestoreService.addPost(widget.collectionName, newPost);

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Eintrag erfolgreich veröffentlicht!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, newPost);
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
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Beitrag bearbeiten' : widget.screenTitle),
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
                  labelText: 'Überschrift *',
                  border: OutlineInputBorder(),
                ),
                validator: (val) => (val == null || val.trim().isEmpty)
                    ? 'Bitte Überschrift eingeben'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Inhalt / Text *',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
                validator: (val) => (val == null || val.trim().isEmpty)
                    ? 'Bitte Text eingeben'
                    : null,
              ),
              const SizedBox(height: 20),
              const Text(
                'Anhang / Beitragsbild',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 8),
              if (_selectedImage != null)
                Stack(
                  children: [
                    Container(
                      height: 180,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.shade400),
                        image: DecorationImage(
                          image: FileImage(_selectedImage!),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: CircleAvatar(
                        backgroundColor: Colors.black54,
                        child: IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () =>
                              setState(() => _selectedImage = null),
                        ),
                      ),
                    ),
                  ],
                )
              else if (_existingImageUrl != null &&
                  _existingImageUrl!.isNotEmpty)
                Stack(
                  children: [
                    Container(
                      height: 180,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.shade400),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: CachedNetworkImage(
                        imageUrl: _existingImageUrl!,
                        fit: BoxFit.cover,
                        placeholder: (ctx, url) => const Center(
                          child: CircularProgressIndicator(),
                        ),
                        errorWidget: (ctx, url, err) => Container(
                          color: Colors.grey.shade200,
                          child: const Icon(Icons.broken_image, size: 40),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: CircleAvatar(
                        backgroundColor: Colors.black54,
                        child: IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          tooltip: 'Bild entfernen',
                          onPressed: () =>
                              setState(() => _existingImageUrl = null),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black54,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                        ),
                        onPressed: _showImageSourceModal,
                        icon: const Icon(Icons.camera_alt, size: 16),
                        label: const Text('Ersetzen',
                            style: TextStyle(fontSize: 12)),
                      ),
                    ),
                  ],
                )
              else
                InkWell(
                  onTap: _showImageSourceModal,
                  child: Container(
                    height: 120,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade400),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_photo_alternate,
                            size: 36, color: Colors.grey),
                        SizedBox(height: 6),
                        Text('Foto hinzufügen',
                            style: TextStyle(color: Colors.black54)),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : _submitPost,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : Icon(isEditing ? Icons.save : Icons.send),
                  label: Text(
                    _isSaving
                        ? 'Wird gespeichert...'
                        : (isEditing
                            ? 'Änderungen speichern'
                            : 'Veröffentlichen'),
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
