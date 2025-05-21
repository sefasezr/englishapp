import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/student.dart';
import '../repository/student_repository.dart';

final userServiceProvider = Provider<UserService>((ref) {
  final repo = ref.watch(userRepositoryProvider);
  return UserService(userRepository: repo);
});

class UserService {
  final UserRepository userRepository;
  UserService({required this.userRepository});

  Future<void> createStudent(Student student) {
    return userRepository.createStudent(student);
  }

  Future<void> addUnknownWord(String wordId) {
    return userRepository.addUnknownWord(wordId);
  }
}
