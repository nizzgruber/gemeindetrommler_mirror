import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import 'admin_messages_screen.dart';
import 'auth_dialog.dart';

class ContactScreen extends StatefulWidget {
  const ContactScreen({super.key});

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _messageController = TextEditingController();

  final FirestoreService _firestoreService = FirestoreService();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submitForm(AuthService auth) async {
    if (!auth.isRegisteredUser) {
      await AuthDialog.show(context);
      return;
    }

    if (!_formKey.currentState!.validate() || _isSubmitting) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final firstName = auth.firstName.isNotEmpty
          ? auth.firstName
          : _firstNameController.text.trim();
      final lastName = auth.lastName.isNotEmpty
          ? auth.lastName
          : _lastNameController.text.trim();
      final email = (auth.email != null && auth.email!.isNotEmpty)
          ? auth.email!
          : _emailController.text.trim();

      await _firestoreService.submitContactMessage(
        firstName: firstName,
        lastName: lastName,
        email: email,
        phone: _phoneController.text.trim(),
        message: _messageController.text.trim(),
        authorUid: auth.user?.uid,
      );

      if (!mounted) return;

      _phoneController.clear();
      _messageController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ihre Nachricht wurde erfolgreich übermittelt!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Fehler beim Senden: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);
    final isRegistered = auth.isRegisteredUser;

    // Sync controllers with authenticated user details
    if (isRegistered) {
      if (_firstNameController.text != auth.firstName) {
        _firstNameController.text = auth.firstName;
      }
      if (_lastNameController.text != auth.lastName) {
        _lastNameController.text = auth.lastName;
      }
      if (_emailController.text != (auth.email ?? '')) {
        _emailController.text = auth.email ?? '';
      }
    } else {
      if (_firstNameController.text.isNotEmpty) _firstNameController.clear();
      if (_lastNameController.text.isNotEmpty) _lastNameController.clear();
      if (_emailController.text.isNotEmpty) _emailController.clear();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kontakt Bürgerforum'),
        centerTitle: true,
        actions: [
          if (auth.isAdmin)
            IconButton(
              icon: const Icon(Icons.inbox),
              tooltip: 'Posteingang: Bürgernachrichten',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AdminMessagesScreen(),
                  ),
                );
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (auth.isAdmin) ...[
                Card(
                  color: Colors.indigo.shade50,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.indigo.shade200),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.indigo.shade700,
                      child: const Icon(Icons.mark_email_unread, color: Colors.white),
                    ),
                    title: const Text(
                      'Admin-Posteingang',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: const Text(
                        'Alle eingegangenen Bürgernachrichten einsehen & verwalten'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AdminMessagesScreen(),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
              ],
              if (!isRegistered) ...[
                Card(
                  color: Colors.amber.shade50,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.amber.shade300),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.lock_outline,
                                color: Colors.amber.shade900, size: 22),
                            const SizedBox(width: 8),
                            Text(
                              'Anmeldung erforderlich',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.amber.shade900,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Um eine Nachricht an das Bürgerforum zu senden, ist ein registriertes Benutzerkonto erforderlich. Deine Kontaktdaten werden dann automatisch hinterlegt.',
                          style: TextStyle(
                              fontSize: 13, color: Colors.grey.shade800),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () => AuthDialog.show(context),
                            icon: const Icon(Icons.login),
                            label: const Text('Jetzt anmelden oder registrieren'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade700,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 11),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ] else ...[
                Card(
                  color: Colors.blue.shade50,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.blue.shade100),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        Icon(Icons.verified_user_outlined,
                            color: Colors.blue.shade700, size: 24),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Angemeldet als ${auth.displayName ?? auth.email}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Deine Kontaktdaten sind automatisch hinterlegt.',
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey.shade700),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _firstNameController,
                      readOnly: true,
                      style: TextStyle(
                        color: isRegistered
                            ? Colors.black87
                            : Colors.grey.shade600,
                        fontWeight: isRegistered
                            ? FontWeight.w500
                            : FontWeight.normal,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Vorname *',
                        hintText:
                            isRegistered ? null : 'Wird automatisch ausgefüllt',
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        prefixIcon: const Icon(Icons.person_outline),
                        suffixIcon: isRegistered
                            ? const Icon(Icons.lock_outline,
                                size: 18, color: Colors.grey)
                            : null,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _lastNameController,
                      readOnly: true,
                      style: TextStyle(
                        color: isRegistered
                            ? Colors.black87
                            : Colors.grey.shade600,
                        fontWeight: isRegistered
                            ? FontWeight.w500
                            : FontWeight.normal,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Nachname *',
                        hintText:
                            isRegistered ? null : 'Wird automatisch ausgefüllt',
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        prefixIcon: const Icon(Icons.person_outline),
                        suffixIcon: isRegistered
                            ? const Icon(Icons.lock_outline,
                                size: 18, color: Colors.grey)
                            : null,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailController,
                readOnly: true,
                style: TextStyle(
                  color: isRegistered ? Colors.black87 : Colors.grey.shade600,
                  fontWeight:
                      isRegistered ? FontWeight.w500 : FontWeight.normal,
                ),
                decoration: InputDecoration(
                  labelText: 'E-Mail-Adresse *',
                  hintText:
                      isRegistered ? null : 'Wird durch Anmeldung ausgefüllt',
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  prefixIcon: const Icon(Icons.email_outlined),
                  suffixIcon: isRegistered
                      ? const Icon(Icons.lock_outline,
                          size: 18, color: Colors.grey)
                      : null,
                  helperText: isRegistered
                      ? 'Antworten des Bürgerforums gehen an diese E-Mail'
                      : null,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                enabled: isRegistered,
                decoration: InputDecoration(
                  labelText: 'Rückrufnummer (optional)',
                  prefixIcon: const Icon(Icons.phone_outlined),
                  border: const OutlineInputBorder(),
                  helperText: isRegistered
                      ? 'Optional für eventuelle telefonische Rückfragen'
                      : null,
                  filled: !isRegistered,
                  fillColor: !isRegistered ? Colors.grey.shade100 : null,
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _messageController,
                maxLines: 5,
                enabled: isRegistered,
                decoration: InputDecoration(
                  labelText: 'Ihr Anliegen / Ihre Nachricht *',
                  alignLabelWithHint: true,
                  border: const OutlineInputBorder(),
                  filled: !isRegistered,
                  fillColor: !isRegistered ? Colors.grey.shade100 : null,
                ),
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? 'Bitte Ihre Nachricht eingeben'
                    : null,
              ),
              const SizedBox(height: 12),
              Text(
                'Hinweis: Strafrechtlich relevante Kommentare und Verleumdungen werden polizeilich verfolgt.',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.red.shade700,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: !isRegistered
                      ? () => AuthDialog.show(context)
                      : (_isSubmitting ? null : () => _submitForm(auth)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isRegistered
                        ? Colors.blue.shade800
                        : Colors.grey.shade700,
                    foregroundColor: Colors.white,
                  ),
                  icon: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : Icon(!isRegistered ? Icons.login : Icons.send),
                  label: Text(
                    !isRegistered
                        ? 'Anmelden zum Absenden'
                        : (_isSubmitting
                            ? 'Wird gesendet...'
                            : 'Nachricht absenden'),
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
