import 'dart:io';

import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart'; // Added for email validation
import 'package:supabase_flutter/supabase_flutter.dart';

import '../Views/FadeAnimation.dart';
import '../Services/auth_service.dart';

class loginScreen extends StatefulWidget {
  const loginScreen({super.key});

  @override
  State<loginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<loginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final AuthService _authService = AuthService();
  bool _isLoading = false; // Added _isLoading variable

  @override
  void initState() {
    super.initState();
    // _authService.clearSession(); // Uncomment if needed
  }

  Future<void> login() async {
    setState(() => _isLoading = true);
    try {
      // Basic validation
      if (emailController.text.isEmpty || passwordController.text.isEmpty) {
        throw Exception('Please fill in all fields');
      }

      if (!EmailValidator.validate(emailController.text.trim())) {
        throw Exception('Invalid email format');
      }

      // Attempt login
      await _authService.login(
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      // Navigate to home screen on success
      Navigator.pushNamedAndRemoveUntil(context, '/home',(Route)=>false);
    } on SocketException {
      _showError('No internet connection');
    } on AuthException catch (e) {
      // If your AuthService throws an AuthException, handle specific error codes if available
      String errorMessage;
      switch (e.code) {
        case 'invalid-credential':
        case 'wrong-password':
          errorMessage = 'Incorrect email or password';
          break;
        case 'user-not-found':
          errorMessage = 'No account found with this email';
          break;
        case 'user-disabled':
          errorMessage = 'This account has been disabled';
          break;
        default:
          errorMessage = 'Login failed. Please try again.';
      }
      _showError(errorMessage);
    } catch (e) {
      _showError(e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FadeAnimation(
              1,
              Image.asset(
                'Assets/logo/fleet_logo.png',
                height: 150,
                width: 200,
              ),
            ),
            FadeAnimation(
              2.4,
              const Text(
                "Login",
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            FadeAnimation(
              2.5,
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                ),
              ),
            ),
            const SizedBox(height: 20),
            FadeAnimation(
              2.5,
              TextField(
                controller: passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                ),
                obscureText: true,
              ),
            ),
            const SizedBox(height: 30),
            // Buttons for login and registration
            FadeAnimation(
              2.6,
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  fixedSize: const Size(200, 50),
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 8,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 15),
                ),
                onPressed: _isLoading ? null : login,
                child: _isLoading
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                      )
                    : const Text('Login'),
              ),
            ),
       
          ],
        ),
      ),
    );
  }
}
