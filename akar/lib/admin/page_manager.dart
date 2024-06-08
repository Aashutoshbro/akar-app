
import 'package:akar/userpages/homepage.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

import 'home_page.dart';
import 'search_page.dart';
import 'settings_page.dart';
import 'users_page.dart';

class PageManager extends StatefulWidget {
  @override
  _PageManagerState createState() => _PageManagerState();
}

class _PageManagerState extends State<PageManager> {
  int _selectedIndex = 0;

  static final List<Widget> _pages = <Widget>[
    AdminHomePage(),
    SearchPage(),
    SettingsPage(),
    UsersPage(),
  ];

  static final List<String> _titles = <String>[
    'Admin DashBoard',
    'Search',
    'Settings',
    'Users',
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          _titles[_selectedIndex],
          style: TextStyle(color: Colors.white),
        ),
      ),
      drawer: Drawer(
        child: Container(
          color: Colors.deepPurple[100],
          child: ListView(
            children: [
              DrawerHeader(
                child: Center(
                  child: Image.asset(
                    "assets/Akar_logo.png",
                  ),
                ),
              ),
              ListTile(
                leading: Icon(Icons.home),
                title: Text(
                  "Home",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.normal),
                ),
                onTap: () {
                  _onItemTapped(0);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.settings),
                title: Text(
                  "Settings",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.normal),
                ),
                onTap: () {
                  _onItemTapped(2);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        color: Colors.deepPurple,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 6.0, vertical: 6),
          child: GNav(
            gap: 8,
            backgroundColor: Colors.deepPurple,
            color: Colors.white,
            activeColor: Colors.white,
            tabBackgroundColor: Colors.white24,
            padding: EdgeInsets.all(17),
            tabs: const [
              GButton(
                icon: Icons.home,
                text: "Home",
              ),
              GButton(
                icon: Icons.search,
                text: "Search",
              ),
              GButton(
                icon: Icons.settings,
                text: "Settings",
              ),
              GButton(
                icon: Icons.person,
                text: "Users",
              ),
            ],
            selectedIndex: _selectedIndex,
            onTabChange: (index) {
              _onItemTapped(index);
            },
          ),
        ),
      ),
    );
  }
}
