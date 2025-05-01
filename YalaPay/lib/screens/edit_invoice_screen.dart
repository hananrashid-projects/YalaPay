import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quickmart/models/invoice.dart';
import 'package:quickmart/providers/customer_provider.dart';
import 'package:quickmart/providers/invoice_provider.dart';
import 'package:quickmart/providers/payment_provider.dart';

class InvoiceEditor extends ConsumerStatefulWidget {
  const InvoiceEditor({super.key, required this.invoiceId});
  final String? invoiceId;

  @override
  ConsumerState<InvoiceEditor> createState() => _InvoiceEditorState();
}

class _InvoiceEditorState extends ConsumerState<InvoiceEditor> {
  bool validData = true;
  String selectedCustomerName = '';
  Future<void> _selectDate(
      BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      controller.text = '${picked.toLocal()}'.split(' ')[0];
    }
  }

  @override
  Widget build(BuildContext context) {
    final payments = ref.watch(paymentNotifierProvider.notifier);
    final invoices = ref.watch(invoiceNotifierProvider);
    final customers = ref.watch(customerNotifierProvider);
    final index = invoices.indexWhere((i) => i.id == widget.invoiceId);
    final invoice = index == -1 ? null : invoices[index];
    final invoicesNof = ref.watch(invoiceNotifierProvider);
    final invoicesNotifier = ref.watch(invoiceNotifierProvider.notifier);
    final TextEditingController amountController =
        TextEditingController(text: invoice?.amount.toString() ?? '');
    final TextEditingController invoiceDateController =
        TextEditingController(text: invoice?.invoiceDate ?? '');
    final TextEditingController dueDateController =
        TextEditingController(text: invoice?.dueDate ?? '');

    if (invoice != null && selectedCustomerName.isEmpty) {
      selectedCustomerName = invoice.customerName;
    }

    String getCustomerId(String customerName) {
      try {
        final customer =
            customers.firstWhere((c) => c.companyName == customerName);
        return customer.id;
      } catch (e) {
        return '';
      }
    }

    String generateInvoiceId() {
      int newId = 1;

      if (invoices.isNotEmpty) {
        final maxId = invoices
            .map((invoice) => int.tryParse(invoice.id) ?? 0)
            .reduce((value, element) => value > element ? value : element);

        newId = maxId + 1;
        while (invoices.any((invoice) => invoice.id == newId.toString())) {
          newId++;
        }
      }

      return newId.toString();
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(120),
        child: Stack(
          children: [
            Container(
              height: 105,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/background.PNG'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            AppBar(
              automaticallyImplyLeading: false,
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,
              title: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  const Text(
                    'Invoice Editor',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF915050),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: selectedCustomerName.isEmpty
                        ? null
                        : selectedCustomerName,
                    items: customers.map((customer) {
                      return DropdownMenuItem<String>(
                        value: customer.companyName,
                        child: Text(customer.companyName),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedCustomerName = value ?? '';
                      });
                      print("Selected customer: $value");
                    },
                    decoration: InputDecoration(
                      labelText: 'Select Customer',
                      fillColor: Colors.grey[300],
                      filled: true,
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                            color: Color.fromARGB(0, 162, 162, 163)),
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
                  const SizedBox(height: 12),
                  TextField(
                    controller: amountController,
                    decoration: InputDecoration(
                      fillColor: Colors.grey[300],
                      filled: true,
                      labelText: 'Amount',
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                            color: Color.fromARGB(0, 162, 162, 163)),
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
                  const SizedBox(height: 12),
                  TextField(
                    controller: invoiceDateController,
                    decoration: InputDecoration(
                      fillColor: Colors.grey[300],
                      filled: true,
                      labelText: 'Invoice Date',
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                            color: Color.fromARGB(0, 162, 162, 163)),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                            color: Color.fromARGB(0, 162, 162, 163),
                            width: 1.0),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onTap: () => _selectDate(context, invoiceDateController),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: dueDateController,
                    decoration: InputDecoration(
                      fillColor: Colors.grey[300],
                      filled: true,
                      labelText: 'Due Date',
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                            color: Color.fromARGB(0, 162, 162, 163)),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                            color: Color.fromARGB(0, 162, 162, 163),
                            width: 1.0),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onTap: () => _selectDate(context, dueDateController),
                  ),
                  const SizedBox(height: 12),
                  if (!validData)
                    const Column(
                      children: [
                        SizedBox(height: 12),
                        Text(
                          'All fields are required.',
                          style: TextStyle(
                              color: Colors.red, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  const SizedBox(height: 12),
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
                      if (invoice != null)
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromARGB(255, 115, 159, 196),
                              foregroundColor: Colors.white),
                          onPressed: () {
                            ref
                                .read(invoiceNotifierProvider.notifier)
                                .updateInvoice(
                                  Invoice(
                                    id: invoice.id,
                                    customerId:
                                        getCustomerId(selectedCustomerName),
                                    customerName: selectedCustomerName,
                                    amount: double.parse(amountController.text),
                                    invoiceDate: invoiceDateController.text,
                                    dueDate: dueDateController.text,
                                  ),
                                );
                            print(
                                "Customer Name: ${selectedCustomerName} ID: ${getCustomerId(selectedCustomerName)}");
                            Navigator.of(context).pop();
                          },
                          child: const Text('Update'),
                        ),
                      if (invoice == null)
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 143, 176, 156),
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () {
                            ref
                                .read(invoiceNotifierProvider.notifier)
                                .addInvoice(Invoice(
                                  id: generateInvoiceId(),
                                  customerId:
                                      getCustomerId(selectedCustomerName),
                                  customerName: selectedCustomerName,
                                  amount: double.parse(amountController.text),
                                  invoiceDate: invoiceDateController.text,
                                  dueDate: dueDateController.text,
                                ));
                            print("Customer Name: ${selectedCustomerName}");
                            Navigator.of(context).pop();
                          },
                          child: const Text('Add'),
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
