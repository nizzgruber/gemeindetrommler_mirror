import 'dart:io';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Compresses and resizes an image to maximum 800x600 landscape bounds
  Future<File> optimizeImage(File originalFile) async {
    try {
      final bytes = await originalFile.readAsBytes();
      final decoded = img.decodeImage(bytes);
      if (decoded == null) return originalFile;

      // Ensure landscape orientation or maximum 800x600 resolution
      int targetWidth = decoded.width;
      int targetHeight = decoded.height;

      const int maxW = 800;
      const int maxH = 600;

      if (targetWidth > maxW || targetHeight > maxH) {
        double ratioW = maxW / targetWidth;
        double ratioH = maxH / targetHeight;
        double scale = min(ratioW, ratioH);

        targetWidth = (targetWidth * scale).round();
        targetHeight = (targetHeight * scale).round();
      }

      final resized = img.copyResize(
        decoded,
        width: targetWidth,
        height: targetHeight,
        interpolation: img.Interpolation.linear,
      );

      final tempDir = originalFile.parent.path;
      final optimizedFile = File(
          '$tempDir/optimized_${DateTime.now().millisecondsSinceEpoch}.jpg');
      await optimizedFile.writeAsBytes(img.encodeJpg(resized, quality: 85));

      return optimizedFile;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Image optimization fallback: $e');
      }
      return originalFile;
    }
  }

  /// Uploads a file to Firebase Storage under $collectionName/$userId/$timestamp.jpg
  Future<String> uploadFile({
    required File file,
    required String collectionName,
    bool optimize = true,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    final userId = user?.uid ?? 'anonymous';

    File fileToUpload = file;
    if (optimize) {
      fileToUpload = await optimizeImage(file);
    }

    final filename = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    final ref = _storage.ref().child('$collectionName/$userId/$filename');

    final uploadTask = ref.putFile(fileToUpload);
    final snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  /// Deletes a file by download URL
  Future<void> deleteFileByUrl(String url) async {
    if (url.isEmpty) return;
    try {
      final ref = _storage.refFromURL(url);
      await ref.delete();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error deleting storage file: $e');
      }
    }
  }
}
