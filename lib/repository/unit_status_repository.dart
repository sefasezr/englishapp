// lib/repository/unit_status_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/unit_status.dart';

/// Provider
final unitStatusRepositoryProvider = Provider<UnitStatusRepository>((ref) {
  return UnitStatusRepository(
    firestore: FirebaseFirestore.instance,
    auth: FirebaseAuth.instance,
  );
});

class UnitStatusRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  UnitStatusRepository({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
  })  : _firestore = firestore,
        _auth = auth;

  /// students/{uid}/unit_status koleksiyonundaki tüm dokümanları stream’le izler
  Stream<List<UnitStatus>> watchAllStatuses() {
    final uid = _auth.currentUser!.uid;
    return _firestore
        .collection('students')
        .doc(uid)
        .collection('unit_status')
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => UnitStatus.fromSnapshot(d)).toList());
  }

  /// Tek bir ünitenin durumunu getirir. Eğer doküman yoksa default obje döner.
  Future<UnitStatus> fetchStatus(int classLevel, String unit) async {
    final uid = _auth.currentUser!.uid;
    final docRef = _firestore
        .collection('students')
        .doc(uid)
        .collection('unit_status')
        .doc(_docId(classLevel, unit));
    final doc = await docRef.get();

    // Eğer doküman yoksa ya da içinde data null ise, default bir UnitStatus yarat:
    if (!doc.exists || doc.data() == null) {
      return UnitStatus(
        id: docRef.id,
        classLevel: classLevel,
        unit: unit,
        // isUnlocked ve isCompleted parametreleri zaten default false
      );
    }

    // Varsa birebir snapshot’dan dön
    return UnitStatus.fromSnapshot(doc);
  }

  /// Başlangıçta, JSON’dan gelen tüm UnitStatus’leri batch ile yaz
  Future<void> initializeStatuses(List<UnitStatus> statuses) async {
    final uid = _auth.currentUser!.uid;
    final batch = _firestore.batch();
    final base =
        _firestore.collection('students').doc(uid).collection('unit_status');
    for (var s in statuses) {
      batch.set(base.doc(s.id), s.toJson());
    }
    await batch.commit();
  }

  /// Mevcut UnitStatus’i günceller (kilitle/aç, tamamlandı vs.)
  Future<void> updateStatus({
    required int classLevel,
    required String unit,
    bool? isUnlocked,
    bool? isCompleted,
    DateTime? completedAt,
    Map<String, dynamic>? lastQuiz,
  }) {
    final uid = _auth.currentUser!.uid;
    final docRef = _firestore
        .collection('students')
        .doc(uid)
        .collection('unit_status')
        .doc(_docId(classLevel, unit));

    final data = <String, dynamic>{};
    if (isUnlocked != null) data['isUnlocked'] = isUnlocked;
    if (isCompleted != null) data['completed'] = isCompleted;
    if (completedAt != null) {
      data['completedAt'] = Timestamp.fromDate(completedAt);
    }
    if (lastQuiz != null) data['lastQuiz'] = lastQuiz;

    return docRef.set(data, SetOptions(merge: true));
  }

  String _docId(int classLevel, String unit) => '${classLevel}_$unit';
}
