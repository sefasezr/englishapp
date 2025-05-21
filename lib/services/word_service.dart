// lib/services/word_service.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/word.dart';
import '../repository/word_repository.dart';

final wordServiceProvider = Provider<WordService>((ref) {
  final repo = ref.watch(wordRepositoryProvider);
  return WordService(wordRepository: repo);
});

class WordService {
  final WordRepository wordRepository;

  WordService({required this.wordRepository});

  /// classLevel → uniq unit listesi
  Future<Map<int, List<String>>> getClassUnitsMap() async {
    final pairs = await wordRepository.fetchClassUnitPairs();
    final tmp = <int, Set<String>>{};
    for (var p in pairs) {
      final lvl = p['classLevel'] as int;
      final unit = p['unit'] as String;
      tmp.putIfAbsent(lvl, () => {}).add(unit);
    }
    return tmp.map((lvl, set) {
      final list = set.toList()..sort();
      return MapEntry(lvl, list);
    });
  }

  /// Seçilen ünite için kelimeleri getir
  Future<List<Word>> getWordsForUnit(int classLevel, String unit) {
    return wordRepository.fetchWordsByLevelAndUnit(classLevel, unit);
  }
}
