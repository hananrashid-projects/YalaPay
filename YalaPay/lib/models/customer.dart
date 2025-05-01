import 'package:quickmart/models/address.dart';
import 'package:quickmart/models/contact_details.dart';

class Customer {
  final String id;
  final String companyName;
  final Address address;
  final ContactDetails contactDetails;
  Customer({
    required this.id,
    required this.companyName,
    required this.address,
    required this.contactDetails,
  });
  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'],
      companyName: json['companyName'],
      address: Address.fromJson(json['address']),
      contactDetails: ContactDetails.fromJson(json['contactDetails']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'companyName': companyName,
      'address': address.toJson(),
      'contactDetails': contactDetails.toJson(),
    };
  }
}
