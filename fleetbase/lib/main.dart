import '../Services/auth_gate.dart';

import '../Views/Login.dart';
import '../Views/Homepage.dart';
import '../Views/Setting.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
void main() async {

WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    anonKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imh4b3BsdnFxYmtzYWZrem1peGd2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzU1NTkzNDcsImV4cCI6MjA1MTEzNTM0N30.nOqH3iPPB6QDnDWrpZoigs0OGttZEUEHPWW10gZxIfs",
    url:"https://hxoplvqqbksafkzmixgv.supabase.co",
    // authOptions: FlutterAuthClientOptions(
    //   autoRefreshToken: true,
    // ),
    );
  runApp(const MyApp());
}   

class MyApp extends StatelessWidget{
const MyApp({super.key});

@override
Widget build(BuildContext context){
  return MaterialApp(
  debugShowCheckedModeBanner: false,
  routes: {
   // '/':(context)=>AuthGate(),
    '/login':(context)=>loginScreen(),
    '/home':(context)=>Homepage(),
  },
//  initialRoute: '/',
home: AuthGate(),
   
 
  );
}
}
