import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'auth_wrapper.dart';
import 'home_view.dart';
import 'profile_screen.dart';
import 'medication_schedule_screen.dart';

class HomeScreen extends StatefulWidget {
  final String userName;
  final String userId;

  const HomeScreen({super.key, required this.userName, required this.userId});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final _authService = AuthService();

  Future<void> _signOut() async {
    await _authService.signOut();
    if (mounted) {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const AuthWrapper()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      HomeView(userName: widget.userName),
      MedicationScheduleScreen(userId: widget.userId),
      ProfileScreen(userId: widget.userId),
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Padding(
          padding: const EdgeInsets.only(top: 20.0),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: Image.asset('AarogyaDoot.png', height: 45),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Medura',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: IconButton(
              onPressed: () {}, // Notification placeholder
              icon: Icon(
                Icons.notifications_outlined,
                color: Theme.of(context).iconTheme.color,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20.0, right: 8.0),
            child: IconButton(
              onPressed: _signOut,
              icon: const Icon(Icons.logout, color: Colors.redAccent),
              tooltip: 'Logout',
            ),
          ),
        ],
      ),
      body: SafeArea(child: screens[_selectedIndex]),
      bottomNavigationBar: NavigationBar(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? Theme.of(context).colorScheme.tertiary
            : Colors.white,
        indicatorColor: Theme.of(context).colorScheme.secondary,
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
