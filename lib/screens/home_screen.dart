import 'package:flutter/material.dart';
import 'home_view.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  final String userName;
  final String userId;

  const HomeScreen({super.key, required this.userName, required this.userId});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      HomeView(userName: widget.userName),
      const Center(child: Text('Schedule Screen Placeholder')),
      ProfileScreen(userId: widget.userId),
    ];

    return Scaffold(
      body: SafeArea(child: screens[_selectedIndex]),
      bottomNavigationBar: NavigationBar(
        backgroundColor: Colors.white,
        elevation: 0,
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_today_outlined),
            selectedIcon: Icon(Icons.calendar_today_rounded),
            label: 'Schedule',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
