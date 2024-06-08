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

  Future<String> _getFullName() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();
        if (userDoc.exists && userDoc.data() != null) {
          return userDoc['name'] ?? 'Guest';
        } else {
          return 'Guest';
        }
      } else {
        return 'Guest';
      }
    } catch (e) {
      print('Error fetching user data: $e');
      return 'Error';
    }
  }

  Future<String?> _getProfileImageURL() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();
        if (userDoc.exists && userDoc.data() != null) {
          return userDoc['profileImageURL'];
        } else {
          return null;
        }
      } else {
        return null;
      }
    } catch (e) {
      print('Error fetching profile image URL: $e');
      return null;
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
              FutureBuilder<String?>(
                future: _getProfileImageURL(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircleAvatar(
                      backgroundColor: Colors.grey.shade300,
                      child: Icon(Icons.person, color: Colors.purple),
                    );
                  } else if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
                    return CircleAvatar(
                      backgroundColor: Colors.grey.shade300,
                      child: Icon(Icons.person, color: Colors.purple),
                    );
                  } else {
                    return CircleAvatar(
                      backgroundImage: NetworkImage(snapshot.data!),
                      backgroundColor: Colors.grey.shade300,
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
                  FutureBuilder<String>(
                    future: _getFullName(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Text(
                          'Loading...',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        );
                      } else if (snapshot.hasError || !snapshot.hasData) {
                        return Text(
                          'Error',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        );
                      } else {
                        return Text(
                          snapshot.data ?? 'Guest',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ComplaintHistory(
                          onPageChanged: (int) {},
                        ),
                      ),
                    );
                  },
                  child: Text("Complain History"),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => TrackComplaintPage()),
                    );
                  },
                  child: Text("Track Complaint"),
                ),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                widget.onPageChanged(1);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
