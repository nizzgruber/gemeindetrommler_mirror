import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/post_item.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../services/pdf_service.dart';
import '../services/storage_service.dart';
import 'add_issue_screen.dart';
import 'add_post_screen.dart';
import 'pdf_viewer_screen.dart';

class DetailScreen extends StatefulWidget {
  final PostItem item;
  final String? collectionName;

  const DetailScreen({
    super.key,
    required this.item,
    this.collectionName,
  });

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late PostItem _item;
  int _currentImageIndex = 0;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _item = widget.item;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _editItem() async {
    final collection = widget.collectionName ??
        (_item.street != null ? 'Issues' : 'CitizensForum');
    PostItem? updated;
    if (collection == 'Issues' || _item.street != null) {
      updated = await Navigator.push<PostItem>(
        context,
        MaterialPageRoute(
          builder: (ctx) => AddIssueScreen(issueToEdit: _item),
        ),
      );
    } else {
      updated = await Navigator.push<PostItem>(
        context,
        MaterialPageRoute(
          builder: (ctx) => AddPostScreen(
            collectionName: collection,
            screenTitle: 'Beitrag bearbeiten',
            postToEdit: _item,
          ),
        ),
      );
    }
    if (updated != null && mounted) {
      setState(() {
        _item = updated!;
      });
    }
  }

  Future<void> _deleteItem() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Eintrag löschen?'),
        content: const Text(
            'Möchten Sie diesen Eintrag wirklich unwiderruflich löschen?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, false),
            child: const Text('Abbrechen'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(dialogCtx, true),
            child: const Text('Löschen'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final collection = widget.collectionName ??
        (_item.street != null ? 'Issues' : 'News');
    try {
      final storage = StorageService();
      final firestore = FirestoreService();
      for (final url in _item.imageUrls) {
        try {
          await storage.deleteFileByUrl(url);
        } catch (_) {}
      }
      await firestore.deletePost(collection, _item.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Eintrag gelöscht.')),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fehler beim Löschen: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);
    final currentUser = auth.user;
    final isAuthor = currentUser != null && _item.authorUid == currentUser.uid;
    final canEdit = !_item.isAussendung && (isAuthor || auth.isAdmin);
    final canDelete = !_item.isAussendung && (isAuthor || auth.isAdmin);
    final isIssue = widget.collectionName == 'Issues' || _item.street != null;

    final formattedDate =
        DateFormat('dd.MM.yyyy HH:mm').format(_item.createdDate);

    return Scaffold(
      appBar: AppBar(
        title: Text(_item.title, overflow: TextOverflow.ellipsis),
        actions: [
          if (canEdit)
            IconButton(
              icon: const Icon(Icons.edit),
              tooltip: 'Beitrag bearbeiten',
              onPressed: _editItem,
            ),
          if (canDelete)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Beitrag löschen',
              onPressed: _deleteItem,
            ),
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: 'Als PDF drucken / teilen',
            onPressed: () => PdfService.printSinglePost(_item),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: 16.0,
          right: 16.0,
          top: 16.0,
          bottom: MediaQuery.paddingOf(context).bottom + 24.0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_item.imageUrls.isNotEmpty) ...[
              if (_item.imageUrls.length == 1)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(
                    imageUrl: _item.imageUrls.first,
                    width: double.infinity,
                    height: 240,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      height: 200,
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.image_not_supported, size: 48),
                    ),
                  ),
                )
              else
                Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: SizedBox(
                        height: 260,
                        width: double.infinity,
                        child: PageView.builder(
                          controller: _pageController,
                          itemCount: _item.imageUrls.length,
                          onPageChanged: (index) {
                            setState(() {
                              _currentImageIndex = index;
                            });
                          },
                          itemBuilder: (context, index) {
                            return CachedNetworkImage(
                              imageUrl: _item.imageUrls[index],
                              width: double.infinity,
                              height: 260,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(32.0),
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                height: 260,
                                color: Colors.grey.shade200,
                                child: const Icon(Icons.image_not_supported,
                                    size: 48),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    // Page indicator dots
                    Positioned(
                      bottom: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(
                            _item.imageUrls.length,
                            (i) => Container(
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 3),
                              width: _currentImageIndex == i ? 16 : 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: _currentImageIndex == i
                                    ? Colors.white
                                    : Colors.white54,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Photo counter badge (e.g. 1 / 2)
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.photo_library,
                                color: Colors.white, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              '${_currentImageIndex + 1} / ${_item.imageUrls.length}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 16),
            ],
            Text(
              _item.title,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                const SizedBox(width: 6),
                Text(
                  formattedDate,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                ),
                if (isIssue && _item.status != null) ...[
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _item.status == 'Erledigt'
                          ? Colors.green.shade50
                          : (_item.status == 'In Bearbeitung'
                              ? Colors.blue.shade50
                              : Colors.orange.shade50),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _item.status == 'Erledigt'
                            ? Colors.green.shade200
                            : (_item.status == 'In Bearbeitung'
                                ? Colors.blue.shade200
                                : Colors.orange.shade200),
                      ),
                    ),
                    child: Text(
                      _item.status!,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: _item.status == 'Erledigt'
                            ? Colors.green.shade800
                            : (_item.status == 'In Bearbeitung'
                                ? Colors.blue.shade800
                                : Colors.orange.shade900),
                      ),
                    ),
                  ),
                ],
              ],
            ),
            if (_item.street != null && _item.street!.isNotEmpty) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.location_on, size: 16, color: Colors.redAccent),
                  const SizedBox(width: 6),
                  Text(
                    'Örtlichkeit: ${_item.street}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ],
            if (_item.category != null && _item.category!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.category, size: 16, color: Colors.orange),
                  const SizedBox(width: 6),
                  Text(
                    'Kategorie: ${_item.category}',
                    style: TextStyle(color: Colors.grey.shade800),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),
            const Text(
              'Beschreibung',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _item.description,
              style: const TextStyle(fontSize: 15, height: 1.5),
            ),
            if (_item.pdfUrl != null && _item.pdfUrl!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Card(
                color: Colors.red.shade50,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.red.shade200),
                ),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.red,
                    child: Icon(Icons.picture_as_pdf, color: Colors.white),
                  ),
                  title: const Text(
                    'PDF-Aussendung ansehen',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle:
                      const Text('Dokument jetzt in der App öffnen und lesen'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (ctx) => PdfViewerScreen(
                          title: _item.title,
                          pdfUrl: _item.pdfUrl!,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
