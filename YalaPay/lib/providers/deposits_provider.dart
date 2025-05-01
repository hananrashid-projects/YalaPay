import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quickmart/repo/deposits_repository.dart';

// StateNotifier for managing deposits state
class DepositsNotifier extends StateNotifier<List<Map<String, dynamic>>> {
  final DepositsRepository depositsRepository;

  DepositsNotifier(this.depositsRepository) : super([]) {
    loadDeposits(); // Load deposits initially
  }

  // Load deposits from the repository and update the state
  Future<void> loadDeposits() async {
    final deposits = await depositsRepository.loadDeposits();
    state = deposits;
  }

  // Delete a deposit by ID, update the repository and state
  Future<void> deleteDeposit(String id) async {
    await depositsRepository.deleteDeposit(id);
    // Remove the deleted deposit from the state
    state = state.where((deposit) => deposit['id'] != id).toList();
  }

  // Update the status of a deposit (e.g., Cashed or Cashed with Returns)
  Future<void> updateDepositStatus(String id, String status, {DateTime? cashedDate, DateTime? returnDate, String? returnReason}) async {
    // Call the repository to update the deposit status
    await depositsRepository.updateDepositStatus(id, status, cashedDate: cashedDate, returnDate: returnDate, returnReason: returnReason);
    // Refresh the deposits to reflect the updated state
    await loadDeposits();
  }

  // Refresh deposits from the repository
  Future<void> refreshDeposits() async {
    await loadDeposits();
  }
}

// Provider for managing deposits state
final depositsProvider = StateNotifierProvider<DepositsNotifier, List<Map<String, dynamic>>>((ref) {
  final depositsRepository = ref.watch(depositsRepositoryProvider);
  return DepositsNotifier(depositsRepository);
});
