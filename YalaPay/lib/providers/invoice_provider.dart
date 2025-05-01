import 'dart:convert';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:quickmart/models/invoice.dart';
import 'package:flutter/services.dart';
import 'package:quickmart/models/payment.dart';

class InvoiceNotifier extends Notifier<List<Invoice>> {
  InvoiceNotifier() {
    _initializeState();
  }

  @override
  List<Invoice> build() {
    return [];
  }

  Future<void> _initializeState() async {
    try {
      final file = await _localFile;
      if (await file.exists()) {
        final data = await file.readAsString();
        final invoicesMap = jsonDecode(data) as List;
        state =
            invoicesMap.map((invoice) => Invoice.fromJson(invoice)).toList();
      } else {
        final data = await rootBundle.loadString('assets/data/invoices.json');
        final invoicesMap = jsonDecode(data) as List;
        state =
            invoicesMap.map((invoice) => Invoice.fromJson(invoice)).toList();
        await _saveToFile();
      }
      print("Data loaded into memory from JSON file.");
    } catch (e) {
      print('Error initializing invoices: $e');
    }
  }

  Future<File> get _localFile async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/invoices.json');
  }

  Future<void> _saveToFile() async {
    try {
      final file = await _localFile;
      final List<Map<String, dynamic>> jsonData =
          state.map((invoice) => invoice.toJson()).toList();
      await file.writeAsString(jsonEncode(jsonData));
      print("Data saved to JSON file.");
    } catch (e) {
      print('Error saving invoices to file: $e');
    }
  }

  void addInvoice(Invoice invoice) {
    state = [...state, invoice];
    _saveToFile();
    _initializeState();
  }

  void updateInvoice(Invoice updatedInvoice) {
    state = state.map((invoice) {
      return invoice.id == updatedInvoice.id ? updatedInvoice : invoice;
    }).toList();
    _saveToFile();
    _initializeState();
  }

  void deleteInvoice(String id) {
    state = state.where((invoice) => invoice.id != id).toList();
    _saveToFile();
    _initializeState();
  }

  List<Invoice> searchInvoices(String query) {
    if (query.isEmpty) {
      return state;
    }
    return state.where((invoice) {
      return invoice.customerName.toLowerCase().contains(query.toLowerCase()) ||
          invoice.id.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  void deleteInvoicesByCustomerId(String customerId) {
    state = state.where((invoice) => invoice.customerId != customerId).toList();
    _saveToFile();
    _initializeState();
  }

  List<Invoice> getInvoicesByCustomerId(String customerId) {
    return state.where((invoice) => invoice.customerId == customerId).toList();
  }

  double getAllPaymentsTotal(String invoiceId, List<Payment> payments) {
    double totalPayments = payments
        .where((payment) => payment.invoiceNo == invoiceId)
        .fold(0.0, (sum, payment) => sum + payment.amount);

    return totalPayments;
  }

  double getBalance(String invoiceId, List<Payment> payments) {
    final invoice = state.firstWhere((i) => i.id == invoiceId);
    double totalPayments = payments
        .where((payment) =>
            payment.invoiceNo == invoiceId && payment.paymentMode != "Cheque")
        .fold(0.0, (sum, payment) => sum + payment.amount);

    return invoice.amount - totalPayments;
  }
}

final invoiceNotifierProvider =
    NotifierProvider<InvoiceNotifier, List<Invoice>>(() => InvoiceNotifier());
