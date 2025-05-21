import 'package:cloud_firestore/cloud_firestore.dart';

/// users/{uid}/unknown_words/{wordId} dokümanı
class UnknownWord {
  final String wordId; // referans kelime ID’si
  final DateTime addedAt; // eklenme zamanı

  UnknownWord({required this.wordId, required this.addedAt});

  factory UnknownWord.fromSnapshot(DocumentSnapshot snap) {
    final data = snap.data() as Map<String, dynamic>;
    return UnknownWord(
      wordId: snap.id,
      addedAt: (data['addedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() => {
        'addedAt': Timestamp.fromDate(addedAt),
      };
}
