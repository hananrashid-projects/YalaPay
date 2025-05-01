import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quickmart/models/address.dart';
import 'package:quickmart/models/customer.dart';
import 'package:quickmart/models/contact_details.dart';
import 'package:quickmart/providers/customer_provider.dart';
import 'package:quickmart/widgets/error_alert.dart';

class CustomerEditor extends ConsumerStatefulWidget {
  const CustomerEditor({super.key, required this.customerId});
  final String? customerId;

  @override
  ConsumerState<CustomerEditor> createState() => _CustomerEditorState();
}

class _CustomerEditorState extends ConsumerState<CustomerEditor> {
  bool validData = true;

  @override
  Widget build(BuildContext context) {
    final customers = ref.watch(customerNotifierProvider);
    final index = customers.indexWhere((c) => c.id == widget.customerId);
    final customer = index == -1 ? null : customers[index];

    final TextEditingController firstNameController =
        TextEditingController(text: customer?.contactDetails.firstName ?? "");
    final TextEditingController lastNameController =
        TextEditingController(text: customer?.contactDetails.lastName ?? "");
    final TextEditingController companyNameController =
        TextEditingController(text: customer?.companyName ?? "");
    final TextEditingController phoneController =
        TextEditingController(text: customer?.contactDetails.mobile ?? "");
    final TextEditingController emailController =
        TextEditingController(text: customer?.contactDetails.email ?? "");
    final TextEditingController streetController =
        TextEditingController(text: customer?.address.street ?? "");
    final TextEditingController cityController =
        TextEditingController(text: customer?.address.city ?? "");
    final TextEditingController countryController =
        TextEditingController(text: customer?.address.country ?? "");

    List<Map<String, dynamic>> items = [
      {'label': 'First Name', 'controller': firstNameController},
      {'label': 'Last Name', 'controller': lastNameController},
      {'label': 'Company Name', 'controller': companyNameController},
      {'label': 'Street', 'controller': streetController},
      {'label': 'City', 'controller': cityController},
      {'label': 'Country', 'controller': countryController},
      {'label': 'Mobile', 'controller': phoneController},
      {'label': 'Email', 'controller': emailController},
    ];

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
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 500,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var item in items)
                    Column(
                      children: [
                        const SizedBox(height: 12),
                        TextField(
                          controller: item['controller'],
                          decoration: InputDecoration(
                            fillColor: Colors.grey[300],
                            filled: true,
                            labelText: item['label'],
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
                      ],
                    ),
                  if (!validData)
                    const Column(
                      children: [
                        SizedBox(height: 12),
                        ErrorAlert(message: 'All fields are required.'),
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
                            foregroundColor: Colors.white),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 10),
                      if (customer != null)
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromARGB(255, 115, 159, 196),
                              foregroundColor: Colors.white),
                          onPressed: () {
                            ref
                                .read(customerNotifierProvider.notifier)
                                .updateCustomer(
                                  Customer(
                                    id: customer.id,
                                    companyName: companyNameController.text,
                                    address: Address(
                                        street: streetController.text,
                                        city: cityController.text,
                                        country: countryController.text),
                                    contactDetails: ContactDetails(
                                        firstName: firstNameController.text,
                                        lastName: lastNameController.text,
                                        mobile: phoneController.text,
                                        email: emailController.text),
                                  ),
                                );
                            Navigator.of(context).pop();
                          },
                          child: const Text('Update'),
                        ),
                      if (customer == null)
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromARGB(255, 158, 192, 135),
                              foregroundColor: Colors.white),
                          onPressed: () {
                            if (firstNameController.text.isEmpty ||
                                lastNameController.text.isEmpty ||
                                companyNameController.text.isEmpty ||
                                streetController.text.isEmpty ||
                                cityController.text.isEmpty ||
                                countryController.text.isEmpty ||
                                phoneController.text.isEmpty ||
                                emailController.text.isEmpty) {
                              setState(() {
                                validData = false;
                              });
                            } else {
                              // Generate a unique ID for the new customer
                              int newId = customers.isEmpty
                                  ? 1
                                  : customers
                                          .map((c) => int.tryParse(c.id) ?? 0)
                                          .reduce((a, b) => a > b ? a : b) +
                                      1;
                              ref
                                  .read(customerNotifierProvider.notifier)
                                  .addCustomer(
                                    Customer(
                                      id: newId.toString(),
                                      companyName: companyNameController.text,
                                      address: Address(
                                          street: streetController.text,
                                          city: cityController.text,
                                          country: countryController.text),
                                      contactDetails: ContactDetails(
                                          firstName: firstNameController.text,
                                          lastName: lastNameController.text,
                                          mobile: phoneController.text,
                                          email: emailController.text),
                                    ),
                                  );
                              Navigator.of(context).pop();
                            }
                          },
                          child: const Text('Add'),
                        ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
