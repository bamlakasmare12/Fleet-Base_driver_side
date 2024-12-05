import '../Views/Login.dart';
import '../Views/Homepage.dart';
import '../Views/Register.dart';
import '../Views/Setting.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}   

class MyApp extends StatelessWidget{
const MyApp({super.key});

@override
Widget build(BuildContext context){
  return MaterialApp(
  debugShowCheckedModeBanner: false,
  theme: ThemeData(
    colorSchemeSeed: Colors.lightBlue,
    brightness: Brightness.light,
   // scaffoldBackgroundColor: Colors.black,
    appBarTheme: const AppBarTheme(
     // backgroundColor: Colors.black,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.lightBlue,
        foregroundColor: Colors.white,
      ),
    )
  ),
        initialRoute: '/',
        routes:{
          '/':(context)=>loginScreen(),
          '/Home':(context)=>Homepage(),
          '/Register':(context)=>RegisterScreen(),
          '/Settings':(context)=>SettingsPage(),
        },
   
 
  );
}
}
