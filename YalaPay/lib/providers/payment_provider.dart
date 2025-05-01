import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quickmart/models/payment.dart';
import 'package:quickmart/repo/payment_repository.dart';

final paymentRepository = PaymentRepository();

class PaymentNotifier extends Notifier<List<Payment>> {
  PaymentNotifier() {
    _initializeState();
  }

  @override
  List<Payment> build() {
    return []; // Initial state as an empty list
  }

  Future<void> _initializeState() async {
    final payments = await paymentRepository.loadPayments();
    state = payments;
  }

  // Add a new payment and save the updated list
  void addPayment(Payment payment) async {
    state = [...state, payment];
    await paymentRepository.savePayments(state);
  }

  // Update an existing payment and save the updated list
  void updatePayment(Payment updatedPayment) async {
    state = state.map((payment) {
      return payment.id == updatedPayment.id ? updatedPayment : payment;
    }).toList();
    await paymentRepository.savePayments(state);
  }

  // Delete a specific payment by ID and save the updated list
  void deletePayment(String id) async {
    state = state.where((payment) => payment.id != id).toList();
    await paymentRepository.savePayments(state);
  }

  // Clear all payments and save the updated empty list
  void deleteAllPayments() async {
    state = [];
    await paymentRepository.savePayments(state);
  }

  Payment? getPaymentById(String id) {
    return state.firstWhere((payment) => payment.id == id);
  }

  void deletePaymentsByInvoice(String invoiceId) async {
    state = state.where((payment) => payment.invoiceNo != invoiceId).toList();
    await paymentRepository.savePayments(state);
  }

  List<Payment> getFilteredPayments(String query, String? selectedInvoiceId) {
    return state.where((payment) {
      final matchesInvoice =
          selectedInvoiceId == null || payment.invoiceNo == selectedInvoiceId;
      final matchesQuery = query.isEmpty ||
          payment.invoiceNo.toLowerCase().contains(query.toLowerCase()) ||
          payment.amount
              .toString()
              .toLowerCase()
              .contains(query.toLowerCase()) ||
          payment.paymentMode.toLowerCase().contains(query.toLowerCase());
      return matchesInvoice && matchesQuery;
    }).toList();
  }

  // Load payment modes through the repository
  Future<List<String>> loadPaymentModes() async {
    return await paymentRepository.loadPaymentModes();
  }
}

final paymentNotifierProvider =
    NotifierProvider<PaymentNotifier, List<Payment>>(() => PaymentNotifier());
