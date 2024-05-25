import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class RecoverPage extends StatefulWidget {
  const RecoverPage({super.key});

  @override
  _RecoverPageState createState() => _RecoverPageState();
}

class _RecoverPageState extends State<RecoverPage> {
  final emailController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  Future<void> sendPasswordResetEmail(
      String email, BuildContext context) async {
    try {
      // Check if the email exists in the Firestore users collection
      var users = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      if (users.docs.isEmpty) {
        // No user found with this email
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No user found for that email'),
            backgroundColor: Colors.red,
          ),
        );
        return null;
      }

      // Send password reset email
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      emailController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Password reset email sent successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.message}'),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e, stackTrace) {
      print('Error: $e');
      print('Stack Trace: $stackTrace');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor:const Color(0xFF33396d),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
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
                    'Recover Account',
                    style: TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(
                    height: 14,
                  ),
                  Image.asset(
                    "assets/reset-password.png",
                    height: 100,
                    width: 100,
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  TextFormField(
                    controller: emailController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                      if (!emailRegex.hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: ' Enter Your Email',
                      prefixIcon: const Icon(Icons.email),
                      // filled: true,
                      //fillColor: const Color(0xFF9ee1d9),

                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  ElevatedButton(
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        sendPasswordResetEmail(
                            emailController.text.trim(), context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple),
                    child: const Text(
                      'Send Password Reset Link',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20), // Adjust padding here
                    child: Container(
                      height: 1,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, "/login");
                    },
                    child: const Text(
                      'Back to Portal',
                      style: TextStyle(color: Colors.black87),
                    ),
                  ),
                ],
              ),
            ))),
      ),
    );
  }
}
