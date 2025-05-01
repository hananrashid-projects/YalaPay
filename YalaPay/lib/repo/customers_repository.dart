import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart'; // To read assets if needed
import 'package:quickmart/models/customer.dart';

class CustomersRepository {
  List<Customer> customers = [];

  // Get the file path to store and read the customers data
  Future<String> get _customersFilePath async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/customers.json';
  }

  // Load customers from the local file or create a default one if not found
  Future<void> loadCustomers() async {
    try {
      final path = await _customersFilePath;
      final file = File(path);

      if (await file.exists()) {
        var response = await file.readAsString();
        List<dynamic> jsonData = jsonDecode(response);
        customers = jsonData.map((item) => Customer.fromJson(item)).toList();
      } else {
        // If file does not exist, initialize with an empty list
        customers = [];
      }
    } catch (e) {
      print('Error loading customers: $e');
    }
  }

  // Save the customers list to the local file
  Future<void> _saveCustomersToFile() async {
    try {
      final path = await _customersFilePath;
      final file = File(path);
      await file.writeAsString(jsonEncode(customers),
          mode: FileMode.write, flush: true);
    } catch (e) {
      print('Error saving customers to file: $e');
    }
  }

  // Get all customers
  List<Customer> getAllCustomers() {
    return customers;
  }

  // Search customers based on a query
  List<Customer> getCustomers(String query) {
    return customers
        .where((customer) =>
            '${customer.contactDetails.firstName} ${customer.contactDetails.lastName}'
                .toLowerCase()
                .contains(query.toLowerCase()))
        .toList();
  }

  // Add a new customer
  void addCustomer(Customer customer) {
    customers.add(customer);
    _saveCustomersToFile(); // Save to file after adding
  }

  // Update an existing customer
  void updateCustomer(Customer customer) {
    int index = customers.indexWhere((c) => c.id == customer.id);
    if (index != -1) {
      customers[index] = customer;
      _saveCustomersToFile(); // Save to file after updating
    }
  }

  // Remove a customer
  void removeCustomer(Customer customer) {
    customers.removeWhere((c) => c.id == customer.id);
    _saveCustomersToFile(); // Save to file after removal
  }
}
