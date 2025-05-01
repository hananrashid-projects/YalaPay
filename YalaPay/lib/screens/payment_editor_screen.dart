import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quickmart/models/cheque.dart';
import 'package:quickmart/models/payment.dart';
import 'package:quickmart/models/chequeTwo.dart';
import 'package:quickmart/providers/cheque_provider.dart';
import 'package:quickmart/providers/payment_provider.dart';
import 'package:quickmart/widgets/custom_app_bar.dart';
import 'package:intl/intl.dart';

class UpdatePaymentScreen extends ConsumerWidget {
  final String? paymentId;
  final String? invoiceId;

  const UpdatePaymentScreen({
    Key? key,
    this.paymentId,
    this.invoiceId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Payment? payment;
    if (paymentId != null) {
      payment = ref.watch(paymentNotifierProvider).firstWhere(
            (p) => p.id == paymentId,
          );
    }

    final isAddMode = payment == null;

    final TextEditingController amountController = TextEditingController(
        text: isAddMode ? '' : payment!.amount.toString());
    String selectedMode = isAddMode ? '' : payment!.paymentMode;
    DateTime selectedDate =
        isAddMode ? DateTime.now() : DateTime.parse(payment!.paymentDate);
    int? chequeNo;
    Cheque? cheque;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        titleText: isAddMode ? 'Add Payment' : 'Update Payment',
        subtitleText:
            isAddMode ? 'Add new payment details' : 'Edit payment details',
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: amountController,
                    label: 'Amount',
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),
                  if (isAddMode)
                    _buildPaymentModeDropdown(selectedMode, (value) async {
                      selectedMode = value!;
                      if (selectedMode == 'Cheque') {
                        final Cheque? newCheque =
                            await _showAddChequeDialog(context, ref);
                        if (newCheque != null) {
                          chequeNo = newCheque.chequeNo;
                        }
                      }
                    })
                  else
                    _buildTextField(
                      controller: TextEditingController(text: selectedMode),
                      label: 'Payment Mode',
                      keyboardType: TextInputType.none,
                    ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () async {
                      final DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                      );
                      if (pickedDate != null) {
                        selectedDate = pickedDate;
                      }
                    },
                    child: AbsorbPointer(
                      child: TextField(
                        decoration: InputDecoration(
                          labelText: 'Payment Date',
                          hintText: "${selectedDate.toLocal()}".split(' ')[0],
                          suffixIcon: const Icon(Icons.calendar_today),
                          fillColor: Colors.grey[300],
                          filled: true,
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Color.fromARGB(0, 162, 162, 163),
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: Color.fromARGB(0, 162, 162, 163),
                                width: 1.0),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (payment?.chequeNo != null)
                    ElevatedButton(
                      onPressed: () {
                        final chequeNo = payment?.chequeNo;
                        if (chequeNo != null) {
                          print("${chequeNo}");
                          _showChequeDetailsDialog(context, ref, chequeNo);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Cheque number not available')),
                          );
                        }
                      },
                      child: const Text('View Cheque Details'),
                    ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 153, 99, 95),
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 115, 159, 196),
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () {
                          if (isAddMode) {
                            final newPayment = Payment(
                              id: UniqueKey().toString(),
                              invoiceNo: invoiceId ?? '',
                              amount:
                                  double.tryParse(amountController.text) ?? 0,
                              paymentDate:
                                  DateFormat('yyyy-MM-dd').format(selectedDate),
                              paymentMode: selectedMode,
                              chequeNo: chequeNo,
                            );

                            ref
                                .read(paymentNotifierProvider.notifier)
                                .addPayment(newPayment);

                            print("Added payment: ${newPayment.id}");
                          } else {
                            final updatedPayment = Payment(
                              id: payment!.id,
                              invoiceNo: payment.invoiceNo,
                              amount:
                                  double.tryParse(amountController.text) ?? 0,
                              paymentDate:
                                  DateFormat('yyyy-MM-dd').format(selectedDate),
                              paymentMode: selectedMode,
                              chequeNo: payment.chequeNo,
                            );

                            ref
                                .read(paymentNotifierProvider.notifier)
                                .updatePayment(updatedPayment);
                            print("Updated payment: ${updatedPayment.id}");
                          }
                          Navigator.of(context).pop();
                        },
                        child: Text(isAddMode ? 'Add' : 'Update'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Widget _buildPaymentModeDropdown(
    String selectedMode, ValueChanged<String?> onChanged) {
  const List<String> paymentModes = [
    "Bank transfer",
    "Credit card",
    "Cheque",
  ];

  return DropdownButtonFormField<String>(
    value: selectedMode.isEmpty ? null : selectedMode,
    items: paymentModes.map((String mode) {
      return DropdownMenuItem<String>(
        value: mode,
        child: Text(mode),
      );
    }).toList(),
    decoration: InputDecoration(
      fillColor: Colors.grey[300],
      filled: true,
      labelText: 'Payment Mode',
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(
          color: Color.fromARGB(0, 162, 162, 163),
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(
            color: Color.fromARGB(0, 162, 162, 163), width: 1.0),
        borderRadius: BorderRadius.circular(10),
      ),
    ),
    onChanged: onChanged,
    hint: const Text('Select Payment Mode'),
  );
}

Future<Cheque?> _showAddChequeDialog(
    BuildContext context, WidgetRef ref) async {
  final TextEditingController amountController = TextEditingController();
  final TextEditingController drawerController = TextEditingController();
  final TextEditingController statusController = TextEditingController();
  final TextEditingController receivedDateController = TextEditingController();
  final TextEditingController dueDateController = TextEditingController();
  final TextEditingController chequeImageUriController =
      TextEditingController();

  DateTime? selectedReceivedDate;
  DateTime? selectedDueDate;

  String selectedBank = '';
  String selectedStatus = '';

  final List<String> bankList = [
    "Qatar National Bank",
    "Doha Bank",
    "Commercial Bank",
    "Qatar International Islamic Bank",
    "Qatar Islamic Bank",
    "Qatar Development Bank",
    "Arab Bank",
    "Ahlibank",
    "Mashreq Bank",
    "HSBC Bank Middle East",
    "BNP Paribas",
    "Bank Saderat Iran",
    "United Bank ltd.",
    "Standard Chartered Bank",
    "Masraf Al Rayan",
    "International Bank of Qatar",
    "Barwa Bank"
  ];

  final List<String> statusList = [
    "Awaiting",
    "Deposited",
    "Cashed",
    "Returned"
  ];

  return showDialog<Cheque?>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Add a New Cheque'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField(
                  controller: amountController,
                  label: 'Amount',
                  keyboardType: TextInputType.number),
              const SizedBox(height: 12),
              _buildTextField(controller: drawerController, label: 'Payee'),
              const SizedBox(height: 12),
              // Bank Dropdown
              _buildDropdown(
                label: 'Bank Name',
                selectedValue: selectedBank,
                options: bankList,
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    selectedBank = newValue;
                  }
                },
              ),
              const SizedBox(height: 12),
              // Status Dropdown
              _buildDropdown(
                label: 'Status',
                selectedValue: selectedStatus,
                options: statusList,
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    selectedStatus = newValue;
                  }
                },
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () async {
                  final DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: selectedReceivedDate ?? DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );
                  if (pickedDate != null) {
                    selectedReceivedDate = pickedDate;
                    receivedDateController.text =
                        DateFormat('yyyy-MM-dd').format(pickedDate);
                  }
                },
                child: AbsorbPointer(
                  child: _buildTextField(
                    controller: receivedDateController,
                    label: 'Received Date',
                    keyboardType: TextInputType.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () async {
                  final DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: selectedDueDate ?? DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );
                  if (pickedDate != null) {
                    selectedDueDate = pickedDate;
                    dueDateController.text =
                        DateFormat('yyyy-MM-dd').format(pickedDate);
                  }
                },
                child: AbsorbPointer(
                  child: _buildTextField(
                    controller: dueDateController,
                    label: 'Due Date',
                    keyboardType: TextInputType.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _buildTextField(
                  controller: chequeImageUriController,
                  label: 'Cheque Image URI'),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              final randomChequeNo = Random().nextInt(1000000);
              final newCheque = Cheque(
                chequeNo: randomChequeNo,
                amount: double.tryParse(amountController.text) ?? 0,
                drawer: drawerController.text,
                bankName: selectedBank,
                status: selectedStatus,
                receivedDate: selectedReceivedDate ?? DateTime.now(),
                dueDate: selectedDueDate ?? DateTime.now(),
                chequeImageUri: chequeImageUriController.text,
              );
              ref.read(chequeProvider.notifier).addCheque(newCheque);
              Navigator.of(context).pop(newCheque);
            },
            child: const Text('Save'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
        ],
      );
    },
  );
}

