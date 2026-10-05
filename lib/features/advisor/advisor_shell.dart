import 'package:flutter/material.dart';
import 'advisor_dashboard_screen.dart';
import 'advisor_settings_screen.dart';
import 'create_guidance_screen.dart';
import 'safety_content_screen.dart';

class AdvisorShell extends StatefulWidget {
  const AdvisorShell({super.key});

  @override
  State<AdvisorShell> createState() => _AdvisorShellState();
}

class _AdvisorShellState extends State<AdvisorShell> {
  int _index = 0;
  final _screens = const [
    AdvisorDashboardScreen(),
    SafetyContentScreen(),
    CreateGuidanceScreen(),
    AdvisorSettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), activeIcon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.shield_outlined), activeIcon: Icon(Icons.shield), label: 'Safety'),
          BottomNavigationBarItem(icon: Icon(Icons.add_circle_outline), activeIcon: Icon(Icons.add_circle), label: 'Guidance'),
          BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), activeIcon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}
