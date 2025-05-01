import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quickmart/providers/customer_provider.dart';
import 'package:quickmart/providers/invoice_provider.dart';
import 'package:quickmart/providers/payment_provider.dart';
import 'package:quickmart/routes/app_router.dart';
import 'package:quickmart/widgets/add_customer.dart';
import 'package:quickmart/widgets/customer_card.dart';

class CustomersScreen extends ConsumerStatefulWidget {
  const CustomersScreen({super.key});

  @override
  ConsumerState<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends ConsumerState<CustomersScreen> {
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
    final invoices = ref.watch(invoiceNotifierProvider.notifier);
    final payments = ref.watch(paymentNotifierProvider.notifier);

    final customers = ref.watch(customerNotifierProvider);
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
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,
              title: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  const Text(
                    'Customers',
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
      floatingActionButton: screenWidth < 600
          ? AddCustomer(customersLength: customers.length)
          : null,
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      fillColor: Colors.brown[50],
                      filled: true,
                      hintText: 'Search...',
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Color.fromARGB(255, 234, 232, 230),
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide:
                            const BorderSide(color: Colors.green, width: 1.0),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onChanged: (value) {
                      ref
                          .read(customerNotifierProvider.notifier)
                          .getCustomers(value);
                    },
                  ),
                ),
                if (screenWidth >= 600)
                  Row(
                    children: [
                      const SizedBox(width: 10),
                      AddCustomer(customersLength: customers.length),
                    ],
                  )
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  crossAxisSpacing: 10.0,
                  mainAxisSpacing: 10.0,
                  mainAxisExtent: 200,
                ),
                itemCount: customers.length,
                itemBuilder: (context, index) {
                  return CustomerCard(
                    customer: customers[index],
                    onEdit: (customer) {
                      context.pushNamed(AppRouter.customerEditor.name,
                          pathParameters: {'customerId': customers[index].id});
                    },
                    onDelete: (customer) {
                      ref
                          .read(customerNotifierProvider.notifier)
                          .removeCustomer(customers[index]);

                      // First, delete the customer
                      ref
                          .read(customerNotifierProvider.notifier)
                          .removeCustomer(customers[index]);

                      final invoicesbyCustomer =
                          invoices.getInvoicesByCustomerId(customer.id);

                      for (final i in invoicesbyCustomer) {
                        invoices.deleteInvoice(i.id);
                        payments.deletePaymentsByInvoice(i.id);
                      }
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
