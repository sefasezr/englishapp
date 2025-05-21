import 'package:cloud_firestore/cloud_firestore.dart';
import 'example.dart';

class Word {
  final String id; // Firestore doküman ID’si
  final String english;
  final String turkish;
  final int classLevel; // 1–4
  final String unit; // Ünite adı
  final Example example; // Örnek cümleler
  final String imageUrl;
  final String audioUrl;

  Word({
    required this.id,
    required this.english,
    required this.turkish,
    required this.classLevel,
    required this.unit,
    required this.example,
    required this.imageUrl,
    required this.audioUrl,
  });

  /// JSON (veya Map<String,dynamic>) kaynaklı tüm constructor’ınızı buraya taşıyoruz:
  factory Word.fromMap(Map<String, dynamic> map, String id) {
    return Word(
      id: id,
      english: map['english'] as String,
      turkish: map['turkish'] as String,
      classLevel: (map['classLevel'] as num).toInt(),
      unit: map['unit'] as String,
      example: Example.fromJson(map['example'] as Map<String, dynamic>),
      imageUrl: map['imageUrl'] as String? ?? '',
      audioUrl: map['audioUrl'] as String? ?? '',
    );
  }

  /// Firestore DocumentSnapshot’tan okumayı buradan yapıyoruz
  factory Word.fromSnapshot(DocumentSnapshot snap) {
    final data = snap.data() as Map<String, dynamic>;
    return Word.fromMap(data, snap.id);
  }

  Map<String, dynamic> toJson() => {
        'english': english,
        'turkish': turkish,
        'classLevel': classLevel,
        'unit': unit,
        'example': example.toJson(),
        'imageUrl': imageUrl,
        'audioUrl': audioUrl,
      };
}
