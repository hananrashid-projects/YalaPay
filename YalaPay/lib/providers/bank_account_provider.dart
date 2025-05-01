import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:quickmart/models/bank_account.dart';

class BankAccountNotifier extends StateNotifier<List<BankAccount>> {
  BankAccountNotifier() : super([]) {
    loadBankAccounts();
  }

  Future<void> loadBankAccounts() async {
    try {
      final data = await rootBundle.loadString('assets/data/bank-accounts.json');
      final List accountsJson = jsonDecode(data);
      state = accountsJson.map((json) => BankAccount.fromJson(json)).toList();
    } catch (e) {
      print("Error loading bank accounts: $e");
    }
  }
}

final bankAccountProvider = StateNotifierProvider<BankAccountNotifier, List<BankAccount>>((ref) {
  return BankAccountNotifier();
});
