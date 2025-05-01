import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:quickmart/repo/cheque_repository.dart';
import 'package:quickmart/models/cheque.dart';
import 'package:quickmart/widgets/custom_app_bar.dart';

class ChequesReportScreen extends ConsumerStatefulWidget {
  @override
  _ChequesReportScreenState createState() => _ChequesReportScreenState();
}

class _ChequesReportScreenState extends ConsumerState<ChequesReportScreen> {
  DateTime? fromDate;
  DateTime? toDate;
  String selectedStatus = "All";
  List<Cheque> filteredCheques = [];
  List<String> statuses = ["All"]; // Default value to include "All"

  @override
  void initState() {
    super.initState();
    _loadStatuses(); // Load statuses on init
  }

  Future<void> _loadStatuses() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final path = 'assets/data/cheque-status.json';
      final statusData = await File(path).readAsString();
      final List<String> loadedStatuses =
          List<String>.from(jsonDecode(statusData));

      setState(() {
        statuses = ["All", ...loadedStatuses]; // Add "All" as the first option
      });
    } catch (e) {
      print("Error loading statuses: $e");
    }
  }

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
    final chequeRepository = ref.read(chequeRepositoryProvider);
    List<Cheque> cheques = await chequeRepository.loadCheques();

    setState(() {
      filteredCheques = cheques.where((cheque) {
        bool isWithinDateRange = (fromDate == null ||
                cheque.receivedDate.isAfter(fromDate!) ||
                cheque.receivedDate.isAtSameMomentAs(fromDate!)) &&
            (toDate == null ||
                cheque.receivedDate.isBefore(toDate!) ||
                cheque.receivedDate.isAtSameMomentAs(toDate!));
        bool matchesStatus =
            selectedStatus == "All" || cheque.status == selectedStatus;
        return isWithinDateRange && matchesStatus;
      }).toList();
    });
  }

  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFEFFF7),
      appBar: CustomAppBar(
        titleText: 'Cheques Reports',
        subtitleText: 'Generate reports based on your preferences.',
      ),
      body: Column(
        children: [
          // Header

          // Input Fields
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // From Date Picker
                TextButton.icon(
                  icon: Icon(Icons.calendar_today, color: Colors.brown[400]),
                  label: Text(
                    fromDate == null ? "From Date" : _formatDate(fromDate!),
                    style: TextStyle(color: Colors.brown[400]),
                  ),
                  onPressed: () => _selectDate(context, true),
                ),
                // To Date Picker
                TextButton.icon(
                  icon: Icon(Icons.calendar_today, color: Colors.brown[400]),
                  label: Text(
                    toDate == null ? "To Date" : _formatDate(toDate!),
                    style: TextStyle(color: Colors.brown[400]),
                  ),
                  onPressed: () => _selectDate(context, false),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: "Select Status",
                labelStyle: TextStyle(color: Colors.brown[400]),
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
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
            child: ElevatedButton(
              onPressed: () => _generateReport(ref),
              child: Text("Generate Report",
                  style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50), // Make button wider
                backgroundColor: Colors.brown[400],
                padding: EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          // Cheque List
          Expanded(
            child: filteredCheques.isEmpty
                ? Center(
                    child: Text("No cheques found for the selected criteria"))
                : ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    itemCount: filteredCheques.length,
                    itemBuilder: (context, index) {
                      final cheque = filteredCheques[index];
                      return Card(
                        elevation: 3,
                        margin: EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          title: Text(
                            "Cheque No: ${cheque.chequeNo}",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF915050),
                            ),
                          ),
                          subtitle: Text(
                            "Amount: \$${cheque.amount}\nStatus: ${cheque.status}\nDate: ${_formatDate(cheque.receivedDate)}",
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          // Totals Section
          if (selectedStatus == "All")
            Padding(
              padding: EdgeInsets.all(8),
              child: _buildTotalsSection(filteredCheques),
            ),
        ],
      ),
    );
  }

  Widget _buildTotalsSection(List<Cheque> cheques) {
    final statusGroups = {
      "Awaiting": cheques.where((c) => c.status == "Awaiting").toList(),
      "Deposited": cheques.where((c) => c.status == "Deposited").toList(),
      "Cashed": cheques.where((c) => c.status == "Cashed").toList(),
      "Returned": cheques.where((c) => c.status == "Returned").toList(),
    };
    final grandTotal = cheques.fold(0.0, (sum, cheque) => sum + cheque.amount);

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
          ...statusGroups.entries.map((entry) {
            final statusTotal =
                entry.value.fold(0.0, (sum, cheque) => sum + cheque.amount);
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 2.0),
              child: Text(
                "${entry.key} - Count: ${entry.value.length}, Total: \$${statusTotal.toStringAsFixed(2)}",
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.brown[700]),
              ),
            );
          }),
          Divider(),
          Text(
            "Grand Total - Count: ${cheques.length}, Total: \$${grandTotal.toStringAsFixed(2)}",
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.brown[800]),
          ),
        ],
      ),
    );
  }
}
