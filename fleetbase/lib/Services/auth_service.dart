import 'package:flutter/material.dart';

class AuthService {
  Future<void> registerUser(String email, String password, String name) async {
  
  /*  try {
      final response = await AppwriteClient.account.create(
        userId: ID.unique(),
        email: email,
        password: password,
        name: name,
      );
      print('User registered: ${response.toMap()}');
    } catch (e) {
      print('Error registering user: $e');
    }
    */


  }

  Future<void> loginUser(
      String email, String password, BuildContext context) async {
  
  
  
  
   /*
   
    try {
      final response = await AppwriteClient.account.createEmailPasswordSession(
        email: email,
        password: password,
      );
      print('User logged in: ${response.toMap()}');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    } catch (e) {
      print('Error logging in: $e');
    }
    */
  }
}
