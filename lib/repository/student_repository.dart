import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/student.dart';

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository(
      auth: FirebaseAuth.instance, firestore: FirebaseFirestore.instance);
});

class UserRepository {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;
  UserRepository({required this.firestore, required this.auth});

  String get _uid => auth.currentUser!.uid;

  Future<void> createStudent(Student student) {
    return firestore.collection('students').doc(_uid).set(student.toJson());
  }

  Future<void> addUnknownWord(String wordId) {
    final doc = firestore
        .collection('students')
        .doc(_uid)
        .collection('unknownWords')
        .doc(wordId);

    return doc.set({
      'wordId': wordId,
      'addedAt': FieldValue.serverTimestamp(),
    });
  }
}
