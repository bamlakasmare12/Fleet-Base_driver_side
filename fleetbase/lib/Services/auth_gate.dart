// auth_gate.dart
import 'package:flutter/material.dart';
import '../Views/Homepage.dart';
import '../Views/Login.dart'; // Import your Login screen
import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth_service.dart'; // Import your auth_service

class AuthGate extends StatefulWidget {
  // Make AuthGate a StatefulWidget
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final _supabase = Supabase.instance.client; // Make _supabase available

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _checkSession(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        final session = snapshot.data;
        if (session != null) {
          return Homepage(); // No const here, so it can rebuild
        } else {
          return loginScreen(); // No const here, so it can rebuild
        }
      },
    );
  }

  Future<Session?> _checkSession() async {
    return _supabase.auth.currentSession; // Use the _supabase from auth_service
  }
}
