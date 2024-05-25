
import "package:akar/userpages/profilepage.dart";
import "package:curved_navigation_bar/curved_navigation_bar.dart";
import "package:flutter/material.dart";

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

  final List<Widget> _pages = [
    HomePage(),
    MessagesPage(),
    AddPage(),
    NotificationsPage(),
    UserProfile(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Colors.transparent,
        buttonBackgroundColor: Colors.deepPurple,
        color: Colors.deepPurple,
        animationDuration: const Duration(milliseconds: 300),
        items: const [
          Icon(Icons.home, color: Colors.white),
          Icon(Icons.message, color: Colors.white),
          Icon(Icons.add, color: Colors.white),
          Icon(Icons.notifications_on, color: Colors.white),
          Icon(Icons.person, color: Colors.white),
        ],
        onTap: (index) {
          setState(() {
            page = index;
          });
        },
      ),
      appBar:AppBar(
          backgroundColor:Colors.transparent,
          elevation:0,
          leading: Builder(
              builder: (context) {
                return IconButton(
                  icon:const Icon(Icons.menu,color:Colors.deepPurple),
                  onPressed: () {Scaffold.of(context).openDrawer();  },
                );
              }
          )
      ),
      drawer:  Drawer(
          backgroundColor:Colors.grey,
          child:Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children:[
              Column(
                children:[
                  //logo
                  DrawerHeader(
                    child:Image.asset("assets/logo3.png"),),


                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal:27.0),
                    child: Divider(color:Colors.grey),
                  ),

                  Padding(
                    padding: const EdgeInsets.only(left: 27.0),
                    child: ListTile(
                      leading:const Icon(Icons.home,color:Colors.white),
                      title: const Text("Home",style:TextStyle(color:Colors.white)),
                      onTap:(){
                        Navigator.pop(context);//close the drawer
                        setState(() {
                          page = 0; // Set the index to HomePage
                        });

                      },
                    ),
                  ),

                  const Padding(
                    padding: EdgeInsets.only(left: 27.0),
                    child: ListTile(
                      leading:Icon(Icons.info,color:Colors.white),
                      title: Text("About",style:TextStyle(color:Colors.white)),
                    ),
                  ),

                ]
                ,

              ),
              Padding(
                padding: const EdgeInsets.only(left: 27.0,bottom:27),
                child: ListTile(
                  leading:const Icon(Icons.logout,color:Colors.white),
                  title: const Text("Logout",style:TextStyle(color:Colors.white)),
                  onTap: () {
                    Navigator.pop(context); // Close the drawer
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) =>const SignInPage()),
                    );
                  },


                ),

              )],
          )
      ),
      body: _pages[page],
    );
  }
}