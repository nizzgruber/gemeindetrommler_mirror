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
  final String? pdfUrl;
  final String? webUrl;
  final bool isAussendung;

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
    this.pdfUrl,
    this.webUrl,
    this.isAussendung = false,
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
      pdfUrl: data['pdfUrl'] as String?,
      webUrl: data['webUrl'] as String?,
      isAussendung: data['isAussendung'] as bool? ?? false,
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
      if (pdfUrl != null) 'pdfUrl': pdfUrl,
      if (webUrl != null) 'webUrl': webUrl,
      if (isAussendung) 'isAussendung': isAussendung,
    };
  }

  /// Convert to standard JSON map for local caching
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'imageUrls': imageUrls,
      'createdDate': createdDate.toIso8601String(),
      'authorUid': authorUid,
      'street': street,
      'category': category,
      'status': status,
      'pdfUrl': pdfUrl,
      'webUrl': webUrl,
      'isAussendung': isAussendung,
    };
  }

  /// Create from standard JSON map (local cache)
  factory PostItem.fromJson(Map<String, dynamic> map) {
    DateTime date;
    if (map['createdDate'] is String) {
      date = DateTime.tryParse(map['createdDate'] as String) ?? DateTime.now();
    } else {
      date = DateTime.now();
    }

    final String legacyImage = map['imageUrl'] as String? ?? '';
    List<String> images = [];
    if (map['imageUrls'] is List) {
      images = List<String>.from(map['imageUrls'] as List);
    } else if (legacyImage.isNotEmpty) {
      images = [legacyImage];
    }

    return PostItem(
      id: map['id'] as String? ?? '',
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      imageUrl: legacyImage.isNotEmpty ? legacyImage : (images.isNotEmpty ? images.first : ''),
      imageUrls: images,
      createdDate: date,
      authorUid: map['authorUid'] as String?,
      street: map['street'] as String?,
      category: map['category'] as String?,
      status: map['status'] as String? ?? 'Gemeldet',
      pdfUrl: map['pdfUrl'] as String?,
      webUrl: map['webUrl'] as String?,
      isAussendung: map['isAussendung'] as bool? ?? false,
    );
  }

  /// Decode HTML entities commonly present in WordPress feeds
  static String unescapeHtml(String text) {
    var result = text
        .replaceAll('&amp;', '&')
        .replaceAll('&quot;', '"')
        .replaceAll('&apos;', "'")
        .replaceAll('&#039;', "'")
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&#8211;', '–')
        .replaceAll('&#8212;', '—')
        .replaceAll('&#8216;', '‘')
        .replaceAll('&#8217;', '’')
        .replaceAll('&#8220;', '“')
        .replaceAll('&#8221;', '”')
        .replaceAll('&#8230;', '…');

    // Decode numerical entities &#DDD;
    result = result.replaceAllMapped(RegExp(r'&#(\d+);'), (match) {
      final code = int.tryParse(match.group(1)!);
      return code != null ? String.fromCharCode(code) : match.group(0)!;
    });

    // Decode hex numerical entities &#xHH;
    result = result.replaceAllMapped(RegExp(r'&#x([0-9a-fA-F]+);'), (match) {
      final code = int.tryParse(match.group(1)!, radix: 16);
      return code != null ? String.fromCharCode(code) : match.group(0)!;
    });

    return result.trim();
  }

  /// Extracts the direct PDF URL from WordPress post HTML content
  static String? extractPdfUrl(String htmlContent) {
    final pdfRegExp = RegExp(
      r'https?://[^\s"<>]+?\.pdf',
      caseSensitive: false,
    );
    final match = pdfRegExp.firstMatch(htmlContent);
    if (match != null) {
      return match.group(0);
    }
    // Fallback: check docx or doc files
    final docRegExp = RegExp(
      r'https?://[^\s"<>]+?\.(?:docx|doc)',
      caseSensitive: false,
    );
    final docMatch = docRegExp.firstMatch(htmlContent);
    return docMatch?.group(0);
  }

  /// Strip HTML tags and clean whitespace for preview text
  static String extractCleanText(String htmlContent) {
    var clean = htmlContent.replaceAll(RegExp(r'<style[^>]*>.*?</style>', dotAll: true), '');
    clean = clean.replaceAll(RegExp(r'<script[^>]*>.*?</script>', dotAll: true), '');
    clean = clean.replaceAll(RegExp(r'<[^>]*>'), ' ');
    clean = unescapeHtml(clean);
    clean = clean.replaceAll(RegExp(r'\s+'), ' ').trim();
    return clean;
  }

  /// Parse a post from the WordPress REST API (/wp-json/wp/v2/posts)
  factory PostItem.fromWordPressJson(Map<String, dynamic> json) {
    final rawTitle = (json['title'] is Map)
        ? (json['title']['rendered'] as String? ?? '')
        : (json['title'] as String? ?? '');
    final title = unescapeHtml(rawTitle);

    final rawContent = (json['content'] is Map)
        ? (json['content']['rendered'] as String? ?? '')
        : (json['content'] as String? ?? '');

    final pdfUrl = extractPdfUrl(rawContent);
    final webUrl = json['link'] as String?;

    DateTime date;
    if (json['date'] is String) {
      date = DateTime.tryParse(json['date'] as String) ?? DateTime.now();
    } else {
      date = DateTime.now();
    }

    String desc = extractCleanText(rawContent);
    if (desc.isEmpty || desc == title) {
      desc = 'Offizielle Aussendung des Bürgerforums Oggau (PDF).';
    }

    return PostItem(
      id: 'wp_${json['id']}',
      title: title.isNotEmpty ? title : 'Aussendung',
      description: desc,
      createdDate: date,
      category: 'Aussendung',
      status: 'Aussendung',
      pdfUrl: pdfUrl,
      webUrl: webUrl,
      isAussendung: true,
    );
  }

  /// Create a copy of this PostItem with updated fields
  PostItem copyWith({
    String? id,
    String? title,
    String? description,
    String? imageUrl,
    List<String>? imageUrls,
    DateTime? createdDate,
    String? authorUid,
    String? street,
    String? category,
    String? status,
    String? pdfUrl,
    String? webUrl,
    bool? isAussendung,
  }) {
    return PostItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      imageUrls: imageUrls ?? this.imageUrls,
      createdDate: createdDate ?? this.createdDate,
      authorUid: authorUid ?? this.authorUid,
      street: street ?? this.street,
      category: category ?? this.category,
      status: status ?? this.status,
      pdfUrl: pdfUrl ?? this.pdfUrl,
      webUrl: webUrl ?? this.webUrl,
      isAussendung: isAussendung ?? this.isAussendung,
    );
  }
}
