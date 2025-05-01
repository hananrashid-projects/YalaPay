// import 'package:flash_news/routes/app_routes.dart';
// import 'package:flutter/material.dart';

// class ShellScreen extends StatelessWidget {
//   final Widget? child;

//   const ShellScreen({super.key, this.child});

//   @override
//   Widget build(BuildContext context) {
//     if (child == null) {
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         Navigator.of(context).pushReplacementNamed(AppRouter.listScreen.name);
//       });
//     }

//     return Scaffold(
//       body: child ??
//           Center(
//               child: CircularProgressIndicator()), // Optional loading indicator
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:quickmart/routes/app_router.dart';

class ShellScreen extends StatefulWidget {
  final Widget? child;

  const ShellScreen({super.key, this.child});

  @override
  _ShellScreenState createState() => _ShellScreenState();
}

class _ShellScreenState extends State<ShellScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth > 900;
    final isMediumScreen = screenWidth >= 840 && screenWidth < 900;

    return Scaffold(
      drawer: isWideScreen ? null : _buildDrawer(),
      body: Row(
        children: [
          if (isWideScreen) _buildSideBar(),
          Expanded(
            child: Stack(
              children: [
                widget.child ?? Container(),
                Positioned(
                  top: 16.0,
                  left: 16.0,
                  child: Builder(
                    builder: (context) {
                      return IconButton(
                        icon: Icon(Icons.menu, color: Colors.black),
                        onPressed: () {
                          if (!isWideScreen) {
                            Scaffold.of(context).openDrawer();
                          }
                        },
                      );
                    },
                  ),
                ),
                // Logout Icon Button
                Positioned(
                  top: 16.0,
                  right: 16.0,
                  child: IconButton(
                    icon: Icon(Icons.logout, color: Colors.black),
                    onPressed: () {
                      context
                          .go(AppRouter.login.path); // Navigate to login page
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      backgroundColor: const Color(0xFFEFD4D4),
      bottomNavigationBar: isWideScreen ? null : _buildBottomNavigationBar(),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: Color(0xFFFEFFF7),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            color: const Color(0xFFEFD4D4),
            padding: const EdgeInsets.all(16.0),
            alignment: Alignment.centerLeft,
            child: const Text(
              'Reports Menu',
              style: TextStyle(
                color: Color.fromARGB(255, 97, 68, 68),
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.receipt_long),
            title: Text('Invoices Report'),
            onTap: () {
              Navigator.pop(context);
              context.go(AppRouter.invoiceReport.path);
            },
          ),
          ListTile(
            leading: Icon(Icons.report),
            title: Text('Cheques Report'),
            onTap: () {
              Navigator.pop(context);
              context.go(AppRouter.chequesReport.path);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSideBar() {
    return Container(
      width: 250,
      color: Color(0xFFEFD4D4),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            alignment: Alignment.centerLeft,
            child: const Text(
              'Quick Access',
              style: TextStyle(
                color: Color.fromARGB(255, 97, 68, 68),
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.dashboard),
            title: Text('Dashboard'),
            onTap: () {
              context.go(AppRouter.main.path);
            },
          ),
          ListTile(
            leading: Icon(Icons.people),
            title: Text('Customers'),
            onTap: () {
              context.go(AppRouter.customer.path);
            },
          ),
          ListTile(
            leading: Icon(Icons.receipt),
            title: Text('Invoices'),
            onTap: () {
              context.go(AppRouter.invoice.path);
            },
          ),
          ListTile(
            leading: Icon(Icons.payment),
            title: Text('Payments'),
            onTap: () {
              context.go(AppRouter.payment.path);
            },
          ),
          ListTile(
            leading: Icon(Icons.manage_accounts),
            title: Text('Manage Cashing'),
            onTap: () {
              context.go(AppRouter.manageCashing.path);
            },
          ),
          ListTile(
            leading: Icon(Icons.receipt_long),
            title: Text('Invoices Report'),
            onTap: () {
              context.go(AppRouter.invoiceReport.path);
            },
          ),
          ListTile(
            leading: Icon(Icons.report),
            title: Text('Cheques Report'),
            onTap: () {
              context.go(AppRouter.chequesReport.path);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: const Color(0xFFEFD4D4),
      currentIndex: _currentIndex,
      selectedItemColor: const Color.fromARGB(255, 74, 52, 52),
      unselectedItemColor: Colors.black,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.people),
          label: 'Customers',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.receipt),
          label: 'Invoices',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.payment),
          label: 'Payments',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.manage_accounts),
          label: 'Manage Cashing',
        ),
      ],
      onTap: (index) {
        setState(() {
          _currentIndex = index;
        });

        switch (index) {
          case 0:
            context.go(AppRouter.main.path);
            break;
          case 1:
            context.go(AppRouter.customer.path);
            break;
          case 2:
            context.go(AppRouter.invoice.path);
            break;
          case 3:
            context.go(AppRouter.payment.path);
            break;
          case 4:
            context.go(AppRouter.manageCashing.path);
            break;
        }
      },
    );
  }
}
