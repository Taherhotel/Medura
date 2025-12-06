import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'edit_profile_screen.dart';
import '../services/database_service.dart';
import '../services/theme_provider.dart';

class ProfileScreen extends StatefulWidget {
  final String userId;

  const ProfileScreen({super.key, required this.userId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final DatabaseService _dbService = DatabaseService();

  // Default data to show while loading or if empty
  Map<String, dynamic> profileData = {
    'name': 'User',
    'age': '',
    'weight': '',
    'height': '',
    'bloodType': '',
    'caretakerName': '',
    'caretakerRelation': '',
    'allergies': '',
  };

  @override
  void initState() {
    super.initState();
    // No need to force initialization here as AuthService handles creation
  }

  Future<void> _navigateToEditProfile(Map<String, dynamic> currentData) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfileScreen(currentData: currentData),
      ),
    );

    if (result != null && result is Map<String, dynamic>) {
      // Save to Firestore
      await _dbService.updateUserProfile(widget.userId, result);
    }
  }

  Future<void> _showSettingsDialog() async {
    showDialog(
      context: context,
      builder: (context) {
        return Consumer<ThemeProvider>(
          builder: (context, themeProvider, child) {
            return AlertDialog(
              title: const Text('App Settings'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SwitchListTile(
                    title: const Text('Dark Mode'),
                    value: themeProvider.isDarkMode,
                    onChanged: (value) {
                      themeProvider.toggleTheme(value);
                    },
                    secondary: Icon(
                      themeProvider.isDarkMode
                          ? Icons.dark_mode
                          : Icons.light_mode,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Text Size'),
                  Slider(
                    value: themeProvider.textScaleFactor,
                    min: 0.8,
                    max: 1.4,
                    divisions: 3,
                    label: themeProvider.textScaleFactor.toString(),
                    onChanged: (value) {
                      themeProvider.setTextScale(value);
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text('Small', style: TextStyle(fontSize: 12)),
                      Text('Large', style: TextStyle(fontSize: 16)),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: _dbService.getUserProfile(widget.userId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Something went wrong'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>;
          // Merge with defaults in case some fields are missing
          profileData = {...profileData, ...data};
        }

        return Scaffold(
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // AppBar-like Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: _showSettingsDialog,
                        icon: const Icon(Icons.settings_outlined),
                        color: Theme.of(context).iconTheme.color,
                      ),
                      Text(
                        'Profile',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        onPressed: () => _navigateToEditProfile(profileData),
                        icon: const Icon(Icons.edit_rounded),
                        color: Theme.of(context).iconTheme.color,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Profile Image & Name
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Theme.of(context).primaryColor,
                            width: 3,
                          ),
                        ),
                        child: const CircleAvatar(
                          radius: 60,
                          backgroundImage: NetworkImage(
                            'https://i.pravatar.cc/150?img=11',
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _navigateToEditProfile(profileData),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(
                            Icons.edit,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    profileData['name'] ?? 'User',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  Text(
                    'ID: ${widget.userId}',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
                  ),
                  const SizedBox(height: 32),

                  // Personal Stats Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatCard(
                        context,
                        'Age',
                        profileData['age'] ?? '-',
                        'yrs',
                      ),
                      _buildStatCard(
                        context,
                        'Weight',
                        profileData['weight'] ?? '-',
                        'kg',
                      ),
                      _buildStatCard(
                        context,
                        'Height',
                        profileData['height'] ?? '-',
                        'cm',
                      ),
                      _buildStatCard(
                        context,
                        'Blood',
                        profileData['bloodType'] ?? '-',
                        '',
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Medical Conditions
                  _buildSectionHeader(context, 'Medical Conditions'),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _buildConditionChip(
                        context,
                        'Hypertension',
                        Colors.orange,
                      ),
                      _buildConditionChip(
                        context,
                        'Type 2 Diabetes',
                        Colors.blue,
                      ),
                      _buildConditionChip(context, 'Arthritis', Colors.purple),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Caretaker Info
                  _buildSectionHeader(context, 'Caretaker Details'),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardTheme.color,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primary.withOpacity(0.3),
                          child: Icon(
                            Icons.person,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                profileData['caretakerName'] ?? 'Not assigned',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                profileData['caretakerRelation'] ?? '',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () {},
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.green.withOpacity(0.2),
                            foregroundColor: Colors.greenAccent,
                          ),
                          icon: const Icon(Icons.phone),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Allergies & Notes
                  _buildSectionHeader(context, 'Allergies & Notes'),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.red.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.warning_amber_rounded,
                              color: Colors.red[700],
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Allergies',
                              style: TextStyle(
                                color: Colors.red[900],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          profileData['allergies'] ?? 'None',
                          style: TextStyle(color: Colors.red[800], height: 1.5),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    String unit,
  ) {
    return Column(
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey[400],
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            if (unit.isNotEmpty) ...[
              const SizedBox(width: 2),
              Text(
                unit,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey[500]),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildConditionChip(BuildContext context, String label, Color color) {
    return Chip(
      label: Text(
        label,
        style: TextStyle(
          color: color.withValues(alpha: 1.0), // Darker text
          fontWeight: FontWeight.w600,
        ),
      ),
      backgroundColor: color.withValues(alpha: 0.1),
      side: BorderSide.none,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    );
  }
}
