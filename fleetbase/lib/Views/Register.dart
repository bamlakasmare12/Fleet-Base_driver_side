import 'package:flutter/material.dart';

class RegisterScreen extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  RegisterScreen({super.key});

  @override

  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        
        child:Container (
              margin: const EdgeInsets.all(50),
              padding: const EdgeInsets.all(30.0),
              child: Column(children: [
           
                TextButton(
                  onPressed: () {
                      Navigator.pushNamedAndRemoveUntil(
                          context, '/',
                          (Route<dynamic> route) => false,
                     );
                    },
                           child: const Text('Already have an account'),

                ),
              ]
              )
              
      ),
      ),
    );
  }
}
