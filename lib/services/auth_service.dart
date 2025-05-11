import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repository/auth_repository.dart';

final authServiceProvider = Provider(
  (ref) => ref.watch(authRepositoryProvider),
);

class AuthService {
  final AuthRepository authRepository;

  AuthService({required this.authRepository});

  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return authRepository.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signUpWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return authRepository.signUpWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<User?> signInWithGoogle() async {
    return await authRepository.signInWithGoogle();
  }

  Future<void> signOut() async {
    return authRepository.signOut();
  }
}
