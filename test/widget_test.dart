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
      );

      expect(item.id, 'test-123');
      expect(item.title, 'Defekte Straßenlaterne');
      expect(item.street, 'Hauptstraße');
      expect(item.category, 'Straßenbeleuchtung');
      expect(item.imageUrls.length, 1);
      expect(item.status, 'Gemeldet');
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
}
