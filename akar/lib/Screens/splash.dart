import 'dart:async';

import 'package:akar/Screens/home.dart';
import 'package:akar/userpages/controllerpage.dart';
import 'package:akar/userpages/homepage.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:observe_internet_connectivity/observe_internet_connectivity.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MySplash extends StatefulWidget {
  const MySplash({super.key});

  @override
  _MySplashState createState() => _MySplashState();
}

class _MySplashState extends State<MySplash> {
  bool _isConnected = false;
  StreamSubscription<bool>? _subscription;

  @override
  void initState() {
    super.initState();
    _checkConnection();
    _listenToConnectionChanges();
    _fetchInitialData();
  }

  Future<void> checkAuthState() async {
    final prefs = await SharedPreferences.getInstance();
    final isSignedIn = prefs.containsKey('userId');

    if (isSignedIn) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MyCont()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MyHome()),
      );
    }
  }

  Future<void> _checkConnection() async {
    final hasInternet = await InternetConnectivity().hasInternetConnection;
    setState(() {
      _isConnected = hasInternet;
    });
    if (_isConnected) {
      // Internet connection is available
      print("Internet connection is available");
    } else {
      // No internet connection
      print("No internet connection");
      _showToast('No Internet Connection');
    }
  }

  void _listenToConnectionChanges() {
    _subscription = InternetConnectivity()
        .observeInternetConnection
        .listen((bool hasInternetAccess) {
      if (!hasInternetAccess) {
        _showToast('No Internet Connection');
      }
    });
  }

  void _showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.black,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  Future<void> _fetchInitialData() async {
    // Simulate fetching data from a database or API
    await Future.delayed(Duration(seconds: 6)); // Adjust this duration as needed

    // Check the authentication state after fetching initial data
    await checkAuthState();

    // Cancel the subscription after a certain period
    await Future.delayed(const Duration(seconds: 7));
    _subscription?.cancel();
  }

  void _showRetryDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('No Internet Connection'),
          content: Text('Please check your internet connection and try again.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _checkConnection();
                _fetchInitialData();
              },
              child: Text('Retry'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Lottie.asset('assets/animation/Animation1.json', width: 400),
      ),
    );
  }
}
