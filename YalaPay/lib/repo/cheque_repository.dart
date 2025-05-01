// lib/repo/cheque_repository.dart

import 'package:flutter/services.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/cheque.dart';

class ChequeRepository {
  Future<String> get _chequesFilePath async {
    final directory = await getApplicationDocumentsDirectory();
    return 'assets/data/cheques.json';
  }

  Future<String> get _depositsFilePath async {
    final directory = await getApplicationDocumentsDirectory();
    return 'assets/data/cheque-deposits.json';
  }

  Future<void> resetData() async {
    final chequesPath = await _chequesFilePath;
    final depositsPath = await _depositsFilePath;

    await File(chequesPath).writeAsString(jsonEncode([]));
    await File(depositsPath).writeAsString(jsonEncode([]));
  }

  Future<List<Cheque>> loadCheques() async {
    try {
      final path = await _chequesFilePath;
      final chequesData = await File(path).readAsString();
      final List chequesJson = jsonDecode(chequesData);
      return chequesJson.map((json) => Cheque.fromJson(json)).toList();
    } catch (e) {
      print("Error loading cheques: $e");
      return [];
    }
  }

  Future<Cheque> getChequeByNumber(int chequeNo) async {
    try {
      final cheques = await loadCheques();
      return cheques.firstWhere(
        (cheque) => cheque.chequeNo == chequeNo,
        orElse: () => Cheque(
          chequeNo: 0,
          amount: 0.0,
          drawer: "Unknown",
          bankName: "Unknown",
          status: "Not Found",
          receivedDate: DateTime.now(),
          dueDate: DateTime.now(),
          chequeImageUri: "assets/images/placeholder.png",
        ),
      );
    } catch (e) {
      print("Error retrieving cheque by number: $e");
      return Cheque(
        chequeNo: 0, // Default values if an error occurs
        amount: 0.0,
        drawer: "Unknown",
        bankName: "Unknown",
        status: "Error",
        receivedDate: DateTime.now(),
        dueDate: DateTime.now(),
        chequeImageUri: "assets/images/placeholder.png", // Default image path
      );
    }
  }

  Future<void> createDeposit(
      List<Cheque> selectedCheques, String bankAccountNo) async {
    final depositDate = DateTime.now();
    final newDepositId = DateTime.now().millisecondsSinceEpoch.toString();
    final selectedChequeNos =
        selectedCheques.map((cheque) => cheque.chequeNo).toList();

    await _updateChequesStatus(selectedChequeNos);

    final newDeposit = {
      "id": newDepositId,
      "depositDate": depositDate.toIso8601String(),
      "bankAccountNo": bankAccountNo,
      "status": "Deposited",
      "chequeNos": selectedChequeNos,
    };
    await _appendDepositToFile(newDeposit);
  }

  // Update the status of selected cheques in cheques.json
  Future<void> _updateChequesStatus(List<int> selectedChequeNos) async {
    try {
      final path = await _chequesFilePath;
      final file = File(path);
      final chequesData = await file.readAsString();
      List chequesJson = jsonDecode(chequesData);

      chequesJson = chequesJson.map((cheque) {
        if (selectedChequeNos.contains(cheque['chequeNo'])) {
          cheque['status'] = "Deposited";
        }
        return cheque;
      }).toList();

      await file.writeAsString(jsonEncode(chequesJson),
          mode: FileMode.write, flush: true);
    } catch (e) {
      print("Error updating cheques.json: $e");
    }
  }

  // Append a new deposit entry to cheque-deposits.json
  Future<void> _appendDepositToFile(Map<String, dynamic> newDeposit) async {
    try {
      final path = await _depositsFilePath;
      final file = File(path);

      // Load existing deposits, append the new deposit, and save back
      final depositsData = await file.readAsString();
      List depositsJson = jsonDecode(depositsData);
      depositsJson.add(newDeposit);

      await file.writeAsString(jsonEncode(depositsJson),
          mode: FileMode.write, flush: true);
    } catch (e) {
      print("Error writing to cheque-deposits.json: $e");
    }
  }

  // Debugging function to check content in the cheques file
  void debugFileContent() async {
    final path = await _chequesFilePath;
    final chequesData = await File(path).readAsString();
    print("Cheques JSON content: $chequesData");
  }

  Future<void> addCheque(Cheque newCheque) async {
    try {
      final path = await _chequesFilePath;
      final file = File(path);
      final chequesData = await file.readAsString();
      List chequesJson = jsonDecode(chequesData);

      chequesJson.add(newCheque
          .toJson()); // Convert newCheque to JSON and add it to the list
      await file.writeAsString(jsonEncode(chequesJson),
          mode: FileMode.write, flush: true);
    } catch (e) {
      print("Error adding cheque: $e");
    }
  }

  // Update an existing cheque in the list
  void updateCheque(List<Cheque> cheques, Cheque updatedCheque) {
    for (int i = 0; i < cheques.length; i++) {
      if (cheques[i].chequeNo == updatedCheque.chequeNo) {
        cheques[i] = updatedCheque;
        break;
      }
    }
  }

  List<Cheque> searchByChequeNo(List<Cheque> cheques, int? chequeNo) {
    if (chequeNo == null) return [];
    return cheques.where((cheque) => cheque.chequeNo == chequeNo).toList();
  }

  Future<void> deleteCheque(int chequeNo) async {
    try {
      final path = await _chequesFilePath;
      final file = File(path);
      final chequesData = await file.readAsString();
      List chequesJson = jsonDecode(chequesData);
      chequesJson.removeWhere((cheque) => cheque['chequeNo'] == chequeNo);
      await file.writeAsString(jsonEncode(chequesJson),
          mode: FileMode.write, flush: true);
    } catch (e) {
      print("Error deleting cheque: $e");
    }
  }
}

// Define the provider
final chequeRepositoryProvider = Provider((ref) => ChequeRepository());
