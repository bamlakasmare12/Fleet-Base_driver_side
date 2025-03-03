import 'dart:io';
import 'dart:convert';
import 'package:fleetbase/Services/auth_gate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final String tokenadmin =
      'eyJhbGciOiJIUzI1NiIsImtpZCI6IkN5UFJXbUZCRUlOcDNrK0ciLCJ0eXAiOiJKV1QifQ.eyJhYWwiOiJhYWwxIiwiYW1yIjpbeyJtZXRob2QiOiJwYXNzd29yZCIsInRpbWVzdGFtcCI6MTczOTI2NzEzOH1dLCJhcHBfbWV0YWRhdGEiOnsicHJvdmlkZXIiOiJlbWFpbCIsInByb3ZpZGVycyI6WyJlbWFpbCJdfSwiYXVkIjoiYXV0aGVudGljYXRlZCIsImVtYWlsIjoieWFwaXI4OTk2NEBrdmVnZy5jb20iLCJleHAiOjE3NDAxNjQ0NzYsImlhdCI6MTc0MDE2MDg3NiwiaXNfYW5vbnltb3VzIjpmYWxzZSwiaXNzIjoiaHR0cHM6Ly9oeG9wbHZxcWJrc2Fma3ptaXhndi5zdXBhYmFzZS5jby9hdXRoL3YxIiwib3JnYW5pemF0aW9uX2lkIjpudWxsLCJwaG9uZSI6IiIsInJvbGUiOiJhdXRoZW50aWNhdGVkIiwic2Vzc2lvbl9pZCI6ImZjZWRkNDUwLWM4NjgtNDc2My1iNzNlLWY0NGJjMTVhNThkZCIsInN1YiI6ImZmNzAzYzBjLTdhNWEtNDQwOC1hNWIxLWMzNWYwNTFiYTA5YSIsInVzZXJfbWV0YWRhdGEiOnsiZW1haWwiOiJ5YXBpcjg5OTY0QGt2ZWdnLmNvbSIsImVtYWlsX3ZlcmlmaWVkIjp0cnVlLCJpbWFnZSI6IiIsIm5hbWUiOiJFdHN1YiIsIm9yZ2FuaXphdGlvbiI6IlN1cHBseSBhdCBsbGMiLCJvcmdhbml6YXRpb25faWQiOjc4LCJwaG9uZV92ZXJpZmllZCI6ZmFsc2UsInJvbGUiOiJhZG1pbiIsInN1YiI6ImZmNzAzYzBjLTdhNWEtNDQwOC1hNWIxLWMzNWYwNTFiYTA5YSJ9LCJ1c2VyX3JvbGUiOiJhZG1pbiJ9.mcmxG4v_UBVDGGED9ptp8lehLWMNrm1pVThfBs_lRsw';
  String? _verifiedCurrentPassword;
  Future<void> login(String email, String password) async {
    final supabase = Supabase.instance.client;

    try {
      // Authenticate user
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final user = response.user;

      if (user == null) {
        print("Invalid credentials. User not found.");
        throw Exception("Login failed. Invalid credentials.");
      }

      // Fetch role from the 'users' table
      final metadata = user.userMetadata;
      if (metadata == null) {
        print("No role found for user.");
        return null;
      }
      String role = metadata["role"]?.toString() ?? '';

      // Check the role
      if (role != null && role == 'driver') {
        print("Login successful! User is authorized (driver).");
        // Continue app flow here
      } else {
        // Immediately sign out if not driver
        await supabase.auth.signOut();
        print("Unauthorized role. Access denied.");
        throw Exception("Invalid Credentials");
      }
    } catch (e) {
      print("Error during login: $e");
      rethrow; // Or handle the error as needed
    }
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Clears session data

    final supabase = Supabase.instance.client;
    await supabase.auth.signOut(); // Clears Supabase session
  }

  Future<String> getUserId() async {
    return await _supabase.auth.currentUser?.id ?? '';
  }

  String? getCurrentUserEmail() {
    try {
      final session = _supabase.auth.currentSession;

      if (session == null) {
        print("No active session found.");
        return null;
      }

      final user = session.user;

      if (user == null) {
        print("No user found in the current session.");
        return null;
      }

      final email = user.email;
      if (email == null) {
        print("No email found in the current session.");
        return null;
      }

      return email;
    } catch (e) {
      print("Error retrieving current user email: $e");
      return null;
    }
  }

  String? getUserName() {
    try {
      final session = _supabase.auth.currentSession;

      if (session == null) {
        print("No active session found.");
        return null;
      }

      final user = session.user;

      if (user == null) {
        print("No user found in the current session.");
        return null;
      }

      final metadat = user.userMetadata;
      if (metadat == null) {
        print("No metadata found in the current session.");
        return null;
      }
      final name = metadat['name']?.toString();
      if (name == null) {
        print("No name found in the current session.");
        return null;
      }
      return name;
    } catch (e) {
      print("Error retrieving current user email: $e");
      return null;
    }
  }

  Future<void> logout(BuildContext context) async {
    try {
      await _supabase.auth.signOut();
      // No navigation here in auth_service.dart.  AuthGate will handle it.
      Navigator.pushNamedAndRemoveUntil(context, '/login', (Route) => false);
    } catch (error) {
      print('Error during sign-out: $error');
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Logout Failed")));
    }
  }

  Future<String?> getToken() async {
    try {
      final SupabaseClient supabase = Supabase.instance.client;

      // Check the current session
      final session = supabase.auth.currentSession;

      if (session == null) {
        print("No active session found.");
        return null;
      }

      final token = session.accessToken;
      print("Access Token: $token");
      return token;
    } catch (e) {
      print("Error retrieving token: $e");
      return null;
    }
  }
