import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';
import '../services/alert_service.dart';
import '../models/alert.dart';
import 'auth_wrapper.dart';
import 'elder_details_screen.dart';
import 'alerts_screen.dart';

class CaregiverHomeScreen extends StatelessWidget {
  final String userId;

  const CaregiverHomeScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    // Enforce Light Theme for Caregiver
    return Theme(
      data: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00BFA6),
          primary: const Color(0xFF00BFA6),
          secondary: const Color.fromARGB(255, 244, 245, 246),
          surface: const Color(0xFFF8F9FA),
          error: const Color(0xFFFF5252),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: Colors.black87),
          titleTextStyle: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          color: Colors.white,
          surfaceTintColor: Colors.white,
        ),
        iconTheme: const IconThemeData(color: Colors.black87),
        textTheme: const TextTheme(
          headlineSmall: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
          headlineMedium: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          titleLarge: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
          bodyMedium: TextStyle(color: Colors.black87),
          bodySmall: TextStyle(color: Colors.grey),
        ),
      ),
      child: Builder(
        builder: (context) {
          final authService = AuthService();
          final alertService = AlertService();

          return Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            body: SafeArea(
              child: StreamBuilder<List<Alert>>(
                stream: alertService.getAlertsForCaregiver(),
                builder: (context, alertSnapshot) {
                  final alerts = alertSnapshot.data ?? [];
                  final unreadCount = alerts
                      .where((a) => a.status == AlertStatus.newAlert)
                      .length;

                  return StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .where('role', isEqualTo: 'elder')
                        .snapshots(),
                    builder: (context, elderSnapshot) {
                      final elderCount = elderSnapshot.hasData
                          ? elderSnapshot.data!.docs.length
                          : 0;

                      return CustomScrollView(
                        slivers: [
                          SliverAppBar(
                            floating: true,
                            backgroundColor: Theme.of(
                              context,
                            ).scaffoldBackgroundColor,
                            elevation: 0,
                            automaticallyImplyLeading: false,
                            toolbarHeight:
                                70, // Increased height for better spacing
                            title: StreamBuilder<DocumentSnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(userId)
                                  .snapshots(),
                              builder: (context, snapshot) {
                                String userName = 'Caregiver';

                                // Gracefully handle errors or loading states by falling back to default
                                if (snapshot.hasData && snapshot.data!.exists) {
                                  final data =
                                      snapshot.data!.data()
                                          as Map<String, dynamic>;
                                  userName = data['name'] ?? 'Caregiver';
                                }

                                return Padding(
                                  padding: const EdgeInsets.only(top: 30.0),
                                  child: Row(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          right: 12.0,
                                        ),
                                        child: Image.asset(
                                          'AarogyaDoot.png',
                                          height: 45,
                                        ),
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Welcome Back,',
                                            style: Theme.of(
                                              context,
                                            ).textTheme.bodySmall,
                                          ),
                                          Text(
                                            userName,
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleLarge
                                                ?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                            actions: [
                              Padding(
                                padding: const EdgeInsets.only(top: 30.0),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    IconButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const AlertsScreen(),
                                          ),
                                        );
                                      },
                                      icon: Icon(
                                        Icons.notifications_outlined,
                                        color: Theme.of(
                                          context,
                                        ).iconTheme.color,
                                      ),
                                    ),
                                    if (unreadCount > 0)
                                      Positioned(
                                        right: 8,
                                        top: 8,
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: const BoxDecoration(
                                            color: Colors.red,
                                            shape: BoxShape.circle,
                                          ),
                                          constraints: const BoxConstraints(
                                            minWidth: 16,
                                            minHeight: 16,
                                          ),
                                          child: Text(
                                            unreadCount > 9
                                                ? '9+'
                                                : '$unreadCount',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                  top: 30.0,
                                  right: 8.0,
                                ),
                                child: IconButton(
                                  onPressed: () async {
                                    await authService.signOut();
                                    if (context.mounted) {
                                      Navigator.of(context).pushReplacement(
                                        MaterialPageRoute(
                                          builder: (_) => const AuthWrapper(),
                                        ),
                                      );
                                    }
                                  },
                                  icon: const Icon(
                                    Icons.logout,
                                    color: Colors.redAccent,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: _buildQuickStats(
                                context,
                                unreadCount,
                                elderCount,
                              ),
                            ),
                          ),
                          SliverPadding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                            ),
                            sliver: SliverToBoxAdapter(
                              child: Text(
                                'Assigned Elders',
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          const SliverToBoxAdapter(child: SizedBox(height: 16)),
                          if (elderSnapshot.hasError)
                            SliverToBoxAdapter(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Center(
                                  child: Text(
                                    'Unable to load elders. Please check your connection.',
                                    style: TextStyle(color: Colors.red[300]),
                                  ),
                                ),
                              ),
                            )
                          else if (elderSnapshot.connectionState ==
                              ConnectionState.waiting)
                            const SliverToBoxAdapter(
                              child: Center(child: CircularProgressIndicator()),
                            )
                          else if (!elderSnapshot.hasData ||
                              elderSnapshot.data!.docs.isEmpty)
                            const SliverToBoxAdapter(
                              child: Center(child: Text('No elders assigned')),
                            )
                          else
                            SliverList(
                              delegate: SliverChildBuilderDelegate((
                                context,
                                index,
                              ) {
                                final elder = elderSnapshot.data!.docs[index];
                                return _buildElderCard(context, elder);
                              }, childCount: elderSnapshot.data!.docs.length),
                            ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () {},
              label: const Text('Add Elder'),
              icon: const Icon(Icons.add),
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
            ),
          );
        },
      ),
    );
  }

  Widget _buildQuickStats(
    BuildContext context,
    int unreadCount,
    int elderCount,
  ) {
    return Row(
      children: [
        Expanded(
          child: _buildStatContainer(
            context,
            'Alerts',
            unreadCount.toString(),
            Icons.notifications_active,
            unreadCount > 0 ? Colors.red : Colors.orange,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatContainer(
            context,
            'Total Patients',
            elderCount.toString(),
            Icons.people_alt,
            Colors.blue,
          ),
        ),
      ],
    );
  }

  Widget _buildStatContainer(
    BuildContext context,
    String label,
    String count,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                count,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                label,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildElderCard(BuildContext context, DocumentSnapshot elder) {
    final data = elder.data() as Map<String, dynamic>;
    return Container(
      margin: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ElderDetailsScreen(
                  elderId: elder.id,
                  elderName: data['name'] ?? 'Unknown',
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Hero(
                  tag: 'avatar_${elder.id}',
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      shape: BoxShape.circle,
                      image: const DecorationImage(
                        image: NetworkImage('https://i.pravatar.cc/150?img=11'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data['name'] ?? 'Unknown',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          _buildStatusChip('Online', Colors.green),
                          const SizedBox(width: 8),
                          Text(
                            'HR: 72 bpm', // Mock live data
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.grey),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
