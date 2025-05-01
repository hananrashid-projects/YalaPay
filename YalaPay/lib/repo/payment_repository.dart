import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:quickmart/models/payment.dart';

class PaymentRepository {
  Future<String> _getPaymentsFilePath() async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/payments.json';
  }

  Future<List<Payment>> loadPayments() async {
    try {
      final path = await _getPaymentsFilePath();
      final file = File(path);

      if (!(await file.exists())) {
        final assetData =
            await rootBundle.loadString('assets/data/payments.json');
        await file.writeAsString(assetData);
      }

      final data = await file.readAsString();
      final List<dynamic> paymentsMap = jsonDecode(data);
      return paymentsMap.map((payment) => Payment.fromJson(payment)).toList();
    } catch (e) {
      print('Error loading payments: $e');
      return [];
    }
  }

  Future<void> savePayments(List<Payment> payments) async {
    try {
      final path = await _getPaymentsFilePath();
      final file = File(path);
      final data =
          jsonEncode(payments.map((payment) => payment.toJson()).toList());
      await file.writeAsString(data);
    } catch (e) {
      print('Error saving payments: $e');
    }
  }

  Future<List<String>> loadPaymentModes() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/payment-modes.json');
      if (!(await file.exists())) {
        final assetData =
            await rootBundle.loadString('assets/payment-modes.json');
        await file.writeAsString(assetData);
      }

      final data = await file.readAsString();
      final Map<String, dynamic> parsed = jsonDecode(data);
      return List<String>.from(parsed['payment_modes']);
    } catch (e) {
      print('Error loading payment modes: $e');
      return [];
    }
  }
}
