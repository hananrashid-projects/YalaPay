// lib/providers/cheque_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quickmart/repo/cheque_repository.dart';
import '../models/cheque.dart';

class ChequeNotifier extends StateNotifier<List<Cheque>> {
  ChequeNotifier(this._repository) : super([]);

  final ChequeRepository _repository;

  Future<void> resetAndLoadCheques() async {
    await _repository.resetData();
    state = await _repository.loadCheques();
  }

  Future<void> createDeposit(
      List<Cheque> selectedCheques, String bankAccountNo) async {
    await _repository.createDeposit(selectedCheques, bankAccountNo);
    state = await _repository.loadCheques();
  }

  Future<void> addCheque(Cheque newCheque) async {
    await _repository.addCheque(newCheque);
    state = await _repository.loadCheques();
  }

  List<Cheque> getCheques() {
    return state;
  }

  // Update an existing cheque in the list
  void updateCheque(Cheque updatedCheque) {
    _repository.updateCheque(state, updatedCheque);
    state = [...state];
  }

  List<Cheque> searchByChequeNo(int? chequeNo) {
    return _repository.searchByChequeNo(state, chequeNo);
  }
}

final chequeProvider =
    StateNotifierProvider<ChequeNotifier, List<Cheque>>((ref) {
  final repository = ref.watch(chequeRepositoryProvider);
  return ChequeNotifier(repository);
});
