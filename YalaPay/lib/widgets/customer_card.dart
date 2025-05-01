import 'package:flutter/material.dart';
import 'package:quickmart/models/customer.dart';

class CustomerCard extends StatelessWidget {
  final Customer customer;
  final Function(Customer) onEdit;
  final Function(Customer) onDelete;

  const CustomerCard({
    super.key,
    required this.customer,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color.fromARGB(255, 245, 238, 226),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  overflow: TextOverflow.ellipsis,
                  '${customer.contactDetails.firstName} ${customer.contactDetails.lastName}',
                  style: const TextStyle(
                      color: Color.fromARGB(255, 78, 53, 33), fontSize: 20),
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: () => onEdit(customer),
                      icon: const Icon(
                        Icons.edit_outlined,
                        color: Colors.blue,
                      ),
                    ),
                    IconButton(
                      onPressed: () => onDelete(customer),
                      icon: const Icon(
                        Icons.delete_outline_rounded,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 5),
            const Divider(),
            Row(
              children: [
                const Icon(Icons.business),
                const SizedBox(width: 5),
                Text(customer.companyName),
              ],
            ),
            // const Divider(),
            const SizedBox(height: 5),
            Row(
              children: [
                const Icon(Icons.home_outlined),
                const SizedBox(width: 5),
                Text(
                    '${customer.address.street}, ${customer.address.city}, ${customer.address.country}'),
              ],
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                const Icon(Icons.phone_android_outlined, size: 15),
                const SizedBox(width: 5),
                Text(customer.contactDetails.mobile),
              ],
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                const Icon(Icons.email_outlined, size: 15),
                const SizedBox(width: 5),
                Text(customer.contactDetails.email),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
