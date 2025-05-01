import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quickmart/models/invoice.dart';
import 'package:quickmart/models/customer.dart';
import 'package:quickmart/providers/invoice_provider.dart';
import 'package:quickmart/providers/customer_provider.dart';
import 'package:quickmart/providers/payment_provider.dart';
import 'package:quickmart/screens/edit_invoice_screen.dart';
import 'package:quickmart/screens/payment_editor_screen.dart';
import 'package:quickmart/widgets/custom_app_bar.dart';

class InvoicesScreen extends ConsumerStatefulWidget {
  const InvoicesScreen({super.key});

  @override
  ConsumerState<InvoicesScreen> createState() => _InvoicesScreenState();
}

class _InvoicesScreenState extends ConsumerState<InvoicesScreen> {
  double screenWidth = 0;
  int columns = 1;

  final TextEditingController _searchController = TextEditingController();
  String? selectedCustomerId;
  String? selectedCustomerName;
  List<Invoice> filteredInvoices = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    screenWidth = MediaQuery.of(context).size.width;
    columns = screenWidth < 840
        ? 1
        : screenWidth < 1150
            ? 2
            : 3;
  }

  @override
  void initState() {
    super.initState();
    filteredInvoices = [];
  }

  @override
  Widget build(BuildContext context) {
    final invoices = ref.watch(invoiceNotifierProvider);
    final invoicesNotifier = ref.watch(invoiceNotifierProvider.notifier);

    final customers = ref.watch(customerNotifierProvider);
    final payments = ref.watch(paymentNotifierProvider);
    final paymentsNotifier = ref.watch(paymentNotifierProvider.notifier);

    _filterInvoices();

    return Scaffold(
      backgroundColor: const Color(0xFFFEFFF7),
      appBar: CustomAppBar(
        titleText: 'Invoices',
        subtitleText: 'Manage your invoice data',
      ),
      body: Padding(
        padding: EdgeInsets.only(top: MediaQuery.of(context).size.height / 50),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.search),
                        hintText: "Search by Customer Name or Invoice ID",
                        hintStyle: const TextStyle(color: Color(0xFF915050)),
                        filled: true,
                        fillColor: Colors.brown[50],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onChanged: (value) => _filterInvoices(),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 150,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        _showAddInvoiceDialog(customers);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 9, 6, 6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        'Add an Invoice',
                        style: TextStyle(
                            color: Color.fromARGB(255, 250, 250, 250)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: filteredInvoices.isEmpty
                  ? const Center(child: Text('No invoices found.'))
                  : GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: columns,
                        crossAxisSpacing: 10.0,
                        mainAxisSpacing: 10.0,
                        mainAxisExtent: 270,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: filteredInvoices.length,
                      itemBuilder: (context, index) {
                        final invoice = filteredInvoices[index];
                        final totalPayments = 0.0;
                        final balance = invoice.amount - totalPayments;

                        return Card(
                          color: const Color.fromARGB(255, 244, 236, 236),
                          elevation: 3,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: Stack(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Customer Name: ${invoice.customerName}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Color(0xFF915050),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text('Invoice ID: ${invoice.id}'),
                                    Text(
                                        'Invoice Date: ${invoice.invoiceDate}'),
                                    Text('Due Date: ${invoice.dueDate}'),
                                    Text(
                                        'Amount: \$${invoice.amount.toStringAsFixed(2)}'),
                                    Text(
                                        'Total Payments: \$${invoicesNotifier.getAllPaymentsTotal(invoice.id, payments).toStringAsFixed(2)}'),
                                    Text(
                                      'Balance(excluding cheques): \$${invoicesNotifier.getBalance(invoice.id, payments).toStringAsFixed(2)}',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 10),
                                    Align(
                                      alignment: Alignment.bottomRight,
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          ElevatedButton(
                                            onPressed: () {
                                              _showUpdateInvoiceDialog(
                                                  invoice, customers);
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  const Color.fromARGB(
                                                      255, 239, 224, 205),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(30),
                                              ),
                                            ),
                                            child: const Text(
                                              'Update',
                                              style: TextStyle(
                                                  color: Color.fromARGB(
                                                      255, 103, 41, 41)),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          ElevatedButton(
                                            onPressed: () {
                                              ref
                                                  .read(invoiceNotifierProvider
                                                      .notifier)
                                                  .deleteInvoice(invoice.id);

                                              paymentsNotifier
                                                  .deletePaymentsByInvoice(
                                                      invoice.id);
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  const Color.fromARGB(
                                                      255, 240, 200, 200),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(30),
                                              ),
                                            ),
                                            child: const Text(
                                              'Delete',
                                              style: TextStyle(
                                                  color: Color.fromARGB(
                                                      255, 103, 41, 41)),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Plus Icon at the top right corner
                              Positioned(
                                right: 8,
                                top: 8,
                                child: IconButton(
                                  icon: const Icon(Icons.add,
                                      color: Color(0xFF915050)),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            UpdatePaymentScreen(
                                          paymentId:
                                              null, // Pass null for paymentId
                                          invoiceId: invoice.id ??
                                              '', // Pass selectedInvoiceId or empty string
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
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

  void _filterInvoices() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredInvoices = ref.read(invoiceNotifierProvider).where((invoice) {
        return invoice.customerName.toLowerCase().contains(query) ||
            invoice.id.toLowerCase().contains(query);
      }).toList();
    });
  }

  void _showAddInvoiceDialog(List<Customer> customers) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => InvoiceEditor(
          invoiceId: '',
        ),
      ),
    );
  }

  void _showUpdateInvoiceDialog(Invoice invoice, List<Customer> customers) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => InvoiceEditor(invoiceId: invoice.id),
      ),
    );
  }

  Future<void> _selectDate(
      BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      controller.text = "${picked.toLocal()}".split(' ')[0];
    }
  }
}
