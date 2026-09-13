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
  });
}
