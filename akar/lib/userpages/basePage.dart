import 'package:akar/Screens/home.dart';
import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Screens/login.dart';

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
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final shouldExit = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Do you want to exit the app?',style: TextStyle(fontSize: 18),),
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
        appBar: AppBar(
          backgroundColor: Colors.deepPurple,
          title: _getTitle(widget.pageIndex),
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
        ),
        drawer: Drawer(
          backgroundColor: Colors.grey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  // Logo
                  DrawerHeader(
                    child: Image.asset("assets/Akar_logo.png"),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 27.0),
                    child: Divider(color: Colors.grey),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 27.0),
                    child: ListTile(
                      leading: const Icon(Icons.home, color: Colors.white),
                      title: const Text("Home", style: TextStyle(color: Colors.white)),
                      onTap: () {
                        Navigator.pop(context); // Close the drawer
                        widget.onPageChanged(0); // Navigate to HomePage
                      },
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(left: 27.0),
                    child: ListTile(
                      leading: Icon(Icons.info, color: Colors.white),
                      title: Text("About", style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(left: 27.0, bottom: 27),
                child: ListTile(
                  leading: const Icon(Icons.logout, color: Colors.white),
                  title: const Text("Logout", style: TextStyle(color: Colors.white)),
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
          animationDuration: const Duration(milliseconds: 200),
          items: const [
            Icon(Icons.home, color: Colors.white),
            Icon(Icons.message, color: Colors.white),
            Icon(Icons.add, color: Colors.white),
            Icon(Icons.notifications_on, color: Colors.white),
            Icon(Icons.person, color: Colors.white),
          ],
          onTap: widget.onPageChanged,
          index: widget.pageIndex,
        ),
      ),
    );
  }

  Text _getTitle(int pageIndex) {
    switch (pageIndex) {
      case 0:
        return Text("Home", style: TextStyle(fontSize: 20, color: Colors.white));
      case 1:
        return Text("Register Complaint", style: TextStyle(fontSize: 20, color: Colors.white));
      case 2:
        return Text("Add", style: TextStyle(fontSize: 20, color: Colors.white));
      case 3:
        return Text("Notifications", style: TextStyle(fontSize: 20, color: Colors.white));
      case 4:
        return Text("My Profile", style: TextStyle(fontSize: 20, color: Colors.white));
      default:
        return Text("App");
    }
  }
}
