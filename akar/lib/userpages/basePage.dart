import 'package:akar/Screens/home.dart';
import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/file.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';


import '../Screens/login.dart';
import 'Notification.dart';
import 'message.dart';

class BasePage extends StatefulWidget {
  final Widget page;
  final int pageIndex;
  final Function(int) onPageChanged;

  const BasePage({
    required this.page,
    required this.pageIndex,
    required this.onPageChanged,
  });

  @override
  _BasePageState createState() => _BasePageState();
}
Future<void> signOut(BuildContext context) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('userId');
  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (context) => MyHome()),
        (Route<dynamic> route) => false,
  );
}

class _BasePageState extends State<BasePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String?> _getProfileImageURL() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();
        if (userDoc.exists && userDoc.data() != null) {
          return (userDoc.data() as Map<String, dynamic>)['profileImageURL'] as String?;
        }
      }
    } catch (e) {
      print('Error fetching profile image URL: $e');
    }
    return null;
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AboutDialog();
      },
    );
  }

  void _showEmergencyContactsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return EmergencyContactsDialog();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final shouldExit = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Do you want to exit the app?', style: TextStyle(fontSize: 18)),
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
        );
        if (shouldExit ?? false) {
          SystemNavigator.pop(); // This exits the app
          return true;
        }
        return false;
      },
      child: Scaffold(
        appBar: _buildAppBar(widget.pageIndex),
        drawer: Drawer(
          backgroundColor: Colors.white,


          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  // Logo
                  DrawerHeader(

                    child: Image.asset("assets/akar3.png"),
                  ),
                  // const Padding(
                  //   padding: EdgeInsets.symmetric(horizontal: 27.0),
                  //   child: Divider(color: Colors.white),
                  // ),
                  Padding(
                    padding: const EdgeInsets.only(left: 27.0),
                    child: ListTile(
                      leading: const Icon(Icons.home, color: Color(0xff321414)),
                      title: const Text("Home", style: TextStyle(color: Color(0xFF321414))),
                      onTap: () {
                        Navigator.pop(context); // Close the drawer
                        widget.onPageChanged(0); // Navigate to HomePage
                      },
                    ),
                  ),


                  Padding(
                    padding: const EdgeInsets.only(left: 27.0),
                    child: ListTile(
                      leading: const Icon(Icons.emergency, color: Color(0xff321414)),
                      title: const Text("Emergency Contacts", style: TextStyle(color: Color(0xFF321414))),
                      onTap: () {
                        Navigator.pop(context);
                        _showEmergencyContactsDialog(context);
                      },
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 27.0),
                    child: ListTile(
                      leading: Icon(Icons.info, color: Color(0xff321414)),
                      title: Text("About", style: TextStyle(color: Color(0xFF321414))),
                      onTap: () {
                        Navigator.pop(context); // Close the drawer
                        _showAboutDialog(context);
                      },

                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(left: 27.0, bottom: 27),
                child: ListTile(
                  leading: const Icon(Icons.logout, color: Color(0xff321414)),
                  title: const Text("Logout", style: TextStyle(color: Color(0xFF321414))),
                  onTap: () async {
                    Navigator.pop(context); // Close the drawer
                    await signOut(context);
                  },
                ),
              ),
            ],
          ),
        ),
        body: widget.page,
        bottomNavigationBar: CurvedNavigationBar(
          backgroundColor: Colors.transparent,
          buttonBackgroundColor: Colors.deepPurple,
          color: Colors.deepPurple,
          animationDuration: const Duration(milliseconds: 30),
          items: const [
            Icon(Icons.home, color: Colors.white),
            Icon(Icons.add, color: Colors.white),
            //Icon(Icons.notifications_on, color: Colors.white),
            Icon(Icons.person, color: Colors.white),
          ],
          onTap: (index) {
            widget.onPageChanged(index);
          },
          index: widget.pageIndex,
        ),
      ),
    );
  }PreferredSizeWidget? _buildAppBar(int pageIndex) {
    if (pageIndex == 0) {
      // Custom AppBar for the Home Page
      return AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(Icons.menu, color: Colors.deepPurple),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
              iconSize: 28.0, // Adjust icon size as needed
            );
          },
        ),
        actions: [
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: SizedBox(
                  // width: 40,
                  // height: 40,
                  child: IconButton(
                    icon: const Icon(Icons.notifications_on, color: Colors.deepPurple),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Message()),
                      );
                    },
                    iconSize: 28.0, // Adjust icon size as needed
                  ),
                ),
              ),
              // Padding(
              //   padding: const EdgeInsets.symmetric(horizontal: 8.0),
              //   child: SizedBox(
              //     width: 40,
              //     height: 40,
              //     child: GestureDetector(
              //       onTap: _reloadProfileImage,
              //       child: CircleAvatar(
              //         radius: 18,
              //         backgroundColor: Colors.deepPurple,
              //         backgroundImage: _profileImage != null ? FileImage(_profileImage!) : null,
              //         child: _profileImage == null ? const Icon(Icons.person, color: Colors.white, size: 28.0) : null,
              //       ),
              //     ),
              //   ),
              // ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: SizedBox(
                  width: 40,
                  height: 40,
                  child: FutureBuilder<String?>(
                    future: _getProfileImageURL(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircleAvatar(
                          backgroundColor: Colors.deepPurple,
                          child: CircularProgressIndicator(color: Colors.white),
                        );
                      } else if (snapshot.hasData && snapshot.data != null) {
                        return CircleAvatar(
                          backgroundImage: NetworkImage(snapshot.data!),
                          backgroundColor: Colors.deepPurple,
                        );
                      } else {
                        return const CircleAvatar(
                          // backgroundColor: Colors.deepPurple,
                          // child: Icon(Icons.person, color: Colors.white, size: 28.0),
                          backgroundImage: AssetImage("assets/Profile Image.png"),
                        );
                      }
                    },
                  ),
                ),
              ),

            ],
          ),
        ],
      );

    } else {
      // Default AppBar for other pages
      return AppBar(
        backgroundColor: Colors.deepPurple,
        title: _getTitle(pageIndex),
        elevation: 0,
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
      );
    }
  }

  Text _getTitle(int pageIndex) {
    switch (pageIndex) {
      case 1:
        return Text("Register Complaint", style: TextStyle(fontSize: 20, color: Colors.white));
      // case 2:
      //   return ComplaintHistory();
      case 2:
        return Text("My Profile", style: TextStyle(fontSize: 20, color: Colors.white));

      default:
        return Text("App", style: TextStyle(fontSize: 20, color: Colors.white));
    }
  }
}

class AboutDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: contentBox(context),
    );
  }

  Widget contentBox(context) {
    return Stack(
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(left: 20, top: 65, right: 20, bottom: 20),
          margin: EdgeInsets.only(top: 45),
          decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(color: Colors.black,offset: Offset(0,10),
                    blurRadius: 10
                ),
              ]
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                "About AKAR",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 15,),
              Text(
                "RMCS is developed by a group of college students, AKAR, as part of their project to empower citizens to report road-related issues directly through the app, fostering community involvement and enhancing road safety and infrastructure.",
                style: TextStyle(fontSize: 14),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 22,),
              Text(
                "RMCS App",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 10,),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: FaIcon(FontAwesomeIcons.linkedin),
                    onPressed: () {
                      // Add LinkedIn URL action
                    },
                  ),
                  IconButton(
                    icon: FaIcon(FontAwesomeIcons.twitter),
                    onPressed: () {
                      // Add Twitter URL action
                    },
                  ),
                  IconButton(
                    icon: FaIcon(FontAwesomeIcons.facebook),
                    onPressed: () {
                      // Add Facebook URL action
                    },
                  ),
                  IconButton(
                    icon: FaIcon(FontAwesomeIcons.instagram),
                    onPressed: () {
                      // Add Instagram URL action
                    },
                  ),
                ],
              ),
              SizedBox(height: 10,),
              Text(
                "www.FixMyRoads.com.np",
                style: TextStyle(fontSize: 16, color: Colors.blue),
              ),
              SizedBox(height: 10,),
              Text(
                "© Copyright 2024 All Rights Reserved.",
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              SizedBox(height: 22,),
              Align(
                alignment: Alignment.bottomRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("Close", style: TextStyle(fontSize: 18)),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          left: 20,
          right: 20,
          child: CircleAvatar(
            backgroundColor: Color(0xFF8E354A),
            radius: 45,
            child: ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(45)),
              child: Image.asset("assets/akar2.png"),
            ),
          ),
        ),
      ],
    );
  }
}

class EmergencyContactsDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: contentBox(context),
    );
  }

  Widget contentBox(context) {
    return Stack(
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(left: 20, top: 65, right: 20, bottom: 20),
          margin: EdgeInsets.only(top: 45),
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(color: Colors.black, offset: Offset(0, 10), blurRadius: 10),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                "Emergency Contacts",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 15),
              Expanded(
                child: ListView(
                  children: [
                    _buildContactItem("Nepal Police", "100"),
                    _buildContactItem("Ambulance Service", "102"),
                    _buildContactItem("Fire Brigade", "101"),
                    _buildContactItem("Nepal Red Cross Society (Blood Bank)", "977-1-4270650"),
                    _buildContactItem("Metropolitan Police Office (Kathmandu Valley)", "100 / 977-1-4411549"),
                    _buildContactItem("Bharatpur Metropolitan City Office ", "+977-056-511467"),
                    _buildContactItem("Nepal Electricity Authority", "1151"),
                    _buildContactItem("Department of Roads", "977-1-4216314 / 197"),
                    _buildContactItem("National Disaster Management Office", "1155"),
                    _buildContactItem("Ministry of Home Affairs", "977-1-4211208"),
                  ],
                ),
              ),
              SizedBox(height: 22),
              Align(
                alignment: Alignment.bottomRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("Close", style: TextStyle(fontSize: 18)),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          left: 20,
          right: 20,
          child: CircleAvatar(
            backgroundColor: Color(0xFF8E354A),
            radius: 45,
            child: Icon(
              Icons.emergency,
              color: Colors.white,
              size: 50,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContactItem(String title, String number) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Text(number),
        ],
      ),
    );
  }
}
