import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quickmart/models/customer.dart';
import 'package:quickmart/repo/customers_repository.dart';

class CustomersNotifier extends Notifier<List<Customer>> {
  final CustomersRepository _customersRepository = CustomersRepository();

  @override
  List<Customer> build() {
    _loadCustomers();
    return [];
  }

  // Load the customers from the repository
  Future<void> _loadCustomers() async {
    await _customersRepository.loadCustomers();
    state = _customersRepository.getAllCustomers();
  }

  // Search customers based on the query
  void getCustomers(String query) {
    state = _customersRepository.getCustomers(query);
  }

  // Add a new customer
  void addCustomer(Customer customer) {
    _customersRepository.addCustomer(customer);
    state = List.from(_customersRepository.getAllCustomers());
  }

  // Update an existing customer
  void updateCustomer(Customer customer) {
    _customersRepository.updateCustomer(customer);
    state = List.from(_customersRepository.getAllCustomers());
  }

  // Remove a customer
  void removeCustomer(Customer customer) {
    _customersRepository.removeCustomer(customer);
    state = List.from(_customersRepository.getAllCustomers());
  }
}

final customerNotifierProvider =
    NotifierProvider<CustomersNotifier, List<Customer>>(
        () => CustomersNotifier());
