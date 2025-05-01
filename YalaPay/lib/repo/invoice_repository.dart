import 'dart:convert';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:quickmart/models/payment.dart';
import '../models/invoice.dart';

class InvoiceRepository {
  Future<String> get _invoicesFilePath async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/invoices.json';
  }

  Future<String> get _paymentsFilePath async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/payments.json';
  }

  Future<void> resetData() async {
    final path = await _invoicesFilePath;
    await File(path).writeAsString(jsonEncode([]));
  }

  Future<List<Invoice>> loadInvoices() async {
    try {
      final path = await _invoicesFilePath;
      final invoicesData = await File(path).readAsString();
      final List invoicesJson = jsonDecode(invoicesData);
      return invoicesJson.map((json) => Invoice.fromJson(json)).toList();
    } catch (e) {
      print("Error loading invoices: $e");
      return [];
    }
  }

  Future<List<Payment>> loadPayments() async {
    try {
      final path = await _paymentsFilePath;
      final paymentsData = await File(path).readAsString();
      final List paymentsJson = jsonDecode(paymentsData);
      return paymentsJson.map((json) => Payment.fromJson(json)).toList();
    } catch (e) {
      print("Error loading payments: $e");
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getInvoicesByStatus() async {
    List<Invoice> invoices = await loadInvoices();
    List<Payment> payments = await loadPayments();

    List<Map<String, dynamic>> invoiceStatusList = [];
    for (var invoice in invoices) {
      double totalPayments = payments
          .where((payment) => payment.invoiceNo == invoice.id)
          .fold(0.0, (sum, payment) => sum + payment.amount);

      double balance = invoice.amount - totalPayments;
      String status;

      if (balance == 0) {
        status = "Paid";
      } else if (balance < invoice.amount) {
        status = "Partially Paid";
      } else {
        status = "Pending";
      }

      invoiceStatusList.add({
        'invoice': invoice,
        'status': status,
        'paymentsTotal': totalPayments.toStringAsFixed(2),
        'balance': balance.toStringAsFixed(2),
        'invoiceAmount': invoice.amount.toStringAsFixed(2),
      });
    }

    return invoiceStatusList;
  }

  Future<void> addInvoice(Invoice invoice) async {
    try {
      final invoices = await loadInvoices();
      invoices.add(invoice);
      await saveInvoices(invoices);
    } catch (e) {
      print("Error adding invoice: $e");
    }
  }

  Future<void> saveInvoices(List<Invoice> invoices) async {
    try {
      final path = await _invoicesFilePath;
      final invoicesJson = invoices.map((invoice) => invoice.toJson()).toList();
      await File(path).writeAsString(jsonEncode(invoicesJson), flush: true);
    } catch (e) {
      print("Error saving invoices: $e");
    }
  }

  Future<void> updateInvoice(Invoice updatedInvoice) async {
    try {
      final invoices = await loadInvoices();
      final index =
          invoices.indexWhere((invoice) => invoice.id == updatedInvoice.id);
      if (index != -1) {
        invoices[index] = updatedInvoice;
        await saveInvoices(invoices);
      } else {
        print("Invoice not found for update");
      }
    } catch (e) {
      print("Error updating invoice: $e");
    }
  }

  Future<void> deleteInvoice(String id) async {
    try {
      final invoices = await loadInvoices();
      final updatedInvoices =
          invoices.where((invoice) => invoice.id != id).toList();
      await saveInvoices(updatedInvoices);
    } catch (e) {
      print("Error deleting invoice: $e");
    }
  }

  Future<void> revertChanges() async {
    await loadInvoices();
    print("Changes have been reverted to the last saved state.");
  }
}

final invoiceRepositoryProvider = Provider((ref) => InvoiceRepository());
