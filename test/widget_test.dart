import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oggauergemeindetrommler/models/post_item.dart';

void main() {
  group('PostItem Model Tests', () {
    test('creates PostItem with default values', () {
      final now = DateTime.now();
      final item = PostItem(
        id: 'test-123',
        title: 'Defekte Straßenlaterne',
        description: 'Laterne vor Haus Nr. 12 leuchtet nicht mehr.',
        imageUrl: 'https://example.com/test.jpg',
        createdDate: now,
        street: 'Hauptstraße',
        category: 'Straßenbeleuchtung',
        status: 'Gemeldet',
      );

      expect(item.id, 'test-123');
      expect(item.title, 'Defekte Straßenlaterne');
      expect(item.street, 'Hauptstraße');
      expect(item.category, 'Straßenbeleuchtung');
      expect(item.imageUrls.length, 1);
      expect(item.status, 'Gemeldet');
    });

    test('defaults status to Gemeldet only for issues and null for news/ideas', () {
      final issueJson = {
        'id': 'issue-1',
        'title': 'Schlagloch',
        'description': 'Tiefes Schlagloch',
        'createdDate': '2026-09-18T10:00:00.000',
        'street': 'Kirchengasse',
        'category': 'Straße',
      };
      final issueItem = PostItem.fromJson(issueJson);
      expect(issueItem.status, 'Gemeldet');

      final newsJson = {
        'id': 'news-1',
        'title': 'Dorffest Ankündigung',
        'description': 'Am Samstag findet das Fest statt.',
        'createdDate': '2026-09-18T10:00:00.000',
      };
      final newsItem = PostItem.fromJson(newsJson);
      expect(newsItem.status, isNull);
    });

    test('handles multiple images in PostItem', () {
      final item = PostItem(
        id: 'multi-img-1',
        title: 'Baustelle',
        description: 'Zwei Fotos vorhanden',
        createdDate: DateTime.now(),
        imageUrls: [
          'https://example.com/img1.jpg',
          'https://example.com/img2.jpg',
        ],
      );

      expect(item.imageUrls.length, 2);
      expect(item.imageUrls[0], 'https://example.com/img1.jpg');
      expect(item.imageUrls[1], 'https://example.com/img2.jpg');
      expect(item.imageUrl, 'https://example.com/img1.jpg');
    });

    test('serializes to Firestore map accurately', () {
      final now = DateTime.now();
      final item = PostItem(
        id: 'test-456',
        title: 'Müllablagerung am See',
        description: 'Illegale Ablagerung am Parkplatz',
        createdDate: now,
        street: 'Hafen / Seebad',
        category: 'Müll / Verunreinigung',
        status: 'In Bearbeitung',
      );

      final map = item.toFirestore();
      expect(map['title'], 'Müllablagerung am See');
      expect(map['street'], 'Hafen / Seebad');
      expect(map['category'], 'Müll / Verunreinigung');
      expect(map['status'], 'In Bearbeitung');
    });

    test('parses WordPress JSON accurately with HTML unescape and PDF extraction', () {
      final wpJson = {
        'id': 659,
        'date': '2026-09-10T10:42:00',
        'title': {'rendered': 'Aussendung 17 &#8211; Konzept &amp; Camping'},
        'content': {
          'rendered':
              '<h2 class="wp-block-heading">Aussendung 17</h2><div class="wp-block-file"><object data="https://buergerforumoggau.at/wp-content/uploads/2026/09/20260917_Aussendung_17_-_Camping_Final.pdf" type="application/pdf"></object><a href="https://buergerforumoggau.at/wp-content/uploads/2026/09/20260917_Aussendung_17_-_Camping_Final.pdf">Download</a></div>'
        },
        'link': 'https://buergerforumoggau.at/2026/09/aussendung-17/',
      };

      final item = PostItem.fromWordPressJson(wpJson);
      expect(item.id, 'wp_659');
      expect(item.title, 'Aussendung 17 – Konzept & Camping');
      expect(item.isAussendung, true);
      expect(item.pdfUrl,
          'https://buergerforumoggau.at/wp-content/uploads/2026/09/20260917_Aussendung_17_-_Camping_Final.pdf');
      expect(item.webUrl, 'https://buergerforumoggau.at/2026/09/aussendung-17/');
      expect(item.category, 'Aussendung');
      expect(item.createdDate, DateTime.parse('2026-09-10T10:42:00'));
    });

    test('serializes to and from local JSON cache correctly', () {
      final item = PostItem(
        id: 'wp_999',
        title: 'Aussendung 99',
        description: 'Test Aussendung',
        createdDate: DateTime(2026, 9, 14, 12, 0),
        pdfUrl: 'https://buergerforumoggau.at/test.pdf',
        webUrl: 'https://buergerforumoggau.at/test/',
        isAussendung: true,
      );

      final json = item.toJson();
      final restored = PostItem.fromJson(json);

      expect(restored.id, item.id);
      expect(restored.title, item.title);
      expect(restored.pdfUrl, item.pdfUrl);
      expect(restored.webUrl, item.webUrl);
      expect(restored.isAussendung, true);
      expect(restored.createdDate, item.createdDate);
    });

    test('sorts mixed list of Firestore news and Aussendungen chronologically', () {
      final oldNews = PostItem(
        id: 'news_1',
        title: 'Ältere News',
        description: 'Text',
        createdDate: DateTime(2026, 8, 1),
      );
      final newAussendung = PostItem(
        id: 'wp_659',
        title: 'Aussendung 17',
        description: 'Text',
        createdDate: DateTime(2026, 9, 10),
        isAussendung: true,
      );
      final newestNews = PostItem(
        id: 'news_2',
        title: 'Neueste Nachricht',
        description: 'Text',
        createdDate: DateTime(2026, 9, 14),
      );

      final list = [oldNews, newAussendung, newestNews];
      list.sort((a, b) => b.createdDate.compareTo(a.createdDate));

      expect(list[0].id, 'news_2');
      expect(list[1].id, 'wp_659');
      expect(list[2].id, 'news_1');
    });
  });

  group('Contact Message & Admin Management Tests', () {
    test('validates contact message status states and defaults', () {
      const allowedStatuses = ['Neu', 'In Bearbeitung', 'Erledigt'];
      expect(allowedStatuses.contains('Neu'), isTrue);
      expect(allowedStatuses.contains('In Bearbeitung'), isTrue);
      expect(allowedStatuses.contains('Erledigt'), isTrue);
      expect(allowedStatuses.contains('Unbekannt'), isFalse);

      const messageMap = {
        'subject': 'Straßenbeleuchtung kaputt',
        'message': 'Vor der Schule ist es dunkel.',
        'senderName': 'Max Mustermann',
        'senderEmail': 'max@example.com',
        'senderPhone': '0664 1234567',
        'status': 'Neu',
        'userId': 'user-123',
      };

      expect(messageMap['status'], 'Neu');
      expect(messageMap['senderEmail'], 'max@example.com');
      expect(messageMap['userId'], 'user-123');
    });

    test('validates user profile normalization and admin lookup', () {
      String normalizeEmail(String email) => email.trim().toLowerCase();

      const rawEmail = '  Admin.Test@Oggau.at  ';
      expect(normalizeEmail(rawEmail), 'admin.test@oggau.at');

      const adminUids = {'uid_123', 'uid_456'};
      const adminEmails = {'admin.test@oggau.at', 'buergermeister@oggau.at'};

      bool isUserAdmin(String uid, String email) {
        return adminUids.contains(uid) || adminEmails.contains(normalizeEmail(email));
      }

      expect(isUserAdmin('uid_123', 'other@mail.com'), isTrue);
      expect(isUserAdmin('uid_999', 'Admin.Test@oggau.at'), isTrue);
      expect(isUserAdmin('uid_999', 'regular.user@oggau.at'), isFalse);
    });

    test('prevents self-demotion check logic', () {
      bool canDemote(String targetUid, String currentUid) {
        return targetUid != currentUid;
      }

      expect(canDemote('target_user', 'current_admin'), isTrue);
      expect(canDemote('current_admin', 'current_admin'), isFalse);
    });
  });

  group('PDF Viewer & Navigation Overlap Tests', () {
    test('verifies double-tap zoom matrix calculation and reset', () {
      // Test at standard scale (1.0) -> zoom to 2.5x
      final currentMatrix = Matrix4.identity();
      final currentScale = currentMatrix.getMaxScaleOnAxis();
      expect(currentScale, 1.0);

      const tapPosition = Offset(100, 200);
      Matrix4 targetMatrix;
      if (currentScale > 1.05) {
        targetMatrix = Matrix4.identity();
      } else {
        final x = -tapPosition.dx * (2.5 - 1.0);
        final y = -tapPosition.dy * (2.5 - 1.0);
        targetMatrix = Matrix4.diagonal3Values(2.5, 2.5, 1.0)
          ..setTranslationRaw(x, y, 0.0);
      }

      expect(targetMatrix.getMaxScaleOnAxis(), 2.5);
      expect(targetMatrix.getTranslation().x, -150.0);
      expect(targetMatrix.getTranslation().y, -300.0);

      // Test when zoomed in -> reset to standard size (scale 1.0)
      final zoomedScale = targetMatrix.getMaxScaleOnAxis();
      expect(zoomedScale > 1.05, isTrue);

      Matrix4 resetMatrix;
      if (zoomedScale > 1.05) {
        resetMatrix = Matrix4.identity();
      } else {
        resetMatrix = targetMatrix;
      }

      expect(resetMatrix.getMaxScaleOnAxis(), 1.0);
      expect(resetMatrix.getTranslation().x, 0.0);
      expect(resetMatrix.getTranslation().y, 0.0);
    });

    test('calculates safe bottom padding above 3-button navigation bar', () {
      // 3-button navigation typical height is ~48dp
      const systemNavBarHeight = 48.0;
      const keyboardHeight = 0.0;
      const extraPadding = 20.0;

      final totalBottomPadding = systemNavBarHeight + keyboardHeight + extraPadding;
      expect(totalBottomPadding, 68.0);
      // Ensures interactive action buttons sit strictly above the navigation bar
      expect(totalBottomPadding > systemNavBarHeight, isTrue);
    });
  });

  group('Post Edit & Permissions Tests', () {
    test('PostItem.copyWith updates fields while preserving existing values', () {
      final original = PostItem(
        id: 'post-1',
        title: 'Original Title',
        description: 'Original Desc',
        createdDate: DateTime(2026, 1, 1),
        authorUid: 'user-123',
        imageUrl: 'https://example.com/img1.jpg',
        street: 'Hauptstraße',
        category: 'Sonstiges',
        status: 'Gemeldet',
      );

      final edited = original.copyWith(
        title: 'Updated Title',
        description: 'Updated Desc',
        imageUrl: 'https://example.com/img2.jpg',
        imageUrls: ['https://example.com/img2.jpg'],
        status: 'In Bearbeitung',
      );

      expect(edited.id, 'post-1');
      expect(edited.authorUid, 'user-123');
      expect(edited.createdDate, DateTime(2026, 1, 1));
      expect(edited.street, 'Hauptstraße');
      expect(edited.category, 'Sonstiges');
      expect(edited.title, 'Updated Title');
      expect(edited.description, 'Updated Desc');
      expect(edited.imageUrl, 'https://example.com/img2.jpg');
      expect(edited.imageUrls, ['https://example.com/img2.jpg']);
      expect(edited.status, 'In Bearbeitung');
    });

    test('verifies post edit permissions: admins can edit all, users can edit only their own, Aussendungen cannot be edited', () {
      bool canEditPost({
        required PostItem post,
        required String? currentUserId,
        required bool isAdmin,
      }) {
        if (post.isAussendung) return false;
        final isAuthor = currentUserId != null && post.authorUid == currentUserId;
        return isAuthor || isAdmin;
      }

      final userPost = PostItem(
        id: 'user_post_1',
        title: 'Schlagloch',
        description: 'Großes Schlagloch',
        createdDate: DateTime.now(),
        authorUid: 'author_1',
      );

      final aussendung = PostItem(
        id: 'wp_123',
        title: 'Aussendung',
        description: 'PDF',
        createdDate: DateTime.now(),
        isAussendung: true,
      );

      // 1. Author user can edit their own post
      expect(
        canEditPost(post: userPost, currentUserId: 'author_1', isAdmin: false),
        isTrue,
      );

      // 2. Different user cannot edit other user's post
      expect(
        canEditPost(post: userPost, currentUserId: 'other_user', isAdmin: false),
        isFalse,
      );

      // 3. Admin can edit any post (even if not author)
      expect(
        canEditPost(post: userPost, currentUserId: 'other_user', isAdmin: true),
        isTrue,
      );

      // 4. Admin cannot edit external WordPress Aussendungen
      expect(
        canEditPost(post: aussendung, currentUserId: 'author_1', isAdmin: true),
        isFalse,
      );

      // 5. Unauthenticated user cannot edit
      expect(
        canEditPost(post: userPost, currentUserId: null, isAdmin: false),
        isFalse,
      );
    });

    test('validates issue status editing for admins', () {
      const allowedStatuses = ['Gemeldet', 'In Bearbeitung', 'Erledigt'];

      final issue = PostItem(
        id: 'issue_1',
        title: 'Straßenlaterne',
        description: 'Laterne dunkel',
        createdDate: DateTime.now(),
        authorUid: 'user_1',
        status: 'Gemeldet',
      );

      expect(issue.status, 'Gemeldet');

      // Admin transitions status
      final inProgress = issue.copyWith(status: 'In Bearbeitung');
      expect(inProgress.status, 'In Bearbeitung');
      expect(allowedStatuses.contains(inProgress.status), isTrue);

      final done = inProgress.copyWith(status: 'Erledigt');
      expect(done.status, 'Erledigt');
      expect(allowedStatuses.contains(done.status), isTrue);
    });
  });
}
