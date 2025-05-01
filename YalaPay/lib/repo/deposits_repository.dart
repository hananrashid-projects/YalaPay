import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DepositsRepository {
  Future<String> get _depositsFilePath async {
    final directory = await getApplicationDocumentsDirectory();
    return 'assets/data/cheque-deposits.json';
  }

  Future<String> get _chequesFilePath async {
    final directory = await getApplicationDocumentsDirectory();
    return 'assets/data/cheques.json';
  }

  Future<String> get _returnReasonsFilePath async {
    final directory = await getApplicationDocumentsDirectory();
    return 'assets/data/return-reasons.json';
  }

  // Load all deposits from the JSON file
  Future<List<Map<String, dynamic>>> loadDeposits() async {
    try {
      final path = await _depositsFilePath;
      final depositsData = await File(path).readAsString();
      return List<Map<String, dynamic>>.from(jsonDecode(depositsData));
    } catch (e) {
      print("Error loading deposits: $e");
      return [];
    }
  }

  // Load return reasons from JSON file
  Future<List<String>> loadReturnReasons() async {
    try {
      final path = await _returnReasonsFilePath;
      final reasonsData = await File(path).readAsString();
      return List<String>.from(jsonDecode(reasonsData));
    } catch (e) {
      print("Error loading return reasons: $e");
      return [];
    }
  }

  // Delete a deposit by ID
  Future<void> deleteDeposit(String id) async {
    try {
      final path = await _depositsFilePath;
      final file = File(path);
      final depositsData = await file.readAsString();
      List depositsJson = jsonDecode(depositsData);

      depositsJson.removeWhere((deposit) => deposit['id'] == id);

      await file.writeAsString(jsonEncode(depositsJson), mode: FileMode.write, flush: true);
    } catch (e) {
      print("Error deleting deposit: $e");
    }
  }

  // Update deposit status with optional cashed date, return date, and return reason
  Future<void> updateDepositStatus(String id, String status, {DateTime? cashedDate, DateTime? returnDate, String? returnReason}) async {
    try {
      final depositsPath = await _depositsFilePath;
      final chequesPath = await _chequesFilePath;

      // Update deposit status
      final depositsFile = File(depositsPath);
      final depositsData = await depositsFile.readAsString();
      List depositsJson = jsonDecode(depositsData);

      List<int> chequeNos = [];

      for (var deposit in depositsJson) {
        if (deposit['id'] == id) {
          deposit['status'] = status;
          deposit['cashedDate'] = cashedDate?.toIso8601String();
          
          if (status == "Cashed with Returns") {
            deposit['returnDate'] = returnDate?.toIso8601String();
            deposit['returnReason'] = returnReason;
          } else {
            deposit.remove('returnDate');
            deposit.remove('returnReason');
          }

          // Collect cheque numbers from the deposit
          chequeNos = List<int>.from(deposit['chequeNos'] ?? []);
          break;
        }
      }

      // Save updated deposits data
      await depositsFile.writeAsString(jsonEncode(depositsJson), mode: FileMode.write, flush: true);

      // Update the status of each cheque in cheques.json
      await _updateChequesStatus(chequesPath, chequeNos, status);
    } catch (e) {
      print("Error updating deposit status: $e");
    }
  }

  // Update the status of all cheques in cheques.json associated with a given deposit
  Future<void> _updateChequesStatus(String chequesPath, List<int> chequeNos, String status) async {
    try {
      final chequesFile = File(chequesPath);
      final chequesData = await chequesFile.readAsString();
      List chequesJson = jsonDecode(chequesData);

      // Update each cheque associated with the deposit
      chequesJson = chequesJson.map((cheque) {
        if (chequeNos.contains(cheque['chequeNo'])) {
          cheque['status'] = status == "Cashed" ? "Cashed" : "Returned";
        }
        return cheque;
      }).toList();

      // Write updated data back to the cheques file
      await chequesFile.writeAsString(jsonEncode(chequesJson), mode: FileMode.write, flush: true);
    } catch (e) {
      print("Error updating cheques status: $e");
    }
  }
}

// Define the provider for DepositsRepository
final depositsRepositoryProvider = Provider((ref) => DepositsRepository());
