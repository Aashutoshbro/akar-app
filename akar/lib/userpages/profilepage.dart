import 'package:akar/CustomComponents/textBox.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({super.key});

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  final currentUser = FirebaseAuth.instance.currentUser!;
  final usersCollection= FirebaseFirestore.instance.collection("users");

  Future<void> editField(String field) async {
    String newValue='';
    await showDialog(context: context, builder: (context)=>AlertDialog(
      backgroundColor: Colors.grey[900],
      title: Text(
        "Edit $field",
        style:const TextStyle(color: Colors.white) ,


      ),
      content: TextField(
        autofocus: true,
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: "Enter new $field",
          hintStyle: TextStyle(color: Colors.grey),
        ),
        onChanged: (value){
          newValue=value;
        },
      ),
      actions: [
        TextButton(onPressed:()=> Navigator.pop(context), child: Text("Cancel",style: TextStyle(color: Colors.white),)),
        TextButton(onPressed:()=> Navigator.of(context).pop(newValue), child: Text("Save",style: TextStyle(color: Colors.white),)),
      ],

    ));

    if(newValue.trim().length>0){
      //only update if there is something in the text field
      await usersCollection.doc(currentUser.uid).update({field:newValue});
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection("users")
            .doc(currentUser.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data != null && snapshot.data!.exists) {
              final userData = snapshot.data!.data() as Map<String, dynamic>;

              return ListView(
                padding: EdgeInsets.all(20),
                children: [
                  const SizedBox(height: 30),
                  Center(
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: AssetImage('assets/userprofile2.png'), // Placeholder image, replace with user's profile image
                        ),
                        const SizedBox(height: 20),
                        Text(
                          currentUser.email!,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey[700], fontSize: 18),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      "My Details",
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  MyBox(
                    text: userData['name'] ?? 'N/A',
                    SectionName: 'Username',
                    onPressed: () => editField('name'),
                  ),

                  MyBox(
                    text: userData['contact'] ?? 'N/A',
                    SectionName: 'Contact',
                    onPressed: () => editField('contact'),
                  ),
                  MyBox(
                    text: userData['Address'] ?? 'N/A',
                    SectionName: 'Address',
                    onPressed: () => editField('Address'),
                  ),
                ],
              );
            } else {
              return const Center(child: Text('User data not found.'));
            }
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