void _showChequeDetailsDialog(
    BuildContext context, WidgetRef ref, int chequeNo) {
  final cheques = ref.read(chequeProvider);
  final foundCheque = cheques.firstWhere(
    (c) => c.chequeNo == chequeNo,
    orElse: () => Cheque(
        chequeNo: -1,
        amount: 0,
        drawer: '',
        bankName: '',
        status: '',
        receivedDate: DateTime.now(),
        dueDate: DateTime.now(),
        chequeImageUri: ''),
  );

  final TextEditingController amountController =
      TextEditingController(text: foundCheque.amount.toString());
  final TextEditingController drawerController =
      TextEditingController(text: foundCheque.drawer);
  final TextEditingController receivedDateController = TextEditingController(
      text: DateFormat('yyyy-MM-dd').format(foundCheque.receivedDate));
  final TextEditingController dueDateController = TextEditingController(
      text: DateFormat('yyyy-MM-dd').format(foundCheque.dueDate));
  final TextEditingController chequeImageUriController =
      TextEditingController(text: foundCheque.chequeImageUri);

  // Initialize dropdowns with the foundCheque values
  String selectedBank = foundCheque.bankName;
  String selectedStatus = foundCheque.status;

  final List<String> bankList = [
    "Qatar National Bank",
    "Doha Bank",
    "Commercial Bank",
    "Qatar International Islamic Bank",
    "Qatar Islamic Bank",
    "Qatar Development Bank",
    "Arab Bank",
    "Ahlibank",
    "Mashreq Bank",
    "HSBC Bank Middle East",
    "BNP Paribas",
    "Bank Saderat Iran",
    "United Bank ltd.",
    "Standard Chartered Bank",
    "Masraf Al Rayan",
    "International Bank of Qatar",
    "Barwa Bank"
  ];

  final List<String> statusList = [
    "Awaiting",
    "Deposited",
    "Cashed",
    "Returned"
  ];

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('Cheque Details - No: ${foundCheque.chequeNo}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField(
                  controller: amountController,
                  label: 'Amount',
                  keyboardType: TextInputType.number),
              const SizedBox(height: 12),
              _buildTextField(controller: drawerController, label: 'Drawer'),
              const SizedBox(height: 12),
              _buildDropdown(
                label: 'Bank Name',
                selectedValue: selectedBank,
                options: bankList,
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    selectedBank = newValue;
                  }
                },
              ),
              const SizedBox(height: 12),
              _buildDropdown(
                label: 'Status',
                selectedValue: selectedStatus,
                options: statusList,
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    selectedStatus = newValue;
                  }
                },
              ),
              const SizedBox(height: 12),
              _buildTextField(
                  controller: receivedDateController,
                  label: 'Received Date',
                  keyboardType: TextInputType.none),
              const SizedBox(height: 12),
              _buildTextField(
                  controller: dueDateController,
                  label: 'Due Date',
                  keyboardType: TextInputType.none),
              const SizedBox(height: 12),
              _buildTextField(
                  controller: chequeImageUriController,
                  label: 'Cheque Image URI'),
              const SizedBox(height: 12),
              if (foundCheque.chequeImageUri.isNotEmpty)
                Column(
                  children: [
                    const Text('Cheque Image:'),
                    const SizedBox(height: 8),
                    Image.asset(
                      'assets/data/cheques/${foundCheque.chequeImageUri}',
                      height: 150,
                      width: 250,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Text('Image not available');
                      },
                    ),
                  ],
                ),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              final updatedCheque = Cheque(
                chequeNo: foundCheque.chequeNo,
                amount: double.tryParse(amountController.text) ?? 0,
                drawer: drawerController.text,
                bankName: selectedBank,
                status: selectedStatus,
                receivedDate: DateTime.parse(receivedDateController.text),
                dueDate: DateTime.parse(dueDateController.text),
                chequeImageUri: chequeImageUriController.text,
              );

              ref.read(chequeProvider.notifier).updateCheque(updatedCheque);

              Navigator.of(context).pop();
            },
            child: const Text('Save'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Close'),
          ),
        ],
      );
    },
  );
}

Widget _buildTextField({
  required TextEditingController controller,
  required String label,
  TextInputType? keyboardType,
}) {
  return TextField(
    controller: controller,
    keyboardType: keyboardType,
    decoration: InputDecoration(
      fillColor: Colors.grey[300],
      filled: true,
      labelText: label,
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(
          color: Color.fromARGB(0, 162, 162, 163),
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(
            color: Color.fromARGB(0, 162, 162, 163), width: 1.0),
        borderRadius: BorderRadius.circular(10),
      ),
    ),
  );
}

Widget _buildDropdown({
  required String label,
  required String selectedValue,
  required List<String> options,
  required Function(String?) onChanged,
}) {
  String currentSelectedValue =
      options.contains(selectedValue) ? selectedValue : options.first;

  return InputDecorator(
    decoration: InputDecoration(
      labelText: label,
      fillColor: Colors.grey[300],
      filled: true,
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: Colors.grey.withOpacity(0.5),
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: Colors.blue,
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
    ),
    child: DropdownButton<String>(
      value: currentSelectedValue,
      isExpanded: true,
      icon: Icon(Icons.arrow_drop_down),
      underline: SizedBox(),
      onChanged: onChanged,
      items: options.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    ),
  );
}
