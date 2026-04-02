import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/login_screen.dart';
import 'main_wrapper.dart';
import '../main.dart' show BiometricLockScreen;
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final session = snapshot.hasData ? snapshot.data!.session : null;

        if (session != null) {
          // User is logged in. Check biometric setting.
          return Consumer<SettingsProvider>(
            builder: (context, settings, child) {
              return settings.biometricEnabled 
                ? const BiometricLockScreen() 
                : const MainWrapper();
            },
          );
        }

        // User is not logged in.
        return const LoginScreen();
      },
    );
  }
}
