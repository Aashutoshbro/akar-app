import 'dart:typed_data';

import 'package:akar/userpages/Home/widgets/userdashboard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:lottie/lottie.dart';

class UserHomePage extends StatefulWidget {
  final Function(int) onPageChanged;

  const UserHomePage({Key? key, required this.onPageChanged}) : super(key: key);

  @override
  State<UserHomePage> createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> {
  String userName = 'Guest';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    setState(() {
      isLoading = true;
    });

    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      String? firebaseName = await _fetchUserNameFromFirebase(user.uid);

      if (firebaseName != null && firebaseName.isNotEmpty) {
        setState(() {
          userName = firebaseName;
          isLoading = false;
        });
        await _cacheUserName(firebaseName);
      } else {
        String? cachedName = await _getCachedUserName();
        setState(() {
          userName = cachedName ?? user.email ?? 'Guest';
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading user name: $e');
      setState(() {
        userName = 'Guest';
        isLoading = false;
      });
    }
  }

  Future<String?> _fetchUserNameFromFirebase(String userId) async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (userDoc.exists && userDoc.data() != null) {
        return (userDoc.data() as Map<String, dynamic>)['name'] as String?;
      }
    } catch (e) {
      print('Error fetching user name from Firebase: $e');
    }
    return null;
  }

  Future<String?> _getCachedUserName() async {
    try {
      final file = await DefaultCacheManager().getFileFromCache('user_name');
      return file?.file.readAsString();
    } catch (e) {
      print('Error reading cached user name: $e');
    }
    return null;
  }

  Future<void> _cacheUserName(String name) async {
    try {
      await DefaultCacheManager().putFile(
        'user_name',
        Uint8List.fromList(name.codeUnits),
        fileExtension: 'txt',
      );
    } catch (e) {
      print('Error caching user name: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Namaste,',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 19,
                          ),
                        ),
                        const SizedBox(width: 4),
                        IconButton(
                          icon: const Icon(Icons.hail, color: Colors.black, size: 16),
                          onPressed: () {},
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          visualDensity: VisualDensity.compact,
                        ),
                      ],
                    ),
                    Text(
                      userName.isNotEmpty ? userName : 'Guest',
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(constraints.maxWidth * 0.04),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Colors.purple.withOpacity(0.7), Colors.blue.withOpacity(0.7)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 5,
                            blurRadius: 7,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            padding: EdgeInsets.all(constraints.maxWidth * 0.04),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white.withOpacity(0.8)),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  height: constraints.maxWidth * 0.28,
                                  width: constraints.maxWidth * 0.25,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.7),
                                    borderRadius: BorderRadius.circular(15),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.deepPurple.withOpacity(0.3),
                                        spreadRadius: 2,
                                        blurRadius: 5,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Lottie.asset(
                                    'assets/animation/AnimationE.json',
                                    width: constraints.maxWidth * 0.2,
                                    height: constraints.maxWidth * 0.2,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                                SizedBox(width: constraints.maxWidth * 0.04),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "See an issue on the road?",
                                        style: TextStyle(
                                          fontSize: constraints.maxWidth * 0.045,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      SizedBox(height: constraints.maxHeight * 0.01),
                                      Text(
                                        "Help improve your community by reporting road problems.",
                                        style: TextStyle(
                                          fontSize: constraints.maxWidth * 0.035,
                                          color: Colors.black54,
                                        ),
                                      ),
                                      SizedBox(height: constraints.maxHeight * 0.02),
                                      SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton(
                                          onPressed: () {
                                            widget.onPageChanged(1);
                                          },
                                          child: const Text("Report Issue", style: TextStyle(color: Colors.white)),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.deepPurple.withOpacity(0.8),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(30),
                                            ),
                                            padding: EdgeInsets.symmetric(vertical: constraints.maxHeight * 0.015),
                                            elevation: 5,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    RoadIssuesDashboard(userID: FirebaseAuth.instance.currentUser?.uid ?? ''),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
