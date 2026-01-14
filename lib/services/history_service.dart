import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import '../models/history_item.dart';

class HistoryService {
  static const String _historyKey = 'scan_history';

  /// Retrieves all scan history items
  static Future<List<HistoryItem>> getHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? historyJson = prefs.getString(_historyKey);
      
      if (historyJson == null) return [];
      
      final List<dynamic> decoded = jsonDecode(historyJson);
      return decoded.map((item) => HistoryItem.fromJson(item)).toList();
    } catch (e) {
      return [];
    }
  }

  /// Adds a new scan to history or updates an existing entry
  static Future<void> addScan({
    required String text,
    required String type,
    String? image,
  }) async {
    try {
      String? imagePath = image;

      // If image is base64, save to file
      if (image != null && image.startsWith('data:image')) {
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final fileName = 'scan_$timestamp.jpg';
        final directory = await getApplicationDocumentsDirectory();
        final filePath = '${directory.path}/$fileName';
        
        // Extract base64 data
        final base64Data = image.split(';base64,').last;
        final bytes = base64Decode(base64Data);
        
        // Write to file
        final file = File(filePath);
        await file.writeAsBytes(bytes);
        imagePath = filePath;
      }

      final history = await getHistory();
      final existingIndex = history.indexWhere(
        (h) => h.text == text && h.type == type,
      );

      if (existingIndex >= 0) {
        // Update existing item
        final existing = history[existingIndex];
        history[existingIndex] = existing.copyWith(
          count: existing.count + 1,
          timestamp: DateTime.now().millisecondsSinceEpoch,
          image: imagePath ?? existing.image,
        );
        
        // Move to front
        final updated = history.removeAt(existingIndex);
        history.insert(0, updated);
      } else {
        // Add new item at the beginning
        history.insert(
          0,
          HistoryItem(
            text: text,
            type: type,
            image: imagePath,
            timestamp: DateTime.now().millisecondsSinceEpoch,
            count: 1,
          ),
        );
      }

      // Save to preferences
      final prefs = await SharedPreferences.getInstance();
      final encoded = jsonEncode(history.map((h) => h.toJson()).toList());
      await prefs.setString(_historyKey, encoded);
    } catch (e) {
      print('Error adding scan to history: $e');
    }
  }

  /// Clears all scan history
  static Future<void> clearHistory() async {
    try {
      // Delete all scan images
      final history = await getHistory();
      
      for (final item in history) {
        if (item.image != null && !item.image!.startsWith('data:')) {
          try {
            final file = File(item.image!);
            if (await file.exists()) {
              await file.delete();
            }
          } catch (e) {
            print('Error deleting image: $e');
          }
        }
      }

      // Clear preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_historyKey);
    } catch (e) {
      print('Error clearing history: $e');
    }
  }
}
