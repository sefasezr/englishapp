// lib/services/word_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/word.dart';
import 'word_service.dart';

/// Eşsiz anahtar
class UnitKey {
  final int classLevel;
  final String unitName;
  const UnitKey({required this.classLevel, required this.unitName});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UnitKey &&
          other.classLevel == classLevel &&
          other.unitName == unitName;

  @override
  int get hashCode => classLevel.hashCode ^ unitName.hashCode;
}

/// Seçilen sınıf ve ünitedeki kelimeleri çeken provider
final wordsForUnitProvider =
    FutureProvider.family<List<Word>, UnitKey>((ref, key) {
  final service = ref.watch(wordServiceProvider);
  return service.getWordsForUnit(key.classLevel, key.unitName);
});
