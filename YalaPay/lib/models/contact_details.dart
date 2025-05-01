class ContactDetails {
  final String firstName;
  final String lastName;
  final String email;
  final String mobile;

  ContactDetails({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.mobile,
  });

  factory ContactDetails.fromJson(Map<String, dynamic> json) {
    return ContactDetails(
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'],
      mobile: json['mobile'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'mobile': mobile,
    };
  }
}
