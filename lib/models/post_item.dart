import 'package:cloud_firestore/cloud_firestore.dart';

class PostItem {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final List<String> imageUrls;
  final DateTime createdDate;
  final String? authorUid;
  final String? street;
  final String? category;
  final String? status;

  PostItem({
    required this.id,
    required this.title,
    required this.description,
    this.imageUrl = '',
    List<String>? imageUrls,
    required this.createdDate,
    this.authorUid,
    this.street,
    this.category,
    this.status = 'Gemeldet',
  }) : imageUrls = imageUrls ?? (imageUrl.isNotEmpty ? [imageUrl] : []);

  factory PostItem.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    DateTime date;
    if (data['createdDate'] is Timestamp) {
      date = (data['createdDate'] as Timestamp).toDate();
    } else {
      date = DateTime.now();
    }

    final String legacyImage = data['imageUrl'] as String? ?? '';
    List<String> images = [];
    if (data['imageUrls'] is List) {
      images = List<String>.from(data['imageUrls'] as List);
    } else if (legacyImage.isNotEmpty) {
      images = [legacyImage];
    }

    return PostItem(
      id: doc.id,
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      imageUrl: legacyImage.isNotEmpty ? legacyImage : (images.isNotEmpty ? images.first : ''),
      imageUrls: images,
      createdDate: date,
      authorUid: data['author_uid'] as String?,
      street: data['street'] as String?,
      category: data['category'] as String?,
      status: data['status'] as String? ?? 'Gemeldet',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'imageUrl': imageUrls.isNotEmpty ? imageUrls.first : '',
      'imageUrls': imageUrls,
      'createdDate': Timestamp.fromDate(createdDate),
      'author_uid': authorUid,
      if (street != null) 'street': street,
      if (category != null) 'category': category,
      if (status != null) 'status': status,
    };
  }
}
