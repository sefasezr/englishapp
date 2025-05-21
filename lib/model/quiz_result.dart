import 'package:cloud_firestore/cloud_firestore.dart';

/// Çoktan seçmeli quiz sonucu: score/total, passed ve zaman
class QuizResult {
  final int score; // Doğru sayısı
  final int total; // Toplam soru
  final bool passed; // Geçme durumu
  final DateTime takenAt; // Çözme zamanı

  QuizResult({
    required this.score,
    required this.total,
    required this.passed,
    required this.takenAt,
  });

  factory QuizResult.fromJson(Map<String, dynamic> json) => QuizResult(
        score: json['score'] as int,
        total: json['total'] as int,
        passed: json['passed'] as bool,
        takenAt: (json['takenAt'] as Timestamp).toDate(),
      );

  Map<String, dynamic> toJson() => {
        'score': score,
        'total': total,
        'passed': passed,
        'takenAt': Timestamp.fromDate(takenAt),
      };
}
