import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../userpages/notification_service.dart';
import '../userpages/userProfile/firebaseApi.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  bool _obscureText = true;

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  Future<void> saveAuthState(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', userId);
  }

  var formKey = GlobalKey<FormState>();

  // text controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  Future signIn() async {
    try {
      showDialog(
        context: context,
        builder: (context) {
          return Center(child: CircularProgressIndicator());
        },
      );
      final UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim());

      final userId = userCredential.user?.uid;

      if (userId != null) {
        await saveAuthState(userId);
        Fluttertoast.showToast(msg: "Login Successfully");
        Navigator.of(context).pop();
        Navigator.pushReplacementNamed(context, "/UserPages");

        //await FirebaseApi().initNotifications();
        await PushNotifications.init();


      }
    } on FirebaseAuthException catch (e) {
      Navigator.of(context).pop();
      if (e.code == 'user-not-found') {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            backgroundColor: Colors.blueAccent,
            content: Text(
              "User not found for that email",
              style: TextStyle(color: Colors.red),
            )));
      } else if (e.code == 'wrong-password') {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            backgroundColor: Colors.orangeAccent,
            content: Text(
              "Wrong password provided",
              style: TextStyle(color: Colors.red),
            )));
      } else if (e.code == 'invalid-email') {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            backgroundColor: Colors.orangeAccent,
            content: Text(
              "The email address is badly formatted",
              style: TextStyle(color: Colors.red),
            )));
      } else if (e.code == 'quota-exceeded') {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            backgroundColor: Colors.orangeAccent,
            content: Text(
              "Exceeded quota for verifying passwords",
              style: TextStyle(color: Colors.red),
            )));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error: ${e.message}'),
          backgroundColor: Colors.red,
        ));
      }
      emailController.clear();
      passwordController.clear();
    }
  }

  // Special regex expression for email validation
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter an email';
    } else if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  // For Password validation
  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter password';
    } else if (value.length < 8) {
      return 'Password must be at least 8 characters long';
    } else if (!RegExp(r'^(?=.*?[A-Z])').hasMatch(value)) {
      return 'Password must have at least one uppercase letter';
    } else if (!RegExp(r'^(?=.*?[a-z])').hasMatch(value)) {
      return 'Password must have at least one lowercase letter';
    } else if (!RegExp(r'^(?=.*?[0-9])').hasMatch(value)) {
      return 'Password must have at least one digit';
    } else if (!RegExp(r'^(?=.*?[!@#$&*~])').hasMatch(value)) {
      return 'Password must have at least one special character';
    }
    return null;
  }

  Future<bool> showExitPopup() async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Are you sure?'),
        content: const Text('Do you want to exit the app?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Yes'),
          ),
        ],
      ),
    ) ?? false;
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          bool shouldExit = await showExitPopup();
          if (shouldExit) {
            SystemNavigator.pop();
            return true; // This line will not be reached as SystemNavigator.pop() closes the app
          } else {
            return false;
          }
        },




        child: Scaffold(
        appBar: AppBar(
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
    ),
      body: Center(

        child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,



                    children: [

                      const Text(
                        'Sign In',
                        style: TextStyle(
                            fontSize: 24.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Image.asset(
                        "assets/auth3.png",
                        height: 200,
                        width: 200,
                      ),
                      const SizedBox(height: 20.0),
                      TextFormField(
                        controller: emailController,
                        validator: validateEmail,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          prefixIcon: const Icon(Icons.email),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10.0),
                      TextFormField(
                        controller: passwordController,
                        validator: validatePassword,
                        obscureText: _obscureText,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureText
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: _togglePasswordVisibility,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () {
                              Navigator.pushNamed(context, "/recover");
                            },
                            child: const Text(
                              'Forgot Password?',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          // Sign in logic
                          if (formKey.currentState!.validate()) {
                            signIn();
                          }

                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple),
                        child: const Text(
                          'SIGN IN',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 10.0),
                      const Center(
                        child: Text("Don't have an account?"),
                      ),
                      TextButton(
                        onPressed: () {
                          // "create account" navigation logic here
                          Navigator.pushNamed(context, "/register");
                        },
                        child: const Text(
                          'Create an account',
                          style: TextStyle(color: Colors.deepPurple),
                        ),
                      ),
                    ],
                  ),
                ))),
      ),
    ));
  }
}
