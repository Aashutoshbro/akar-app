import 'dart:async';

import 'package:akar/Screens/splash.dart';
import 'package:akar/admin/admin_login.dart';
import 'package:akar/userpages/controllerpage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'Screens/home.dart';
import 'Screens/login.dart';
import 'Screens/register.dart';
import 'Screens/recover.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: FirebaseOptions(
          apiKey: 'AIzaSyCxzPHuDDAfduqnMUE5Wymgdwc5TwHhu4o',
          appId: '1:897372433402:android:4ace3450735673096d9243',
          messagingSenderId: '897372433402',
          projectId: 'demo1-3efb8'),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        "/": (context) =>  MySplash(),
        "/register": (context) => const RegistrationPage(),
        "/login": (context) => const SignInPage(),
        "/recover": (context) => const RecoverPage(),
        "/UserPages": (context)=> const MyCont(),
<<<<<<< HEAD
        "/home":(context)=> const MyHome(),
=======
        "/admin":(context)=> const AdminLogin(),
>>>>>>> c9001bedd9a5d6dfc596d32eae8194d42b4437cf
      },
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',

      //home: MyHome(),
    );
  }
}

