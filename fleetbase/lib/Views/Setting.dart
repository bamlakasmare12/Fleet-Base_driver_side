import 'package:flutter/material.dart'; 
class SettingsPage extends StatelessWidget {
   const SettingsPage({super.key}); 
   @override
    Widget build(BuildContext context) {
       return Scaffold
       ( appBar: AppBar( 
        title:  Text('Settings'),
       
         ), 
         body: const Center(
           child: Text( 'Settings', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold), 
           ), 
           ),
            );
             
             } 
             }
