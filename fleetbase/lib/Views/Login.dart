import 'package:fleetbase/Views/FadeAnimation.dart';
import 'package:flutter/material.dart';
class loginScreen extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  loginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        
        child: Container(
              
            margin: const EdgeInsets.symmetric(vertical: 10,horizontal: 20),
            padding: const EdgeInsets.all(30.0),
            child: Column(
              
              mainAxisAlignment:MainAxisAlignment.center,
              children:  [
                
               FadeAnimation(1, Image.asset(
                'Assets/logo/fleet_logo.png',
                height: 150,
                width: 200,
              )
               ),
               FadeAnimation(2.4, 
             const Text("Login",
              style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold, // Text weight (e.g., bold)

             ),
             ),
               ),
               FadeAnimation(2.5, 
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email', ),
              ),
               ),
             const SizedBox(height: 20),
             FadeAnimation(2.5, 
              TextField(
                controller: passwordController,
                decoration: const InputDecoration(labelText: 'Passwrod'),
                obscureText: true,
              ),
             ),
                  const SizedBox(height: 30),
              //buttons for the login and registeration
              FadeAnimation(2.6, 
              ElevatedButton(
                
                style: ElevatedButton.styleFrom(
                  fixedSize: const Size(200, 50),
                  foregroundColor: Colors.white,
                   backgroundColor: Colors.blue, // text 
                   
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    
                    
                  ),
                  elevation: 8,
                  padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 15),
                  
                ),
      
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/Home',
                    (Route<dynamic> route) => false,
                  );
                },
                
                child: const Text('Login'),
                
              ),
              ),
                const SizedBox(height: 20),
                FadeAnimation(2.7,
              TextButton(
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/Register',
                    (Route<dynamic> route) => false,
                  );
                },
                child: const Text("Don't have an account?"),
              ),
                ),
            
            ]
              
            )
            ),
      ),
    );
  }
}
