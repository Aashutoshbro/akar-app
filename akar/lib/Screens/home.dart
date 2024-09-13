
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class MyHome extends StatefulWidget {
  const MyHome({Key? key}) : super(key: key);

  @override
  _MyHomeState createState() => _MyHomeState();
}

class _MyHomeState extends State<MyHome> {
//   @override
//   Future<void> initState() async {
//     // TODO: implement initState
//     super.initState();
//     bool? isAutoStartEnabled = await DisableBatteryOptimization.isAutoStartEnabled;
//     await DisableBatteryOptimization.showEnableAutoStartSettings("Enable Auto Start", "Follow the steps and enable the auto start of this app");
//     await DisableBatteryOptimization.showDisableBatteryOptimizationSettings();
//     await DisableBatteryOptimization.showDisableManufacturerBatteryOptimizationSettings("Your device has additional battery optimization", "Follow the steps and disable the optimizations to allow smooth functioning of this app");
//   }
  int _clickCount = 0;
  final int _requiredClicks = 5;

  void _handleImageClick() {
    setState(() {
      _clickCount++;
      if (_clickCount == _requiredClicks) {
        _clickCount = 0; // Reset the count
        _navigateToAdminLogin();
      }
    });
  }

  void _navigateToAdminLogin() {
    Navigator.pushNamed(context, "/admin");
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Expanded(
            flex: 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                GestureDetector(
                  onTap: _handleImageClick,
                  child: Image.asset(
                    'assets/Akar_logo.png',
                    width: 200,
                    height: 200,
                  ),
                ), // Replace with your logo
                const SizedBox(height: 10),
                RichText(
                  text: const TextSpan(
                    children: [
                      TextSpan(
                        text: 'Road\n',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF663AB6),
                        ),
                      ),
                      TextSpan(
                        text: 'Maintenance\n',
                        style: TextStyle(
                          fontSize: 50,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF663AB6),
                        ),
                      ),
                      TextSpan(
                        text: 'Complaint System',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF663AB6),
                        ),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    height: 1,
                    color: Colors.black,
                  ),
                ),
                const Text(
                  'Empowering citizens for the safer roads',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, color: Color(0xFF663AB6)),
                ),
                const SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, "/login");
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                  ),
                  child: const Text(
                    'SIGN IN',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(height: 10),
                const Center(
                  child: Text("Don't have an account?"),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, "/register");
                  },
                  child: const Text(
                    'Create an account',
                    style: TextStyle(color: Colors.deepPurple),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
