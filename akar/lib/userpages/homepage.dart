<<<<<<< HEAD
=======
import 'package:akar/userpages/track_complaint.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'complaint_history.dart';

class HomePage extends StatefulWidget {
  final Function(int) onPageChanged;

  const HomePage({Key? key, required this.onPageChanged}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, String?>> _getUserDetails() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc =
        await _firestore.collection('users').doc(user.uid).get();
        if (userDoc.exists && userDoc.data() != null) {
          return {
            'name': userDoc['name'] ?? 'Guest',
            'profileImageURL': userDoc['profileImageURL']
          };
        }
      }
      return {'name': 'Guest', 'profileImageURL': null};
    } catch (e) {
      print('Error fetching user data: $e');
      return {'name': 'Error', 'profileImageURL': null};
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Removes the back arrow
        title: GestureDetector(
          onTap: () {},
          child: Row(
            children: [
              FutureBuilder<Map<String, String?>>(
                future: _getUserDetails(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircleAvatar(
                      backgroundColor: Colors.grey.shade300,
                      child: Icon(Icons.person, color: Colors.purple),
                    );
                  } else if (snapshot.hasError || !snapshot.hasData) {
                    return CircleAvatar(
                      backgroundColor: Colors.grey.shade300,
                      child: Icon(Icons.person, color: Colors.purple),
                    );
                  } else {
                    var userData = snapshot.data!;
                    return CircleAvatar(
                      backgroundImage: userData['profileImageURL'] != null
                          ? NetworkImage(userData['profileImageURL']!)
                          : null,
                      backgroundColor: Colors.grey.shade300,
                      child: userData['profileImageURL'] == null
                          ? Icon(Icons.person, color: Colors.purple)
                          : null,
                    );
                  }
                },
              ),
              SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Namaste',
                    style: TextStyle(fontSize: 16),
                  ),
                  FutureBuilder<Map<String, String?>>(
                    future: _getUserDetails(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Text(
                          'Loading...',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        );
                      } else if (snapshot.hasError || !snapshot.hasData) {
                        return Text(
                          'Error',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        );
                      } else {
                        return Text(
                          snapshot.data?['name'] ?? 'Guest',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        );
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    if (_auth.currentUser != null && _auth.currentUser!.uid.isNotEmpty) {
                      print("Navigating with userID: ${_auth.currentUser!.uid}");
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ComplaintHistory(
                            onPageChanged: widget.onPageChanged,
                            userID: _auth.currentUser!.uid, // Passing userID
                          ),
                        ),
                      );
                    } else {
                      print("Error: userID is null or empty");
                    }
                  },
                  child: Text("Complain History"),
                ),

              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                widget.onPageChanged(1); // Register Complaint action
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              child: const Text(
                'Register Complaint',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
>>>>>>> f114e18724d5313e0b02ddf676f7260b17c90995
