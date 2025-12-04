import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uni_track/features/documents/utils/gallery_item.dart';

class ImagePageHandler {
  static const String _storageKey = 'gallery_items_data';

  static Future<void> saveItems(List<GalleryItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedData = jsonEncode(
      items.map((item) => item.toJson()).toList(),
    );
    await prefs.setString(_storageKey, encodedData);
  }

  static Future<List<GalleryItem>> loadItems() async {
    final prefs = await SharedPreferences.getInstance();
    final String? encodedData = prefs.getString(_storageKey);

    if (encodedData == null) {
      return [];
    }

    try {
      final List<dynamic> decodedList = jsonDecode(encodedData);
      return decodedList.map((item) => GalleryItem.fromJson(item)).toList();
    } catch (e) {
      debugPrint("Fehler beim Laden der Daten: $e");
      return [];
    }
  }
}
