import 'package:flutter/material.dart';

import 'Screens/login.dart';
import 'Screens/register.dart';

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
        "/": (context) => const SignInPage(),
        "/register" : (context)=> const RegistrationPage(),
      },
      debugShowCheckedModeBanner:false,
      title: 'Flutter Demo',


      //home: SignInPage(),
    );
  }
}

