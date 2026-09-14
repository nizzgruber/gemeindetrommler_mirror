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
import 'auth_dialog.dart';
import 'detail_screen.dart';

class PostListScreen extends StatefulWidget {
  final String collectionName;
  final String title;

  const PostListScreen({
    super.key,
    required this.collectionName,
    required this.title,
  });

  @override
  State<PostListScreen> createState() => _PostListScreenState();
}

class _PostListScreenState extends State<PostListScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final StorageService _storageService = StorageService();

  final Map<String, PostItem> _selectedItems = {};
  String _searchQuery = '';
  bool _isSearchActive = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleSelection(PostItem item) {
    setState(() {
      if (_selectedItems.containsKey(item.id)) {
        _selectedItems.remove(item.id);
      } else {
        _selectedItems[item.id] = item;
      }
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedItems.clear();
    });
  }

  Future<void> _deletePost(PostItem item) async {
    final auth = Provider.of<AuthService>(context, listen: false);
    final currentUser = auth.user;
    final isAuthor = currentUser != null && item.authorUid == currentUser.uid;
    final canDelete = isAuthor || auth.isAdmin;

    if (!canDelete) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Keine Berechtigung zum Löschen dieses Beitrags.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      for (final url in item.imageUrls) {
        await _storageService.deleteFileByUrl(url);
      }
      await _firestoreService.deletePost(widget.collectionName, item.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Eintrag gelöscht.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fehler beim Löschen: $e')),
      );
    }
  }

  Future<void> _onAddNewPressed() async {
    final auth = Provider.of<AuthService>(context, listen: false);

    // News are official announcements and can only be created by Admins
    if (widget.collectionName == 'News' && !auth.isAdmin) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Nur Administratoren können Neuigkeiten veröffentlichen.'),
          backgroundColor: Colors.amber,
        ),
      );
      return;
    }

    if (!auth.isCommunityUnlocked && !auth.isAuthenticated) {
      await AuthDialog.show(context);
      if (!mounted) return;
      if (!auth.isCommunityUnlocked && !auth.isAuthenticated) {
        return;
      }
    }

    _clearSelection();

    if (widget.collectionName == 'Issues') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (ctx) => const AddIssueScreen()),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (ctx) => AddPostScreen(
            collectionName: widget.collectionName,
            screenTitle: widget.collectionName == 'News'
                ? 'Neue Nachricht'
                : 'Neue Idee einbringen',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);
    final currentUser = auth.user;

    return Scaffold(
      appBar: AppBar(
        title: _isSearchActive
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(color: Colors.black87),
                decoration: InputDecoration(
                  hintText: 'Suche in ${widget.title}...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.grey.shade600),
                ),
                onChanged: (val) => setState(() => _searchQuery = val.trim()),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image.asset(
                      'assets/images/logo.png',
                      height: 26,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      widget.title,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
        actions: [
          IconButton(
            icon: Icon(_isSearchActive ? Icons.close : Icons.search),
            tooltip: _isSearchActive ? 'Suche beenden' : 'Suchen',
            onPressed: () {
              setState(() {
                if (_isSearchActive) {
                  _isSearchActive = false;
                  _searchQuery = '';
                  _searchController.clear();
                } else {
                  _isSearchActive = true;
                }
              });
            },
          ),
          if (_selectedItems.isNotEmpty) ...[
            IconButton(
              icon: const Icon(Icons.picture_as_pdf),
              tooltip: 'Auswahl als PDF-Tabelle drucken',
              onPressed: () => PdfService.printSelectedItemsTable(
                items: _selectedItems.values.toList(),
                title: widget.title,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.deselect),
              tooltip: 'Auswahl aufheben',
              onPressed: _clearSelection,
            ),
          ],
        ],
      ),
      body: StreamBuilder<List<PostItem>>(
        stream: _firestoreService.getPostsStream(widget.collectionName),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Fehler beim Laden: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final allItems = snapshot.data ?? [];
          final filteredItems = allItems.where((item) {
            if (_searchQuery.isEmpty) return true;
            final query = _searchQuery.toLowerCase();
            final matchesTitle = item.title.toLowerCase().contains(query);
            final matchesDesc = item.description.toLowerCase().contains(query);
            final matchesStreet =
                item.street?.toLowerCase().contains(query) ?? false;
            final matchesCategory =
                item.category?.toLowerCase().contains(query) ?? false;
            return matchesTitle || matchesDesc || matchesStreet || matchesCategory;
          }).toList();

          if (filteredItems.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 12),
                  Text(
                    _searchQuery.isNotEmpty
                        ? 'Keine Treffer für "$_searchQuery"'
                        : 'Noch keine Einträge vorhanden.',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            itemCount: filteredItems.length,
            separatorBuilder: (ctx, idx) => const Divider(
              height: 1,
              indent: 16,
              endIndent: 16,
              color: Colors.black12,
            ),
            itemBuilder: (context, index) {
              final item = filteredItems[index];
              final isSelected = _selectedItems.containsKey(item.id);
              final isAuthor =
                  currentUser != null && item.authorUid == currentUser.uid;
              final canDelete = isAuthor || auth.isAdmin;
              final formattedDate =
                  DateFormat('dd.MM.yyyy').format(item.createdDate);

              Widget itemTile = ListTile(
                selected: isSelected,
                selectedTileColor: Colors.blue.shade50,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                onTap: () {
                  if (_selectedItems.isNotEmpty) {
                    _toggleSelection(item);
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (ctx) => DetailScreen(item: item),
                      ),
                    );
                  }
                },
                onLongPress: () => _toggleSelection(item),
                leading: item.imageUrl.isNotEmpty
                    ? Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: CachedNetworkImage(
                              imageUrl: item.imageUrl,
                              width: 70,
                              height: 70,
                              fit: BoxFit.cover,
                              placeholder: (ctx, url) => Container(
                                width: 70,
                                height: 70,
                                color: Colors.grey.shade200,
                                child: const Center(
                                  child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  ),
                                ),
                              ),
                              errorWidget: (ctx, url, err) => Container(
                                width: 70,
                                height: 70,
                                color: Colors.grey.shade200,
                                child: const Icon(Icons.image, color: Colors.grey),
                              ),
                            ),
                          ),
                          if (isSelected)
                            const Positioned(
                              top: 2,
                              left: 2,
                              child: CircleAvatar(
                                radius: 12,
                                backgroundColor: Colors.blue,
                                child: Icon(Icons.check, size: 16, color: Colors.white),
                              ),
                            ),
                        ],
                      )
                    : isSelected
                        ? const CircleAvatar(
                            backgroundColor: Colors.blue,
                            child: Icon(Icons.check, color: Colors.white),
                          )
                        : null,
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      formattedDate,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (item.street != null && item.street!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Icons.location_on, size: 12, color: Colors.redAccent),
                          const SizedBox(width: 4),
                          Text(
                            item.street!,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 4),
                    Text(
                      item.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade800,
                      ),
                    ),
                  ],
                ),
              );

              if (canDelete) {
                return Dismissible(
                  key: Key(item.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  confirmDismiss: (direction) async {
                    return await showDialog(
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
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red),
                            onPressed: () => Navigator.pop(dialogCtx, true),
                            child: const Text('Löschen'),
                          ),
                        ],
                      ),
                    );
                  },
                  onDismissed: (direction) => _deletePost(item),
                  child: itemTile,
                );
              }

              return itemTile;
            },
          );
        },
      ),
      floatingActionButton: (widget.collectionName == 'News' && !auth.isAdmin)
          ? null
          : FloatingActionButton(
              onPressed: _onAddNewPressed,
              tooltip: widget.collectionName == 'News'
                  ? 'Nachricht verfassen'
                  : 'Neuen Eintrag erstellen',
              child: const Icon(Icons.add),
            ),
    );
  }
}
