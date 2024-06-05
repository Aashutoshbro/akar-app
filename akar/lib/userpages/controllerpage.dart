import "package:akar/userpages/profilepage.dart";
import "package:flutter/material.dart";
import "basePage.dart";
// Import the BasePage widget

import "../Screens/login.dart";
import "addpage.dart";
import "homepage.dart";
import "messagepage.dart";
import "notificationpage.dart";

class MyCont extends StatefulWidget {

  const MyCont({super.key});

  @override
  State<MyCont> createState() => _MyContState();
}

class _MyContState extends State<MyCont> {
  int page = 0;

  late final List<Widget> _pages = [
    HomePage(onPageChanged: _onPageChanged,),
    RegisterComplaintForm(),
    AddPage(),
    NotificationsPage(),
    UserProfile(),
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