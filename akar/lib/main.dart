import 'package:flutter/material.dart';
import 'Screens/login.dart';
import 'Screens/register.dart';
import 'Screens/home.dart';

void main() {
  runApp(const MyApp(

  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return  MaterialApp(

      routes: {
        "/": (context) => const MyHome(),
        "/register" : (context)=> const RegistrationPage(),
        "/login" : (context)=> const SignInPage(),
      },
      debugShowCheckedModeBanner:false,
      title: 'Flutter Demo',


      //home: MyHome(),
    );
  }
}

