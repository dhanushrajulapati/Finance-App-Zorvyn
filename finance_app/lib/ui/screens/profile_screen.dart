import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../providers/settings_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile & Settings')),
      body: Consumer<SettingsProvider>(
        builder: (context, settings, child) {
          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              const CircleAvatar(
                radius: 40,
                child: Icon(Icons.person, size: 40),
              ),
              const SizedBox(height: 16),
              const Center(
                child: Text(
                  'Finance Saver',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 32),
              SwitchListTile(
                title: const Text('Dark Mode'),
                secondary: const Icon(Icons.dark_mode),
                value: settings.isDarkMode,
                onChanged: (val) => settings.toggleTheme(val),
              ),
              const Divider(),
              ListTile(
                title: const Text('Preferred Currency'),
                leading: const Icon(Icons.attach_money),
                trailing: DropdownButton<String>(
                  value: settings.currencySymbol,
                  underline: const SizedBox(),
                  items: const [
                    DropdownMenuItem(value: '\$', child: Text('USD (\$)')),
                    DropdownMenuItem(value: '€', child: Text('EUR (€)')),
                    DropdownMenuItem(value: '£', child: Text('GBP (£)')),
                    DropdownMenuItem(value: '₹', child: Text('INR (₹)')),
                  ],
                  onChanged: (val) {
                    if (val != null) settings.setCurrency(val);
                  },
                ),
              ),
              const Divider(),
              SwitchListTile(
                title: const Text('Simulate Biometric Lock'),
                subtitle: const Text('Locks app until authenticated'),
                secondary: const Icon(Icons.fingerprint),
                value: settings.biometricEnabled,
                onChanged: (val) => settings.toggleBiometric(val),
              ),
              const Divider(),
              SwitchListTile(
                title: const Text('Enable Daily Push Notifications'),
                subtitle: const Text('Simulated daily log reminders'),
                secondary: const Icon(Icons.notifications_active),
                value: settings.notificationsEnabled,
                onChanged: (val) => settings.toggleNotifications(val),
              ),
              const Divider(),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                icon: const Icon(Icons.download),
                label: const Text('Export Data to CSV'),
                onPressed: () async {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Starting Export...')),
                  );
                  await settings.exportDataMock();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Export Saved! (Simulated)')),
                  );
                },
              ),
              const SizedBox(height: 16),
              TextButton.icon(
                icon: const Icon(Icons.logout, color: Colors.red),
                label: const Text('Sign Out', style: TextStyle(color: Colors.red)),
                onPressed: () async {
                  await Supabase.instance.client.auth.signOut();
                  if (context.mounted) {
                    Navigator.popUntil(context, (route) => route.isFirst);
                  }
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
