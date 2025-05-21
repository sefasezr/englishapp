import 'package:cloud_firestore/cloud_firestore.dart';

/// Artık classLevel yok; onun yerine surname, username, email saklıyoruz.
class Student {
  String? uid; // FirebaseAuth UID
  String name;
  String surname;
  String username; // uygulama içi takma ad
  String email;
  DateTime joinedAt;

  Student({
    this.uid,
    required this.name,
    required this.surname,
    required this.username,
    required this.email,
    required this.joinedAt,
  });

  factory Student.fromSnapshot(DocumentSnapshot snap) {
    final data = snap.data() as Map<String, dynamic>;
    return Student(
      uid: snap.id,
      name: data['name'] as String,
      surname: data['surname'] as String,
      username: data['username'] as String,
      email: data['email'] as String,
      joinedAt: (data['joinedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'name': name,
        'surname': surname,
        'username': username,
        'email': email,
        'joinedAt': Timestamp.fromDate(joinedAt),
      };
}
