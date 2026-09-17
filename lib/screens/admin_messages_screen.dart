import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/firestore_service.dart';

class AdminMessagesScreen extends StatefulWidget {
  const AdminMessagesScreen({super.key});

  @override
  State<AdminMessagesScreen> createState() => _AdminMessagesScreenState();
}

class _AdminMessagesScreenState extends State<AdminMessagesScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  String _selectedFilter = 'all'; // 'all', 'Neu', 'In Bearbeitung', 'Erledigt'
  String _searchQuery = '';
  bool _isSearchActive = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _sendMail(String email) async {
    final uri = Uri(scheme: 'mailto', path: email);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('E-Mail-App konnte nicht geöffnet werden: $e')),
        );
      }
    }
  }

  Future<void> _callPhone(String phone) async {
    final cleanPhone = phone.replaceAll(RegExp(r'\s+'), '');
    final uri = Uri(scheme: 'tel', path: cleanPhone);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Telefon-App konnte nicht geöffnet werden: $e')),
        );
      }
    }
  }

  void _showMessageDetail(
    BuildContext context,
    String docId,
    Map<String, dynamic> data,
  ) {
    final firstName = data['firstName'] as String? ?? '';
    final lastName = data['lastName'] as String? ?? '';
    final rawName = '$firstName $lastName'.trim();
    final fullName = rawName.isNotEmpty ? rawName : 'Unbekannter Absender';
    final email = data['email'] as String? ?? '';
    final phone = data['phone'] as String? ?? '';
    final message = data['message'] as String? ?? '';
    final currentStatus = data['status'] as String? ?? 'Neu';

    DateTime createdDate;
    if (data['createdDate'] is Timestamp) {
      createdDate = (data['createdDate'] as Timestamp).toDate();
    } else {
      createdDate = DateTime.now();
    }
    final formattedDate =
        DateFormat('dd.MM.yyyy HH:mm').format(createdDate);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          final bottomInset = MediaQuery.viewPaddingOf(ctx).bottom > 0
              ? MediaQuery.viewPaddingOf(ctx).bottom
              : MediaQuery.paddingOf(ctx).bottom;
          final keyboardInset = MediaQuery.viewInsetsOf(ctx).bottom;

          return Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: bottomInset + keyboardInset + 20,
            ),
            child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        fullName,
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    _buildStatusBadge(currentStatus),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Eingegangen: $formattedDate Uhr',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                const Divider(height: 24),
                if (email.isNotEmpty) ...[
                  Row(
                    children: [
                      const Icon(Icons.email_outlined,
                          size: 18, color: Colors.blue),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          email,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () => _sendMail(email),
                        icon: const Icon(Icons.send, size: 16),
                        label: const Text('Antworten'),
                      ),
                    ],
                  ),
                ],
                if (phone.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.phone_outlined,
                          size: 18, color: Colors.green),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          phone,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () => _callPhone(phone),
                        icon: const Icon(Icons.call, size: 16),
                        label: const Text('Anrufen'),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 14),
                const Text(
                  'Nachricht / Anliegen:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: SelectableText(
                    message,
                    style: const TextStyle(fontSize: 14, height: 1.45),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Status ändern:',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildStatusButton(docId, 'Neu', currentStatus, Colors.orange),
                    const SizedBox(width: 8),
                    _buildStatusButton(
                        docId, 'In Bearbeitung', currentStatus, Colors.blue),
                    const SizedBox(width: 8),
                    _buildStatusButton(
                        docId, 'Erledigt', currentStatus, Colors.green),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton.icon(
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('Nachricht löschen'),
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (dCtx) => AlertDialog(
                            title: const Text('Nachricht löschen?'),
                            content: const Text(
                                'Möchten Sie diese Bürgernachricht unwiderruflich löschen?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(dCtx, false),
                                child: const Text('Abbrechen'),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red),
                                onPressed: () => Navigator.pop(dCtx, true),
                                child: const Text('Löschen'),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          await _firestoreService.deleteContactMessage(docId);
                          if (context.mounted) {
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Nachricht gelöscht.')),
                            );
                          }
                        }
                      },
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Schließen'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    ),
  );
}

  Widget _buildStatusButton(
    String docId,
    String targetStatus,
    String currentStatus,
    Color color,
  ) {
    final isCurrent = currentStatus == targetStatus;
    return Expanded(
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          backgroundColor: isCurrent ? color.withValues(alpha: 0.15) : null,
          side: BorderSide(
            color: isCurrent ? color : Colors.grey.shade300,
            width: isCurrent ? 2 : 1,
          ),
          padding: const EdgeInsets.symmetric(vertical: 8),
        ),
        onPressed: () async {
          await _firestoreService.updateContactMessageStatus(
              docId, targetStatus);
          if (mounted) Navigator.pop(context);
        },
        child: Text(
          targetStatus,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
            color: isCurrent ? color : Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bg;
    Color fg;
    switch (status) {
      case 'In Bearbeitung':
        bg = Colors.blue.shade50;
        fg = Colors.blue.shade800;
        break;
      case 'Erledigt':
        bg = Colors.green.shade50;
        fg = Colors.green.shade800;
        break;
      case 'Neu':
      default:
        bg = Colors.orange.shade50;
        fg = Colors.orange.shade900;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: fg.withValues(alpha: 0.3)),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: fg,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearchActive
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(color: Colors.black87),
                decoration: InputDecoration(
                  hintText: 'Nachrichten durchsuchen...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.grey.shade600),
                ),
                onChanged: (val) => setState(() => _searchQuery = val.trim()),
              )
            : const Text('Posteingang (Bürgernachrichten)'),
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
                    onSelected: (_) =>
                        setState(() => _selectedFilter = 'all'),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    avatar: const Icon(Icons.fiber_new,
                        size: 16, color: Colors.orange),
                    label: const Text('Neu'),
                    selected: _selectedFilter == 'Neu',
                    onSelected: (_) =>
                        setState(() => _selectedFilter = 'Neu'),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    avatar: const Icon(Icons.hourglass_top,
                        size: 16, color: Colors.blue),
                    label: const Text('In Bearbeitung'),
                    selected: _selectedFilter == 'In Bearbeitung',
                    onSelected: (_) =>
                        setState(() => _selectedFilter = 'In Bearbeitung'),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    avatar: const Icon(Icons.check_circle_outline,
                        size: 16, color: Colors.green),
                    label: const Text('Erledigt'),
                    selected: _selectedFilter == 'Erledigt',
                    onSelected: (_) =>
                        setState(() => _selectedFilter = 'Erledigt'),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _firestoreService.getContactMessagesStream(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Text(
                        'Fehler beim Abrufen der Nachrichten: ${snapshot.error}',
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data?.docs ?? [];
                final filteredDocs = docs.where((doc) {
                  final data = doc.data();
                  final status = data['status'] as String? ?? 'Neu';
                  if (_selectedFilter != 'all' && status != _selectedFilter) {
                    return false;
                  }

                  if (_searchQuery.isNotEmpty) {
                    final q = _searchQuery.toLowerCase();
                    final fn = (data['firstName'] as String? ?? '').toLowerCase();
                    final ln = (data['lastName'] as String? ?? '').toLowerCase();
                    final em = (data['email'] as String? ?? '').toLowerCase();
                    final msg = (data['message'] as String? ?? '').toLowerCase();
                    return fn.contains(q) ||
                        ln.contains(q) ||
                        em.contains(q) ||
                        msg.contains(q);
                  }

                  return true;
                }).toList();

                if (filteredDocs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.mark_email_read_outlined,
                            size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 12),
                        Text(
                          _searchQuery.isNotEmpty
                              ? 'Keine Treffer für "'
 : 'Keine Nachrichten vorhanden.',
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
                  itemCount: filteredDocs.length,
 separatorBuilder: (ctx, i) => const Divider(height: 1),
 itemBuilder: (context, index) {
 final doc = filteredDocs[index];
 final data = doc.data();
                    final firstName = data['firstName'] as String? ?? '';
                    final lastName = data['lastName'] as String? ?? '';
                    final rawName = '$firstName $lastName'.trim();
                    final fullName =
                        rawName.isNotEmpty ? rawName : 'Unbekannter Absender';
 final email = data['email'] as String? ?? '';
 final message = data['message'] as String? ?? '';
 final status = data['status'] as String? ?? 'Neu';

 DateTime createdDate;
 if (data['createdDate'] is Timestamp) {
 createdDate = (data['createdDate'] as Timestamp).toDate();
 } else {
 createdDate = DateTime.now();
 }
 final formattedDate =
 DateFormat('dd.MM.yyyy HH:mm').format(createdDate);

 return ListTile(
 contentPadding: const EdgeInsets.symmetric(
 horizontal: 16, vertical: 8),
 leading: CircleAvatar(
 backgroundColor: status == 'Neu'
 ? Colors.orange.shade100
 : status == 'In Bearbeitung'
 ? Colors.blue.shade100
 : Colors.green.shade100,
 child: Text(
 fullName.isNotEmpty ? fullName[0].toUpperCase() : '?',
 style: TextStyle(
 fontWeight: FontWeight.bold,
 color: status == 'Neu'
 ? Colors.orange.shade900
 : status == 'In Bearbeitung'
 ? Colors.blue.shade900
 : Colors.green.shade900,
 ),
 ),
 ),
 title: Row(
 mainAxisAlignment: MainAxisAlignment.spaceBetween,
 children: [
 Expanded(
 child: Text(
 fullName,
 style: TextStyle(
 fontSize: 15,
 fontWeight: status == 'Neu'
 ? FontWeight.bold
 : FontWeight.w600,
 ),
 overflow: TextOverflow.ellipsis,
 ),
 ),
 const SizedBox(width: 8),
 Text(
 formattedDate,
 style: TextStyle(
 fontSize: 11,
 color: Colors.grey.shade600,
 ),
 ),
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
 color: Colors.blue.shade800,
 ),
 ),
 ],
 const SizedBox(height: 4),
 Text(
 message,
 maxLines: 2,
 overflow: TextOverflow.ellipsis,
 style: TextStyle(
 fontSize: 13,
 color: Colors.grey.shade800,
 ),
 ),
 ],
 ),
 trailing: _buildStatusBadge(status),
 onTap: () => _showMessageDetail(context, doc.id, data),
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
