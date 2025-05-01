import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quickmart/models/user.dart';
import 'package:quickmart/repo/user_repository.dart';

class UserNotifier extends StateNotifier<List<User>> {
  final UsersRepository usersRepository;

  UserNotifier(this.usersRepository) : super([]) {
    _initializeState();
  }

  Future<void> _initializeState() async {
    state = await usersRepository.getUsers();
  }

  void addUser(User user) {
    state = [...state, user];
  }

  bool validateCredentials(String email, String password) {
    return usersRepository.validateCredentials(email, password);
  }
}

final userNotifierProvider = StateNotifierProvider<UserNotifier, List<User>>(
  (ref) => UserNotifier(UsersRepository()),
);
