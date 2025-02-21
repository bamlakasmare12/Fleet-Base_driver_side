import 'dart:io';
import 'package:fleetbase/Services/auth_gate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;
import '../Services/auth_service.dart';
import '../services/auth_gate.dart';
import '../Views/homepage.dart';
import '../Views/login.dart';
// Update AuthService class
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isLoading = true;
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _checkAuthState();
  }

  Future<void> _checkAuthState() async {
    final session = Supabase.instance.client.auth.currentSession;
    final user = Supabase.instance.client.auth.currentUser;

    // Add a small delay to allow session recovery
    await Future.delayed(const Duration(milliseconds: 500));

    if (session != null && user != null) {
      // Verify user role from database
      final response = await Supabase.instance.client
          .from('users')
          .select('role')
          .eq('id', user.id)
          .single();

      setState(() {
        _isAuthenticated = response['role'] == 'driver';
        _isLoading = false;
      });
    } else {
      setState(() {
        _isAuthenticated = false;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return _isAuthenticated ? const Homepage() : const loginScreen();
  }
}
