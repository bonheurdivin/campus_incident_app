import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import 'home/home_screen.dart';
import 'profile/profile_screen.dart';
import 'report/report_screen.dart';
import 'reports/reports_screen.dart';
import 'staff/staff_dashboard_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final isStaff = context.watch<AuthProvider>().isStaff;

    final pages = [
      isStaff ? const StaffDashboardScreen() : const HomeScreen(),
      const ReportsScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: _index, children: pages),
      floatingActionButton: isStaff
          ? null
          : FloatingActionButton.extended(
              icon: const Icon(Icons.add),
              label: const Text('Report'),
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => const ReportScreen())),
            ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: [
          NavigationDestination(
              icon: const Icon(Icons.home_outlined),
              selectedIcon: const Icon(Icons.home),
              label: isStaff ? 'Dashboard' : 'Home'),
          const NavigationDestination(
              icon: Icon(Icons.list_alt_outlined),
              selectedIcon: Icon(Icons.list_alt),
              label: 'Reports'),
          const NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Profile'),
        ],
      ),
    );
  }
}