// lib/services/import_service.dart
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:cloud_firestore/cloud_firestore.dart';

class ImportService {
  /// assets/ingilizce_kelimeler.json içindeki kelimeleri
  /// Firestore’daki 'words' koleksiyonuna batch halinde yazar.
  static Future<void> importWordsFromJson() async {
    final jsonString =
        await rootBundle.loadString('assets/ingilizce_kelimeler.json');
    final rawList = jsonDecode(jsonString) as List<dynamic>;

    // Sadece geçerli kayıtları al
    final wordsList = rawList
        .whereType<Map<String, dynamic>>()
        .where((w) =>
            w['english'] != null &&
            w['turkish'] != null &&
            w['classLevel'] != null &&
            w['unit'] != null &&
            w['example'] != null)
        .toList();

    final firestore = FirebaseFirestore.instance;
    const batchSize = 500;

    for (var i = 0; i < wordsList.length; i += batchSize) {
      final batch = firestore.batch();
      for (final w in wordsList.skip(i).take(batchSize)) {
        final docRef = firestore.collection('words').doc();
        batch.set(docRef, {
          'english': w['english'] as String,
          'turkish': w['turkish'] as String,
          'classLevel': w['classLevel'] as int,
          'unit': w['unit'] as String,
          'example': w['example'] as Map<String, dynamic>,
          'imageUrl': w['imageUrl'] as String? ?? '',
          'audioUrl': w['audioUrl'] as String? ?? '',
        });
      }
      await batch.commit();
      print('✔️ Batch ${i ~/ batchSize + 1} tamamlandı');
    }

    print('✅ Toplam ${wordsList.length} kelime yüklendi.');
  }
}
