import 'package:flutter/material.dart';

class RecoverPage extends StatefulWidget {
  const RecoverPage ({super.key});

  @override
  _RecoverPageState createState() => _RecoverPageState();
}

class _RecoverPageState  extends State<RecoverPage>{
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
                    height: 90,
                  ),
                  const Text(
                    'Enter Your Email Properly',
                    style: TextStyle(
                        fontSize: 10.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple),
                    textAlign: TextAlign.left,
                  ),
                  const SizedBox(
                    height: 10,
                  ),

                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Email',
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
                      //Sign in logic yaha
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
                    padding: const EdgeInsets.symmetric(horizontal: 20), // Adjust padding here
                    child: Container(
                      height: 1,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 10.0),

                  TextButton(
                    onPressed: () {
                      // "create account" navigation logic yaha lekhne
                      Navigator.pushNamed(context, "/login");
                    },
                    child: const Text(
                      'Back to Portal',
                      style: TextStyle(color: Colors.deepPurple),
                    ),
                  ),
                ],
              ),
            )),
      ),
    );
  }

}


