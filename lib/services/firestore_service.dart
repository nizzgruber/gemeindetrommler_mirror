import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/post_item.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  FirestoreService() {
    _initSettings();
  }

  void _initSettings() {
    try {
      _firestore.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Firestore settings initialization error: $e');
      }
    }
  }

  /// Stream of posts ordered by creation date descending
  Stream<List<PostItem>> getPostsStream(String collectionName) {
    return _firestore
        .collection(collectionName)
        .orderBy('createdDate', descending: true)
        .snapshots(includeMetadataChanges: true)
        .map((snapshot) =>
            snapshot.docs.map((doc) => PostItem.fromFirestore(doc)).toList());
  }

  /// Add a new post / issue / idea
  Future<DocumentReference> addPost(
      String collectionName, PostItem item) async {
    return await _firestore.collection(collectionName).add(item.toFirestore());
  }

  /// Delete a post by ID
  Future<void> deletePost(String collectionName, String documentId) async {
    await _firestore.collection(collectionName).doc(documentId).delete();
  }

  /// Update an existing post by ID
  Future<void> updatePost(String collectionName, PostItem item) async {
    await _firestore
        .collection(collectionName)
        .doc(item.id)
        .update(item.toFirestore());
  }

  /// Send a contact form submission to Firestore
  Future<void> submitContactMessage({
    required String firstName,
    required String lastName,
    required String email,
    String? phone,
    required String message,
    String? authorUid,
  }) async {
    await _firestore.collection('ContactMessages').add({
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone ?? '',
      'message': message,
      'author_uid': authorUid ?? '',
      'createdDate': Timestamp.now(),
      'status': 'Neu',
    });
  }

  /// Stream of all contact messages (for admins)
  Stream<QuerySnapshot<Map<String, dynamic>>> getContactMessagesStream() {
    return _firestore
        .collection('ContactMessages')
        .orderBy('createdDate', descending: true)
        .snapshots();
  }

  /// Update the status of a contact message
  Future<void> updateContactMessageStatus(String docId, String status) async {
    await _firestore.collection('ContactMessages').doc(docId).update({
      'status': status,
      'statusUpdatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Delete a contact message
  Future<void> deleteContactMessage(String docId) async {
    await _firestore.collection('ContactMessages').doc(docId).delete();
  }

  /// Stream of all registered users
  Stream<QuerySnapshot<Map<String, dynamic>>> getUsersStream() {
    return _firestore.collection('Users').snapshots();
  }

  /// Stream of all admin documents
  Stream<QuerySnapshot<Map<String, dynamic>>> getAdminsStream() {
    return _firestore.collection('Admins').snapshots();
  }

  /// Upsert a registered user profile into Firestore
  Future<void> syncUserProfile({
    required String uid,
    required String email,
    String? displayName,
    String? firstName,
    String? lastName,
    bool? emailVerified,
    bool? isAdmin,
  }) async {
    try {
      final docRef = _firestore.collection('Users').doc(uid);
      final doc = await docRef.get();
      final data = <String, dynamic>{
        'uid': uid,
        'email': email.trim().toLowerCase(),
        'lastLogin': FieldValue.serverTimestamp(),
        if (displayName != null && displayName.isNotEmpty)
          'displayName': displayName,
        if (firstName != null && firstName.isNotEmpty)
          'firstName': firstName,
        if (lastName != null && lastName.isNotEmpty)
          'lastName': lastName,
        'emailVerified': ?emailVerified,
        'isAdmin': ?isAdmin,
      };

      if (!doc.exists) {
        data['createdAt'] = FieldValue.serverTimestamp();
      }

      await docRef.set(data, SetOptions(merge: true));
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error syncing user profile to Firestore: $e');
      }
    }
  }

  /// Promote or demote a user to Admin in Firestore
  Future<void> setAdminRole({
    required String uid,
    required String email,
    required bool makeAdmin,
    String? grantedBy,
  }) async {
    final cleanEmail = email.trim().toLowerCase();
    final adminRef = _firestore.collection('Admins').doc(uid);
    final userRef = _firestore.collection('Users').doc(uid);

    if (makeAdmin) {
      // 1. Add UID to Admins collection
      await adminRef.set({
        'uid': uid,
        'email': cleanEmail,
        'grantedAt': FieldValue.serverTimestamp(),
        'grantedBy': grantedBy ?? '',
      }, SetOptions(merge: true));

      // 2. Also ensure email doc exists if email is known
      if (cleanEmail.isNotEmpty) {
        await _firestore.collection('Admins').doc(cleanEmail).set({
          'uid': uid,
          'email': cleanEmail,
          'grantedAt': FieldValue.serverTimestamp(),
          'grantedBy': grantedBy ?? '',
        }, SetOptions(merge: true));
      }

      // 3. Mark user document as admin
      await userRef.set({'isAdmin': true}, SetOptions(merge: true));
    } else {
      // 1. Remove UID from Admins collection
      await adminRef.delete();

      // 2. Remove email from Admins collection if present
      if (cleanEmail.isNotEmpty) {
        try {
          await _firestore.collection('Admins').doc(cleanEmail).delete();
        } catch (_) {}
      }

      // 3. Update user document
      await userRef.set({'isAdmin': false}, SetOptions(merge: true));
    }
  }

  /// Add admin directly by UID or email (e.g. manual entry)
  Future<void> addAdminDirectly({
    required String identifier,
    required String email,
    String? grantedBy,
  }) async {
    final cleanId = identifier.trim();
    final cleanEmail = email.trim().toLowerCase();
    await _firestore.collection('Admins').doc(cleanId).set({
      'uid': cleanId,
      'email': cleanEmail,
      'grantedAt': FieldValue.serverTimestamp(),
      'grantedBy': grantedBy ?? '',
    }, SetOptions(merge: true));
  }
}
