class User {
  final String firstName;
  final String lastName;
  final String email;
  final String password;
  final String username;

  User({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
    required this.username,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'],
      password: json['password'],
      username: json['username'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'password': password,
      'username': username,
    };
  }
}
