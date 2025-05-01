import 'package:flutter/material.dart';
import 'package:quickmart/widgets/custom_app_bar.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  double screenWidth = 0;
  int columns = 1;
  double aspectRatio = 1.5;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth < 840) {
      columns = 1; // Small tablets & mobile
      aspectRatio = 3;
    } else if (screenWidth < 1000) {
      columns = 1; // Large tablets
      aspectRatio = 2;
    } else if (screenWidth < 1200) {
      columns = 2; // Desktops
      aspectRatio = 1.5;
    } else {
      columns = 2; // More
      aspectRatio = 2;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFEFFF7),
      appBar: CustomAppBar(
        titleText: 'YalaPay Dashboard',
        subtitleText: 'Summaries of invoices and cheques',
      ),
      body: Container(
        color: const Color(0xFFFEFFF7),
        padding: const EdgeInsets.all(20),
        child: GridView.count(
          crossAxisCount: columns,
          childAspectRatio: aspectRatio,
          children: [
            _buildSummaryCard(
              'Invoices',
              [
                _buildSummaryRow('All:', '99.99 QR',
                    const Color.fromARGB(255, 137, 204, 118)),
                _buildSummaryRow('Due in 30 days:', '33.33 QR',
                    const Color.fromARGB(255, 134, 184, 224)),
                _buildSummaryRow('Due in 60 days:', '66.66 QR',
                    const Color.fromARGB(255, 223, 128, 121)),
              ],
              Icons.receipt,
            ),
            _buildSummaryCard(
              'Cheques',
              [
                _buildSummaryRow('Awaiting:', '99.99 QR',
                    const Color.fromARGB(255, 232, 192, 130)),
                _buildSummaryRow('Deposited:', '22.22 QR',
                    const Color.fromARGB(255, 123, 185, 237)),
                _buildSummaryRow('Cashed:', '44.44 QR',
                    const Color.fromARGB(255, 137, 204, 118)),
                _buildSummaryRow('Returned:', '11.11 QR',
                    const Color.fromARGB(255, 223, 128, 121)),
              ],
              Icons.check,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String title, List<Widget> rows, IconData icon) {
    return Card(
      color: const Color(0xFFF9F2EA),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 5,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxHeight: 200, // Fixed maximum height for the card
          maxWidth: 300, // Optional: Set a fixed width
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF54514A),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  Icon(
                    icon,
                    color: const Color(0xFF54514A),
                    size: 24,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: rows,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, Color valueColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 16,
                color: Color.fromARGB(255, 105, 60, 60).withOpacity(0.8),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}
