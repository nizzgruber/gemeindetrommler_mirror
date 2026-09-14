import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/post_item.dart';

class AussendungenService {
  static const String _cacheKey = 'cached_aussendungen_v1';
  static const String _apiUrl =
      'https://buergerforumoggau.at/wp-json/wp/v2/posts?categories=9&per_page=50';

  static List<PostItem>? _memoryCache;

  /// Returns cached posts immediately if available, followed by fresh network posts
  Future<List<PostItem>> getAussendungen({bool forceRefresh = false}) async {
    if (!forceRefresh && _memoryCache != null && _memoryCache!.isNotEmpty) {
      return _memoryCache!;
    }

    // Try loading from local SharedPreferences cache first
    if (!forceRefresh) {
      final cached = await _loadFromLocalCache();
      if (cached.isNotEmpty) {
        _memoryCache = cached;
        // Trigger background refresh silently
        _fetchFromNetworkAndCache().catchError((e) {
          debugPrint('Silent background refresh failed: ');
          return <PostItem>[];
        });
        return cached;
      }
    }

    // Otherwise fetch fresh from network
    try {
      final fresh = await _fetchFromNetworkAndCache();
      if (fresh.isNotEmpty) {
        _memoryCache = fresh;
        return fresh;
      }
    } catch (e) {
      debugPrint('Aussendungen network fetch error: ');
      final fallback = await _loadFromLocalCache();
      if (fallback.isNotEmpty) {
        _memoryCache = fallback;
        return fallback;
      }
      rethrow;
    }

    return _memoryCache ?? [];
  }

  /// Network request to WordPress REST API
  Future<List<PostItem>> _fetchFromNetworkAndCache() async {
    final response = await http
        .get(Uri.parse(_apiUrl))
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final dynamic decoded = jsonDecode(utf8.decode(response.bodyBytes));
      if (decoded is List) {
        final List<PostItem> items = [];
        for (final item in decoded) {
          if (item is Map<String, dynamic>) {
            try {
              final post = PostItem.fromWordPressJson(item);
              items.add(post);
            } catch (e) {
              debugPrint('Error parsing WP post item: ');
            }
          }
        }

        await _saveToLocalCache(decoded);
        _memoryCache = items;
        return items;
      }
    } else {
      throw Exception('Server returned ');
    }
    return [];
  }

  /// Load from SharedPreferences
  Future<List<PostItem>> _loadFromLocalCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonString = prefs.getString(_cacheKey);
      if (jsonString != null && jsonString.isNotEmpty) {
        final dynamic decoded = jsonDecode(jsonString);
        if (decoded is List) {
          final List<PostItem> items = [];
          for (final item in decoded) {
            if (item is Map<String, dynamic>) {
              try {
                items.add(PostItem.fromWordPressJson(item));
              } catch (e) {
                debugPrint('Error parsing cached WP item: ');
              }
            }
          }
          return items;
        }
      }
    } catch (e) {
      debugPrint('Error loading cached aussendungen: ');
    }
    return [];
  }

  /// Save to SharedPreferences
  Future<void> _saveToLocalCache(List<dynamic> jsonList) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_cacheKey, jsonEncode(jsonList));
    } catch (e) {
      debugPrint('Error saving aussendungen to cache: ');
    }
  }
}
