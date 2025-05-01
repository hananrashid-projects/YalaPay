import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:quickmart/models/user.dart';

class UsersRepository {
  List<User> users = [];

  Future<List<User>> getUsers() async {
    var response = await rootBundle.loadString('assets/data/users.json');
    List<dynamic> jsonData = jsonDecode(response);
    users = jsonData.map((item) => User.fromJson(item)).toList();
    return users;
  }

  bool validateCredentials(String email, String password) {
    return users
        .any((user) => user.email == email && user.password == password);
  }
}
