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

  /// Send a contact form submission to Firestore
  Future<void> submitContactMessage({
    required String firstName,
    required String lastName,
    required String email,
    String? phone,
    required String message,
  }) async {
    await _firestore.collection('ContactMessages').add({
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone ?? '',
      'message': message,
      'createdDate': Timestamp.now(),
      'status': 'Neu',
    });
  }
}
