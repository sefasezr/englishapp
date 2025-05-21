import 'package:cloud_firestore/cloud_firestore.dart';
import 'quiz_result.dart';

class UnitStatus {
  final String id;
  final int classLevel;
  final String unit;
  final bool isUnlocked;
  final bool isCompleted;
  final DateTime? completedAt;
  final QuizResult? lastQuiz;

  UnitStatus({
    required this.id,
    required this.classLevel,
    required this.unit,
    this.isUnlocked = false,
    this.isCompleted = false,
    this.completedAt,
    this.lastQuiz,
  });

  factory UnitStatus.fromSnapshot(DocumentSnapshot snap) {
    // eğer dokümanda data null ise boş bir map kullan
    final data = snap.data() as Map<String, dynamic>? ?? {};

    // 1) classLevel alanı varsa kullan, yoksa ID’den split ile parse et
    final int lvl = data['classLevel'] != null
        ? (data['classLevel'] as num).toInt()
        : int.tryParse(snap.id.split('_').first) ?? 0;

    // 2) unit alanı varsa kullan, yoksa ID’den _ sonrası string
    final String unitName = data['unit'] != null
        ? data['unit'] as String
        : snap.id.substring(snap.id.indexOf('_') + 1);

    final bool unlocked = data['isUnlocked'] as bool? ?? false;
    final bool completed = data['completed'] as bool? ?? false;

    final DateTime? doneAt = data['completedAt'] != null
        ? (data['completedAt'] as Timestamp).toDate()
        : null;

    final QuizResult? last = data['lastQuiz'] != null
        ? QuizResult.fromJson(data['lastQuiz'] as Map<String, dynamic>)
        : null;

    return UnitStatus(
      id: snap.id,
      classLevel: lvl,
      unit: unitName,
      isUnlocked: unlocked,
      isCompleted: completed,
      completedAt: doneAt,
      lastQuiz: last,
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'classLevel': classLevel,
      'unit': unit,
      'isUnlocked': isUnlocked,
      'completed': isCompleted,
    };
    if (completedAt != null) {
      map['completedAt'] = Timestamp.fromDate(completedAt!);
    }
    if (lastQuiz != null) {
      map['lastQuiz'] = lastQuiz!.toJson();
    }
    return map;
  }
}
