// lib/repositories/word_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/word.dart';

final wordRepositoryProvider = Provider<WordRepository>((ref) {
  return WordRepository(firestore: FirebaseFirestore.instance);
});

class WordRepository {
  final FirebaseFirestore _firestore;

  WordRepository({required FirebaseFirestore firestore})
      : _firestore = firestore;

  /// Sadece classLevel ve unit alanlarını çek
  // lib/repositories/word_repository.dart
  /// Sadece classLevel ve unit alanlarını çek (null olanları atla)
  Future<List<Map<String, dynamic>>> fetchClassUnitPairs() async {
    final snapshot = await _firestore.collection('words').get();
    return snapshot.docs
        .map((d) {
          final data = d.data();
          final lvl = data['classLevel'];
          final unit = data['unit'];
          // lvl null veya String vs. farklı tipse at
          if (lvl is num && unit is String) {
            return {
              'classLevel': lvl.toInt(),
              'unit': unit,
            };
          } else {
            return null;
          }
        })
        .where((e) => e != null)
        .cast<Map<String, dynamic>>()
        .toList();
  }

  /// Belirli bir sınıfın, belirli bir ünitesindeki tüm kelimeleri çek
  Future<List<Word>> fetchWordsByLevelAndUnit(
    int classLevel,
    String unit,
  ) async {
    final snapshot = await _firestore
        .collection('words')
        .where('classLevel', isEqualTo: classLevel)
        .where('unit', isEqualTo: unit)
        .get();

    return snapshot.docs.map((doc) => Word.fromSnapshot(doc)).toList();
  }
}
