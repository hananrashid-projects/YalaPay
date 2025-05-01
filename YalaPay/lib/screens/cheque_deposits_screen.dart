import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quickmart/models/cheque.dart';
import 'package:quickmart/repo/cheque_repository.dart';
import 'package:quickmart/repo/deposits_repository.dart';

class ChequeDepositsScreen extends StatefulWidget {
  const ChequeDepositsScreen({super.key});

  @override
  _ChequeDepositsScreenState createState() => _ChequeDepositsScreenState();
}

class _ChequeDepositsScreenState extends State<ChequeDepositsScreen> {
  final DepositsRepository depositsRepository = DepositsRepository();
  final ChequeRepository chequeRepository = ChequeRepository();

  Future<List<Map<String, dynamic>>>? depositsFuture;

  @override
  void initState() {
    super.initState();
    loadDeposits();
  }

  void loadDeposits() {
    setState(() {
      depositsFuture = depositsRepository.loadDeposits(); // Refresh data
    });
  }

  @override
  Widget build(BuildContext context) {
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
              child: Center(
                child: Text(
                  'Cheque Deposits',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF915050),
                  ),
                ),
              ),
            ),
          ),
          // Body with FutureBuilder for fetching deposits
          Positioned(
            top: MediaQuery.of(context).size.height / 5.5,
            left: 0,
            right: 0,
            child: Container(
              height: MediaQuery.of(context).size.height / 1.5,
              color: Color(0xFFFEFFF7),
              padding: EdgeInsets.all(20),
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: depositsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text("Error loading deposits"));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text("No deposits available"));
                  }

                  final deposits = snapshot.data!;
                  return ListView.builder(
                    itemCount: deposits.length,
                    itemBuilder: (context, index) {
                      final deposit = deposits[index];
                      final chequeNos =
                          List<int>.from(deposit['chequeNos'] ?? []);
                      final DateTime parsedDate =
                          DateTime.parse(deposit["depositDate"]);
                      final String depositDate =
                          "${parsedDate.day.toString().padLeft(2, '0')}/${parsedDate.month.toString().padLeft(2, '0')}/${parsedDate.year}";

                      return FutureBuilder<List<Cheque>>(
                        future: Future.wait(chequeNos.map(
                            (no) => chequeRepository.getChequeByNumber(no))),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          }

                          final cheques = snapshot.data ?? [];
                          final totalAmount = cheques.fold(
                              0.0, (sum, cheque) => sum + cheque.amount);

                          return Card(
                            margin: EdgeInsets.symmetric(vertical: 10),
                            child: ExpansionTile(
                              title: Text(
                                'Deposit ID: ${deposit["id"]}',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.brown[800]),
                              ),
                              subtitle: Text(
                                'Date: $depositDate\nTotal Amount: \$${totalAmount.toStringAsFixed(2)} - Cheques Count: ${cheques.length}',
                                style: TextStyle(color: Colors.brown[600]),
                              ),
                              children: [
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount: cheques.length,
                                  itemBuilder: (context, chequeIndex) {
                                    final cheque = cheques[chequeIndex];
                                    return ListTile(
                                      leading: cheque.chequeImageUri != null
                                          ? Image.asset(
                                              'assets/data/cheques/${cheque.chequeImageUri}',
                                              width: 50,
                                              height: 50,
                                              fit: BoxFit.cover,
                                            )
                                          : Icon(Icons.image_not_supported,
                                              color: Colors.grey),
                                      title:
                                          Text('Cheque No: ${cheque.chequeNo}'),
                                      subtitle:
                                          Text('Amount: \$${cheque.amount}'),
                                    );
                                  },
                                ),
                                OverflowBar(
                                  alignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    ElevatedButton(
                                      onPressed: () async {
                                        final returnReasons =
                                            await depositsRepository
                                                .loadReturnReasons();
                                        _showUpdateDialog(context,
                                            deposit["id"], returnReasons);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.orangeAccent,
                                      ),
                                      child: Text('Update Status'),
                                    ),
                                    ElevatedButton.icon(
                                      onPressed: () async {
                                        await depositsRepository
                                            .deleteDeposit(deposit["id"]);
                                        loadDeposits(); // Reload data after deletion
                                      },
                                      icon: Icon(Icons.delete),
                                      label: Text('Delete'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.redAccent,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showUpdateDialog(
      BuildContext context, String depositId, List<String> returnReasons) {
    String selectedStatus = "Cashed";
    DateTime cashedDate = DateTime.now();
    DateTime? returnDate;
    String? selectedReturnReason;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text("Update Deposit Status"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: selectedStatus,
                    items: ["Cashed", "Cashed with Returns"].map((status) {
                      return DropdownMenuItem(
                          value: status, child: Text(status));
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedStatus = value!;
                      });
                    },
                  ),
                  SizedBox(height: 10),
                  TextButton.icon(
                    icon: Icon(Icons.calendar_today),
                    onPressed: () async {
                      final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: cashedDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now(),
                      );
                      if (pickedDate != null) {
                        setState(() {
                          cashedDate = pickedDate;
                        });
                      }
                    },
                    label: Text(
                        "Cashing Date: ${cashedDate.toLocal()}".split(' ')[0]),
                  ),
                  if (selectedStatus == "Cashed with Returns") ...[
                    SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      hint: Text("Select Return Reason"),
                      items: returnReasons.map((reason) {
                        return DropdownMenuItem(
                            value: reason, child: Text(reason));
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedReturnReason = value;
                        });
                      },
                    ),
                    SizedBox(height: 10),
                    TextButton.icon(
                      icon: Icon(Icons.calendar_today),
                      onPressed: () async {
                        final pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime.now(),
                        );
                        if (pickedDate != null) {
                          setState(() {
                            returnDate = pickedDate;
                          });
                        }
                      },
                      label: Text(
                        returnDate == null
                            ? "Select Return Date"
                            : "Return Date: ${returnDate!.toLocal()}"
                                .split(' ')[0],
                      ),
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () async {
                    await depositsRepository.updateDepositStatus(
                      depositId,
                      selectedStatus,
                      cashedDate: cashedDate,
                      returnDate: returnDate,
                      returnReason: selectedReturnReason,
                    );
                    Navigator.pop(context);
                    loadDeposits(); // Reload data after updating status
                  },
                  child: Text("Update"),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
