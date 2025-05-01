import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quickmart/repo/invoice_repository.dart';
import 'package:quickmart/widgets/custom_app_bar.dart';

class InvoiceReportScreen extends ConsumerStatefulWidget {
  const InvoiceReportScreen({super.key});

  @override
  _InvoiceReportScreenState createState() => _InvoiceReportScreenState();
}

class _InvoiceReportScreenState extends ConsumerState<InvoiceReportScreen> {
  DateTime? fromDate;
  DateTime? toDate;
  String selectedStatus = "All";
  List<Map<String, dynamic>> filteredInvoices = [];
  Map<String, dynamic> totals = {
    "Pending": {"count": 0, "total": 0.0},
    "Partially Paid": {"count": 0, "total": 0.0},
    "Paid": {"count": 0, "total": 0.0},
    "Grand Total": {"count": 0, "total": 0.0},
  };

  List<String> statuses = ["All", "Pending", "Partially Paid", "Paid"];

  Future<void> _selectDate(BuildContext context, bool isFromDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        if (isFromDate) {
          fromDate = picked;
        } else {
          toDate = picked;
        }
      });
    }
  }

  Future<void> _generateReport(WidgetRef ref) async {
    try {
      final invoiceRepository = ref.read(invoiceRepositoryProvider);
      final invoiceStatusList = await invoiceRepository.getInvoicesByStatus();

      setState(() {
        totals = {
          "Pending": {"count": 0, "total": 0.0},
          "Partially Paid": {"count": 0, "total": 0.0},
          "Paid": {"count": 0, "total": 0.0},
          "Grand Total": {"count": 0, "total": 0.0},
        };

        filteredInvoices = invoiceStatusList.where((invoiceItem) {
          final invoice = invoiceItem['invoice'];
          final status = invoiceItem['status'];
          final invoiceDate = DateTime.parse(invoice.invoiceDate);

          final isWithinDateRange = (fromDate == null ||
                  invoiceDate.isAfter(fromDate!) ||
                  invoiceDate.isAtSameMomentAs(fromDate!)) &&
              (toDate == null ||
                  invoiceDate.isBefore(toDate!) ||
                  invoiceDate.isAtSameMomentAs(toDate!));

          final matchesStatus =
              selectedStatus == "All" || status == selectedStatus;

          if (isWithinDateRange && matchesStatus) {
            // Update totals
            totals[status]["count"] += 1;
            totals[status]["total"] += invoice.amount;
            totals["Grand Total"]["count"] += 1;
            totals["Grand Total"]["total"] += invoice.amount;

            return true;
          }
          return false;
        }).toList();
      });
    } catch (e) {
      print("Error generating report: $e");
    }
  }

  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
  }

  Widget _buildTotalsSection() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.brown[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.brown[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...statuses.where((status) => status != "All").map((status) {
            final count = totals[status]["count"];
            final total = totals[status]["total"].toStringAsFixed(2);
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 2.0),
              child: Text(
                "$status - Count: $count, Total: \$ $total",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown[700],
                ),
              ),
            );
          }),
          Divider(),
          Text(
            "Grand Total - Count: ${totals["Grand Total"]["count"]}, Total: \$${totals["Grand Total"]["total"].toStringAsFixed(2)}",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.brown[800],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFEFFF7),
      appBar: CustomAppBar(
        titleText: 'Invoice Reports',
        subtitleText: 'Generate the report.',
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  icon: Icon(Icons.calendar_today, color: Colors.brown[500]),
                  label: Text(
                    toDate == null ? "To Date" : _formatDate(toDate!),
                    style: TextStyle(color: Colors.brown[500]),
                  ),
                  onPressed: () => _selectDate(context, false),
                ),
                TextButton.icon(
                  icon: Icon(Icons.calendar_today, color: Colors.brown[400]),
                  label: Text(
                    fromDate == null ? "From Date" : _formatDate(fromDate!),
                    style: TextStyle(color: Colors.brown[400]),
                  ),
                  onPressed: () => _selectDate(context, true),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.1),
            child: DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: "Select Status",
                labelStyle: TextStyle(color: Colors.brown[401]),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.brown.shade400),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.brown.shade600),
                ),
              ),
              value: selectedStatus,
              items: statuses.map((status) {
                return DropdownMenuItem(value: status, child: Text(status));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedStatus = value!;
                });
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 8.0),
            child: ElevatedButton(
              onPressed: () => _generateReport(ref),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
                backgroundColor: Colors.brown[400],
                padding: EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text("Generate Report",
                  style: TextStyle(color: Colors.white, fontSize: 25)),
            ),
          ),
          Expanded(
            child: filteredInvoices.isEmpty
                ? Center(
                    child: Text("No invoices found for the selected criteria"),
                  )
                : ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    itemCount: filteredInvoices.length,
                    itemBuilder: (context, index) {
                      final invoice = filteredInvoices[index]['invoice'];
                      final status = filteredInvoices[index]['status'];
                      final balance = filteredInvoices[index]['balance'];
                      return Card(
                        elevation: 3,
                        margin: EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          title: Text(
                            "Invoice ID: ${invoice.id}",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF915050),
                            ),
                          ),
                          subtitle: Text(
                            "Amount: \$${invoice.amount.toStringAsFixed(2)},\nStatus: $status,\nBalance: \$$balance,\nDate: ${_formatDate(DateTime.parse(invoice.invoiceDate))}",
                            style: TextStyle(color: Colors.grey[620]),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          if (selectedStatus == "All")
            Padding(
              padding: EdgeInsets.all(8),
              child: _buildTotalsSection(),
            ),
        ],
      ),
    );
  }
}