Future<int?> getDriverId() async {
  final String baseUrl = "https://supply-y47s.onrender.com";
  final String endpoint = "/driver_id";
  final uri = Uri.parse('$baseUrl$endpoint');

   try {
    final response = await http.get(
      uri,
      headers: {
        "accept": "application/json",
        "Authorization": "Bearer ${await getToken()}",
      },
    );

    final decoded = jsonDecode(response.body);
    dynamic rawId;

    // If the response is a list, extract the first element.
    if (decoded is List && decoded.isNotEmpty) {
      rawId = decoded[0]['id'];
    } else if (decoded is Map) {
      rawId = decoded['id'];
    } else {
      print("Unexpected JSON format");
      return null;
    }

    print('The driver id is: $rawId');

    // If rawId is already an int, return it. If it's a string, try to parse it.
    if (rawId is int) {
      return rawId;
    } else if (rawId is String) {
      return int.tryParse(rawId);
    } else {
      print("Unexpected type for id: ${rawId.runtimeType}");
      return null;
    }
  } catch (e) {
    print("Error retrieving user ID: $e");
    return null;
  }
}
 Future<bool> checkCurrentPassword(String currentPassword) async {
  try {
    final user = _supabase.auth.currentUser;
    if (user == null || user.email == null) {
      throw Exception('No user is currently signed in.');
    }

    final response = await _supabase.auth.signInWithPassword(
      email: user.email!,
      password: currentPassword,
    );

    if (response.session == null || response.user == null) {
      throw Exception('Current password check failed. Possibly invalid credentials.');
    }

    _verifiedCurrentPassword = currentPassword;
    print('Current password is correct.');
    return true;
  } catch (e) {
    print('Error in checkCurrentPassword: $e');
    return false;
  }
}

Future<bool> changePassword(String newPassword) async {
  try {
    if (_verifiedCurrentPassword == null) {
      throw Exception('Current password has not been verified.');
    }

    final response = await _supabase.auth.updateUser(
      UserAttributes(password: newPassword),
    );

    if (response.user == null) {
      throw Exception('Failed to update password. Possibly invalid request.');
    }

    _verifiedCurrentPassword = null;
    print('Password updated successfully.');
    return true;
  } catch (e) {
    print('Error in changePassword: $e');
    return false;
  }
}
}
