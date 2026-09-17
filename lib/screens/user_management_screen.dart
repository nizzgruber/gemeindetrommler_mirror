import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  String _searchQuery = '';
  bool _isSearchActive = false;
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'all'; // 'all', 'admins', 'citizens'

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _toggleAdminRole({
    required String uid,
    required String email,
    required String displayName,
    required bool currentIsAdmin,
    required String currentAdminUid,
  }) async {
    if (currentIsAdmin && uid == currentAdminUid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Sie können sich nicht selbst die Administrator-Rechte entziehen.'),
          backgroundColor: Colors.amber,
        ),
      );
      return;
    }

    final targetAction = currentIsAdmin ? 'entziehen' : 'erteilen';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dCtx) => AlertDialog(
        title: Text(currentIsAdmin
            ? 'Admin-Rechte entziehen?'
            : 'Zum Administrator ernennen?'),
        content: Text(currentIsAdmin
            ? 'Möchten Sie $displayName die Administrator-Rechte wirklich entziehen?'
            : 'Möchten Sie $displayName wirklich zum Administrator ernennen? Dieser Nutzer erhält vollen Zugriff auf News, alle Beiträge, Bürgernachrichten und die Benutzerverwaltung.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dCtx, false),
            child: const Text('Abbrechen'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  currentIsAdmin ? Colors.red : Colors.indigo.shade700,
            ),
            onPressed: () => Navigator.pop(dCtx, true),
            child: Text(currentIsAdmin ? 'Rechte entziehen' : 'Ernennen'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _firestoreService.setAdminRole(
          uid: uid,
          email: email,
          makeAdmin: !currentIsAdmin,
          grantedBy: currentAdminUid,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Administrator-Rechte wurden erfolgreich $targetAction.'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Fehler beim Ändern der Rechte: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _showAddAdminDialog(String currentAdminUid) async {
    final emailController = TextEditingController();
    final uidController = TextEditingController();

    await showDialog(
      context: context,
      builder: (dCtx) => AlertDialog(
        title: const Text('Admin manuell hinzufügen'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Geben Sie die E-Mail-Adresse oder Firebase-UID des neuen Administrators ein:',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'E-Mail-Adresse *',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: uidController,
              decoration: const InputDecoration(
                labelText: 'UID (optional)',
                hintText: 'z. B. aus Firebase Auth',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dCtx),
            child: const Text('Abbrechen'),
          ),
          ElevatedButton(
            onPressed: () async {
              final email = emailController.text.trim().toLowerCase();
              final uid = uidController.text.trim();
              if (email.isEmpty && uid.isEmpty) {
                return;
              }
              final identifier = uid.isNotEmpty ? uid : email;
              try {
                await _firestoreService.addAdminDirectly(
                  identifier: identifier,
                  email: email,
                  grantedBy: currentAdminUid,
                );
                if (dCtx.mounted) {
                  Navigator.pop(dCtx);
                }
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Administrator erfolgreich hinzugefügt.'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Fehler beim Hinzufügen: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Hinzufügen'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);
    final currentAdminUid = auth.user?.uid ?? '';

    return Scaffold(
      appBar: AppBar(
        title: _isSearchActive
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(color: Colors.black87),
                decoration: InputDecoration(
                  hintText: 'Benutzer nach Name oder E-Mail suchen...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.grey.shade600),
                ),
                onChanged: (val) => setState(() => _searchQuery = val.trim()),
              )
            : const Text('Benutzerverwaltung'),
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
          IconButton(
            icon: const Icon(Icons.person_add_alt_1),
            tooltip: 'Admin manuell hinzufügen',
            onPressed: () => _showAddAdminDialog(currentAdminUid),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips
          Container(
            width: double.infinity,
            color: Colors.grey.shade50,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ChoiceChip(
                    label: const Text('Alle'),
                    selected: _selectedFilter == 'all',
                    onSelected: (_) => setState(() => _selectedFilter = 'all'),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    avatar: const Icon(Icons.admin_panel_settings,
                        size: 16, color: Colors.indigo),
                    label: const Text('Administratoren'),
                    selected: _selectedFilter == 'admins',
                    onSelected: (_) =>
                        setState(() => _selectedFilter = 'admins'),
                    selectedColor: Colors.indigo.shade100,
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    avatar: const Icon(Icons.person_outline,
                        size: 16, color: Colors.teal),
                    label: const Text('Bürger'),
                    selected: _selectedFilter == 'citizens',
                    onSelected: (_) =>
                        setState(() => _selectedFilter = 'citizens'),
                    selectedColor: Colors.teal.shade100,
                  ),
                ],
              ),
            ),
          ),
          // Users and Admins Stream
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _firestoreService.getAdminsStream(),
              builder: (context, adminSnapshot) {
                final Set<String> adminUids = {};
                final Set<String> adminEmails = {};

                if (adminSnapshot.hasData) {
                  for (final doc in adminSnapshot.data!.docs) {
                    adminUids.add(doc.id.toLowerCase());
                    final data = doc.data();
                    final email =
                        (data['email'] as String? ?? '').toLowerCase();
                    if (email.isNotEmpty) adminEmails.add(email);
                    final uid =
                        (data['uid'] as String? ?? '').toLowerCase();
                    if (uid.isNotEmpty) adminUids.add(uid);
                  }
                }

                return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: _firestoreService.getUsersStream(),
                  builder: (context, userSnapshot) {
                    if (userSnapshot.hasError) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Text(
                            'Fehler beim Laden der Benutzer: ${userSnapshot.error}',
                            style: const TextStyle(color: Colors.red),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    }

                    if (userSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final userDocs = userSnapshot.data?.docs ?? [];
                    final filteredUsers = userDocs.where((doc) {
                      final data = doc.data();
                      final uid = doc.id;
                      final email =
                          (data['email'] as String? ?? '').toLowerCase();
                      final isUserAdmin = adminUids.contains(uid.toLowerCase()) ||
                          adminEmails.contains(email) ||
                          data['isAdmin'] == true;

                      if (_selectedFilter == 'admins' && !isUserAdmin) {
                        return false;
                      }
                      if (_selectedFilter == 'citizens' && isUserAdmin) {
                        return false;
                      }

                      if (_searchQuery.isNotEmpty) {
                        final q = _searchQuery.toLowerCase();
                        final name =
                            (data['displayName'] as String? ?? '').toLowerCase();
                        final fn =
                            (data['firstName'] as String? ?? '').toLowerCase();
                        final ln =
                            (data['lastName'] as String? ?? '').toLowerCase();
                        return name.contains(q) ||
                            email.contains(q) ||
                            fn.contains(q) ||
                            ln.contains(q);
                      }

                      return true;
                    }).toList();

                    if (filteredUsers.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.people_outline,
                                size: 64, color: Colors.grey.shade400),
                            const SizedBox(height: 12),
                            Text(
                              _searchQuery.isNotEmpty
                                  ? 'Keine Treffer für "$_searchQuery"'
                                  : 'Noch keine registrierten Benutzer vorhanden.',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.separated(
                      padding: EdgeInsets.only(
                        bottom: MediaQuery.paddingOf(context).bottom + 20,
                      ),
                      itemCount: filteredUsers.length,
                      separatorBuilder: (ctx, i) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final doc = filteredUsers[index];
                        final data = doc.data();
                        final uid = doc.id;
                        final email = data['email'] as String? ?? '';
                        final displayName = data['displayName'] as String? ??
                            '${data['firstName'] ?? ''} ${data['lastName'] ?? ''}'.trim();
                        final name = displayName.isNotEmpty
                            ? displayName
                            : (email.isNotEmpty ? email : 'Bürger');
                        final isCurrentUser = uid == currentAdminUid;
                        final isUserAdmin =
                            adminUids.contains(uid.toLowerCase()) ||
                                adminEmails.contains(email.toLowerCase()) ||
                                data['isAdmin'] == true;

                        DateTime? createdAt;
                        if (data['createdAt'] is Timestamp) {
                          createdAt = (data['createdAt'] as Timestamp).toDate();
                        }

                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          leading: CircleAvatar(
                            backgroundColor: isUserAdmin
                                ? Colors.indigo.shade100
                                : Colors.blue.shade50,
                            child: Icon(
                              isUserAdmin
                                  ? Icons.admin_panel_settings
                                  : Icons.person,
                              color: isUserAdmin
                                  ? Colors.indigo.shade800
                                  : Colors.blue.shade700,
                            ),
                          ),
                          title: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  name,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (isCurrentUser) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    'Du',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (email.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(
                                  email,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ],
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: isUserAdmin
                                          ? Colors.indigo.shade50
                                          : Colors.teal.shade50,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: isUserAdmin
                                            ? Colors.indigo.shade200
                                            : Colors.teal.shade200,
                                      ),
                                    ),
                                    child: Text(
                                      isUserAdmin ? 'Administrator' : 'Bürger',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: isUserAdmin
                                            ? Colors.indigo.shade800
                                            : Colors.teal.shade800,
                                      ),
                                    ),
                                  ),
                                  if (createdAt != null) ...[
                                    const SizedBox(width: 8),
                                    Text(
                                      'Seit ${DateFormat('dd.MM.yyyy').format(createdAt)}',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey.shade500,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                          trailing: PopupMenuButton<String>(
                            icon: const Icon(Icons.more_vert),
                            tooltip: 'Optionen',
                            onSelected: (action) {
                              if (action == 'toggleAdmin') {
                                _toggleAdminRole(
                                  uid: uid,
                                  email: email,
                                  displayName: name,
                                  currentIsAdmin: isUserAdmin,
                                  currentAdminUid: currentAdminUid,
                                );
                              }
                            },
                            itemBuilder: (ctx) => [
                              PopupMenuItem(
                                value: 'toggleAdmin',
                                enabled: !(isUserAdmin && isCurrentUser),
                                child: Row(
                                  children: [
                                    Icon(
                                      isUserAdmin
                                          ? Icons.remove_moderator
                                          : Icons.add_moderator,
                                      size: 20,
                                      color: isUserAdmin
                                          ? Colors.red
                                          : Colors.indigo.shade700,
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      isUserAdmin
                                          ? 'Admin-Rechte entziehen'
                                          : 'Zum Admin ernennen',
                                      style: TextStyle(
                                        color: isUserAdmin
                                            ? Colors.red
                                            : Colors.indigo.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
