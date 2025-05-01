import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quickmart/models/payment.dart';
import 'package:quickmart/providers/invoice_provider.dart';
import 'package:quickmart/providers/payment_provider.dart';
import 'package:quickmart/widgets/custom_app_bar.dart';
import 'package:quickmart/screens/payment_editor_screen.dart';

class PaymentsScreen extends ConsumerStatefulWidget {
  const PaymentsScreen({super.key});

  @override
  ConsumerState<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends ConsumerState<PaymentsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String? selectedInvoiceId;
  double screenWidth = 0;
  int columns = 1;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    screenWidth = MediaQuery.of(context).size.width;
    columns = switch (screenWidth) {
      < 840 => 1,
      >= 840 && < 1150 => 2,
      _ => 3,
    };
  }

  @override
  Widget build(BuildContext context) {
    final invoices = ref.watch(invoiceNotifierProvider);
    final payments = ref.watch(paymentNotifierProvider);

    final filteredPayments = payments.where((payment) {
      final matchesSearch =
          payment.invoiceNo.contains(_searchController.text) ||
              payment.amount.toString().contains(_searchController.text) ||
              payment.paymentMode
                  .toLowerCase()
                  .contains(_searchController.text.toLowerCase());

      final matchesInvoice =
          selectedInvoiceId == null || payment.invoiceNo == selectedInvoiceId;

      return matchesSearch && matchesInvoice;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFFEFFF7),
      appBar: CustomAppBar(
        titleText: 'Payments',
        subtitleText: 'Search your payment data',
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          children: [
            // Top Row for Dropdown and Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.brown[50],
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: DropdownButton<String>(
                      value: selectedInvoiceId,
                      hint: const Text("        Select Invoice"),
                      isExpanded: true,
                      dropdownColor: Colors.brown[50],
                      underline: SizedBox(),
                      items: invoices.map((invoice) {
                        return DropdownMenuItem<String>(
                          value: invoice.id,
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Text(
                                "${invoice.customerName}, amount: ${invoice.amount}"),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedInvoiceId = value;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Black Button with Icon and Text
                ElevatedButton(
                  onPressed: () {
                    if (selectedInvoiceId == null) {
                      // Show an error message if no invoice is selected
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              'Please select an invoice before adding a payment.'),
                        ),
                      );
                      return;
                    }
                    // Navigate to UpdatePaymentScreen with null values
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => UpdatePaymentScreen(
                          paymentId: null, // Pass null for paymentId
                          invoiceId: selectedInvoiceId ??
                              '', // Pass selectedInvoiceId or empty string
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    minimumSize: const Size(100, 55),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.add, color: Colors.white),
                      SizedBox(width: 5),
                      Text('Add Payment',
                          style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Search Field
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: "Search by Invoice No, Amount, or Payment Mode",
                filled: true,
                fillColor: Colors.brown[50],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                setState(() {});
              },
              style: const TextStyle(height: 1.5), // Shrink height
            ),
            const SizedBox(height: 20),
            Expanded(
              child: filteredPayments.isEmpty
                  ? const Center(child: Text('No payments found.'))
                  : GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: columns,
                        crossAxisSpacing: 10.0,
                        mainAxisSpacing: 10.0,
                        mainAxisExtent: 150,
                      ),
                      itemCount: filteredPayments.length,
                      itemBuilder: (context, index) {
                        final payment = filteredPayments[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            title: Text('Invoice No: ${payment.invoiceNo}'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    'Amount: \$${payment.amount.toStringAsFixed(2)}'),
                                Text('Payment Date: ${payment.paymentDate}'),
                                Text('Mode: ${payment.paymentMode}'),
                                if (payment.chequeNo != null)
                                  Text('Cheque No: ${payment.chequeNo}'),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () {
                                    _showEditDialog(payment);
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () {
                                    ref
                                        .read(paymentNotifierProvider.notifier)
                                        .deletePayment(payment.id);
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(Payment payment) {
    if (payment.id != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => UpdatePaymentScreen(
              paymentId: payment.id,
              invoiceId: payment.invoiceNo), // Pass invoiceId as well
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payment ID is not available.')),
      );
    }
  }
}
