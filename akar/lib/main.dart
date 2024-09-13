import 'dart:async';
import 'dart:convert';

import 'package:akar/Screens/splash.dart';
import 'package:akar/admin/admin_login.dart';
import 'package:akar/userpages/controllerpage.dart';
import 'package:akar/userpages/message.dart';
import 'package:akar/userpages/notification_service.dart';
import 'package:akar/userpages/userProfile/Identification.dart';
import 'package:akar/userpages/userProfile/profileDetails.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'Screens/home.dart';
import 'Screens/login.dart';
import 'Screens/register.dart';
import 'Screens/recover.dart';



 final navigatorKey = GlobalKey<NavigatorState>();


 //function to listen to bg chnages
Future bgMessage(RemoteMessage message)async{
  await Firebase.initializeApp();

  if(message.notification!=null) {
    print("Received in background..");
  }


}




void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
        apiKey: 'AIzaSyCxzPHuDDAfduqnMUE5Wymgdwc5TwHhu4o',
        appId: '1:897372433402:android:4ace3450735673096d9243',
        messagingSenderId: '897372433402',
        projectId: 'demo1-3efb8',
        storageBucket: 'gs://demo1-3efb8.appspot.com'),
  );

  // await PushNotifications.init();
  await PushNotifications.localNotiInit();

  FirebaseMessaging.onBackgroundMessage(bgMessage);

//on bg notification tapped
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message){
    if(message.notification!=null){
      print("bg tapped...");
      navigatorKey.currentState!.pushNamed("/message",arguments: message);

    }
  });

  //to handle foreground notifications
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    String payloadData = jsonEncode(message.data);
    print("Got a message in foreground");
    if (message.notification != null) {
        PushNotifications.showSimpleNotification(
            title: message.notification!.title!,
            body: message.notification!.body!,
            payload: payloadData);
      }

  });

  //
  // for handling in terminated state
  @pragma("vm:entry-point")
  final RemoteMessage? message =
  await FirebaseMessaging.instance.getInitialMessage();

  if (message != null) {
    print("Launched from terminated state");
    Future.delayed(Duration(seconds: 1), () {
      navigatorKey.currentState!.pushNamed("/message", arguments: message);
    });
  }


  runApp(const MyApp());
}


class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      routes: {
        "/": (context) => MySplash(),
        "/message":(context)=> Message2(),
        "/register": (context) => const RegistrationPage(),
        "/login": (context) => const SignInPage(),
        "/recover": (context) => const RecoverPage(),
        "/UserPages": (context) => const MyCont(),
        '/profile-details': (context) => const ProfileDetailsPage(),
        '/upload-gov-id': (context) => const UploadId(),

        "/home": (context) => const MyHome(),

        "/admin": (context) => const AdminLogin(),

      },
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',

      //home: MyHome(),
    );
  }
}

