import "package:akar/userpages/Home/HomePage.dart";
import "package:akar/userpages/profilepage.dart";
import "package:akar/userpages/userProfile/profileScreen.dart";
import "package:flutter/material.dart";
import "basePage.dart";
// Import the BasePage widget

import "../Screens/login.dart";

import "homepage.dart";
import "messagepage.dart";

class MyCont extends StatefulWidget {

  const MyCont({super.key});

  @override
  State<MyCont> createState() => _MyContState();
}

class _MyContState extends State<MyCont> {
  int page = 0;

  late final List<Widget> _pages = [

    UserHomePage(onPageChanged: _onPageChanged,),
    RegisterComplaintForm(),
    //NotificationsPage(),
    //UserProfile(),
    ProfileScreen(),

  ];

  void _onPageChanged(int index) {
    setState(() {
      page = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BasePage(
      page: _pages[page],
      pageIndex: page,
      onPageChanged: _onPageChanged,
    );
  }
}