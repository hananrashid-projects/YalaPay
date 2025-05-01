// lib/screens/manage_cashings_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quickmart/repo/cheque_repository.dart';
import 'package:quickmart/models/cheque.dart';
import 'package:quickmart/providers/bank_account_provider.dart';
import 'package:quickmart/models/bank_account.dart';
import 'package:go_router/go_router.dart';

class ManageCashingsScreen extends ConsumerStatefulWidget {
  const ManageCashingsScreen({super.key});

  @override
  _ManageCashingsScreenState createState() => _ManageCashingsScreenState();
}

class _ManageCashingsScreenState extends ConsumerState<ManageCashingsScreen> {
  Set<int> selectedChequeNumbers = {};
  BankAccount? selectedBankAccount;

  @override
  Widget build(BuildContext context) {
    final chequeRepository = ref.read(chequeRepositoryProvider);
    final bankAccounts = ref.watch(bankAccountProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFFEFFF7),
      body: Stack(
        children: [
          // Header
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: MediaQuery.of(context).size.height / 7.5,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/background.PNG'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Manage Cashing',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF915050),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Select cheques to deposit',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF915050).withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height / 3.4,
            left: 0,
            right: 0,
            child: ClipPath(
              child: Container(
                height: MediaQuery.of(context).size.height / 1.5,
                color: Color(0xFFFEFFF7),
                padding: EdgeInsets.all(30),
                child: FutureBuilder<List<Cheque>>(
                  future: chequeRepository.loadCheques(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text("Error loading cheques"));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(child: Text("No cheques available"));
                    }

                    final cheques = snapshot.data!;

                    return Column(
                      children: [
                        Expanded(
                          child: ListView.builder(
                            itemCount: cheques.length,
                            itemBuilder: (context, index) {
                              final cheque = cheques[index];
                              final daysRemaining = cheque.dueDate
                                  .difference(DateTime.now())
                                  .inDays;

                              return CheckboxListTile(
                                title: Text(
                                  "Cheque No: ${cheque.chequeNo}",
                                  style: TextStyle(
                                    color: Color(0xFF915050),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(
                                  "Status: ${cheque.status}\nDue Date: ${cheque.dueDate.toLocal()} (${daysRemaining >= 0 ? '+' : ''}$daysRemaining days)",
                                  style: TextStyle(
                                    color: cheque.status == "Deposited"
                                        ? Colors.grey
                                        : (daysRemaining >= 0
                                            ? Colors.green
                                            : Colors.red),
                                  ),
                                ),
                                value: selectedChequeNumbers
                                    .contains(cheque.chequeNo),
                                onChanged: cheque.status == "Deposited"
                                    ? null
                                    : (bool? value) {
                                        setState(() {
                                          if (value == true) {
                                            selectedChequeNumbers
                                                .add(cheque.chequeNo);
                                          } else {
                                            selectedChequeNumbers
                                                .remove(cheque.chequeNo);
                                          }
                                        });
                                      },
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                              );
                            },
                          ),
                        ),
                        DropdownButton<BankAccount>(
                          hint: Text("Select Bank Account"),
                          value: selectedBankAccount,
                          onChanged: (BankAccount? newAccount) {
                            setState(() {
                              selectedBankAccount = newAccount;
                            });
                          },
                          items: bankAccounts.map((account) {
                            return DropdownMenuItem(
                              value: account,
                              child: Text(
                                  '${account.bank} - ${account.accountNo}'),
                            );
                          }).toList(),
                        ),
                        SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                              onPressed: selectedBankAccount == null ||
                                      selectedChequeNumbers.isEmpty
                                  ? null
                                  : () async {
                                      final selectedCheques = cheques
                                          .where((cheque) =>
                                              selectedChequeNumbers
                                                  .contains(cheque.chequeNo))
                                          .toList();
                                      await chequeRepository.createDeposit(
                                        selectedCheques,
                                        selectedBankAccount!.accountNo,
                                      );
                                      setState(() {
                                        selectedChequeNumbers.clear();
                                      });
                                      ref.refresh(chequeRepositoryProvider);
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.brown[400],
                                padding: EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              child: Text(
                                "Create Deposit",
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Color.fromARGB(255, 250, 250, 250),
                                ),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                GoRouter.of(context).go('/chequeDeposits');
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.brown[400],
                                padding: EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              child: Text(
                                "View Deposits",
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Color.fromARGB(255, 250, 250, 250),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
